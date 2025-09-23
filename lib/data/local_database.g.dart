// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $PodsTable extends Pods with TableInfo<$PodsTable, Pod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _podPdaMeta = const VerificationMeta('podPda');
  @override
  late final GeneratedColumn<String> podPda = GeneratedColumn<String>(
    'pod_pda',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorMeta = const VerificationMeta(
    'creator',
  );
  @override
  late final GeneratedColumn<String> creator = GeneratedColumn<String>(
    'creator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _podIdMeta = const VerificationMeta('podId');
  @override
  late final GeneratedColumn<int> podId = GeneratedColumn<int>(
    'pod_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lamportsMeta = const VerificationMeta(
    'lamports',
  );
  @override
  late final GeneratedColumn<int> lamports = GeneratedColumn<int>(
    'lamports',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _delaySecondsMeta = const VerificationMeta(
    'delaySeconds',
  );
  @override
  late final GeneratedColumn<int> delaySeconds = GeneratedColumn<int>(
    'delay_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _escapeCodeMeta = const VerificationMeta(
    'escapeCode',
  );
  @override
  late final GeneratedColumn<String> escapeCode = GeneratedColumn<String>(
    'escape_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMsgMeta = const VerificationMeta(
    'statusMsg',
  );
  @override
  late final GeneratedColumn<String> statusMsg = GeneratedColumn<String>(
    'status_msg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _launchSigMeta = const VerificationMeta(
    'launchSig',
  );
  @override
  late final GeneratedColumn<String> launchSig = GeneratedColumn<String>(
    'launch_sig',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSigMeta = const VerificationMeta(
    'lastSig',
  );
  @override
  late final GeneratedColumn<String> lastSig = GeneratedColumn<String>(
    'last_sig',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _draftedAtMeta = const VerificationMeta(
    'draftedAt',
  );
  @override
  late final GeneratedColumn<int> draftedAt = GeneratedColumn<int>(
    'drafted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittingAtMeta = const VerificationMeta(
    'submittingAt',
  );
  @override
  late final GeneratedColumn<int> submittingAt = GeneratedColumn<int>(
    'submitting_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<int> submittedAt = GeneratedColumn<int>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skrambledAtMeta = const VerificationMeta(
    'skrambledAt',
  );
  @override
  late final GeneratedColumn<int> skrambledAt = GeneratedColumn<int>(
    'skrambled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  @override
  late final GeneratedColumn<int> finalizedAt = GeneratedColumn<int>(
    'finalized_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCreatorBurnerMeta = const VerificationMeta(
    'isCreatorBurner',
  );
  @override
  late final GeneratedColumn<bool> isCreatorBurner = GeneratedColumn<bool>(
    'is_creator_burner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_creator_burner" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDestinationBurnerMeta =
      const VerificationMeta('isDestinationBurner');
  @override
  late final GeneratedColumn<bool> isDestinationBurner = GeneratedColumn<bool>(
    'is_destination_burner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_destination_burner" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unsignedMessageB64Meta =
      const VerificationMeta('unsignedMessageB64');
  @override
  late final GeneratedColumn<String> unsignedMessageB64 =
      GeneratedColumn<String>(
        'unsigned_message_b64',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podPda,
    creator,
    podId,
    lamports,
    fee,
    mode,
    delaySeconds,
    escapeCode,
    status,
    statusMsg,
    location,
    destination,
    launchSig,
    lastSig,
    draftedAt,
    submittingAt,
    submittedAt,
    skrambledAt,
    finalizedAt,
    durationSeconds,
    isCreatorBurner,
    isDestinationBurner,
    unsignedMessageB64,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pod_pda')) {
      context.handle(
        _podPdaMeta,
        podPda.isAcceptableOrUnknown(data['pod_pda']!, _podPdaMeta),
      );
    }
    if (data.containsKey('creator')) {
      context.handle(
        _creatorMeta,
        creator.isAcceptableOrUnknown(data['creator']!, _creatorMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorMeta);
    }
    if (data.containsKey('pod_id')) {
      context.handle(
        _podIdMeta,
        podId.isAcceptableOrUnknown(data['pod_id']!, _podIdMeta),
      );
    }
    if (data.containsKey('lamports')) {
      context.handle(
        _lamportsMeta,
        lamports.isAcceptableOrUnknown(data['lamports']!, _lamportsMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportsMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    } else if (isInserting) {
      context.missing(_feeMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('delay_seconds')) {
      context.handle(
        _delaySecondsMeta,
        delaySeconds.isAcceptableOrUnknown(
          data['delay_seconds']!,
          _delaySecondsMeta,
        ),
      );
    }
    if (data.containsKey('escape_code')) {
      context.handle(
        _escapeCodeMeta,
        escapeCode.isAcceptableOrUnknown(data['escape_code']!, _escapeCodeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('status_msg')) {
      context.handle(
        _statusMsgMeta,
        statusMsg.isAcceptableOrUnknown(data['status_msg']!, _statusMsgMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('launch_sig')) {
      context.handle(
        _launchSigMeta,
        launchSig.isAcceptableOrUnknown(data['launch_sig']!, _launchSigMeta),
      );
    }
    if (data.containsKey('last_sig')) {
      context.handle(
        _lastSigMeta,
        lastSig.isAcceptableOrUnknown(data['last_sig']!, _lastSigMeta),
      );
    }
    if (data.containsKey('drafted_at')) {
      context.handle(
        _draftedAtMeta,
        draftedAt.isAcceptableOrUnknown(data['drafted_at']!, _draftedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_draftedAtMeta);
    }
    if (data.containsKey('submitting_at')) {
      context.handle(
        _submittingAtMeta,
        submittingAt.isAcceptableOrUnknown(
          data['submitting_at']!,
          _submittingAtMeta,
        ),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('skrambled_at')) {
      context.handle(
        _skrambledAtMeta,
        skrambledAt.isAcceptableOrUnknown(
          data['skrambled_at']!,
          _skrambledAtMeta,
        ),
      );
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_creator_burner')) {
      context.handle(
        _isCreatorBurnerMeta,
        isCreatorBurner.isAcceptableOrUnknown(
          data['is_creator_burner']!,
          _isCreatorBurnerMeta,
        ),
      );
    }
    if (data.containsKey('is_destination_burner')) {
      context.handle(
        _isDestinationBurnerMeta,
        isDestinationBurner.isAcceptableOrUnknown(
          data['is_destination_burner']!,
          _isDestinationBurnerMeta,
        ),
      );
    }
    if (data.containsKey('unsigned_message_b64')) {
      context.handle(
        _unsignedMessageB64Meta,
        unsignedMessageB64.isAcceptableOrUnknown(
          data['unsigned_message_b64']!,
          _unsignedMessageB64Meta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      podPda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pod_pda'],
      ),
      creator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator'],
      )!,
      podId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pod_id'],
      ),
      lamports: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamports'],
      )!,
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode'],
      )!,
      delaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delay_seconds'],
      )!,
      escapeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}escape_code'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      statusMsg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_msg'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      launchSig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}launch_sig'],
      ),
      lastSig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sig'],
      ),
      draftedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drafted_at'],
      )!,
      submittingAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitting_at'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitted_at'],
      ),
      skrambledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skrambled_at'],
      ),
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finalized_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      isCreatorBurner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_creator_burner'],
      )!,
      isDestinationBurner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_destination_burner'],
      )!,
      unsignedMessageB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unsigned_message_b64'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PodsTable createAlias(String alias) {
    return $PodsTable(attachedDatabase, alias);
  }
}

class Pod extends DataClass implements Insertable<Pod> {
  final String id;
  final String? podPda;
  final String creator;
  final int? podId;
  final int lamports;
  final int fee;
  final int mode;
  final int delaySeconds;
  final String? escapeCode;
  final int status;
  final String? statusMsg;
  final String? location;
  final String destination;
  final String? launchSig;
  final String? lastSig;
  final int draftedAt;
  final int? submittingAt;
  final int? submittedAt;
  final int? skrambledAt;
  final int? finalizedAt;
  final int durationSeconds;
  final bool isCreatorBurner;
  final bool isDestinationBurner;
  final String? unsignedMessageB64;
  final String? lastError;
  const Pod({
    required this.id,
    this.podPda,
    required this.creator,
    this.podId,
    required this.lamports,
    required this.fee,
    required this.mode,
    required this.delaySeconds,
    this.escapeCode,
    required this.status,
    this.statusMsg,
    this.location,
    required this.destination,
    this.launchSig,
    this.lastSig,
    required this.draftedAt,
    this.submittingAt,
    this.submittedAt,
    this.skrambledAt,
    this.finalizedAt,
    required this.durationSeconds,
    required this.isCreatorBurner,
    required this.isDestinationBurner,
    this.unsignedMessageB64,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || podPda != null) {
      map['pod_pda'] = Variable<String>(podPda);
    }
    map['creator'] = Variable<String>(creator);
    if (!nullToAbsent || podId != null) {
      map['pod_id'] = Variable<int>(podId);
    }
    map['lamports'] = Variable<int>(lamports);
    map['fee'] = Variable<int>(fee);
    map['mode'] = Variable<int>(mode);
    map['delay_seconds'] = Variable<int>(delaySeconds);
    if (!nullToAbsent || escapeCode != null) {
      map['escape_code'] = Variable<String>(escapeCode);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || statusMsg != null) {
      map['status_msg'] = Variable<String>(statusMsg);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || launchSig != null) {
      map['launch_sig'] = Variable<String>(launchSig);
    }
    if (!nullToAbsent || lastSig != null) {
      map['last_sig'] = Variable<String>(lastSig);
    }
    map['drafted_at'] = Variable<int>(draftedAt);
    if (!nullToAbsent || submittingAt != null) {
      map['submitting_at'] = Variable<int>(submittingAt);
    }
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<int>(submittedAt);
    }
    if (!nullToAbsent || skrambledAt != null) {
      map['skrambled_at'] = Variable<int>(skrambledAt);
    }
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<int>(finalizedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['is_creator_burner'] = Variable<bool>(isCreatorBurner);
    map['is_destination_burner'] = Variable<bool>(isDestinationBurner);
    if (!nullToAbsent || unsignedMessageB64 != null) {
      map['unsigned_message_b64'] = Variable<String>(unsignedMessageB64);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PodsCompanion toCompanion(bool nullToAbsent) {
    return PodsCompanion(
      id: Value(id),
      podPda: podPda == null && nullToAbsent
          ? const Value.absent()
          : Value(podPda),
      creator: Value(creator),
      podId: podId == null && nullToAbsent
          ? const Value.absent()
          : Value(podId),
      lamports: Value(lamports),
      fee: Value(fee),
      mode: Value(mode),
      delaySeconds: Value(delaySeconds),
      escapeCode: escapeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(escapeCode),
      status: Value(status),
      statusMsg: statusMsg == null && nullToAbsent
          ? const Value.absent()
          : Value(statusMsg),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      destination: Value(destination),
      launchSig: launchSig == null && nullToAbsent
          ? const Value.absent()
          : Value(launchSig),
      lastSig: lastSig == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSig),
      draftedAt: Value(draftedAt),
      submittingAt: submittingAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittingAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      skrambledAt: skrambledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(skrambledAt),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
      durationSeconds: Value(durationSeconds),
      isCreatorBurner: Value(isCreatorBurner),
      isDestinationBurner: Value(isDestinationBurner),
      unsignedMessageB64: unsignedMessageB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(unsignedMessageB64),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory Pod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pod(
      id: serializer.fromJson<String>(json['id']),
      podPda: serializer.fromJson<String?>(json['podPda']),
      creator: serializer.fromJson<String>(json['creator']),
      podId: serializer.fromJson<int?>(json['podId']),
      lamports: serializer.fromJson<int>(json['lamports']),
      fee: serializer.fromJson<int>(json['fee']),
      mode: serializer.fromJson<int>(json['mode']),
      delaySeconds: serializer.fromJson<int>(json['delaySeconds']),
      escapeCode: serializer.fromJson<String?>(json['escapeCode']),
      status: serializer.fromJson<int>(json['status']),
      statusMsg: serializer.fromJson<String?>(json['statusMsg']),
      location: serializer.fromJson<String?>(json['location']),
      destination: serializer.fromJson<String>(json['destination']),
      launchSig: serializer.fromJson<String?>(json['launchSig']),
      lastSig: serializer.fromJson<String?>(json['lastSig']),
      draftedAt: serializer.fromJson<int>(json['draftedAt']),
      submittingAt: serializer.fromJson<int?>(json['submittingAt']),
      submittedAt: serializer.fromJson<int?>(json['submittedAt']),
      skrambledAt: serializer.fromJson<int?>(json['skrambledAt']),
      finalizedAt: serializer.fromJson<int?>(json['finalizedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      isCreatorBurner: serializer.fromJson<bool>(json['isCreatorBurner']),
      isDestinationBurner: serializer.fromJson<bool>(
        json['isDestinationBurner'],
      ),
      unsignedMessageB64: serializer.fromJson<String?>(
        json['unsignedMessageB64'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'podPda': serializer.toJson<String?>(podPda),
      'creator': serializer.toJson<String>(creator),
      'podId': serializer.toJson<int?>(podId),
      'lamports': serializer.toJson<int>(lamports),
      'fee': serializer.toJson<int>(fee),
      'mode': serializer.toJson<int>(mode),
      'delaySeconds': serializer.toJson<int>(delaySeconds),
      'escapeCode': serializer.toJson<String?>(escapeCode),
      'status': serializer.toJson<int>(status),
      'statusMsg': serializer.toJson<String?>(statusMsg),
      'location': serializer.toJson<String?>(location),
      'destination': serializer.toJson<String>(destination),
      'launchSig': serializer.toJson<String?>(launchSig),
      'lastSig': serializer.toJson<String?>(lastSig),
      'draftedAt': serializer.toJson<int>(draftedAt),
      'submittingAt': serializer.toJson<int?>(submittingAt),
      'submittedAt': serializer.toJson<int?>(submittedAt),
      'skrambledAt': serializer.toJson<int?>(skrambledAt),
      'finalizedAt': serializer.toJson<int?>(finalizedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'isCreatorBurner': serializer.toJson<bool>(isCreatorBurner),
      'isDestinationBurner': serializer.toJson<bool>(isDestinationBurner),
      'unsignedMessageB64': serializer.toJson<String?>(unsignedMessageB64),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  Pod copyWith({
    String? id,
    Value<String?> podPda = const Value.absent(),
    String? creator,
    Value<int?> podId = const Value.absent(),
    int? lamports,
    int? fee,
    int? mode,
    int? delaySeconds,
    Value<String?> escapeCode = const Value.absent(),
    int? status,
    Value<String?> statusMsg = const Value.absent(),
    Value<String?> location = const Value.absent(),
    String? destination,
    Value<String?> launchSig = const Value.absent(),
    Value<String?> lastSig = const Value.absent(),
    int? draftedAt,
    Value<int?> submittingAt = const Value.absent(),
    Value<int?> submittedAt = const Value.absent(),
    Value<int?> skrambledAt = const Value.absent(),
    Value<int?> finalizedAt = const Value.absent(),
    int? durationSeconds,
    bool? isCreatorBurner,
    bool? isDestinationBurner,
    Value<String?> unsignedMessageB64 = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => Pod(
    id: id ?? this.id,
    podPda: podPda.present ? podPda.value : this.podPda,
    creator: creator ?? this.creator,
    podId: podId.present ? podId.value : this.podId,
    lamports: lamports ?? this.lamports,
    fee: fee ?? this.fee,
    mode: mode ?? this.mode,
    delaySeconds: delaySeconds ?? this.delaySeconds,
    escapeCode: escapeCode.present ? escapeCode.value : this.escapeCode,
    status: status ?? this.status,
    statusMsg: statusMsg.present ? statusMsg.value : this.statusMsg,
    location: location.present ? location.value : this.location,
    destination: destination ?? this.destination,
    launchSig: launchSig.present ? launchSig.value : this.launchSig,
    lastSig: lastSig.present ? lastSig.value : this.lastSig,
    draftedAt: draftedAt ?? this.draftedAt,
    submittingAt: submittingAt.present ? submittingAt.value : this.submittingAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    skrambledAt: skrambledAt.present ? skrambledAt.value : this.skrambledAt,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    isCreatorBurner: isCreatorBurner ?? this.isCreatorBurner,
    isDestinationBurner: isDestinationBurner ?? this.isDestinationBurner,
    unsignedMessageB64: unsignedMessageB64.present
        ? unsignedMessageB64.value
        : this.unsignedMessageB64,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  Pod copyWithCompanion(PodsCompanion data) {
    return Pod(
      id: data.id.present ? data.id.value : this.id,
      podPda: data.podPda.present ? data.podPda.value : this.podPda,
      creator: data.creator.present ? data.creator.value : this.creator,
      podId: data.podId.present ? data.podId.value : this.podId,
      lamports: data.lamports.present ? data.lamports.value : this.lamports,
      fee: data.fee.present ? data.fee.value : this.fee,
      mode: data.mode.present ? data.mode.value : this.mode,
      delaySeconds: data.delaySeconds.present
          ? data.delaySeconds.value
          : this.delaySeconds,
      escapeCode: data.escapeCode.present
          ? data.escapeCode.value
          : this.escapeCode,
      status: data.status.present ? data.status.value : this.status,
      statusMsg: data.statusMsg.present ? data.statusMsg.value : this.statusMsg,
      location: data.location.present ? data.location.value : this.location,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      launchSig: data.launchSig.present ? data.launchSig.value : this.launchSig,
      lastSig: data.lastSig.present ? data.lastSig.value : this.lastSig,
      draftedAt: data.draftedAt.present ? data.draftedAt.value : this.draftedAt,
      submittingAt: data.submittingAt.present
          ? data.submittingAt.value
          : this.submittingAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      skrambledAt: data.skrambledAt.present
          ? data.skrambledAt.value
          : this.skrambledAt,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      isCreatorBurner: data.isCreatorBurner.present
          ? data.isCreatorBurner.value
          : this.isCreatorBurner,
      isDestinationBurner: data.isDestinationBurner.present
          ? data.isDestinationBurner.value
          : this.isDestinationBurner,
      unsignedMessageB64: data.unsignedMessageB64.present
          ? data.unsignedMessageB64.value
          : this.unsignedMessageB64,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pod(')
          ..write('id: $id, ')
          ..write('podPda: $podPda, ')
          ..write('creator: $creator, ')
          ..write('podId: $podId, ')
          ..write('lamports: $lamports, ')
          ..write('fee: $fee, ')
          ..write('mode: $mode, ')
          ..write('delaySeconds: $delaySeconds, ')
          ..write('escapeCode: $escapeCode, ')
          ..write('status: $status, ')
          ..write('statusMsg: $statusMsg, ')
          ..write('location: $location, ')
          ..write('destination: $destination, ')
          ..write('launchSig: $launchSig, ')
          ..write('lastSig: $lastSig, ')
          ..write('draftedAt: $draftedAt, ')
          ..write('submittingAt: $submittingAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('skrambledAt: $skrambledAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isCreatorBurner: $isCreatorBurner, ')
          ..write('isDestinationBurner: $isDestinationBurner, ')
          ..write('unsignedMessageB64: $unsignedMessageB64, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    podPda,
    creator,
    podId,
    lamports,
    fee,
    mode,
    delaySeconds,
    escapeCode,
    status,
    statusMsg,
    location,
    destination,
    launchSig,
    lastSig,
    draftedAt,
    submittingAt,
    submittedAt,
    skrambledAt,
    finalizedAt,
    durationSeconds,
    isCreatorBurner,
    isDestinationBurner,
    unsignedMessageB64,
    lastError,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pod &&
          other.id == this.id &&
          other.podPda == this.podPda &&
          other.creator == this.creator &&
          other.podId == this.podId &&
          other.lamports == this.lamports &&
          other.fee == this.fee &&
          other.mode == this.mode &&
          other.delaySeconds == this.delaySeconds &&
          other.escapeCode == this.escapeCode &&
          other.status == this.status &&
          other.statusMsg == this.statusMsg &&
          other.location == this.location &&
          other.destination == this.destination &&
          other.launchSig == this.launchSig &&
          other.lastSig == this.lastSig &&
          other.draftedAt == this.draftedAt &&
          other.submittingAt == this.submittingAt &&
          other.submittedAt == this.submittedAt &&
          other.skrambledAt == this.skrambledAt &&
          other.finalizedAt == this.finalizedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.isCreatorBurner == this.isCreatorBurner &&
          other.isDestinationBurner == this.isDestinationBurner &&
          other.unsignedMessageB64 == this.unsignedMessageB64 &&
          other.lastError == this.lastError);
}

class PodsCompanion extends UpdateCompanion<Pod> {
  final Value<String> id;
  final Value<String?> podPda;
  final Value<String> creator;
  final Value<int?> podId;
  final Value<int> lamports;
  final Value<int> fee;
  final Value<int> mode;
  final Value<int> delaySeconds;
  final Value<String?> escapeCode;
  final Value<int> status;
  final Value<String?> statusMsg;
  final Value<String?> location;
  final Value<String> destination;
  final Value<String?> launchSig;
  final Value<String?> lastSig;
  final Value<int> draftedAt;
  final Value<int?> submittingAt;
  final Value<int?> submittedAt;
  final Value<int?> skrambledAt;
  final Value<int?> finalizedAt;
  final Value<int> durationSeconds;
  final Value<bool> isCreatorBurner;
  final Value<bool> isDestinationBurner;
  final Value<String?> unsignedMessageB64;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PodsCompanion({
    this.id = const Value.absent(),
    this.podPda = const Value.absent(),
    this.creator = const Value.absent(),
    this.podId = const Value.absent(),
    this.lamports = const Value.absent(),
    this.fee = const Value.absent(),
    this.mode = const Value.absent(),
    this.delaySeconds = const Value.absent(),
    this.escapeCode = const Value.absent(),
    this.status = const Value.absent(),
    this.statusMsg = const Value.absent(),
    this.location = const Value.absent(),
    this.destination = const Value.absent(),
    this.launchSig = const Value.absent(),
    this.lastSig = const Value.absent(),
    this.draftedAt = const Value.absent(),
    this.submittingAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.skrambledAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isCreatorBurner = const Value.absent(),
    this.isDestinationBurner = const Value.absent(),
    this.unsignedMessageB64 = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodsCompanion.insert({
    required String id,
    this.podPda = const Value.absent(),
    required String creator,
    this.podId = const Value.absent(),
    required int lamports,
    required int fee,
    required int mode,
    this.delaySeconds = const Value.absent(),
    this.escapeCode = const Value.absent(),
    required int status,
    this.statusMsg = const Value.absent(),
    this.location = const Value.absent(),
    required String destination,
    this.launchSig = const Value.absent(),
    this.lastSig = const Value.absent(),
    required int draftedAt,
    this.submittingAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.skrambledAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isCreatorBurner = const Value.absent(),
    this.isDestinationBurner = const Value.absent(),
    this.unsignedMessageB64 = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creator = Value(creator),
       lamports = Value(lamports),
       fee = Value(fee),
       mode = Value(mode),
       status = Value(status),
       destination = Value(destination),
       draftedAt = Value(draftedAt);
  static Insertable<Pod> custom({
    Expression<String>? id,
    Expression<String>? podPda,
    Expression<String>? creator,
    Expression<int>? podId,
    Expression<int>? lamports,
    Expression<int>? fee,
    Expression<int>? mode,
    Expression<int>? delaySeconds,
    Expression<String>? escapeCode,
    Expression<int>? status,
    Expression<String>? statusMsg,
    Expression<String>? location,
    Expression<String>? destination,
    Expression<String>? launchSig,
    Expression<String>? lastSig,
    Expression<int>? draftedAt,
    Expression<int>? submittingAt,
    Expression<int>? submittedAt,
    Expression<int>? skrambledAt,
    Expression<int>? finalizedAt,
    Expression<int>? durationSeconds,
    Expression<bool>? isCreatorBurner,
    Expression<bool>? isDestinationBurner,
    Expression<String>? unsignedMessageB64,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podPda != null) 'pod_pda': podPda,
      if (creator != null) 'creator': creator,
      if (podId != null) 'pod_id': podId,
      if (lamports != null) 'lamports': lamports,
      if (fee != null) 'fee': fee,
      if (mode != null) 'mode': mode,
      if (delaySeconds != null) 'delay_seconds': delaySeconds,
      if (escapeCode != null) 'escape_code': escapeCode,
      if (status != null) 'status': status,
      if (statusMsg != null) 'status_msg': statusMsg,
      if (location != null) 'location': location,
      if (destination != null) 'destination': destination,
      if (launchSig != null) 'launch_sig': launchSig,
      if (lastSig != null) 'last_sig': lastSig,
      if (draftedAt != null) 'drafted_at': draftedAt,
      if (submittingAt != null) 'submitting_at': submittingAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (skrambledAt != null) 'skrambled_at': skrambledAt,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (isCreatorBurner != null) 'is_creator_burner': isCreatorBurner,
      if (isDestinationBurner != null)
        'is_destination_burner': isDestinationBurner,
      if (unsignedMessageB64 != null)
        'unsigned_message_b64': unsignedMessageB64,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? podPda,
    Value<String>? creator,
    Value<int?>? podId,
    Value<int>? lamports,
    Value<int>? fee,
    Value<int>? mode,
    Value<int>? delaySeconds,
    Value<String?>? escapeCode,
    Value<int>? status,
    Value<String?>? statusMsg,
    Value<String?>? location,
    Value<String>? destination,
    Value<String?>? launchSig,
    Value<String?>? lastSig,
    Value<int>? draftedAt,
    Value<int?>? submittingAt,
    Value<int?>? submittedAt,
    Value<int?>? skrambledAt,
    Value<int?>? finalizedAt,
    Value<int>? durationSeconds,
    Value<bool>? isCreatorBurner,
    Value<bool>? isDestinationBurner,
    Value<String?>? unsignedMessageB64,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return PodsCompanion(
      id: id ?? this.id,
      podPda: podPda ?? this.podPda,
      creator: creator ?? this.creator,
      podId: podId ?? this.podId,
      lamports: lamports ?? this.lamports,
      fee: fee ?? this.fee,
      mode: mode ?? this.mode,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      escapeCode: escapeCode ?? this.escapeCode,
      status: status ?? this.status,
      statusMsg: statusMsg ?? this.statusMsg,
      location: location ?? this.location,
      destination: destination ?? this.destination,
      launchSig: launchSig ?? this.launchSig,
      lastSig: lastSig ?? this.lastSig,
      draftedAt: draftedAt ?? this.draftedAt,
      submittingAt: submittingAt ?? this.submittingAt,
      submittedAt: submittedAt ?? this.submittedAt,
      skrambledAt: skrambledAt ?? this.skrambledAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCreatorBurner: isCreatorBurner ?? this.isCreatorBurner,
      isDestinationBurner: isDestinationBurner ?? this.isDestinationBurner,
      unsignedMessageB64: unsignedMessageB64 ?? this.unsignedMessageB64,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (podPda.present) {
      map['pod_pda'] = Variable<String>(podPda.value);
    }
    if (creator.present) {
      map['creator'] = Variable<String>(creator.value);
    }
    if (podId.present) {
      map['pod_id'] = Variable<int>(podId.value);
    }
    if (lamports.present) {
      map['lamports'] = Variable<int>(lamports.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (delaySeconds.present) {
      map['delay_seconds'] = Variable<int>(delaySeconds.value);
    }
    if (escapeCode.present) {
      map['escape_code'] = Variable<String>(escapeCode.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (statusMsg.present) {
      map['status_msg'] = Variable<String>(statusMsg.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (launchSig.present) {
      map['launch_sig'] = Variable<String>(launchSig.value);
    }
    if (lastSig.present) {
      map['last_sig'] = Variable<String>(lastSig.value);
    }
    if (draftedAt.present) {
      map['drafted_at'] = Variable<int>(draftedAt.value);
    }
    if (submittingAt.present) {
      map['submitting_at'] = Variable<int>(submittingAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<int>(submittedAt.value);
    }
    if (skrambledAt.present) {
      map['skrambled_at'] = Variable<int>(skrambledAt.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<int>(finalizedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (isCreatorBurner.present) {
      map['is_creator_burner'] = Variable<bool>(isCreatorBurner.value);
    }
    if (isDestinationBurner.present) {
      map['is_destination_burner'] = Variable<bool>(isDestinationBurner.value);
    }
    if (unsignedMessageB64.present) {
      map['unsigned_message_b64'] = Variable<String>(unsignedMessageB64.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodsCompanion(')
          ..write('id: $id, ')
          ..write('podPda: $podPda, ')
          ..write('creator: $creator, ')
          ..write('podId: $podId, ')
          ..write('lamports: $lamports, ')
          ..write('fee: $fee, ')
          ..write('mode: $mode, ')
          ..write('delaySeconds: $delaySeconds, ')
          ..write('escapeCode: $escapeCode, ')
          ..write('status: $status, ')
          ..write('statusMsg: $statusMsg, ')
          ..write('location: $location, ')
          ..write('destination: $destination, ')
          ..write('launchSig: $launchSig, ')
          ..write('lastSig: $lastSig, ')
          ..write('draftedAt: $draftedAt, ')
          ..write('submittingAt: $submittingAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('skrambledAt: $skrambledAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isCreatorBurner: $isCreatorBurner, ')
          ..write('isDestinationBurner: $isDestinationBurner, ')
          ..write('unsignedMessageB64: $unsignedMessageB64, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BurnersTable extends Burners with TableInfo<$BurnersTable, Burner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BurnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pubkeyMeta = const VerificationMeta('pubkey');
  @override
  late final GeneratedColumn<String> pubkey = GeneratedColumn<String>(
    'pubkey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _derivationIndexMeta = const VerificationMeta(
    'derivationIndex',
  );
  @override
  late final GeneratedColumn<int> derivationIndex = GeneratedColumn<int>(
    'derivation_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usedMeta = const VerificationMeta('used');
  @override
  late final GeneratedColumn<bool> used = GeneratedColumn<bool>(
    'used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("used" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _txCountMeta = const VerificationMeta(
    'txCount',
  );
  @override
  late final GeneratedColumn<int> txCount = GeneratedColumn<int>(
    'tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    pubkey,
    derivationIndex,
    note,
    used,
    txCount,
    createdAt,
    lastUsedAt,
    lastSeenAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'burners';
  @override
  VerificationContext validateIntegrity(
    Insertable<Burner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pubkey')) {
      context.handle(
        _pubkeyMeta,
        pubkey.isAcceptableOrUnknown(data['pubkey']!, _pubkeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pubkeyMeta);
    }
    if (data.containsKey('derivation_index')) {
      context.handle(
        _derivationIndexMeta,
        derivationIndex.isAcceptableOrUnknown(
          data['derivation_index']!,
          _derivationIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_derivationIndexMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('used')) {
      context.handle(
        _usedMeta,
        used.isAcceptableOrUnknown(data['used']!, _usedMeta),
      );
    }
    if (data.containsKey('tx_count')) {
      context.handle(
        _txCountMeta,
        txCount.isAcceptableOrUnknown(data['tx_count']!, _txCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pubkey};
  @override
  Burner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Burner(
      pubkey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pubkey'],
      )!,
      derivationIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}derivation_index'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      used: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}used'],
      )!,
      txCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $BurnersTable createAlias(String alias) {
    return $BurnersTable(attachedDatabase, alias);
  }
}

class Burner extends DataClass implements Insertable<Burner> {
  final String pubkey;
  final int derivationIndex;
  final String? note;
  final bool used;
  final int txCount;
  final int createdAt;
  final int? lastUsedAt;
  final int? lastSeenAt;
  final bool archived;
  const Burner({
    required this.pubkey,
    required this.derivationIndex,
    this.note,
    required this.used,
    required this.txCount,
    required this.createdAt,
    this.lastUsedAt,
    this.lastSeenAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pubkey'] = Variable<String>(pubkey);
    map['derivation_index'] = Variable<int>(derivationIndex);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['used'] = Variable<bool>(used);
    map['tx_count'] = Variable<int>(txCount);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<int>(lastUsedAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<int>(lastSeenAt);
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  BurnersCompanion toCompanion(bool nullToAbsent) {
    return BurnersCompanion(
      pubkey: Value(pubkey),
      derivationIndex: Value(derivationIndex),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      used: Value(used),
      txCount: Value(txCount),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      archived: Value(archived),
    );
  }

  factory Burner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Burner(
      pubkey: serializer.fromJson<String>(json['pubkey']),
      derivationIndex: serializer.fromJson<int>(json['derivationIndex']),
      note: serializer.fromJson<String?>(json['note']),
      used: serializer.fromJson<bool>(json['used']),
      txCount: serializer.fromJson<int>(json['txCount']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUsedAt: serializer.fromJson<int?>(json['lastUsedAt']),
      lastSeenAt: serializer.fromJson<int?>(json['lastSeenAt']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pubkey': serializer.toJson<String>(pubkey),
      'derivationIndex': serializer.toJson<int>(derivationIndex),
      'note': serializer.toJson<String?>(note),
      'used': serializer.toJson<bool>(used),
      'txCount': serializer.toJson<int>(txCount),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUsedAt': serializer.toJson<int?>(lastUsedAt),
      'lastSeenAt': serializer.toJson<int?>(lastSeenAt),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Burner copyWith({
    String? pubkey,
    int? derivationIndex,
    Value<String?> note = const Value.absent(),
    bool? used,
    int? txCount,
    int? createdAt,
    Value<int?> lastUsedAt = const Value.absent(),
    Value<int?> lastSeenAt = const Value.absent(),
    bool? archived,
  }) => Burner(
    pubkey: pubkey ?? this.pubkey,
    derivationIndex: derivationIndex ?? this.derivationIndex,
    note: note.present ? note.value : this.note,
    used: used ?? this.used,
    txCount: txCount ?? this.txCount,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    archived: archived ?? this.archived,
  );
  Burner copyWithCompanion(BurnersCompanion data) {
    return Burner(
      pubkey: data.pubkey.present ? data.pubkey.value : this.pubkey,
      derivationIndex: data.derivationIndex.present
          ? data.derivationIndex.value
          : this.derivationIndex,
      note: data.note.present ? data.note.value : this.note,
      used: data.used.present ? data.used.value : this.used,
      txCount: data.txCount.present ? data.txCount.value : this.txCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Burner(')
          ..write('pubkey: $pubkey, ')
          ..write('derivationIndex: $derivationIndex, ')
          ..write('note: $note, ')
          ..write('used: $used, ')
          ..write('txCount: $txCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pubkey,
    derivationIndex,
    note,
    used,
    txCount,
    createdAt,
    lastUsedAt,
    lastSeenAt,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Burner &&
          other.pubkey == this.pubkey &&
          other.derivationIndex == this.derivationIndex &&
          other.note == this.note &&
          other.used == this.used &&
          other.txCount == this.txCount &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.archived == this.archived);
}

class BurnersCompanion extends UpdateCompanion<Burner> {
  final Value<String> pubkey;
  final Value<int> derivationIndex;
  final Value<String?> note;
  final Value<bool> used;
  final Value<int> txCount;
  final Value<int> createdAt;
  final Value<int?> lastUsedAt;
  final Value<int?> lastSeenAt;
  final Value<bool> archived;
  final Value<int> rowid;
  const BurnersCompanion({
    this.pubkey = const Value.absent(),
    this.derivationIndex = const Value.absent(),
    this.note = const Value.absent(),
    this.used = const Value.absent(),
    this.txCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BurnersCompanion.insert({
    required String pubkey,
    required int derivationIndex,
    this.note = const Value.absent(),
    this.used = const Value.absent(),
    this.txCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pubkey = Value(pubkey),
       derivationIndex = Value(derivationIndex);
  static Insertable<Burner> custom({
    Expression<String>? pubkey,
    Expression<int>? derivationIndex,
    Expression<String>? note,
    Expression<bool>? used,
    Expression<int>? txCount,
    Expression<int>? createdAt,
    Expression<int>? lastUsedAt,
    Expression<int>? lastSeenAt,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pubkey != null) 'pubkey': pubkey,
      if (derivationIndex != null) 'derivation_index': derivationIndex,
      if (note != null) 'note': note,
      if (used != null) 'used': used,
      if (txCount != null) 'tx_count': txCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BurnersCompanion copyWith({
    Value<String>? pubkey,
    Value<int>? derivationIndex,
    Value<String?>? note,
    Value<bool>? used,
    Value<int>? txCount,
    Value<int>? createdAt,
    Value<int?>? lastUsedAt,
    Value<int?>? lastSeenAt,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return BurnersCompanion(
      pubkey: pubkey ?? this.pubkey,
      derivationIndex: derivationIndex ?? this.derivationIndex,
      note: note ?? this.note,
      used: used ?? this.used,
      txCount: txCount ?? this.txCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pubkey.present) {
      map['pubkey'] = Variable<String>(pubkey.value);
    }
    if (derivationIndex.present) {
      map['derivation_index'] = Variable<int>(derivationIndex.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (used.present) {
      map['used'] = Variable<bool>(used.value);
    }
    if (txCount.present) {
      map['tx_count'] = Variable<int>(txCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BurnersCompanion(')
          ..write('pubkey: $pubkey, ')
          ..write('derivationIndex: $derivationIndex, ')
          ..write('note: $note, ')
          ..write('used: $used, ')
          ..write('txCount: $txCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $PodsTable pods = $PodsTable(this);
  late final $BurnersTable burners = $BurnersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pods, burners];
}

typedef $$PodsTableCreateCompanionBuilder =
    PodsCompanion Function({
      required String id,
      Value<String?> podPda,
      required String creator,
      Value<int?> podId,
      required int lamports,
      required int fee,
      required int mode,
      Value<int> delaySeconds,
      Value<String?> escapeCode,
      required int status,
      Value<String?> statusMsg,
      Value<String?> location,
      required String destination,
      Value<String?> launchSig,
      Value<String?> lastSig,
      required int draftedAt,
      Value<int?> submittingAt,
      Value<int?> submittedAt,
      Value<int?> skrambledAt,
      Value<int?> finalizedAt,
      Value<int> durationSeconds,
      Value<bool> isCreatorBurner,
      Value<bool> isDestinationBurner,
      Value<String?> unsignedMessageB64,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$PodsTableUpdateCompanionBuilder =
    PodsCompanion Function({
      Value<String> id,
      Value<String?> podPda,
      Value<String> creator,
      Value<int?> podId,
      Value<int> lamports,
      Value<int> fee,
      Value<int> mode,
      Value<int> delaySeconds,
      Value<String?> escapeCode,
      Value<int> status,
      Value<String?> statusMsg,
      Value<String?> location,
      Value<String> destination,
      Value<String?> launchSig,
      Value<String?> lastSig,
      Value<int> draftedAt,
      Value<int?> submittingAt,
      Value<int?> submittedAt,
      Value<int?> skrambledAt,
      Value<int?> finalizedAt,
      Value<int> durationSeconds,
      Value<bool> isCreatorBurner,
      Value<bool> isDestinationBurner,
      Value<String?> unsignedMessageB64,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$PodsTableFilterComposer extends Composer<_$LocalDatabase, $PodsTable> {
  $$PodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get podPda => $composableBuilder(
    column: $table.podPda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get podId => $composableBuilder(
    column: $table.podId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamports => $composableBuilder(
    column: $table.lamports,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get escapeCode => $composableBuilder(
    column: $table.escapeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusMsg => $composableBuilder(
    column: $table.statusMsg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get launchSig => $composableBuilder(
    column: $table.launchSig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSig => $composableBuilder(
    column: $table.lastSig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get draftedAt => $composableBuilder(
    column: $table.draftedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get submittingAt => $composableBuilder(
    column: $table.submittingAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skrambledAt => $composableBuilder(
    column: $table.skrambledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCreatorBurner => $composableBuilder(
    column: $table.isCreatorBurner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDestinationBurner => $composableBuilder(
    column: $table.isDestinationBurner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unsignedMessageB64 => $composableBuilder(
    column: $table.unsignedMessageB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PodsTableOrderingComposer
    extends Composer<_$LocalDatabase, $PodsTable> {
  $$PodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get podPda => $composableBuilder(
    column: $table.podPda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get podId => $composableBuilder(
    column: $table.podId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamports => $composableBuilder(
    column: $table.lamports,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get escapeCode => $composableBuilder(
    column: $table.escapeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusMsg => $composableBuilder(
    column: $table.statusMsg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get launchSig => $composableBuilder(
    column: $table.launchSig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSig => $composableBuilder(
    column: $table.lastSig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get draftedAt => $composableBuilder(
    column: $table.draftedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get submittingAt => $composableBuilder(
    column: $table.submittingAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skrambledAt => $composableBuilder(
    column: $table.skrambledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCreatorBurner => $composableBuilder(
    column: $table.isCreatorBurner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDestinationBurner => $composableBuilder(
    column: $table.isDestinationBurner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unsignedMessageB64 => $composableBuilder(
    column: $table.unsignedMessageB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PodsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PodsTable> {
  $$PodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get podPda =>
      $composableBuilder(column: $table.podPda, builder: (column) => column);

  GeneratedColumn<String> get creator =>
      $composableBuilder(column: $table.creator, builder: (column) => column);

  GeneratedColumn<int> get podId =>
      $composableBuilder(column: $table.podId, builder: (column) => column);

  GeneratedColumn<int> get lamports =>
      $composableBuilder(column: $table.lamports, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get escapeCode => $composableBuilder(
    column: $table.escapeCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get statusMsg =>
      $composableBuilder(column: $table.statusMsg, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get launchSig =>
      $composableBuilder(column: $table.launchSig, builder: (column) => column);

  GeneratedColumn<String> get lastSig =>
      $composableBuilder(column: $table.lastSig, builder: (column) => column);

  GeneratedColumn<int> get draftedAt =>
      $composableBuilder(column: $table.draftedAt, builder: (column) => column);

  GeneratedColumn<int> get submittingAt => $composableBuilder(
    column: $table.submittingAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skrambledAt => $composableBuilder(
    column: $table.skrambledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCreatorBurner => $composableBuilder(
    column: $table.isCreatorBurner,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDestinationBurner => $composableBuilder(
    column: $table.isDestinationBurner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unsignedMessageB64 => $composableBuilder(
    column: $table.unsignedMessageB64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PodsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PodsTable,
          Pod,
          $$PodsTableFilterComposer,
          $$PodsTableOrderingComposer,
          $$PodsTableAnnotationComposer,
          $$PodsTableCreateCompanionBuilder,
          $$PodsTableUpdateCompanionBuilder,
          (Pod, BaseReferences<_$LocalDatabase, $PodsTable, Pod>),
          Pod,
          PrefetchHooks Function()
        > {
  $$PodsTableTableManager(_$LocalDatabase db, $PodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> podPda = const Value.absent(),
                Value<String> creator = const Value.absent(),
                Value<int?> podId = const Value.absent(),
                Value<int> lamports = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<int> mode = const Value.absent(),
                Value<int> delaySeconds = const Value.absent(),
                Value<String?> escapeCode = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> statusMsg = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String?> launchSig = const Value.absent(),
                Value<String?> lastSig = const Value.absent(),
                Value<int> draftedAt = const Value.absent(),
                Value<int?> submittingAt = const Value.absent(),
                Value<int?> submittedAt = const Value.absent(),
                Value<int?> skrambledAt = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> isCreatorBurner = const Value.absent(),
                Value<bool> isDestinationBurner = const Value.absent(),
                Value<String?> unsignedMessageB64 = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodsCompanion(
                id: id,
                podPda: podPda,
                creator: creator,
                podId: podId,
                lamports: lamports,
                fee: fee,
                mode: mode,
                delaySeconds: delaySeconds,
                escapeCode: escapeCode,
                status: status,
                statusMsg: statusMsg,
                location: location,
                destination: destination,
                launchSig: launchSig,
                lastSig: lastSig,
                draftedAt: draftedAt,
                submittingAt: submittingAt,
                submittedAt: submittedAt,
                skrambledAt: skrambledAt,
                finalizedAt: finalizedAt,
                durationSeconds: durationSeconds,
                isCreatorBurner: isCreatorBurner,
                isDestinationBurner: isDestinationBurner,
                unsignedMessageB64: unsignedMessageB64,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> podPda = const Value.absent(),
                required String creator,
                Value<int?> podId = const Value.absent(),
                required int lamports,
                required int fee,
                required int mode,
                Value<int> delaySeconds = const Value.absent(),
                Value<String?> escapeCode = const Value.absent(),
                required int status,
                Value<String?> statusMsg = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required String destination,
                Value<String?> launchSig = const Value.absent(),
                Value<String?> lastSig = const Value.absent(),
                required int draftedAt,
                Value<int?> submittingAt = const Value.absent(),
                Value<int?> submittedAt = const Value.absent(),
                Value<int?> skrambledAt = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> isCreatorBurner = const Value.absent(),
                Value<bool> isDestinationBurner = const Value.absent(),
                Value<String?> unsignedMessageB64 = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodsCompanion.insert(
                id: id,
                podPda: podPda,
                creator: creator,
                podId: podId,
                lamports: lamports,
                fee: fee,
                mode: mode,
                delaySeconds: delaySeconds,
                escapeCode: escapeCode,
                status: status,
                statusMsg: statusMsg,
                location: location,
                destination: destination,
                launchSig: launchSig,
                lastSig: lastSig,
                draftedAt: draftedAt,
                submittingAt: submittingAt,
                submittedAt: submittedAt,
                skrambledAt: skrambledAt,
                finalizedAt: finalizedAt,
                durationSeconds: durationSeconds,
                isCreatorBurner: isCreatorBurner,
                isDestinationBurner: isDestinationBurner,
                unsignedMessageB64: unsignedMessageB64,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PodsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PodsTable,
      Pod,
      $$PodsTableFilterComposer,
      $$PodsTableOrderingComposer,
      $$PodsTableAnnotationComposer,
      $$PodsTableCreateCompanionBuilder,
      $$PodsTableUpdateCompanionBuilder,
      (Pod, BaseReferences<_$LocalDatabase, $PodsTable, Pod>),
      Pod,
      PrefetchHooks Function()
    >;
typedef $$BurnersTableCreateCompanionBuilder =
    BurnersCompanion Function({
      required String pubkey,
      required int derivationIndex,
      Value<String?> note,
      Value<bool> used,
      Value<int> txCount,
      Value<int> createdAt,
      Value<int?> lastUsedAt,
      Value<int?> lastSeenAt,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$BurnersTableUpdateCompanionBuilder =
    BurnersCompanion Function({
      Value<String> pubkey,
      Value<int> derivationIndex,
      Value<String?> note,
      Value<bool> used,
      Value<int> txCount,
      Value<int> createdAt,
      Value<int?> lastUsedAt,
      Value<int?> lastSeenAt,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$BurnersTableFilterComposer
    extends Composer<_$LocalDatabase, $BurnersTable> {
  $$BurnersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get derivationIndex => $composableBuilder(
    column: $table.derivationIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BurnersTableOrderingComposer
    extends Composer<_$LocalDatabase, $BurnersTable> {
  $$BurnersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get derivationIndex => $composableBuilder(
    column: $table.derivationIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BurnersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BurnersTable> {
  $$BurnersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pubkey =>
      $composableBuilder(column: $table.pubkey, builder: (column) => column);

  GeneratedColumn<int> get derivationIndex => $composableBuilder(
    column: $table.derivationIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get used =>
      $composableBuilder(column: $table.used, builder: (column) => column);

  GeneratedColumn<int> get txCount =>
      $composableBuilder(column: $table.txCount, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$BurnersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $BurnersTable,
          Burner,
          $$BurnersTableFilterComposer,
          $$BurnersTableOrderingComposer,
          $$BurnersTableAnnotationComposer,
          $$BurnersTableCreateCompanionBuilder,
          $$BurnersTableUpdateCompanionBuilder,
          (Burner, BaseReferences<_$LocalDatabase, $BurnersTable, Burner>),
          Burner,
          PrefetchHooks Function()
        > {
  $$BurnersTableTableManager(_$LocalDatabase db, $BurnersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BurnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BurnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BurnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pubkey = const Value.absent(),
                Value<int> derivationIndex = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> used = const Value.absent(),
                Value<int> txCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastUsedAt = const Value.absent(),
                Value<int?> lastSeenAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BurnersCompanion(
                pubkey: pubkey,
                derivationIndex: derivationIndex,
                note: note,
                used: used,
                txCount: txCount,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                lastSeenAt: lastSeenAt,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pubkey,
                required int derivationIndex,
                Value<String?> note = const Value.absent(),
                Value<bool> used = const Value.absent(),
                Value<int> txCount = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastUsedAt = const Value.absent(),
                Value<int?> lastSeenAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BurnersCompanion.insert(
                pubkey: pubkey,
                derivationIndex: derivationIndex,
                note: note,
                used: used,
                txCount: txCount,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                lastSeenAt: lastSeenAt,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BurnersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $BurnersTable,
      Burner,
      $$BurnersTableFilterComposer,
      $$BurnersTableOrderingComposer,
      $$BurnersTableAnnotationComposer,
      $$BurnersTableCreateCompanionBuilder,
      $$BurnersTableUpdateCompanionBuilder,
      (Burner, BaseReferences<_$LocalDatabase, $BurnersTable, Burner>),
      Burner,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$PodsTableTableManager get pods => $$PodsTableTableManager(_db, _db.pods);
  $$BurnersTableTableManager get burners =>
      $$BurnersTableTableManager(_db, _db.burners);
}
