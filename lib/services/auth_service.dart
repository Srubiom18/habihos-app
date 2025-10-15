import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart';
import 'jwt_service.dart';

/// Servicio principal de autenticación
/// 
/// Maneja todo el flujo de autenticación de la aplicación incluyendo
/// login, logout, verificación de tokens JWT, y gestión de sesiones.
/// Utiliza SharedPreferences para persistir datos de autenticación.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';

  /// Realiza el proceso de login del usuario
  /// 
  /// Envía las credenciales al servidor, procesa la respuesta JWT,
  /// decodifica la información del usuario y guarda los datos localmente.
  /// Maneja errores de conexión y credenciales inválidas.
  /// 
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// 
  /// Retorna [AuthResult] con el resultado de la operación
  static Future<AuthResult> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      
      final response = await http.post(
        Uri.parse(AppConfig.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginRequest.toJson()),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        // El endpoint devuelve directamente el token como string
        final token = response.body;
        
        // Decodificar el token para obtener la información del usuario
        final payload = JwtService.decodeToken(token);
        if (payload == null) {
          return AuthResult.error('Error procesando el token de autenticación');
        }

        // Crear objeto UserInfo desde el payload del JWT
        final userInfo = UserInfo(
          id: payload.sub,
          nickname: payload.nickname,
          roles: payload.roles,
          permissions: payload.permissions,
        );

        // Guardar token y información del usuario
        await _saveAuthData(token, userInfo);

        return AuthResult.success(token, userInfo);
      } else if (response.statusCode == 401) {
        return AuthResult.error('Credenciales incorrectas');
      } else if (response.statusCode == 400) {
        return AuthResult.error('Datos de login inválidos');
      } else {
        return AuthResult.error('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return AuthResult.error('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        return AuthResult.error('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        return AuthResult.error('Error de conexión: ${e.toString()}');
      }
    }
  }

  /// Realiza el proceso de unirse a una casa existente
  /// 
  /// Envía el código de la casa al servidor para unir al usuario autenticado,
  /// procesa la respuesta JWT actualizada con el houseId y guarda los datos localmente.
  /// Maneja errores de conexión y códigos inválidos.
  /// 
  /// [houseCode] - Código de la casa a la que unirse
  /// 
  /// Retorna [AuthResult] con el resultado de la operación
  static Future<AuthResult> joinHouse(String houseCode) async {
    try {
      // Obtener el token actual para la autenticación
      final currentToken = await getCurrentToken();
      if (currentToken == null) {
        return AuthResult.error('No hay sesión activa. Inicia sesión primero.');
      }

      final joinRequest = JoinHouseRequest(houseCode: houseCode);
      
      final response = await http.post(
        Uri.parse(AppConfig.joinHouseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
        body: json.encode(joinRequest.toJson()),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        // El endpoint devuelve JoinHouseResponse con message y updatedToken
        final responseData = json.decode(response.body);
        final joinResponse = JoinHouseResponse.fromJson(responseData);
        
        print('Join house response: ${joinResponse.message}');
        print('Updated token received: ${joinResponse.updatedToken.substring(0, 20)}...');
        
        // Actualizar el token con el nuevo token que incluye el houseId
        await updateToken(joinResponse.updatedToken);
        
        // Verificar que el token se guardó correctamente
        final savedToken = await getCurrentToken();
        print('Token saved successfully: ${savedToken?.substring(0, 20)}...');
        
        // Verificar si tiene casa activa
        final hasHouse = JwtService.hasActiveHouse(joinResponse.updatedToken);
        print('Has active house after join: $hasHouse');
        
        // Obtener la información del usuario actualizada
        final userInfo = await getCurrentUser();
        if (userInfo == null) {
          return AuthResult.error('Error obteniendo información del usuario');
        }

        return AuthResult.success(joinResponse.updatedToken, userInfo);
      } else if (response.statusCode == 401) {
        return AuthResult.error('Sesión expirada. Inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        return AuthResult.error('Código de casa inválido');
      } else if (response.statusCode == 404) {
        return AuthResult.error('Casa no encontrada con ese código');
      } else if (response.statusCode == 409) {
        return AuthResult.error('Ya eres miembro de esta casa');
      } else {
        return AuthResult.error('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return AuthResult.error('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        return AuthResult.error('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        return AuthResult.error('Error de conexión: ${e.toString()}');
      }
    }
  }

  /// Realiza el proceso de login de invitado
  /// 
  /// Envía las credenciales de invitado al servidor (nombre, código de casa y PIN),
  /// procesa la respuesta JWT, decodifica la información del usuario y guarda los datos localmente.
  /// Maneja errores de conexión y credenciales inválidas.
  /// 
  /// [guestName] - Nombre del invitado
  /// [houseCode] - Código de 6 caracteres de la casa
  /// [pinCode] - PIN de 6 dígitos del invitado
  /// 
  /// Retorna [AuthResult] con el resultado de la operación
  static Future<AuthResult> guestLogin(String guestName, String houseCode, String pinCode) async {
    try {
      final guestLoginRequest = GuestLoginRequest(
        guestName: guestName,
        houseCode: houseCode,
        pinCode: pinCode,
      );
      
      final response = await http.post(
        Uri.parse(AppConfig.guestLoginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(guestLoginRequest.toJson()),
      ).timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (response.statusCode == 200) {
        // El endpoint devuelve directamente el token como string
        final token = response.body;
        
        // Decodificar el token para obtener la información del usuario
        final payload = JwtService.decodeToken(token);
        if (payload == null) {
          return AuthResult.error('Error procesando el token de autenticación');
        }

        // Crear objeto UserInfo desde el payload del JWT
        final userInfo = UserInfo(
          id: payload.sub,
          nickname: payload.nickname,
          roles: payload.roles,
          permissions: payload.permissions,
        );

        // Guardar token y información del usuario
        await _saveAuthData(token, userInfo);

        return AuthResult.success(token, userInfo);
      } else if (response.statusCode == 401) {
        return AuthResult.error('Credenciales de invitado incorrectas');
      } else if (response.statusCode == 400) {
        return AuthResult.error('Datos de login de invitado inválidos');
      } else if (response.statusCode == 404) {
        return AuthResult.error('Casa o invitado no encontrado');
      } else {
        return AuthResult.error('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return AuthResult.error('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.toString().contains('SocketException')) {
        return AuthResult.error('No se puede conectar al servidor. Verifica que la API esté ejecutándose.');
      } else {
        return AuthResult.error('Error de conexión: ${e.toString()}');
      }
    }
  }

  /// Verifica si el usuario está autenticado
  /// 
  /// Comprueba si existe un token válido almacenado localmente
  /// y si no ha expirado. No realiza llamadas al servidor.
  /// 
  /// Retorna true si el usuario está autenticado, false en caso contrario
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    if (token == null) return false;
    
    return JwtService.isTokenValid(token);
  }

  /// Obtiene el token de autenticación actual
  /// 
  /// Recupera el token almacenado localmente y verifica su validez.
  /// Si el token ha expirado, automáticamente limpia la sesión.
  /// 
  /// Retorna el token válido o null si no hay sesión activa
  static Future<String?> getCurrentToken() async {
    final token = await _getToken();
    if (token == null) return null;
    
    if (JwtService.isTokenValid(token)) {
      return token;
    } else {
      await logout();
      return null;
    }
  }

  /// Obtiene la información del usuario actual
  /// 
  /// Decodifica el token JWT para extraer la información del usuario
  /// incluyendo ID, nickname, roles y permisos.
  /// 
  /// Retorna [UserInfo] con los datos del usuario o null si no hay sesión
  static Future<UserInfo?> getCurrentUser() async {
    final token = await getCurrentToken();
    if (token == null) return null;
    
    return JwtService.decodeToken(token) != null 
        ? UserInfo(
            id: JwtService.getUserId(token) ?? '',
            nickname: JwtService.getUserNickname(token) ?? '',
            roles: JwtService.getUserRoles(token),
            permissions: JwtService.getUserPermissions(token),
          )
        : null;
  }

  /// Verifica si el usuario tiene una casa activa
  /// 
  /// Comprueba si el token JWT contiene un houseId válido,
  /// lo que indica que el usuario está asociado a una casa.
  /// 
  /// Retorna true si tiene casa activa, false en caso contrario
  static Future<bool> hasActiveHouse() async {
    final token = await getCurrentToken();
    if (token == null) return false;
    
    return JwtService.hasActiveHouse(token);
  }

  /// Obtiene el ID de la casa actual del usuario
  /// 
  /// Extrae el houseId del token JWT si existe.
  /// 
  /// Retorna el ID de la casa o null si no hay casa asociada
  static Future<String?> getCurrentHouseId() async {
    final token = await getCurrentToken();
    if (token == null) return null;
    
    return JwtService.getHouseId(token);
  }

  /// Cierra la sesión del usuario
  /// 
  /// Limpia todos los datos de autenticación almacenados localmente.
  /// En una implementación completa, también debería notificar al servidor.
  static Future<void> logout() async {
    try {
      // Aquí podrías implementar una llamada al endpoint de logout si existe
      await _clearAuthData();
    } catch (e) {
      // Aún así intentamos limpiar los datos locales
      try {
        await _clearAuthData();
      } catch (e2) {
        // Error crítico al limpiar datos
        rethrow;
      }
    }
  }

  /// Actualiza el token de autenticación
  /// 
  /// Útil cuando se crea una nueva casa y el servidor devuelve
  /// un nuevo token con el houseId incluido. Valida el nuevo token
  /// y actualiza los datos almacenados localmente.
  /// 
  /// [newToken] - Nuevo token JWT con información actualizada
  static Future<void> updateToken(String newToken) async {
    final payload = JwtService.decodeToken(newToken);
    if (payload == null) {
      throw Exception('Token inválido');
    }

    // Crear objeto UserInfo desde el payload del JWT
    final userInfo = UserInfo(
      id: payload.sub,
      nickname: payload.nickname,
      roles: payload.roles,
      permissions: payload.permissions,
    );

    // Guardar nuevo token y información del usuario
    await _saveAuthData(newToken, userInfo);
    print('Token actualizado con houseId: ${payload.houseId ?? 'null'}');
  }

  /// Guarda los datos de autenticación localmente
  /// 
  /// Almacena el token JWT y la información del usuario en SharedPreferences
  /// para persistir la sesión entre reinicios de la aplicación.
  /// 
  /// [token] - Token JWT del usuario
  /// [userInfo] - Información del usuario decodificada
  static Future<void> _saveAuthData(String token, UserInfo userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userInfoKey, json.encode(userInfo.toJson()));
    print('Token guardado: ${token.substring(0, 20)}...');
    print('Usuario: ${userInfo.nickname}');
  }

  /// Obtiene el token almacenado localmente
  /// 
  /// Recupera el token JWT desde SharedPreferences sin validar su validez.
  /// 
  /// Retorna el token almacenado o null si no existe
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Limpia todos los datos de autenticación
  /// 
  /// Elimina el token y la información del usuario de SharedPreferences,
  /// efectivamente cerrando la sesión local.
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userInfoKey);
    print('Datos de autenticación limpiados');
  }
}

/// Resultado de una operación de autenticación
/// 
/// Encapsula el resultado de operaciones como login, registro, etc.
/// Contiene información sobre el éxito o fallo de la operación
/// y los datos relevantes (token, usuario, error).
class AuthResult {
  final bool success;
  final String? token;
  final UserInfo? userInfo;
  final String? error;

  AuthResult._({
    required this.success,
    this.token,
    this.userInfo,
    this.error,
  });

  /// Crea un resultado exitoso de autenticación
  /// 
  /// [token] - Token JWT obtenido
  /// [userInfo] - Información del usuario autenticado
  factory AuthResult.success(String token, UserInfo userInfo) {
    return AuthResult._(
      success: true,
      token: token,
      userInfo: userInfo,
    );
  }

  /// Crea un resultado de error de autenticación
  /// 
  /// [error] - Mensaje de error descriptivo
  factory AuthResult.error(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}
