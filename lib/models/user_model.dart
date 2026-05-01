class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // user | provider | admin

  UserModel({required this.uid, required this.name, required this.email, this.role = 'user'});

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
      };
}
