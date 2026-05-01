class LoginResponse {
  final int status;
  final LoginData data;

  LoginResponse({required this.status, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final AuthTicket authTicket;
  final User user;

  LoginData({required this.authTicket, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      authTicket: AuthTicket.fromJson(json['authTicket']),
      user: User.fromJson(json['user']),
    );
  }
}

class AuthTicket {
  final String token;
  final int expires;
  final int duration;

  AuthTicket({
    required this.token,
    required this.expires,
    required this.duration,
  });

  factory AuthTicket.fromJson(Map<String, dynamic> json) {
    return AuthTicket(
      token: json['token'],
      expires: json['expires'],
      duration: json['duration'],
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
}
