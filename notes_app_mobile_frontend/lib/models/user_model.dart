class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String userType;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.userType,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  // FROM JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      userType: json['userType'] ?? 'user',
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'isVerified': isVerified,
      'userType': userType,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
