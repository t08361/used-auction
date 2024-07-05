// user.dart
class User {
  final String id;
  final String username;
  final String password;
  final String nickname;
  final String email;
  final String location;
  final int age;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.nickname,
    required this.email,
    required this.location,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'nickname': nickname,
    'email': email,
    'location': location,
    'age': age,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      nickname: json['nickname'],
      email: json['email'],
      location: json['location'],
      age: json['age'],
    );
  }
}