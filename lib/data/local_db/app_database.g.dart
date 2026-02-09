// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('EUR'));
  static const VerificationMeta _initialBalanceMeta =
      const VerificationMeta('initialBalance');
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
      'initial_balance', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<int> currentBalance = GeneratedColumn<int>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        currency,
        initialBalance,
        currentBalance,
        createdAt,
        updatedAt,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
          _initialBalanceMeta,
          initialBalance.isAcceptableOrUnknown(
              data['initial_balance']!, _initialBalanceMeta));
    } else if (isInserting) {
      context.missing(_initialBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      initialBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}initial_balance'])!,
      currentBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_balance'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String type;
  final String currency;
  final int initialBalance;
  final int currentBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      required this.currency,
      required this.initialBalance,
      required this.currentBalance,
      required this.createdAt,
      required this.updatedAt,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    map['initial_balance'] = Variable<int>(initialBalance);
    map['current_balance'] = Variable<int>(currentBalance);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      currentBalance: serializer.fromJson<int>(json['currentBalance']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'currentBalance': serializer.toJson<int>(currentBalance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Account copyWith(
          {String? id,
          String? name,
          String? type,
          String? currency,
          int? initialBalance,
          int? currentBalance,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isActive}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        currency: currency ?? this.currency,
        initialBalance: initialBalance ?? this.initialBalance,
        currentBalance: currentBalance ?? this.currentBalance,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, currency, initialBalance,
      currentBalance, createdAt, updatedAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currency;
  final Value<int> initialBalance;
  final Value<int> currentBalance;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.currency = const Value.absent(),
    required int initialBalance,
    required int currentBalance,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        initialBalance = Value(initialBalance),
        currentBalance = Value(currentBalance),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<int>? initialBalance,
    Expression<int>? currentBalance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String>? currency,
      Value<int>? initialBalance,
      Value<int>? currentBalance,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<int>(currentBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChainEventsTable extends ChainEvents
    with TableInfo<$ChainEventsTable, ChainEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChainEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _previousHashMeta =
      const VerificationMeta('previousHash');
  @override
  late final GeneratedColumn<String> previousHash = GeneratedColumn<String>(
      'previous_hash', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 64, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sharerSignatureMeta =
      const VerificationMeta('sharerSignature');
  @override
  late final GeneratedColumn<String> sharerSignature = GeneratedColumn<String>(
      'sharer_signature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keeperSignatureMeta =
      const VerificationMeta('keeperSignature');
  @override
  late final GeneratedColumn<String> keeperSignature = GeneratedColumn<String>(
      'keeper_signature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataSourceMeta =
      const VerificationMeta('metadataSource');
  @override
  late final GeneratedColumn<String> metadataSource = GeneratedColumn<String>(
      'metadata_source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataTrustLevelMeta =
      const VerificationMeta('metadataTrustLevel');
  @override
  late final GeneratedColumn<int> metadataTrustLevel = GeneratedColumn<int>(
      'metadata_trust_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _metadataAiEngineMeta =
      const VerificationMeta('metadataAiEngine');
  @override
  late final GeneratedColumn<String> metadataAiEngine = GeneratedColumn<String>(
      'metadata_ai_engine', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 64, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        sequence,
        previousHash,
        timestamp,
        eventType,
        payload,
        sharerSignature,
        keeperSignature,
        metadataSource,
        metadataTrustLevel,
        metadataAiEngine,
        hash
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chain_events';
  @override
  VerificationContext validateIntegrity(Insertable<ChainEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    }
    if (data.containsKey('previous_hash')) {
      context.handle(
          _previousHashMeta,
          previousHash.isAcceptableOrUnknown(
              data['previous_hash']!, _previousHashMeta));
    } else if (isInserting) {
      context.missing(_previousHashMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('sharer_signature')) {
      context.handle(
          _sharerSignatureMeta,
          sharerSignature.isAcceptableOrUnknown(
              data['sharer_signature']!, _sharerSignatureMeta));
    }
    if (data.containsKey('keeper_signature')) {
      context.handle(
          _keeperSignatureMeta,
          keeperSignature.isAcceptableOrUnknown(
              data['keeper_signature']!, _keeperSignatureMeta));
    } else if (isInserting) {
      context.missing(_keeperSignatureMeta);
    }
    if (data.containsKey('metadata_source')) {
      context.handle(
          _metadataSourceMeta,
          metadataSource.isAcceptableOrUnknown(
              data['metadata_source']!, _metadataSourceMeta));
    } else if (isInserting) {
      context.missing(_metadataSourceMeta);
    }
    if (data.containsKey('metadata_trust_level')) {
      context.handle(
          _metadataTrustLevelMeta,
          metadataTrustLevel.isAcceptableOrUnknown(
              data['metadata_trust_level']!, _metadataTrustLevelMeta));
    } else if (isInserting) {
      context.missing(_metadataTrustLevelMeta);
    }
    if (data.containsKey('metadata_ai_engine')) {
      context.handle(
          _metadataAiEngineMeta,
          metadataAiEngine.isAcceptableOrUnknown(
              data['metadata_ai_engine']!, _metadataAiEngineMeta));
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  ChainEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChainEvent(
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      previousHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}previous_hash'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      sharerSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sharer_signature']),
      keeperSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}keeper_signature'])!,
      metadataSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}metadata_source'])!,
      metadataTrustLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}metadata_trust_level'])!,
      metadataAiEngine: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}metadata_ai_engine']),
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
    );
  }

  @override
  $ChainEventsTable createAlias(String alias) {
    return $ChainEventsTable(attachedDatabase, alias);
  }
}

class ChainEvent extends DataClass implements Insertable<ChainEvent> {
  final int sequence;
  final String previousHash;
  final DateTime timestamp;
  final String eventType;
  final String payload;
  final String? sharerSignature;
  final String keeperSignature;
  final String metadataSource;
  final int metadataTrustLevel;
  final String? metadataAiEngine;
  final String hash;
  const ChainEvent(
      {required this.sequence,
      required this.previousHash,
      required this.timestamp,
      required this.eventType,
      required this.payload,
      this.sharerSignature,
      required this.keeperSignature,
      required this.metadataSource,
      required this.metadataTrustLevel,
      this.metadataAiEngine,
      required this.hash});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['previous_hash'] = Variable<String>(previousHash);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['event_type'] = Variable<String>(eventType);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || sharerSignature != null) {
      map['sharer_signature'] = Variable<String>(sharerSignature);
    }
    map['keeper_signature'] = Variable<String>(keeperSignature);
    map['metadata_source'] = Variable<String>(metadataSource);
    map['metadata_trust_level'] = Variable<int>(metadataTrustLevel);
    if (!nullToAbsent || metadataAiEngine != null) {
      map['metadata_ai_engine'] = Variable<String>(metadataAiEngine);
    }
    map['hash'] = Variable<String>(hash);
    return map;
  }

  ChainEventsCompanion toCompanion(bool nullToAbsent) {
    return ChainEventsCompanion(
      sequence: Value(sequence),
      previousHash: Value(previousHash),
      timestamp: Value(timestamp),
      eventType: Value(eventType),
      payload: Value(payload),
      sharerSignature: sharerSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(sharerSignature),
      keeperSignature: Value(keeperSignature),
      metadataSource: Value(metadataSource),
      metadataTrustLevel: Value(metadataTrustLevel),
      metadataAiEngine: metadataAiEngine == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataAiEngine),
      hash: Value(hash),
    );
  }

  factory ChainEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChainEvent(
      sequence: serializer.fromJson<int>(json['sequence']),
      previousHash: serializer.fromJson<String>(json['previousHash']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payload: serializer.fromJson<String>(json['payload']),
      sharerSignature: serializer.fromJson<String?>(json['sharerSignature']),
      keeperSignature: serializer.fromJson<String>(json['keeperSignature']),
      metadataSource: serializer.fromJson<String>(json['metadataSource']),
      metadataTrustLevel: serializer.fromJson<int>(json['metadataTrustLevel']),
      metadataAiEngine: serializer.fromJson<String?>(json['metadataAiEngine']),
      hash: serializer.fromJson<String>(json['hash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'previousHash': serializer.toJson<String>(previousHash),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'eventType': serializer.toJson<String>(eventType),
      'payload': serializer.toJson<String>(payload),
      'sharerSignature': serializer.toJson<String?>(sharerSignature),
      'keeperSignature': serializer.toJson<String>(keeperSignature),
      'metadataSource': serializer.toJson<String>(metadataSource),
      'metadataTrustLevel': serializer.toJson<int>(metadataTrustLevel),
      'metadataAiEngine': serializer.toJson<String?>(metadataAiEngine),
      'hash': serializer.toJson<String>(hash),
    };
  }

  ChainEvent copyWith(
          {int? sequence,
          String? previousHash,
          DateTime? timestamp,
          String? eventType,
          String? payload,
          Value<String?> sharerSignature = const Value.absent(),
          String? keeperSignature,
          String? metadataSource,
          int? metadataTrustLevel,
          Value<String?> metadataAiEngine = const Value.absent(),
          String? hash}) =>
      ChainEvent(
        sequence: sequence ?? this.sequence,
        previousHash: previousHash ?? this.previousHash,
        timestamp: timestamp ?? this.timestamp,
        eventType: eventType ?? this.eventType,
        payload: payload ?? this.payload,
        sharerSignature: sharerSignature.present
            ? sharerSignature.value
            : this.sharerSignature,
        keeperSignature: keeperSignature ?? this.keeperSignature,
        metadataSource: metadataSource ?? this.metadataSource,
        metadataTrustLevel: metadataTrustLevel ?? this.metadataTrustLevel,
        metadataAiEngine: metadataAiEngine.present
            ? metadataAiEngine.value
            : this.metadataAiEngine,
        hash: hash ?? this.hash,
      );
  ChainEvent copyWithCompanion(ChainEventsCompanion data) {
    return ChainEvent(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      previousHash: data.previousHash.present
          ? data.previousHash.value
          : this.previousHash,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payload: data.payload.present ? data.payload.value : this.payload,
      sharerSignature: data.sharerSignature.present
          ? data.sharerSignature.value
          : this.sharerSignature,
      keeperSignature: data.keeperSignature.present
          ? data.keeperSignature.value
          : this.keeperSignature,
      metadataSource: data.metadataSource.present
          ? data.metadataSource.value
          : this.metadataSource,
      metadataTrustLevel: data.metadataTrustLevel.present
          ? data.metadataTrustLevel.value
          : this.metadataTrustLevel,
      metadataAiEngine: data.metadataAiEngine.present
          ? data.metadataAiEngine.value
          : this.metadataAiEngine,
      hash: data.hash.present ? data.hash.value : this.hash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChainEvent(')
          ..write('sequence: $sequence, ')
          ..write('previousHash: $previousHash, ')
          ..write('timestamp: $timestamp, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('sharerSignature: $sharerSignature, ')
          ..write('keeperSignature: $keeperSignature, ')
          ..write('metadataSource: $metadataSource, ')
          ..write('metadataTrustLevel: $metadataTrustLevel, ')
          ..write('metadataAiEngine: $metadataAiEngine, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      sequence,
      previousHash,
      timestamp,
      eventType,
      payload,
      sharerSignature,
      keeperSignature,
      metadataSource,
      metadataTrustLevel,
      metadataAiEngine,
      hash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChainEvent &&
          other.sequence == this.sequence &&
          other.previousHash == this.previousHash &&
          other.timestamp == this.timestamp &&
          other.eventType == this.eventType &&
          other.payload == this.payload &&
          other.sharerSignature == this.sharerSignature &&
          other.keeperSignature == this.keeperSignature &&
          other.metadataSource == this.metadataSource &&
          other.metadataTrustLevel == this.metadataTrustLevel &&
          other.metadataAiEngine == this.metadataAiEngine &&
          other.hash == this.hash);
}

class ChainEventsCompanion extends UpdateCompanion<ChainEvent> {
  final Value<int> sequence;
  final Value<String> previousHash;
  final Value<DateTime> timestamp;
  final Value<String> eventType;
  final Value<String> payload;
  final Value<String?> sharerSignature;
  final Value<String> keeperSignature;
  final Value<String> metadataSource;
  final Value<int> metadataTrustLevel;
  final Value<String?> metadataAiEngine;
  final Value<String> hash;
  const ChainEventsCompanion({
    this.sequence = const Value.absent(),
    this.previousHash = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payload = const Value.absent(),
    this.sharerSignature = const Value.absent(),
    this.keeperSignature = const Value.absent(),
    this.metadataSource = const Value.absent(),
    this.metadataTrustLevel = const Value.absent(),
    this.metadataAiEngine = const Value.absent(),
    this.hash = const Value.absent(),
  });
  ChainEventsCompanion.insert({
    this.sequence = const Value.absent(),
    required String previousHash,
    required DateTime timestamp,
    required String eventType,
    required String payload,
    this.sharerSignature = const Value.absent(),
    required String keeperSignature,
    required String metadataSource,
    required int metadataTrustLevel,
    this.metadataAiEngine = const Value.absent(),
    required String hash,
  })  : previousHash = Value(previousHash),
        timestamp = Value(timestamp),
        eventType = Value(eventType),
        payload = Value(payload),
        keeperSignature = Value(keeperSignature),
        metadataSource = Value(metadataSource),
        metadataTrustLevel = Value(metadataTrustLevel),
        hash = Value(hash);
  static Insertable<ChainEvent> custom({
    Expression<int>? sequence,
    Expression<String>? previousHash,
    Expression<DateTime>? timestamp,
    Expression<String>? eventType,
    Expression<String>? payload,
    Expression<String>? sharerSignature,
    Expression<String>? keeperSignature,
    Expression<String>? metadataSource,
    Expression<int>? metadataTrustLevel,
    Expression<String>? metadataAiEngine,
    Expression<String>? hash,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (previousHash != null) 'previous_hash': previousHash,
      if (timestamp != null) 'timestamp': timestamp,
      if (eventType != null) 'event_type': eventType,
      if (payload != null) 'payload': payload,
      if (sharerSignature != null) 'sharer_signature': sharerSignature,
      if (keeperSignature != null) 'keeper_signature': keeperSignature,
      if (metadataSource != null) 'metadata_source': metadataSource,
      if (metadataTrustLevel != null)
        'metadata_trust_level': metadataTrustLevel,
      if (metadataAiEngine != null) 'metadata_ai_engine': metadataAiEngine,
      if (hash != null) 'hash': hash,
    });
  }

  ChainEventsCompanion copyWith(
      {Value<int>? sequence,
      Value<String>? previousHash,
      Value<DateTime>? timestamp,
      Value<String>? eventType,
      Value<String>? payload,
      Value<String?>? sharerSignature,
      Value<String>? keeperSignature,
      Value<String>? metadataSource,
      Value<int>? metadataTrustLevel,
      Value<String?>? metadataAiEngine,
      Value<String>? hash}) {
    return ChainEventsCompanion(
      sequence: sequence ?? this.sequence,
      previousHash: previousHash ?? this.previousHash,
      timestamp: timestamp ?? this.timestamp,
      eventType: eventType ?? this.eventType,
      payload: payload ?? this.payload,
      sharerSignature: sharerSignature ?? this.sharerSignature,
      keeperSignature: keeperSignature ?? this.keeperSignature,
      metadataSource: metadataSource ?? this.metadataSource,
      metadataTrustLevel: metadataTrustLevel ?? this.metadataTrustLevel,
      metadataAiEngine: metadataAiEngine ?? this.metadataAiEngine,
      hash: hash ?? this.hash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (previousHash.present) {
      map['previous_hash'] = Variable<String>(previousHash.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (sharerSignature.present) {
      map['sharer_signature'] = Variable<String>(sharerSignature.value);
    }
    if (keeperSignature.present) {
      map['keeper_signature'] = Variable<String>(keeperSignature.value);
    }
    if (metadataSource.present) {
      map['metadata_source'] = Variable<String>(metadataSource.value);
    }
    if (metadataTrustLevel.present) {
      map['metadata_trust_level'] = Variable<int>(metadataTrustLevel.value);
    }
    if (metadataAiEngine.present) {
      map['metadata_ai_engine'] = Variable<String>(metadataAiEngine.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChainEventsCompanion(')
          ..write('sequence: $sequence, ')
          ..write('previousHash: $previousHash, ')
          ..write('timestamp: $timestamp, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('sharerSignature: $sharerSignature, ')
          ..write('keeperSignature: $keeperSignature, ')
          ..write('metadataSource: $metadataSource, ')
          ..write('metadataTrustLevel: $metadataTrustLevel, ')
          ..write('metadataAiEngine: $metadataAiEngine, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chainEventSequenceMeta =
      const VerificationMeta('chainEventSequence');
  @override
  late final GeneratedColumn<int> chainEventSequence = GeneratedColumn<int>(
      'chain_event_sequence', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chain_events (sequence)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumnWithTypeConverter<TransactionCategory, String>
      category = GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionCategory>(
              $TransactionsTable.$convertercategory);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiptImagePathMeta =
      const VerificationMeta('receiptImagePath');
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
      'receipt_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chainEventSequence,
        accountId,
        amount,
        description,
        merchant,
        category,
        date,
        notes,
        receiptImagePath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chain_event_sequence')) {
      context.handle(
          _chainEventSequenceMeta,
          chainEventSequence.isAcceptableOrUnknown(
              data['chain_event_sequence']!, _chainEventSequenceMeta));
    } else if (isInserting) {
      context.missing(_chainEventSequenceMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    }
    context.handle(_categoryMeta, const VerificationResult.success());
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
          _receiptImagePathMeta,
          receiptImagePath.isAcceptableOrUnknown(
              data['receipt_image_path']!, _receiptImagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chainEventSequence: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}chain_event_sequence'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant']),
      category: $TransactionsTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      receiptImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receipt_image_path']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<TransactionCategory, String> $convertercategory =
      const TransactionCategoryConverter();
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final int chainEventSequence;
  final String accountId;
  final int amount;
  final String description;
  final String? merchant;
  final TransactionCategory category;
  final DateTime date;
  final String? notes;
  final String? receiptImagePath;
  const Transaction(
      {required this.id,
      required this.chainEventSequence,
      required this.accountId,
      required this.amount,
      required this.description,
      this.merchant,
      required this.category,
      required this.date,
      this.notes,
      this.receiptImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chain_event_sequence'] = Variable<int>(chainEventSequence);
    map['account_id'] = Variable<String>(accountId);
    map['amount'] = Variable<int>(amount);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    {
      map['category'] = Variable<String>(
          $TransactionsTable.$convertercategory.toSql(category));
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      chainEventSequence: Value(chainEventSequence),
      accountId: Value(accountId),
      amount: Value(amount),
      description: Value(description),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      category: Value(category),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      chainEventSequence: serializer.fromJson<int>(json['chainEventSequence']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amount: serializer.fromJson<int>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      category: serializer.fromJson<TransactionCategory>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chainEventSequence': serializer.toJson<int>(chainEventSequence),
      'accountId': serializer.toJson<String>(accountId),
      'amount': serializer.toJson<int>(amount),
      'description': serializer.toJson<String>(description),
      'merchant': serializer.toJson<String?>(merchant),
      'category': serializer.toJson<TransactionCategory>(category),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
    };
  }

  Transaction copyWith(
          {String? id,
          int? chainEventSequence,
          String? accountId,
          int? amount,
          String? description,
          Value<String?> merchant = const Value.absent(),
          TransactionCategory? category,
          DateTime? date,
          Value<String?> notes = const Value.absent(),
          Value<String?> receiptImagePath = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        chainEventSequence: chainEventSequence ?? this.chainEventSequence,
        accountId: accountId ?? this.accountId,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        merchant: merchant.present ? merchant.value : this.merchant,
        category: category ?? this.category,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
        receiptImagePath: receiptImagePath.present
            ? receiptImagePath.value
            : this.receiptImagePath,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      chainEventSequence: data.chainEventSequence.present
          ? data.chainEventSequence.value
          : this.chainEventSequence,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('chainEventSequence: $chainEventSequence, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('receiptImagePath: $receiptImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chainEventSequence, accountId, amount,
      description, merchant, category, date, notes, receiptImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.chainEventSequence == this.chainEventSequence &&
          other.accountId == this.accountId &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.merchant == this.merchant &&
          other.category == this.category &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.receiptImagePath == this.receiptImagePath);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<int> chainEventSequence;
  final Value<String> accountId;
  final Value<int> amount;
  final Value<String> description;
  final Value<String?> merchant;
  final Value<TransactionCategory> category;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String?> receiptImagePath;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.chainEventSequence = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.merchant = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int chainEventSequence,
    required String accountId,
    required int amount,
    required String description,
    this.merchant = const Value.absent(),
    required TransactionCategory category,
    required DateTime date,
    this.notes = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chainEventSequence = Value(chainEventSequence),
        accountId = Value(accountId),
        amount = Value(amount),
        description = Value(description),
        category = Value(category),
        date = Value(date);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<int>? chainEventSequence,
    Expression<String>? accountId,
    Expression<int>? amount,
    Expression<String>? description,
    Expression<String>? merchant,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? receiptImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chainEventSequence != null)
        'chain_event_sequence': chainEventSequence,
      if (accountId != null) 'account_id': accountId,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (merchant != null) 'merchant': merchant,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<int>? chainEventSequence,
      Value<String>? accountId,
      Value<int>? amount,
      Value<String>? description,
      Value<String?>? merchant,
      Value<TransactionCategory>? category,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<String?>? receiptImagePath,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      chainEventSequence: chainEventSequence ?? this.chainEventSequence,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chainEventSequence.present) {
      map['chain_event_sequence'] = Variable<int>(chainEventSequence.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $TransactionsTable.$convertercategory.toSql(category.value));
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('chainEventSequence: $chainEventSequence, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxMessagesTable extends InboxMessages
    with TableInfo<$InboxMessagesTable, InboxMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMessageIdMeta =
      const VerificationMeta('emailMessageId');
  @override
  late final GeneratedColumn<String> emailMessageId = GeneratedColumn<String>(
      'email_message_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _senderEmailMeta =
      const VerificationMeta('senderEmail');
  @override
  late final GeneratedColumn<String> senderEmail = GeneratedColumn<String>(
      'sender_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bodyTextMeta =
      const VerificationMeta('bodyText');
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
      'body_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharerSignatureMeta =
      const VerificationMeta('sharerSignature');
  @override
  late final GeneratedColumn<String> sharerSignature = GeneratedColumn<String>(
      'sharer_signature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signatureValidMeta =
      const VerificationMeta('signatureValid');
  @override
  late final GeneratedColumn<bool> signatureValid = GeneratedColumn<bool>(
      'signature_valid', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("signature_valid" IN (0, 1))'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processedAtMeta =
      const VerificationMeta('processedAt');
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
      'processed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _linkedChainEventSequenceMeta =
      const VerificationMeta('linkedChainEventSequence');
  @override
  late final GeneratedColumn<int> linkedChainEventSequence =
      GeneratedColumn<int>('linked_chain_event_sequence', aliasedName, true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES chain_events (sequence)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        emailMessageId,
        receivedAt,
        senderEmail,
        subject,
        bodyText,
        sharerSignature,
        signatureValid,
        status,
        processedAt,
        linkedChainEventSequence
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_messages';
  @override
  VerificationContext validateIntegrity(Insertable<InboxMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email_message_id')) {
      context.handle(
          _emailMessageIdMeta,
          emailMessageId.isAcceptableOrUnknown(
              data['email_message_id']!, _emailMessageIdMeta));
    } else if (isInserting) {
      context.missing(_emailMessageIdMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('sender_email')) {
      context.handle(
          _senderEmailMeta,
          senderEmail.isAcceptableOrUnknown(
              data['sender_email']!, _senderEmailMeta));
    } else if (isInserting) {
      context.missing(_senderEmailMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('body_text')) {
      context.handle(_bodyTextMeta,
          bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta));
    }
    if (data.containsKey('sharer_signature')) {
      context.handle(
          _sharerSignatureMeta,
          sharerSignature.isAcceptableOrUnknown(
              data['sharer_signature']!, _sharerSignatureMeta));
    }
    if (data.containsKey('signature_valid')) {
      context.handle(
          _signatureValidMeta,
          signatureValid.isAcceptableOrUnknown(
              data['signature_valid']!, _signatureValidMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
          _processedAtMeta,
          processedAt.isAcceptableOrUnknown(
              data['processed_at']!, _processedAtMeta));
    }
    if (data.containsKey('linked_chain_event_sequence')) {
      context.handle(
          _linkedChainEventSequenceMeta,
          linkedChainEventSequence.isAcceptableOrUnknown(
              data['linked_chain_event_sequence']!,
              _linkedChainEventSequenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      emailMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}email_message_id'])!,
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at'])!,
      senderEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_email'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject']),
      bodyText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_text']),
      sharerSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sharer_signature']),
      signatureValid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}signature_valid']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      processedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}processed_at']),
      linkedChainEventSequence: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}linked_chain_event_sequence']),
    );
  }

  @override
  $InboxMessagesTable createAlias(String alias) {
    return $InboxMessagesTable(attachedDatabase, alias);
  }
}

class InboxMessage extends DataClass implements Insertable<InboxMessage> {
  final String id;
  final String emailMessageId;
  final DateTime receivedAt;
  final String senderEmail;
  final String? subject;
  final String? bodyText;
  final String? sharerSignature;
  final bool? signatureValid;
  final String status;
  final DateTime? processedAt;
  final int? linkedChainEventSequence;
  const InboxMessage(
      {required this.id,
      required this.emailMessageId,
      required this.receivedAt,
      required this.senderEmail,
      this.subject,
      this.bodyText,
      this.sharerSignature,
      this.signatureValid,
      required this.status,
      this.processedAt,
      this.linkedChainEventSequence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email_message_id'] = Variable<String>(emailMessageId);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['sender_email'] = Variable<String>(senderEmail);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || bodyText != null) {
      map['body_text'] = Variable<String>(bodyText);
    }
    if (!nullToAbsent || sharerSignature != null) {
      map['sharer_signature'] = Variable<String>(sharerSignature);
    }
    if (!nullToAbsent || signatureValid != null) {
      map['signature_valid'] = Variable<bool>(signatureValid);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    if (!nullToAbsent || linkedChainEventSequence != null) {
      map['linked_chain_event_sequence'] =
          Variable<int>(linkedChainEventSequence);
    }
    return map;
  }

  InboxMessagesCompanion toCompanion(bool nullToAbsent) {
    return InboxMessagesCompanion(
      id: Value(id),
      emailMessageId: Value(emailMessageId),
      receivedAt: Value(receivedAt),
      senderEmail: Value(senderEmail),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      bodyText: bodyText == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyText),
      sharerSignature: sharerSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(sharerSignature),
      signatureValid: signatureValid == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureValid),
      status: Value(status),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      linkedChainEventSequence: linkedChainEventSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedChainEventSequence),
    );
  }

  factory InboxMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxMessage(
      id: serializer.fromJson<String>(json['id']),
      emailMessageId: serializer.fromJson<String>(json['emailMessageId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      senderEmail: serializer.fromJson<String>(json['senderEmail']),
      subject: serializer.fromJson<String?>(json['subject']),
      bodyText: serializer.fromJson<String?>(json['bodyText']),
      sharerSignature: serializer.fromJson<String?>(json['sharerSignature']),
      signatureValid: serializer.fromJson<bool?>(json['signatureValid']),
      status: serializer.fromJson<String>(json['status']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      linkedChainEventSequence:
          serializer.fromJson<int?>(json['linkedChainEventSequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'emailMessageId': serializer.toJson<String>(emailMessageId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'senderEmail': serializer.toJson<String>(senderEmail),
      'subject': serializer.toJson<String?>(subject),
      'bodyText': serializer.toJson<String?>(bodyText),
      'sharerSignature': serializer.toJson<String?>(sharerSignature),
      'signatureValid': serializer.toJson<bool?>(signatureValid),
      'status': serializer.toJson<String>(status),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'linkedChainEventSequence':
          serializer.toJson<int?>(linkedChainEventSequence),
    };
  }

  InboxMessage copyWith(
          {String? id,
          String? emailMessageId,
          DateTime? receivedAt,
          String? senderEmail,
          Value<String?> subject = const Value.absent(),
          Value<String?> bodyText = const Value.absent(),
          Value<String?> sharerSignature = const Value.absent(),
          Value<bool?> signatureValid = const Value.absent(),
          String? status,
          Value<DateTime?> processedAt = const Value.absent(),
          Value<int?> linkedChainEventSequence = const Value.absent()}) =>
      InboxMessage(
        id: id ?? this.id,
        emailMessageId: emailMessageId ?? this.emailMessageId,
        receivedAt: receivedAt ?? this.receivedAt,
        senderEmail: senderEmail ?? this.senderEmail,
        subject: subject.present ? subject.value : this.subject,
        bodyText: bodyText.present ? bodyText.value : this.bodyText,
        sharerSignature: sharerSignature.present
            ? sharerSignature.value
            : this.sharerSignature,
        signatureValid:
            signatureValid.present ? signatureValid.value : this.signatureValid,
        status: status ?? this.status,
        processedAt: processedAt.present ? processedAt.value : this.processedAt,
        linkedChainEventSequence: linkedChainEventSequence.present
            ? linkedChainEventSequence.value
            : this.linkedChainEventSequence,
      );
  InboxMessage copyWithCompanion(InboxMessagesCompanion data) {
    return InboxMessage(
      id: data.id.present ? data.id.value : this.id,
      emailMessageId: data.emailMessageId.present
          ? data.emailMessageId.value
          : this.emailMessageId,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      senderEmail:
          data.senderEmail.present ? data.senderEmail.value : this.senderEmail,
      subject: data.subject.present ? data.subject.value : this.subject,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      sharerSignature: data.sharerSignature.present
          ? data.sharerSignature.value
          : this.sharerSignature,
      signatureValid: data.signatureValid.present
          ? data.signatureValid.value
          : this.signatureValid,
      status: data.status.present ? data.status.value : this.status,
      processedAt:
          data.processedAt.present ? data.processedAt.value : this.processedAt,
      linkedChainEventSequence: data.linkedChainEventSequence.present
          ? data.linkedChainEventSequence.value
          : this.linkedChainEventSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxMessage(')
          ..write('id: $id, ')
          ..write('emailMessageId: $emailMessageId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('senderEmail: $senderEmail, ')
          ..write('subject: $subject, ')
          ..write('bodyText: $bodyText, ')
          ..write('sharerSignature: $sharerSignature, ')
          ..write('signatureValid: $signatureValid, ')
          ..write('status: $status, ')
          ..write('processedAt: $processedAt, ')
          ..write('linkedChainEventSequence: $linkedChainEventSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      emailMessageId,
      receivedAt,
      senderEmail,
      subject,
      bodyText,
      sharerSignature,
      signatureValid,
      status,
      processedAt,
      linkedChainEventSequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxMessage &&
          other.id == this.id &&
          other.emailMessageId == this.emailMessageId &&
          other.receivedAt == this.receivedAt &&
          other.senderEmail == this.senderEmail &&
          other.subject == this.subject &&
          other.bodyText == this.bodyText &&
          other.sharerSignature == this.sharerSignature &&
          other.signatureValid == this.signatureValid &&
          other.status == this.status &&
          other.processedAt == this.processedAt &&
          other.linkedChainEventSequence == this.linkedChainEventSequence);
}

class InboxMessagesCompanion extends UpdateCompanion<InboxMessage> {
  final Value<String> id;
  final Value<String> emailMessageId;
  final Value<DateTime> receivedAt;
  final Value<String> senderEmail;
  final Value<String?> subject;
  final Value<String?> bodyText;
  final Value<String?> sharerSignature;
  final Value<bool?> signatureValid;
  final Value<String> status;
  final Value<DateTime?> processedAt;
  final Value<int?> linkedChainEventSequence;
  final Value<int> rowid;
  const InboxMessagesCompanion({
    this.id = const Value.absent(),
    this.emailMessageId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.senderEmail = const Value.absent(),
    this.subject = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.sharerSignature = const Value.absent(),
    this.signatureValid = const Value.absent(),
    this.status = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.linkedChainEventSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxMessagesCompanion.insert({
    required String id,
    required String emailMessageId,
    required DateTime receivedAt,
    required String senderEmail,
    this.subject = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.sharerSignature = const Value.absent(),
    this.signatureValid = const Value.absent(),
    required String status,
    this.processedAt = const Value.absent(),
    this.linkedChainEventSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        emailMessageId = Value(emailMessageId),
        receivedAt = Value(receivedAt),
        senderEmail = Value(senderEmail),
        status = Value(status);
  static Insertable<InboxMessage> custom({
    Expression<String>? id,
    Expression<String>? emailMessageId,
    Expression<DateTime>? receivedAt,
    Expression<String>? senderEmail,
    Expression<String>? subject,
    Expression<String>? bodyText,
    Expression<String>? sharerSignature,
    Expression<bool>? signatureValid,
    Expression<String>? status,
    Expression<DateTime>? processedAt,
    Expression<int>? linkedChainEventSequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emailMessageId != null) 'email_message_id': emailMessageId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (senderEmail != null) 'sender_email': senderEmail,
      if (subject != null) 'subject': subject,
      if (bodyText != null) 'body_text': bodyText,
      if (sharerSignature != null) 'sharer_signature': sharerSignature,
      if (signatureValid != null) 'signature_valid': signatureValid,
      if (status != null) 'status': status,
      if (processedAt != null) 'processed_at': processedAt,
      if (linkedChainEventSequence != null)
        'linked_chain_event_sequence': linkedChainEventSequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? emailMessageId,
      Value<DateTime>? receivedAt,
      Value<String>? senderEmail,
      Value<String?>? subject,
      Value<String?>? bodyText,
      Value<String?>? sharerSignature,
      Value<bool?>? signatureValid,
      Value<String>? status,
      Value<DateTime?>? processedAt,
      Value<int?>? linkedChainEventSequence,
      Value<int>? rowid}) {
    return InboxMessagesCompanion(
      id: id ?? this.id,
      emailMessageId: emailMessageId ?? this.emailMessageId,
      receivedAt: receivedAt ?? this.receivedAt,
      senderEmail: senderEmail ?? this.senderEmail,
      subject: subject ?? this.subject,
      bodyText: bodyText ?? this.bodyText,
      sharerSignature: sharerSignature ?? this.sharerSignature,
      signatureValid: signatureValid ?? this.signatureValid,
      status: status ?? this.status,
      processedAt: processedAt ?? this.processedAt,
      linkedChainEventSequence:
          linkedChainEventSequence ?? this.linkedChainEventSequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (emailMessageId.present) {
      map['email_message_id'] = Variable<String>(emailMessageId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (senderEmail.present) {
      map['sender_email'] = Variable<String>(senderEmail.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (sharerSignature.present) {
      map['sharer_signature'] = Variable<String>(sharerSignature.value);
    }
    if (signatureValid.present) {
      map['signature_valid'] = Variable<bool>(signatureValid.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (linkedChainEventSequence.present) {
      map['linked_chain_event_sequence'] =
          Variable<int>(linkedChainEventSequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxMessagesCompanion(')
          ..write('id: $id, ')
          ..write('emailMessageId: $emailMessageId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('senderEmail: $senderEmail, ')
          ..write('subject: $subject, ')
          ..write('bodyText: $bodyText, ')
          ..write('sharerSignature: $sharerSignature, ')
          ..write('signatureValid: $signatureValid, ')
          ..write('status: $status, ')
          ..write('processedAt: $processedAt, ')
          ..write('linkedChainEventSequence: $linkedChainEventSequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ChainEventsTable chainEvents = $ChainEventsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $InboxMessagesTable inboxMessages = $InboxMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [accounts, chainEvents, transactions, inboxMessages];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<String> currency,
  required int initialBalance,
  required int currentBalance,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> currency,
  Value<int> initialBalance,
  Value<int> currentBalance,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AccountsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AccountsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> initialBalance = const Value.absent(),
            Value<int> currentBalance = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            currency: currency,
            initialBalance: initialBalance,
            currentBalance: currentBalance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<String> currency = const Value.absent(),
            required int initialBalance,
            required int currentBalance,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            currency: currency,
            initialBalance: initialBalance,
            currentBalance: currentBalance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isActive: isActive,
            rowid: rowid,
          ),
        ));
}

class $$AccountsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get initialBalance => $state.composableBuilder(
      column: $state.table.initialBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentBalance => $state.composableBuilder(
      column: $state.table.currentBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter transactionsRefs(
      ComposableFilter Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.transactions,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder, parentComposers) =>
            $$TransactionsTableFilterComposer(ComposerState($state.db,
                $state.db.transactions, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get initialBalance => $state.composableBuilder(
      column: $state.table.initialBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentBalance => $state.composableBuilder(
      column: $state.table.currentBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChainEventsTableCreateCompanionBuilder = ChainEventsCompanion
    Function({
  Value<int> sequence,
  required String previousHash,
  required DateTime timestamp,
  required String eventType,
  required String payload,
  Value<String?> sharerSignature,
  required String keeperSignature,
  required String metadataSource,
  required int metadataTrustLevel,
  Value<String?> metadataAiEngine,
  required String hash,
});
typedef $$ChainEventsTableUpdateCompanionBuilder = ChainEventsCompanion
    Function({
  Value<int> sequence,
  Value<String> previousHash,
  Value<DateTime> timestamp,
  Value<String> eventType,
  Value<String> payload,
  Value<String?> sharerSignature,
  Value<String> keeperSignature,
  Value<String> metadataSource,
  Value<int> metadataTrustLevel,
  Value<String?> metadataAiEngine,
  Value<String> hash,
});

class $$ChainEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChainEventsTable,
    ChainEvent,
    $$ChainEventsTableFilterComposer,
    $$ChainEventsTableOrderingComposer,
    $$ChainEventsTableCreateCompanionBuilder,
    $$ChainEventsTableUpdateCompanionBuilder> {
  $$ChainEventsTableTableManager(_$AppDatabase db, $ChainEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChainEventsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChainEventsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> sequence = const Value.absent(),
            Value<String> previousHash = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String?> sharerSignature = const Value.absent(),
            Value<String> keeperSignature = const Value.absent(),
            Value<String> metadataSource = const Value.absent(),
            Value<int> metadataTrustLevel = const Value.absent(),
            Value<String?> metadataAiEngine = const Value.absent(),
            Value<String> hash = const Value.absent(),
          }) =>
              ChainEventsCompanion(
            sequence: sequence,
            previousHash: previousHash,
            timestamp: timestamp,
            eventType: eventType,
            payload: payload,
            sharerSignature: sharerSignature,
            keeperSignature: keeperSignature,
            metadataSource: metadataSource,
            metadataTrustLevel: metadataTrustLevel,
            metadataAiEngine: metadataAiEngine,
            hash: hash,
          ),
          createCompanionCallback: ({
            Value<int> sequence = const Value.absent(),
            required String previousHash,
            required DateTime timestamp,
            required String eventType,
            required String payload,
            Value<String?> sharerSignature = const Value.absent(),
            required String keeperSignature,
            required String metadataSource,
            required int metadataTrustLevel,
            Value<String?> metadataAiEngine = const Value.absent(),
            required String hash,
          }) =>
              ChainEventsCompanion.insert(
            sequence: sequence,
            previousHash: previousHash,
            timestamp: timestamp,
            eventType: eventType,
            payload: payload,
            sharerSignature: sharerSignature,
            keeperSignature: keeperSignature,
            metadataSource: metadataSource,
            metadataTrustLevel: metadataTrustLevel,
            metadataAiEngine: metadataAiEngine,
            hash: hash,
          ),
        ));
}

class $$ChainEventsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChainEventsTable> {
  $$ChainEventsTableFilterComposer(super.$state);
  ColumnFilters<int> get sequence => $state.composableBuilder(
      column: $state.table.sequence,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get previousHash => $state.composableBuilder(
      column: $state.table.previousHash,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sharerSignature => $state.composableBuilder(
      column: $state.table.sharerSignature,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get keeperSignature => $state.composableBuilder(
      column: $state.table.keeperSignature,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get metadataSource => $state.composableBuilder(
      column: $state.table.metadataSource,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get metadataTrustLevel => $state.composableBuilder(
      column: $state.table.metadataTrustLevel,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get metadataAiEngine => $state.composableBuilder(
      column: $state.table.metadataAiEngine,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get hash => $state.composableBuilder(
      column: $state.table.hash,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter transactionsRefs(
      ComposableFilter Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sequence,
        referencedTable: $state.db.transactions,
        getReferencedColumn: (t) => t.chainEventSequence,
        builder: (joinBuilder, parentComposers) =>
            $$TransactionsTableFilterComposer(ComposerState($state.db,
                $state.db.transactions, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter inboxMessagesRefs(
      ComposableFilter Function($$InboxMessagesTableFilterComposer f) f) {
    final $$InboxMessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sequence,
        referencedTable: $state.db.inboxMessages,
        getReferencedColumn: (t) => t.linkedChainEventSequence,
        builder: (joinBuilder, parentComposers) =>
            $$InboxMessagesTableFilterComposer(ComposerState($state.db,
                $state.db.inboxMessages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ChainEventsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChainEventsTable> {
  $$ChainEventsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get sequence => $state.composableBuilder(
      column: $state.table.sequence,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get previousHash => $state.composableBuilder(
      column: $state.table.previousHash,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sharerSignature => $state.composableBuilder(
      column: $state.table.sharerSignature,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get keeperSignature => $state.composableBuilder(
      column: $state.table.keeperSignature,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get metadataSource => $state.composableBuilder(
      column: $state.table.metadataSource,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get metadataTrustLevel => $state.composableBuilder(
      column: $state.table.metadataTrustLevel,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get metadataAiEngine => $state.composableBuilder(
      column: $state.table.metadataAiEngine,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hash => $state.composableBuilder(
      column: $state.table.hash,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required int chainEventSequence,
  required String accountId,
  required int amount,
  required String description,
  Value<String?> merchant,
  required TransactionCategory category,
  required DateTime date,
  Value<String?> notes,
  Value<String?> receiptImagePath,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<int> chainEventSequence,
  Value<String> accountId,
  Value<int> amount,
  Value<String> description,
  Value<String?> merchant,
  Value<TransactionCategory> category,
  Value<DateTime> date,
  Value<String?> notes,
  Value<String?> receiptImagePath,
  Value<int> rowid,
});

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TransactionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TransactionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> chainEventSequence = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> merchant = const Value.absent(),
            Value<TransactionCategory> category = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> receiptImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            chainEventSequence: chainEventSequence,
            accountId: accountId,
            amount: amount,
            description: description,
            merchant: merchant,
            category: category,
            date: date,
            notes: notes,
            receiptImagePath: receiptImagePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int chainEventSequence,
            required String accountId,
            required int amount,
            required String description,
            Value<String?> merchant = const Value.absent(),
            required TransactionCategory category,
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            Value<String?> receiptImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            chainEventSequence: chainEventSequence,
            accountId: accountId,
            amount: amount,
            description: description,
            merchant: merchant,
            category: category,
            date: date,
            notes: notes,
            receiptImagePath: receiptImagePath,
            rowid: rowid,
          ),
        ));
}

class $$TransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get merchant => $state.composableBuilder(
      column: $state.table.merchant,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<TransactionCategory, TransactionCategory,
          String>
      get category => $state.composableBuilder(
          column: $state.table.category,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get receiptImagePath => $state.composableBuilder(
      column: $state.table.receiptImagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ChainEventsTableFilterComposer get chainEventSequence {
    final $$ChainEventsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chainEventSequence,
        referencedTable: $state.db.chainEvents,
        getReferencedColumn: (t) => t.sequence,
        builder: (joinBuilder, parentComposers) =>
            $$ChainEventsTableFilterComposer(ComposerState($state.db,
                $state.db.chainEvents, joinBuilder, parentComposers)));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $state.db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AccountsTableFilterComposer(ComposerState(
                $state.db, $state.db.accounts, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get merchant => $state.composableBuilder(
      column: $state.table.merchant,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get receiptImagePath => $state.composableBuilder(
      column: $state.table.receiptImagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ChainEventsTableOrderingComposer get chainEventSequence {
    final $$ChainEventsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chainEventSequence,
        referencedTable: $state.db.chainEvents,
        getReferencedColumn: (t) => t.sequence,
        builder: (joinBuilder, parentComposers) =>
            $$ChainEventsTableOrderingComposer(ComposerState($state.db,
                $state.db.chainEvents, joinBuilder, parentComposers)));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $state.db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AccountsTableOrderingComposer(ComposerState(
                $state.db, $state.db.accounts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$InboxMessagesTableCreateCompanionBuilder = InboxMessagesCompanion
    Function({
  required String id,
  required String emailMessageId,
  required DateTime receivedAt,
  required String senderEmail,
  Value<String?> subject,
  Value<String?> bodyText,
  Value<String?> sharerSignature,
  Value<bool?> signatureValid,
  required String status,
  Value<DateTime?> processedAt,
  Value<int?> linkedChainEventSequence,
  Value<int> rowid,
});
typedef $$InboxMessagesTableUpdateCompanionBuilder = InboxMessagesCompanion
    Function({
  Value<String> id,
  Value<String> emailMessageId,
  Value<DateTime> receivedAt,
  Value<String> senderEmail,
  Value<String?> subject,
  Value<String?> bodyText,
  Value<String?> sharerSignature,
  Value<bool?> signatureValid,
  Value<String> status,
  Value<DateTime?> processedAt,
  Value<int?> linkedChainEventSequence,
  Value<int> rowid,
});

class $$InboxMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InboxMessagesTable,
    InboxMessage,
    $$InboxMessagesTableFilterComposer,
    $$InboxMessagesTableOrderingComposer,
    $$InboxMessagesTableCreateCompanionBuilder,
    $$InboxMessagesTableUpdateCompanionBuilder> {
  $$InboxMessagesTableTableManager(_$AppDatabase db, $InboxMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$InboxMessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$InboxMessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> emailMessageId = const Value.absent(),
            Value<DateTime> receivedAt = const Value.absent(),
            Value<String> senderEmail = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> sharerSignature = const Value.absent(),
            Value<bool?> signatureValid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int?> linkedChainEventSequence = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InboxMessagesCompanion(
            id: id,
            emailMessageId: emailMessageId,
            receivedAt: receivedAt,
            senderEmail: senderEmail,
            subject: subject,
            bodyText: bodyText,
            sharerSignature: sharerSignature,
            signatureValid: signatureValid,
            status: status,
            processedAt: processedAt,
            linkedChainEventSequence: linkedChainEventSequence,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String emailMessageId,
            required DateTime receivedAt,
            required String senderEmail,
            Value<String?> subject = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> sharerSignature = const Value.absent(),
            Value<bool?> signatureValid = const Value.absent(),
            required String status,
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int?> linkedChainEventSequence = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InboxMessagesCompanion.insert(
            id: id,
            emailMessageId: emailMessageId,
            receivedAt: receivedAt,
            senderEmail: senderEmail,
            subject: subject,
            bodyText: bodyText,
            sharerSignature: sharerSignature,
            signatureValid: signatureValid,
            status: status,
            processedAt: processedAt,
            linkedChainEventSequence: linkedChainEventSequence,
            rowid: rowid,
          ),
        ));
}

class $$InboxMessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emailMessageId => $state.composableBuilder(
      column: $state.table.emailMessageId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get receivedAt => $state.composableBuilder(
      column: $state.table.receivedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get senderEmail => $state.composableBuilder(
      column: $state.table.senderEmail,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subject => $state.composableBuilder(
      column: $state.table.subject,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bodyText => $state.composableBuilder(
      column: $state.table.bodyText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sharerSignature => $state.composableBuilder(
      column: $state.table.sharerSignature,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get signatureValid => $state.composableBuilder(
      column: $state.table.signatureValid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get processedAt => $state.composableBuilder(
      column: $state.table.processedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ChainEventsTableFilterComposer get linkedChainEventSequence {
    final $$ChainEventsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedChainEventSequence,
        referencedTable: $state.db.chainEvents,
        getReferencedColumn: (t) => t.sequence,
        builder: (joinBuilder, parentComposers) =>
            $$ChainEventsTableFilterComposer(ComposerState($state.db,
                $state.db.chainEvents, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$InboxMessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emailMessageId => $state.composableBuilder(
      column: $state.table.emailMessageId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get receivedAt => $state.composableBuilder(
      column: $state.table.receivedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get senderEmail => $state.composableBuilder(
      column: $state.table.senderEmail,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subject => $state.composableBuilder(
      column: $state.table.subject,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bodyText => $state.composableBuilder(
      column: $state.table.bodyText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sharerSignature => $state.composableBuilder(
      column: $state.table.sharerSignature,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get signatureValid => $state.composableBuilder(
      column: $state.table.signatureValid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get processedAt => $state.composableBuilder(
      column: $state.table.processedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ChainEventsTableOrderingComposer get linkedChainEventSequence {
    final $$ChainEventsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedChainEventSequence,
        referencedTable: $state.db.chainEvents,
        getReferencedColumn: (t) => t.sequence,
        builder: (joinBuilder, parentComposers) =>
            $$ChainEventsTableOrderingComposer(ComposerState($state.db,
                $state.db.chainEvents, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ChainEventsTableTableManager get chainEvents =>
      $$ChainEventsTableTableManager(_db, _db.chainEvents);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$InboxMessagesTableTableManager get inboxMessages =>
      $$InboxMessagesTableTableManager(_db, _db.inboxMessages);
}
