class UserApp {
  List database = [];

  String email;
  String username;
  String password;

  UserApp({
    required this.email,
    required this.username,
    required this.password,
  });

  register(UserApp newUserApp) {
    database.add(newUserApp.toMap);
  }

  Map toMap(UserApp newUserApp) {
    return {
      'email': newUserApp.email,
      'username': newUserApp.username,
      'password': newUserApp.password,
    };
  }

  UserApp fromMap(Map userMap) {
    return UserApp(
      email: userMap['email'],
      username: userMap['username'],
      password: userMap['password'],
    );
  }

  Map newUser = {
    'email': 'karol@gmail.com',
    'username': 'karol',
    'password': '123456',
    'theme': 'dark',
  };
}
