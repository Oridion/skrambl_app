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
        podId: podId,
        podPda: podPda,
        lamports: lamports,
        mode: mode,
        delaySeconds: delaySeconds,
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
  Future<void> markFinalized({required String id}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (update(pods)..where((t) => t.id.equals(id))).write(
      PodsCompanion(
        finalizedAt: Value(now),
        status: Value(PodStatus.finalized.index),
        statusMsg: const Value('Launch finalized'),
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
}
