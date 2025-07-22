class UserModel {
  final String id;
  final String email;
  final String name;
  final String createdAt;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.photoUrl,
  });

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
    };
  }

  // Create User from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: json['createdAt'],
      photoUrl: json['photoUrl'],
    );
  }
} 