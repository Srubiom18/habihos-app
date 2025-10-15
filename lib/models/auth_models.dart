class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class GuestLoginRequest {
  final String guestName;
  final String houseCode;
  final String pinCode;

  GuestLoginRequest({
    required this.guestName,
    required this.houseCode,
    required this.pinCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'guestName': guestName,
      'houseCode': houseCode,
      'pinCode': pinCode,
    };
  }

  factory GuestLoginRequest.fromJson(Map<String, dynamic> json) {
    return GuestLoginRequest(
      guestName: json['guestName'] ?? '',
      houseCode: json['houseCode'] ?? '',
      pinCode: json['pinCode'] ?? '',
    );
  }
}

class JoinHouseRequest {
  final String houseCode;

  JoinHouseRequest({
    required this.houseCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'houseCode': houseCode,
    };
  }

  factory JoinHouseRequest.fromJson(Map<String, dynamic> json) {
    return JoinHouseRequest(
      houseCode: json['houseCode'] ?? '',
    );
  }
}

class JoinHouseResponse {
  final String message;
  final String updatedToken;

  JoinHouseResponse({
    required this.message,
    required this.updatedToken,
  });

  factory JoinHouseResponse.fromJson(Map<String, dynamic> json) {
    return JoinHouseResponse(
      message: json['message'] ?? '',
      updatedToken: json['updatedToken'] ?? '',
    );
  }
}

class LoginResponse {
  final String token;
  final UserInfo? userInfo;

  LoginResponse({
    required this.token,
    this.userInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userInfo: json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
    );
  }
}

class UserInfo {
  final String id;
  final String nickname;
  final List<String> roles;
  final List<String> permissions;

  UserInfo({
    required this.id,
    required this.nickname,
    required this.roles,
    required this.permissions,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'roles': roles,
      'permissions': permissions,
    };
  }
}

class JwtPayload {
  final String sub; // User ID
  final String nickname;
  final List<String> roles;
  final List<String> permissions;
  final String? houseId; // House ID (opcional)
  final int iat; // Issued at
  final int exp; // Expiration

  JwtPayload({
    required this.sub,
    required this.nickname,
    required this.roles,
    required this.permissions,
    this.houseId,
    required this.iat,
    required this.exp,
  });

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    return JwtPayload(
      sub: json['sub'] ?? '',
      nickname: json['nickname'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      houseId: json['houseId'] as String?,
      iat: json['iat'] ?? 0,
      exp: json['exp'] ?? 0,
    );
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp < now;
  }

  DateTime get expirationDate {
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }
}
