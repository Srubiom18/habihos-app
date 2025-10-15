import 'dart:convert';
import '../models/auth_models.dart';

class JwtService {
  static JwtPayload? decodeToken(String token) {
    try {
      // Dividir el token JWT en sus partes
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }

      // Decodificar el payload (segunda parte)
      final payload = parts[1];
      
      // Agregar padding si es necesario
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      
      // Parsear el JSON
      final Map<String, dynamic> payloadMap = json.decode(resp);
      
      return JwtPayload.fromJson(payloadMap);
    } catch (e) {
      print('Error decodificando JWT: $e');
      return null;
    }
  }

  static bool isTokenValid(String token) {
    final payload = decodeToken(token);
    if (payload == null) return false;
    
    return !payload.isExpired;
  }

  static String? getUserId(String token) {
    final payload = decodeToken(token);
    return payload?.sub;
  }

  static String? getUserNickname(String token) {
    final payload = decodeToken(token);
    return payload?.nickname;
  }

  static List<String> getUserRoles(String token) {
    final payload = decodeToken(token);
    return payload?.roles ?? [];
  }

  static List<String> getUserPermissions(String token) {
    final payload = decodeToken(token);
    return payload?.permissions ?? [];
  }

  static DateTime? getTokenExpiration(String token) {
    final payload = decodeToken(token);
    return payload?.expirationDate;
  }

  static String? getHouseId(String token) {
    final payload = decodeToken(token);
    return payload?.houseId;
  }

  static bool hasActiveHouse(String token) {
    final houseId = getHouseId(token);
    return houseId != null && houseId.isNotEmpty;
  }
}
