/// Modelos de datos para los miembros de la casa
class HouseMemberInfo {
  final String id;
  final String nickname;
  final DateTime createdAt;
  final String status;
  final bool isCurrentUser;

  const HouseMemberInfo({
    required this.id,
    required this.nickname,
    required this.createdAt,
    required this.status,
    required this.isCurrentUser,
  });

  factory HouseMemberInfo.fromJson(Map<String, dynamic> json) {
    return HouseMemberInfo(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      status: json['status']?.toString() ?? 'ACTIVE',
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'isCurrentUser': isCurrentUser,
    };
  }
}

class CreateGuestRequest {
  final String guestName;

  const CreateGuestRequest({
    required this.guestName,
  });

  Map<String, dynamic> toJson() {
    return {
      'guestName': guestName,
    };
  }
}

class CreateGuestResponse {
  final String memberId;
  final String guestName;
  final String pinCode;
  final String houseCode;
  final DateTime createdAt;

  const CreateGuestResponse({
    required this.memberId,
    required this.guestName,
    required this.pinCode,
    required this.houseCode,
    required this.createdAt,
  });

  factory CreateGuestResponse.fromJson(Map<String, dynamic> json) {
    return CreateGuestResponse(
      memberId: json['memberId']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      houseCode: json['houseCode']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'guestName': guestName,
      'pinCode': pinCode,
      'houseCode': houseCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
