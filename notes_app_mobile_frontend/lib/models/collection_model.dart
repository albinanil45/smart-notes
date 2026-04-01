class CollectionModel {
  final String? id; // MongoDB _id
  final String userId;
  final String name;
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CollectionModel({
    this.id,
    required this.userId,
    required this.name,
    this.color = "",
    this.createdAt,
    this.updatedAt,
  });

  // ✅ Convert JSON → Dart Object
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      color: json['color'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // ✅ Convert Dart Object → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'name': name,
      'color': color,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ✅ CopyWith (very useful for state updates)
  CollectionModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
