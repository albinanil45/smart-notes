class NoteModel {
  final String id;
  final String userId;
  final String? collectionId;
  final String title;
  final String content;
  final bool isPinnedGlobal;
  final bool isPinnedInCollection;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.userId,
    this.collectionId,
    this.title = '',
    this.content = '',
    this.isPinnedGlobal = false,
    this.isPinnedInCollection = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
    this.color = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      collectionId: json['collectionId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isPinnedGlobal: json['isPinnedGlobal'] ?? false,
      isPinnedInCollection: json['isPinnedInCollection'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      color: json['color'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'collectionId': collectionId,
      'title': title,
      'content': content,
      'isPinnedGlobal': isPinnedGlobal,
      'isPinnedInCollection': isPinnedInCollection,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NoteModel copyWith({
    String? id,
    String? userId,
    String? collectionId,
    bool clearCollectionId = false,
    String? title,
    String? content,
    bool? isPinnedGlobal,
    bool? isPinnedInCollection,
    bool? isArchived,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionId: clearCollectionId
          ? null
          : (collectionId ?? this.collectionId),
      title: title ?? this.title,
      content: content ?? this.content,
      isPinnedGlobal: isPinnedGlobal ?? this.isPinnedGlobal,
      isPinnedInCollection: isPinnedInCollection ?? this.isPinnedInCollection,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
