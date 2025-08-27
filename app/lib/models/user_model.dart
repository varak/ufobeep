class UserModel {
  final String id;
  final String? email;
  final String? username;
  final String? phone;

  UserModel({
    required this.id,
    this.email,
    this.username,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] as String?,
        username: json['username'] as String?,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'phone': phone,
      };
}