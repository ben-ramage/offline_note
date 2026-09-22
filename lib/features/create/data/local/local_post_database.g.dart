// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_post_database.dart';

// ignore_for_file: type=lint
class $LocalPostsTable extends LocalPosts
    with TableInfo<$LocalPostsTable, LocalPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paragraphMeta = const VerificationMeta(
    'paragraph',
  );
  @override
  late final GeneratedColumn<String> paragraph = GeneratedColumn<String>(
    'paragraph',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageStoragePathMeta = const VerificationMeta(
    'imageStoragePath',
  );
  @override
  late final GeneratedColumn<String> imageStoragePath = GeneratedColumn<String>(
    'image_storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localImageBytesMeta = const VerificationMeta(
    'localImageBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> localImageBytes =
      GeneratedColumn<Uint8List>(
        'local_image_bytes',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDraftMeta = const VerificationMeta(
    'isDraft',
  );
  @override
  late final GeneratedColumn<bool> isDraft = GeneratedColumn<bool>(
    'is_draft',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_draft" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _draftDateMeta = const VerificationMeta(
    'draftDate',
  );
  @override
  late final GeneratedColumn<DateTime> draftDate = GeneratedColumn<DateTime>(
    'draft_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingActionMeta = const VerificationMeta(
    'pendingAction',
  );
  @override
  late final GeneratedColumn<String> pendingAction = GeneratedColumn<String>(
    'pending_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    paragraph,
    imageUrl,
    imageStoragePath,
    localImagePath,
    localImageBytes,
    createdAt,
    updatedAt,
    isDraft,
    draftDate,
    syncState,
    pendingAction,
    lastSyncError,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('paragraph')) {
      context.handle(
        _paragraphMeta,
        paragraph.isAcceptableOrUnknown(data['paragraph']!, _paragraphMeta),
      );
    } else if (isInserting) {
      context.missing(_paragraphMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('image_storage_path')) {
      context.handle(
        _imageStoragePathMeta,
        imageStoragePath.isAcceptableOrUnknown(
          data['image_storage_path']!,
          _imageStoragePathMeta,
        ),
      );
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('local_image_bytes')) {
      context.handle(
        _localImageBytesMeta,
        localImageBytes.isAcceptableOrUnknown(
          data['local_image_bytes']!,
          _localImageBytesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_draft')) {
      context.handle(
        _isDraftMeta,
        isDraft.isAcceptableOrUnknown(data['is_draft']!, _isDraftMeta),
      );
    }
    if (data.containsKey('draft_date')) {
      context.handle(
        _draftDateMeta,
        draftDate.isAcceptableOrUnknown(data['draft_date']!, _draftDateMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('pending_action')) {
      context.handle(
        _pendingActionMeta,
        pendingAction.isAcceptableOrUnknown(
          data['pending_action']!,
          _pendingActionMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      paragraph: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paragraph'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      imageStoragePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_storage_path'],
      ),
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      localImageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}local_image_bytes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      isDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_draft'],
      )!,
      draftDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}draft_date'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      ),
      pendingAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_action'],
      ),
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LocalPostsTable createAlias(String alias) {
    return $LocalPostsTable(attachedDatabase, alias);
  }
}

class LocalPost extends DataClass implements Insertable<LocalPost> {
  final String id;
  final String userId;
  final String title;
  final String paragraph;
  final String? imageUrl;
  final String? imageStoragePath;
  final String? localImagePath;
  final Uint8List? localImageBytes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDraft;
  final DateTime? draftDate;
  final String? syncState;
  final String? pendingAction;
  final String? lastSyncError;
  final bool isDeleted;
  const LocalPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.paragraph,
    this.imageUrl,
    this.imageStoragePath,
    this.localImagePath,
    this.localImageBytes,
    required this.createdAt,
    this.updatedAt,
    required this.isDraft,
    this.draftDate,
    this.syncState,
    this.pendingAction,
    this.lastSyncError,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['paragraph'] = Variable<String>(paragraph);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || imageStoragePath != null) {
      map['image_storage_path'] = Variable<String>(imageStoragePath);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || localImageBytes != null) {
      map['local_image_bytes'] = Variable<Uint8List>(localImageBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_draft'] = Variable<bool>(isDraft);
    if (!nullToAbsent || draftDate != null) {
      map['draft_date'] = Variable<DateTime>(draftDate);
    }
    if (!nullToAbsent || syncState != null) {
      map['sync_state'] = Variable<String>(syncState);
    }
    if (!nullToAbsent || pendingAction != null) {
      map['pending_action'] = Variable<String>(pendingAction);
    }
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LocalPostsCompanion toCompanion(bool nullToAbsent) {
    return LocalPostsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      paragraph: Value(paragraph),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      imageStoragePath: imageStoragePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageStoragePath),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      localImageBytes: localImageBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(localImageBytes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDraft: Value(isDraft),
      draftDate: draftDate == null && nullToAbsent
          ? const Value.absent()
          : Value(draftDate),
      syncState: syncState == null && nullToAbsent
          ? const Value.absent()
          : Value(syncState),
      pendingAction: pendingAction == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingAction),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      isDeleted: Value(isDeleted),
    );
  }

  factory LocalPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPost(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      paragraph: serializer.fromJson<String>(json['paragraph']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      imageStoragePath: serializer.fromJson<String?>(json['imageStoragePath']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      localImageBytes: serializer.fromJson<Uint8List?>(json['localImageBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDraft: serializer.fromJson<bool>(json['isDraft']),
      draftDate: serializer.fromJson<DateTime?>(json['draftDate']),
      syncState: serializer.fromJson<String?>(json['syncState']),
      pendingAction: serializer.fromJson<String?>(json['pendingAction']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'paragraph': serializer.toJson<String>(paragraph),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'imageStoragePath': serializer.toJson<String?>(imageStoragePath),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'localImageBytes': serializer.toJson<Uint8List?>(localImageBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDraft': serializer.toJson<bool>(isDraft),
      'draftDate': serializer.toJson<DateTime?>(draftDate),
      'syncState': serializer.toJson<String?>(syncState),
      'pendingAction': serializer.toJson<String?>(pendingAction),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LocalPost copyWith({
    String? id,
    String? userId,
    String? title,
    String? paragraph,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> imageStoragePath = const Value.absent(),
    Value<String?> localImagePath = const Value.absent(),
    Value<Uint8List?> localImageBytes = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    bool? isDraft,
    Value<DateTime?> draftDate = const Value.absent(),
    Value<String?> syncState = const Value.absent(),
    Value<String?> pendingAction = const Value.absent(),
    Value<String?> lastSyncError = const Value.absent(),
    bool? isDeleted,
  }) => LocalPost(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    paragraph: paragraph ?? this.paragraph,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    imageStoragePath: imageStoragePath.present
        ? imageStoragePath.value
        : this.imageStoragePath,
    localImagePath: localImagePath.present
        ? localImagePath.value
        : this.localImagePath,
    localImageBytes: localImageBytes.present
        ? localImageBytes.value
        : this.localImageBytes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isDraft: isDraft ?? this.isDraft,
    draftDate: draftDate.present ? draftDate.value : this.draftDate,
    syncState: syncState.present ? syncState.value : this.syncState,
    pendingAction: pendingAction.present
        ? pendingAction.value
        : this.pendingAction,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LocalPost copyWithCompanion(LocalPostsCompanion data) {
    return LocalPost(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      paragraph: data.paragraph.present ? data.paragraph.value : this.paragraph,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imageStoragePath: data.imageStoragePath.present
          ? data.imageStoragePath.value
          : this.imageStoragePath,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      localImageBytes: data.localImageBytes.present
          ? data.localImageBytes.value
          : this.localImageBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDraft: data.isDraft.present ? data.isDraft.value : this.isDraft,
      draftDate: data.draftDate.present ? data.draftDate.value : this.draftDate,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      pendingAction: data.pendingAction.present
          ? data.pendingAction.value
          : this.pendingAction,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPost(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('paragraph: $paragraph, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageStoragePath: $imageStoragePath, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('localImageBytes: $localImageBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDraft: $isDraft, ')
          ..write('draftDate: $draftDate, ')
          ..write('syncState: $syncState, ')
          ..write('pendingAction: $pendingAction, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    paragraph,
    imageUrl,
    imageStoragePath,
    localImagePath,
    $driftBlobEquality.hash(localImageBytes),
    createdAt,
    updatedAt,
    isDraft,
    draftDate,
    syncState,
    pendingAction,
    lastSyncError,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPost &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.paragraph == this.paragraph &&
          other.imageUrl == this.imageUrl &&
          other.imageStoragePath == this.imageStoragePath &&
          other.localImagePath == this.localImagePath &&
          $driftBlobEquality.equals(
            other.localImageBytes,
            this.localImageBytes,
          ) &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDraft == this.isDraft &&
          other.draftDate == this.draftDate &&
          other.syncState == this.syncState &&
          other.pendingAction == this.pendingAction &&
          other.lastSyncError == this.lastSyncError &&
          other.isDeleted == this.isDeleted);
}

class LocalPostsCompanion extends UpdateCompanion<LocalPost> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> paragraph;
  final Value<String?> imageUrl;
  final Value<String?> imageStoragePath;
  final Value<String?> localImagePath;
  final Value<Uint8List?> localImageBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isDraft;
  final Value<DateTime?> draftDate;
  final Value<String?> syncState;
  final Value<String?> pendingAction;
  final Value<String?> lastSyncError;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LocalPostsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.paragraph = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageStoragePath = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.localImageBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.draftDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.pendingAction = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPostsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required String paragraph,
    this.imageUrl = const Value.absent(),
    this.imageStoragePath = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.localImageBytes = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.draftDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.pendingAction = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       paragraph = Value(paragraph),
       createdAt = Value(createdAt);
  static Insertable<LocalPost> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? paragraph,
    Expression<String>? imageUrl,
    Expression<String>? imageStoragePath,
    Expression<String>? localImagePath,
    Expression<Uint8List>? localImageBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDraft,
    Expression<DateTime>? draftDate,
    Expression<String>? syncState,
    Expression<String>? pendingAction,
    Expression<String>? lastSyncError,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (paragraph != null) 'paragraph': paragraph,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageStoragePath != null) 'image_storage_path': imageStoragePath,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (localImageBytes != null) 'local_image_bytes': localImageBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDraft != null) 'is_draft': isDraft,
      if (draftDate != null) 'draft_date': draftDate,
      if (syncState != null) 'sync_state': syncState,
      if (pendingAction != null) 'pending_action': pendingAction,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPostsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? paragraph,
    Value<String?>? imageUrl,
    Value<String?>? imageStoragePath,
    Value<String?>? localImagePath,
    Value<Uint8List?>? localImageBytes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isDraft,
    Value<DateTime?>? draftDate,
    Value<String?>? syncState,
    Value<String?>? pendingAction,
    Value<String?>? lastSyncError,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LocalPostsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      paragraph: paragraph ?? this.paragraph,
      imageUrl: imageUrl ?? this.imageUrl,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      localImagePath: localImagePath ?? this.localImagePath,
      localImageBytes: localImageBytes ?? this.localImageBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDraft: isDraft ?? this.isDraft,
      draftDate: draftDate ?? this.draftDate,
      syncState: syncState ?? this.syncState,
      pendingAction: pendingAction ?? this.pendingAction,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (paragraph.present) {
      map['paragraph'] = Variable<String>(paragraph.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imageStoragePath.present) {
      map['image_storage_path'] = Variable<String>(imageStoragePath.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (localImageBytes.present) {
      map['local_image_bytes'] = Variable<Uint8List>(localImageBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDraft.present) {
      map['is_draft'] = Variable<bool>(isDraft.value);
    }
    if (draftDate.present) {
      map['draft_date'] = Variable<DateTime>(draftDate.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (pendingAction.present) {
      map['pending_action'] = Variable<String>(pendingAction.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPostsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('paragraph: $paragraph, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageStoragePath: $imageStoragePath, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('localImageBytes: $localImageBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDraft: $isDraft, ')
          ..write('draftDate: $draftDate, ')
          ..write('syncState: $syncState, ')
          ..write('pendingAction: $pendingAction, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalPostDatabase extends GeneratedDatabase {
  _$LocalPostDatabase(QueryExecutor e) : super(e);
  $LocalPostDatabaseManager get managers => $LocalPostDatabaseManager(this);
  late final $LocalPostsTable localPosts = $LocalPostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localPosts];
}

typedef $$LocalPostsTableCreateCompanionBuilder = LocalPostsCompanion Function({
  required String id,
  required String userId,
  required String title,
  required String paragraph,
  Value<String?> imageUrl,
  Value<String?> imageStoragePath,
  Value<String?> localImagePath,
  Value<Uint8List?> localImageBytes,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isDraft,
  Value<DateTime?> draftDate,
  Value<String?> syncState,
  Value<String?> pendingAction,
  Value<String?> lastSyncError,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$LocalPostsTableUpdateCompanionBuilder = LocalPostsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String> paragraph,
  Value<String?> imageUrl,
  Value<String?> imageStoragePath,
  Value<String?> localImagePath,
  Value<Uint8List?> localImageBytes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isDraft,
  Value<DateTime?> draftDate,
  Value<String?> syncState,
  Value<String?> pendingAction,
  Value<String?> lastSyncError,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$LocalPostsTableFilterComposer
    extends Composer<_$LocalPostDatabase, $LocalPostsTable> {
  $$LocalPostsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paragraph => $composableBuilder(
    column: $table.paragraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get localImageBytes => $composableBuilder(
    column: $table.localImageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDraft => $composableBuilder(
    column: $table.isDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get draftDate => $composableBuilder(
    column: $table.draftDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPostsTableOrderingComposer
    extends Composer<_$LocalPostDatabase, $LocalPostsTable> {
  $$LocalPostsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paragraph => $composableBuilder(
    column: $table.paragraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get localImageBytes => $composableBuilder(
    column: $table.localImageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDraft => $composableBuilder(
    column: $table.isDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get draftDate => $composableBuilder(
    column: $table.draftDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPostsTableAnnotationComposer
    extends Composer<_$LocalPostDatabase, $LocalPostsTable> {
  $$LocalPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get paragraph =>
      $composableBuilder(column: $table.paragraph, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get localImageBytes => $composableBuilder(
    column: $table.localImageBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDraft =>
      $composableBuilder(column: $table.isDraft, builder: (column) => column);

  GeneratedColumn<DateTime> get draftDate =>
      $composableBuilder(column: $table.draftDate, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get pendingAction => $composableBuilder(
    column: $table.pendingAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LocalPostsTableTableManager
    extends
        RootTableManager<
          _$LocalPostDatabase,
          $LocalPostsTable,
          LocalPost,
          $$LocalPostsTableFilterComposer,
          $$LocalPostsTableOrderingComposer,
          $$LocalPostsTableAnnotationComposer,
          $$LocalPostsTableCreateCompanionBuilder,
          $$LocalPostsTableUpdateCompanionBuilder,
          (
            LocalPost,
            BaseReferences<_$LocalPostDatabase, $LocalPostsTable, LocalPost>,
          ),
          LocalPost,
          PrefetchHooks Function()
        > {
  $$LocalPostsTableTableManager(_$LocalPostDatabase db, $LocalPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> paragraph = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageStoragePath = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<Uint8List?> localImageBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isDraft = const Value.absent(),
                Value<DateTime?> draftDate = const Value.absent(),
                Value<String?> syncState = const Value.absent(),
                Value<String?> pendingAction = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPostsCompanion(
                id: id,
                userId: userId,
                title: title,
                paragraph: paragraph,
                imageUrl: imageUrl,
                imageStoragePath: imageStoragePath,
                localImagePath: localImagePath,
                localImageBytes: localImageBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDraft: isDraft,
                draftDate: draftDate,
                syncState: syncState,
                pendingAction: pendingAction,
                lastSyncError: lastSyncError,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                required String paragraph,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageStoragePath = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<Uint8List?> localImageBytes = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isDraft = const Value.absent(),
                Value<DateTime?> draftDate = const Value.absent(),
                Value<String?> syncState = const Value.absent(),
                Value<String?> pendingAction = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPostsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                paragraph: paragraph,
                imageUrl: imageUrl,
                imageStoragePath: imageStoragePath,
                localImagePath: localImagePath,
                localImageBytes: localImageBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDraft: isDraft,
                draftDate: draftDate,
                syncState: syncState,
                pendingAction: pendingAction,
                lastSyncError: lastSyncError,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalPostsTable, LocalPost>(table),
                  BaseReferences<
                    _$LocalPostDatabase,
                    $LocalPostsTable,
                    LocalPost
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalPostDatabase,
      $LocalPostsTable,
      LocalPost,
      $$LocalPostsTableFilterComposer,
      $$LocalPostsTableOrderingComposer,
      $$LocalPostsTableAnnotationComposer,
      $$LocalPostsTableCreateCompanionBuilder,
      $$LocalPostsTableUpdateCompanionBuilder,
      (
        LocalPost,
        BaseReferences<_$LocalPostDatabase, $LocalPostsTable, LocalPost>,
      ),
      LocalPost,
      PrefetchHooks Function()
    >;

class $LocalPostDatabaseManager {
  final _$LocalPostDatabase _db;
  $LocalPostDatabaseManager(this._db);
  $$LocalPostsTableTableManager get localPosts =>
      $$LocalPostsTableTableManager(_db, _db.localPosts);
}
