class User {
  final String id;
  final String username;
  final String password;
  final String nickname;
  final String email;
  final String location;
  final int age;
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.nickname,
    required this.email,
    required this.location,
    required this.age,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'nickname': nickname,
    'email': email,
    'location': location,
    'age': age,
    'profileImage' : profileImage,
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
      profileImage: json['profileImage'],
    );
  }
}