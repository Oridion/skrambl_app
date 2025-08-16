import 'package:drift/drift.dart';
import 'local_database.dart';
import 'skrambl_entity.dart';
import 'package:uuid/uuid.dart';

part 'skrambl_dao.g.dart';

@DriftAccessor(tables: [Pods])
class PodDao extends DatabaseAccessor<LocalDatabase> with _$PodDaoMixin {
  PodDao(super.db);

  // Streams
  Stream<List<Pod>> watchAll() => (select(pods)..orderBy([(t) => OrderingTerm.desc(t.draftedAt)])).watch();

  Stream<Pod?> watchById(String id) => (select(pods)..where((t) => t.id.equals(id))).watchSingleOrNull();

  // Add this alongside watchAll()
  Stream<List<Pod>> watchRecent({int limit = 5}) =>
      (select(pods)
            ..orderBy([(t) => OrderingTerm.desc(t.draftedAt)])
            ..limit(limit))
          .watch();

  // Watch / resume only pending pods
  /// Pending pods are those that are in the process of being launched or scrambled.
  Stream<List<Pod>> watchPendingPods() {
    return (select(pods)..where(
          (p) => p.status.isIn([
            PodStatus.submitted.index,
            PodStatus.scrambling.index,
            PodStatus.delivering.index,
          ]),
        ))
        .watch();
  }

  ///Watch only non standard pods
  Stream<List<Pod>> watchPendingNonStandardPods() {
    return (select(pods)
          ..where(
            (p) => p.status.isIn([
              PodStatus.submitted.index,
              PodStatus.scrambling.index,
              PodStatus.delivering.index,
            ]),
          )
          ..where((p) => p.mode.isNotValue(5))
          ..where((p) => p.podPda.isNotNull()))
        .watch();
  }

  // Create local draft row when user hits "Launch"
  Future<String> createDraft({
    required String creator,
    required int podId,
    required String podPda,
    required int lamports,
    required int mode,
    required int delaySeconds,
    required String destination,
    required String escapeCode,
    bool showMemo = false,
    PodStatus initialStatus = PodStatus.drafting,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final localId = const Uuid().v4();

    await into(pods).insert(
      PodsCompanion.insert(
        id: localId,
        creator: creator,
        podId: Value(podId),
        podPda: Value(podPda),
        lamports: lamports,
        mode: mode,
        delaySeconds: Value(delaySeconds),
        showMemo: Value(showMemo),
        escapeCode: Value(escapeCode),
        destination: destination,
        status: initialStatus.index,
        draftedAt: now,
      ),
    );
    return localId;
  }

  Future<void> attachUnsignedMessage({required String id, String? unsignedMessageB64}) async {
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(unsignedMessageB64: Value(unsignedMessageB64), status: Value(PodStatus.launching.index)),
    );
  }

  // Once pod has on-chain then we update and mark the pod as scrambling
  Future<void> markSubmitted({required String id, required String signature}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(
        launchSig: Value(signature),
        lastSig: Value(signature),
        submittedAt: Value(now),
        status: Value(PodStatus.submitted.index),
        statusMsg: const Value('Submitted to chain'),
      ),
    );
  }

  // Sent to queue for full processing and now waiting for hops to complete
  Future<void> markSkrambling({required String id}) async {
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(status: Value(PodStatus.scrambling.index), statusMsg: const Value('Scrambling')),
    );
  }

  // Mark pod as delivering. Hops have completed and now we are delivering to destination
  Future<void> markDelivering({required String id}) async {
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(status: Value(PodStatus.delivering.index), statusMsg: const Value('Delivering')),
    );
  }

  // Mark pod as finalized. This means the delivery was successful.
  // This also removes the escape code and unsigned message.
  Future<void> markFinalized({required String id}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(
        finalizedAt: Value(now),
        status: Value(PodStatus.finalized.index),
        statusMsg: const Value('Finalized'),
        escapeCode: Value(null),
        unsignedMessageB64: const Value(null),
      ),
    );
  }

  // Mark pod as failed. This is a critical error that prevents delivery.
  Future<void> markFailed({required String id, String? message}) async {
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(
        status: Value(PodStatus.failed.index),
        statusMsg: Value(message),
        lastError: Value(message),
      ),
    );
  }

  // Update location from chain. (Currently only used only for delayed pods)
  Future<void> upsertFromChain({required String id, required String location}) async {
    final existing = await (select(pods)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      throw Exception('Pod with id $id not found for upsert.');
    }
    await (update(pods)..where((t) => t.id.equals(id))).write(PodsCompanion(location: Value(location)));
  }

  // Trim secrets from the pod after it's finalized
  Future<void> trimSecrets(String id) async {
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(escapeCode: Value(null), unsignedMessageB64: const Value(null)),
    );
  }

  // Insert a STANDARD pod row at the moment you have a tx signature.
  // (No podId/PDA, delay=0, mode=5)
  Future<String> insertStandardPending({
    required String creator, // sender pubkey (base58)
    required String destination, // recipient base58
    required int lamports, // amount
    required String signature, // launch tx sig
  }) async {
    final localId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await into(pods).insert(
      PodsCompanion.insert(
        id: localId,
        creator: creator,
        destination: destination,
        lamports: lamports,
        // Standard markers:
        mode: 5, // 5 = standard
        delaySeconds: const Value(0),
        podId: const Value(null), // no on-chain pod id
        podPda: const Value(null), // no PDA
        // Status at submission:
        status: PodStatus.submitted.index,
        statusMsg: const Value('Submitted (standard)'),
        draftedAt: now,
        submittedAt: Value(now),

        // Signature:
        launchSig: Value(signature),
        lastSig: Value(signature),
      ),
    );

    return localId;
  }

  // If user retried and we already have the row (by signature), just upsert:
  Future<void> upsertStandardPendingBySig({
    required String signature,
    required String creator,
    required String destination,
    required int lamports,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final q = update(pods)..where((t) => t.launchSig.equals(signature));

    final updated = await q.write(
      PodsCompanion(
        creator: Value(creator),
        destination: Value(destination),
        lamports: Value(lamports),
        lastSig: Value(signature),
        status: Value(PodStatus.submitted.index),
        statusMsg: const Value('Submitted (standard)'),
        submittedAt: Value(now),
      ),
    );

    if (updated == 0) {
      // No row with that signature → insert
      await insertStandardPending(
        creator: creator,
        destination: destination,
        lamports: lamports,
        signature: signature,
      );
    }
  }

  // Mark finalized by signature (reuse same flow as skrambled)
  Future<void> markStandardFinalizedBySig(String signature) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(pods)..where((t) => t.launchSig.equals(signature))).write(
      PodsCompanion(
        status: Value(PodStatus.finalized.index),
        statusMsg: const Value('Finalized'),
        finalizedAt: Value(now),
        // Trim secrets fields are already null for standard, but safe to set:
        escapeCode: const Value(null),
        unsignedMessageB64: const Value(null),
      ),
    );
  }

  // Mark failed by signature
  Future<void> markStandardFailedBySig(String signature, {String? message}) async {
    await (update(pods)..where((t) => t.launchSig.equals(signature))).write(
      PodsCompanion(
        status: Value(PodStatus.failed.index),
        statusMsg: Value(message ?? 'Failed'),
        lastError: Value(message),
      ),
    );
  }
}
