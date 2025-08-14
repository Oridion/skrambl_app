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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _showMemoMeta = const VerificationMeta(
    'showMemo',
  );
  @override
  late final GeneratedColumn<bool> showMemo = GeneratedColumn<bool>(
    'show_memo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_memo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    mode,
    delaySeconds,
    showMemo,
    escapeCode,
    status,
    statusMsg,
    location,
    destination,
    launchSig,
    lastSig,
    draftedAt,
    submittedAt,
    finalizedAt,
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
    } else if (isInserting) {
      context.missing(_podPdaMeta);
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
    } else if (isInserting) {
      context.missing(_podIdMeta);
    }
    if (data.containsKey('lamports')) {
      context.handle(
        _lamportsMeta,
        lamports.isAcceptableOrUnknown(data['lamports']!, _lamportsMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportsMeta);
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
    } else if (isInserting) {
      context.missing(_delaySecondsMeta);
    }
    if (data.containsKey('show_memo')) {
      context.handle(
        _showMemoMeta,
        showMemo.isAcceptableOrUnknown(data['show_memo']!, _showMemoMeta),
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
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
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
      )!,
      creator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator'],
      )!,
      podId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pod_id'],
      )!,
      lamports: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamports'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode'],
      )!,
      delaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delay_seconds'],
      )!,
      showMemo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_memo'],
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
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitted_at'],
      ),
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finalized_at'],
      ),
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
  final String podPda;
  final String creator;
  final int podId;
  final int lamports;
  final int mode;
  final int delaySeconds;
  final bool showMemo;
  final String? escapeCode;
  final int status;
  final String? statusMsg;
  final String? location;
  final String destination;
  final String? launchSig;
  final String? lastSig;
  final int draftedAt;
  final int? submittedAt;
  final int? finalizedAt;
  final String? unsignedMessageB64;
  final String? lastError;
  const Pod({
    required this.id,
    required this.podPda,
    required this.creator,
    required this.podId,
    required this.lamports,
    required this.mode,
    required this.delaySeconds,
    required this.showMemo,
    this.escapeCode,
    required this.status,
    this.statusMsg,
    this.location,
    required this.destination,
    this.launchSig,
    this.lastSig,
    required this.draftedAt,
    this.submittedAt,
    this.finalizedAt,
    this.unsignedMessageB64,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pod_pda'] = Variable<String>(podPda);
    map['creator'] = Variable<String>(creator);
    map['pod_id'] = Variable<int>(podId);
    map['lamports'] = Variable<int>(lamports);
    map['mode'] = Variable<int>(mode);
    map['delay_seconds'] = Variable<int>(delaySeconds);
    map['show_memo'] = Variable<bool>(showMemo);
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
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<int>(submittedAt);
    }
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<int>(finalizedAt);
    }
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
      podPda: Value(podPda),
      creator: Value(creator),
      podId: Value(podId),
      lamports: Value(lamports),
      mode: Value(mode),
      delaySeconds: Value(delaySeconds),
      showMemo: Value(showMemo),
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
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
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
      podPda: serializer.fromJson<String>(json['podPda']),
      creator: serializer.fromJson<String>(json['creator']),
      podId: serializer.fromJson<int>(json['podId']),
      lamports: serializer.fromJson<int>(json['lamports']),
      mode: serializer.fromJson<int>(json['mode']),
      delaySeconds: serializer.fromJson<int>(json['delaySeconds']),
      showMemo: serializer.fromJson<bool>(json['showMemo']),
      escapeCode: serializer.fromJson<String?>(json['escapeCode']),
      status: serializer.fromJson<int>(json['status']),
      statusMsg: serializer.fromJson<String?>(json['statusMsg']),
      location: serializer.fromJson<String?>(json['location']),
      destination: serializer.fromJson<String>(json['destination']),
      launchSig: serializer.fromJson<String?>(json['launchSig']),
      lastSig: serializer.fromJson<String?>(json['lastSig']),
      draftedAt: serializer.fromJson<int>(json['draftedAt']),
      submittedAt: serializer.fromJson<int?>(json['submittedAt']),
      finalizedAt: serializer.fromJson<int?>(json['finalizedAt']),
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
      'podPda': serializer.toJson<String>(podPda),
      'creator': serializer.toJson<String>(creator),
      'podId': serializer.toJson<int>(podId),
      'lamports': serializer.toJson<int>(lamports),
      'mode': serializer.toJson<int>(mode),
      'delaySeconds': serializer.toJson<int>(delaySeconds),
      'showMemo': serializer.toJson<bool>(showMemo),
      'escapeCode': serializer.toJson<String?>(escapeCode),
      'status': serializer.toJson<int>(status),
      'statusMsg': serializer.toJson<String?>(statusMsg),
      'location': serializer.toJson<String?>(location),
      'destination': serializer.toJson<String>(destination),
      'launchSig': serializer.toJson<String?>(launchSig),
      'lastSig': serializer.toJson<String?>(lastSig),
      'draftedAt': serializer.toJson<int>(draftedAt),
      'submittedAt': serializer.toJson<int?>(submittedAt),
      'finalizedAt': serializer.toJson<int?>(finalizedAt),
      'unsignedMessageB64': serializer.toJson<String?>(unsignedMessageB64),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  Pod copyWith({
    String? id,
    String? podPda,
    String? creator,
    int? podId,
    int? lamports,
    int? mode,
    int? delaySeconds,
    bool? showMemo,
    Value<String?> escapeCode = const Value.absent(),
    int? status,
    Value<String?> statusMsg = const Value.absent(),
    Value<String?> location = const Value.absent(),
    String? destination,
    Value<String?> launchSig = const Value.absent(),
    Value<String?> lastSig = const Value.absent(),
    int? draftedAt,
    Value<int?> submittedAt = const Value.absent(),
    Value<int?> finalizedAt = const Value.absent(),
    Value<String?> unsignedMessageB64 = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => Pod(
    id: id ?? this.id,
    podPda: podPda ?? this.podPda,
    creator: creator ?? this.creator,
    podId: podId ?? this.podId,
    lamports: lamports ?? this.lamports,
    mode: mode ?? this.mode,
    delaySeconds: delaySeconds ?? this.delaySeconds,
    showMemo: showMemo ?? this.showMemo,
    escapeCode: escapeCode.present ? escapeCode.value : this.escapeCode,
    status: status ?? this.status,
    statusMsg: statusMsg.present ? statusMsg.value : this.statusMsg,
    location: location.present ? location.value : this.location,
    destination: destination ?? this.destination,
    launchSig: launchSig.present ? launchSig.value : this.launchSig,
    lastSig: lastSig.present ? lastSig.value : this.lastSig,
    draftedAt: draftedAt ?? this.draftedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
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
      mode: data.mode.present ? data.mode.value : this.mode,
      delaySeconds: data.delaySeconds.present
          ? data.delaySeconds.value
          : this.delaySeconds,
      showMemo: data.showMemo.present ? data.showMemo.value : this.showMemo,
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
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
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
          ..write('mode: $mode, ')
          ..write('delaySeconds: $delaySeconds, ')
          ..write('showMemo: $showMemo, ')
          ..write('escapeCode: $escapeCode, ')
          ..write('status: $status, ')
          ..write('statusMsg: $statusMsg, ')
          ..write('location: $location, ')
          ..write('destination: $destination, ')
          ..write('launchSig: $launchSig, ')
          ..write('lastSig: $lastSig, ')
          ..write('draftedAt: $draftedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('unsignedMessageB64: $unsignedMessageB64, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podPda,
    creator,
    podId,
    lamports,
    mode,
    delaySeconds,
    showMemo,
    escapeCode,
    status,
    statusMsg,
    location,
    destination,
    launchSig,
    lastSig,
    draftedAt,
    submittedAt,
    finalizedAt,
    unsignedMessageB64,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pod &&
          other.id == this.id &&
          other.podPda == this.podPda &&
          other.creator == this.creator &&
          other.podId == this.podId &&
          other.lamports == this.lamports &&
          other.mode == this.mode &&
          other.delaySeconds == this.delaySeconds &&
          other.showMemo == this.showMemo &&
          other.escapeCode == this.escapeCode &&
          other.status == this.status &&
          other.statusMsg == this.statusMsg &&
          other.location == this.location &&
          other.destination == this.destination &&
          other.launchSig == this.launchSig &&
          other.lastSig == this.lastSig &&
          other.draftedAt == this.draftedAt &&
          other.submittedAt == this.submittedAt &&
          other.finalizedAt == this.finalizedAt &&
          other.unsignedMessageB64 == this.unsignedMessageB64 &&
          other.lastError == this.lastError);
}

class PodsCompanion extends UpdateCompanion<Pod> {
  final Value<String> id;
  final Value<String> podPda;
  final Value<String> creator;
  final Value<int> podId;
  final Value<int> lamports;
  final Value<int> mode;
  final Value<int> delaySeconds;
  final Value<bool> showMemo;
  final Value<String?> escapeCode;
  final Value<int> status;
  final Value<String?> statusMsg;
  final Value<String?> location;
  final Value<String> destination;
  final Value<String?> launchSig;
  final Value<String?> lastSig;
  final Value<int> draftedAt;
  final Value<int?> submittedAt;
  final Value<int?> finalizedAt;
  final Value<String?> unsignedMessageB64;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PodsCompanion({
    this.id = const Value.absent(),
    this.podPda = const Value.absent(),
    this.creator = const Value.absent(),
    this.podId = const Value.absent(),
    this.lamports = const Value.absent(),
    this.mode = const Value.absent(),
    this.delaySeconds = const Value.absent(),
    this.showMemo = const Value.absent(),
    this.escapeCode = const Value.absent(),
    this.status = const Value.absent(),
    this.statusMsg = const Value.absent(),
    this.location = const Value.absent(),
    this.destination = const Value.absent(),
    this.launchSig = const Value.absent(),
    this.lastSig = const Value.absent(),
    this.draftedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.unsignedMessageB64 = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodsCompanion.insert({
    required String id,
    required String podPda,
    required String creator,
    required int podId,
    required int lamports,
    required int mode,
    required int delaySeconds,
    this.showMemo = const Value.absent(),
    this.escapeCode = const Value.absent(),
    required int status,
    this.statusMsg = const Value.absent(),
    this.location = const Value.absent(),
    required String destination,
    this.launchSig = const Value.absent(),
    this.lastSig = const Value.absent(),
    required int draftedAt,
    this.submittedAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.unsignedMessageB64 = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       podPda = Value(podPda),
       creator = Value(creator),
       podId = Value(podId),
       lamports = Value(lamports),
       mode = Value(mode),
       delaySeconds = Value(delaySeconds),
       status = Value(status),
       destination = Value(destination),
       draftedAt = Value(draftedAt);
  static Insertable<Pod> custom({
    Expression<String>? id,
    Expression<String>? podPda,
    Expression<String>? creator,
    Expression<int>? podId,
    Expression<int>? lamports,
    Expression<int>? mode,
    Expression<int>? delaySeconds,
    Expression<bool>? showMemo,
    Expression<String>? escapeCode,
    Expression<int>? status,
    Expression<String>? statusMsg,
    Expression<String>? location,
    Expression<String>? destination,
    Expression<String>? launchSig,
    Expression<String>? lastSig,
    Expression<int>? draftedAt,
    Expression<int>? submittedAt,
    Expression<int>? finalizedAt,
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
      if (mode != null) 'mode': mode,
      if (delaySeconds != null) 'delay_seconds': delaySeconds,
      if (showMemo != null) 'show_memo': showMemo,
      if (escapeCode != null) 'escape_code': escapeCode,
      if (status != null) 'status': status,
      if (statusMsg != null) 'status_msg': statusMsg,
      if (location != null) 'location': location,
      if (destination != null) 'destination': destination,
      if (launchSig != null) 'launch_sig': launchSig,
      if (lastSig != null) 'last_sig': lastSig,
      if (draftedAt != null) 'drafted_at': draftedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (unsignedMessageB64 != null)
        'unsigned_message_b64': unsignedMessageB64,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodsCompanion copyWith({
    Value<String>? id,
    Value<String>? podPda,
    Value<String>? creator,
    Value<int>? podId,
    Value<int>? lamports,
    Value<int>? mode,
    Value<int>? delaySeconds,
    Value<bool>? showMemo,
    Value<String?>? escapeCode,
    Value<int>? status,
    Value<String?>? statusMsg,
    Value<String?>? location,
    Value<String>? destination,
    Value<String?>? launchSig,
    Value<String?>? lastSig,
    Value<int>? draftedAt,
    Value<int?>? submittedAt,
    Value<int?>? finalizedAt,
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
      mode: mode ?? this.mode,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      showMemo: showMemo ?? this.showMemo,
      escapeCode: escapeCode ?? this.escapeCode,
      status: status ?? this.status,
      statusMsg: statusMsg ?? this.statusMsg,
      location: location ?? this.location,
      destination: destination ?? this.destination,
      launchSig: launchSig ?? this.launchSig,
      lastSig: lastSig ?? this.lastSig,
      draftedAt: draftedAt ?? this.draftedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
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
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (delaySeconds.present) {
      map['delay_seconds'] = Variable<int>(delaySeconds.value);
    }
    if (showMemo.present) {
      map['show_memo'] = Variable<bool>(showMemo.value);
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
    if (submittedAt.present) {
      map['submitted_at'] = Variable<int>(submittedAt.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<int>(finalizedAt.value);
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
          ..write('mode: $mode, ')
          ..write('delaySeconds: $delaySeconds, ')
          ..write('showMemo: $showMemo, ')
          ..write('escapeCode: $escapeCode, ')
          ..write('status: $status, ')
          ..write('statusMsg: $statusMsg, ')
          ..write('location: $location, ')
          ..write('destination: $destination, ')
          ..write('launchSig: $launchSig, ')
          ..write('lastSig: $lastSig, ')
          ..write('draftedAt: $draftedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('unsignedMessageB64: $unsignedMessageB64, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $PodsTable pods = $PodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pods];
}

typedef $$PodsTableCreateCompanionBuilder =
    PodsCompanion Function({
      required String id,
      required String podPda,
      required String creator,
      required int podId,
      required int lamports,
      required int mode,
      required int delaySeconds,
      Value<bool> showMemo,
      Value<String?> escapeCode,
      required int status,
      Value<String?> statusMsg,
      Value<String?> location,
      required String destination,
      Value<String?> launchSig,
      Value<String?> lastSig,
      required int draftedAt,
      Value<int?> submittedAt,
      Value<int?> finalizedAt,
      Value<String?> unsignedMessageB64,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$PodsTableUpdateCompanionBuilder =
    PodsCompanion Function({
      Value<String> id,
      Value<String> podPda,
      Value<String> creator,
      Value<int> podId,
      Value<int> lamports,
      Value<int> mode,
      Value<int> delaySeconds,
      Value<bool> showMemo,
      Value<String?> escapeCode,
      Value<int> status,
      Value<String?> statusMsg,
      Value<String?> location,
      Value<String> destination,
      Value<String?> launchSig,
      Value<String?> lastSig,
      Value<int> draftedAt,
      Value<int?> submittedAt,
      Value<int?> finalizedAt,
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

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showMemo => $composableBuilder(
    column: $table.showMemo,
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

  ColumnFilters<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
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

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showMemo => $composableBuilder(
    column: $table.showMemo,
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

  ColumnOrderings<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
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

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get delaySeconds => $composableBuilder(
    column: $table.delaySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showMemo =>
      $composableBuilder(column: $table.showMemo, builder: (column) => column);

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

  GeneratedColumn<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
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
                Value<String> podPda = const Value.absent(),
                Value<String> creator = const Value.absent(),
                Value<int> podId = const Value.absent(),
                Value<int> lamports = const Value.absent(),
                Value<int> mode = const Value.absent(),
                Value<int> delaySeconds = const Value.absent(),
                Value<bool> showMemo = const Value.absent(),
                Value<String?> escapeCode = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> statusMsg = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String?> launchSig = const Value.absent(),
                Value<String?> lastSig = const Value.absent(),
                Value<int> draftedAt = const Value.absent(),
                Value<int?> submittedAt = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<String?> unsignedMessageB64 = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodsCompanion(
                id: id,
                podPda: podPda,
                creator: creator,
                podId: podId,
                lamports: lamports,
                mode: mode,
                delaySeconds: delaySeconds,
                showMemo: showMemo,
                escapeCode: escapeCode,
                status: status,
                statusMsg: statusMsg,
                location: location,
                destination: destination,
                launchSig: launchSig,
                lastSig: lastSig,
                draftedAt: draftedAt,
                submittedAt: submittedAt,
                finalizedAt: finalizedAt,
                unsignedMessageB64: unsignedMessageB64,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String podPda,
                required String creator,
                required int podId,
                required int lamports,
                required int mode,
                required int delaySeconds,
                Value<bool> showMemo = const Value.absent(),
                Value<String?> escapeCode = const Value.absent(),
                required int status,
                Value<String?> statusMsg = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required String destination,
                Value<String?> launchSig = const Value.absent(),
                Value<String?> lastSig = const Value.absent(),
                required int draftedAt,
                Value<int?> submittedAt = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<String?> unsignedMessageB64 = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodsCompanion.insert(
                id: id,
                podPda: podPda,
                creator: creator,
                podId: podId,
                lamports: lamports,
                mode: mode,
                delaySeconds: delaySeconds,
                showMemo: showMemo,
                escapeCode: escapeCode,
                status: status,
                statusMsg: statusMsg,
                location: location,
                destination: destination,
                launchSig: launchSig,
                lastSig: lastSig,
                draftedAt: draftedAt,
                submittedAt: submittedAt,
                finalizedAt: finalizedAt,
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

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$PodsTableTableManager get pods => $$PodsTableTableManager(_db, _db.pods);
}
