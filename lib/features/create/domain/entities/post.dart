import 'dart:typed_data';

const Object _unset = Object();

class Post {
  final String id;
  final String userId;

  final String title;
  final String paragraph;

  // Image
  final String? imageUrl;
  final String? imageStoragePath;
  final String? localImagePath;
  final Uint8List? localImageBytes;

  // Dates
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Draft
  final bool isDraft;
  final DateTime? draftDate;

  // Sync
  final String? syncState;
  final String? pendingAction;
  final String? lastSyncError;

  // Deletion
  final bool isDeleted;

  Post({
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

  static DateTime _dateFromJson(Object? value, {DateTime? fallback}) {
    if (value is DateTime) return value;

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }

    return fallback ?? DateTime.now();
  }

  static DateTime? _nullableDateFromJson(Object? value) {
    if (value is DateTime) return value;

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      paragraph: json['paragraph'] as String,
      imageUrl: json['imageUrl'] as String?,

      imageStoragePath: json['imageStoragePath'] as String?,
      localImagePath: json['localImagePath'] as String?,
      localImageBytes: json['localImageBytes'] as Uint8List?,

      createdAt: _dateFromJson(json['createdAt']),
      updatedAt: _nullableDateFromJson(json['updatedAt']),
      isDraft: json['isDraft'] as bool? ?? false,
      draftDate: _nullableDateFromJson(json['draftDate']),
      syncState: json['syncState'] as String?,

      pendingAction: json['pendingAction'] as String?,
      lastSyncError: json['lastSyncError'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'paragraph': paragraph,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'localImagePath': localImagePath,
      'localImageBytes': localImageBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDraft': isDraft,
      'draftDate': draftDate?.toIso8601String(),
      'syncState': syncState,
      'pendingAction': pendingAction,
      'lastSyncError': lastSyncError,
      'isDeleted': isDeleted,
    };
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'paragraph': paragraph,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? paragraph,
    String? imageUrl,
    Object? localImagePath = _unset,
    Object? localImageBytes = _unset,
    Object? imageStoragePath = _unset,
    DateTime? createdAt,
    Object? updatedAt = _unset,
    bool? isDraft,
    Object? draftDate = _unset,
    String? syncState,
    String? pendingAction,
    Object? lastSyncError = _unset,
    bool? isDeleted,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      paragraph: paragraph ?? this.paragraph,
      imageUrl: imageUrl ?? this.imageUrl,

      imageStoragePath: imageStoragePath == _unset
          ? this.imageStoragePath
          : imageStoragePath as String?,
      localImagePath: localImagePath == _unset
          ? this.localImagePath
          : localImagePath as String?,
      localImageBytes: localImageBytes == _unset
          ? this.localImageBytes
          : localImageBytes as Uint8List?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
      isDraft: isDraft ?? this.isDraft,

      draftDate: draftDate == _unset ? this.draftDate : draftDate as DateTime?,
      syncState: syncState ?? this.syncState,
      pendingAction: pendingAction ?? this.pendingAction,
      lastSyncError: lastSyncError == _unset
          ? this.lastSyncError
          : lastSyncError as String?,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
