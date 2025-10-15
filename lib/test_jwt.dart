// Archivo de prueba para verificar la decodificación del JWT
// Este archivo se puede eliminar después de verificar que funciona

import 'services/jwt_service.dart';

void testJwtDecoding() {
  // JWT de ejemplo que proporcionaste
  const String testJwt = 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI2N2VlMGFmOC0xZDk0LTQyNjQtYmM4Mi0wYmQ3ZTJiMGFjODkiLCJuaWNrbmFtZSI6IkFkbWluIFNpc3RlbWEiLCJyb2xlcyI6WyJBRE1JTiJdLCJwZXJtaXNzaW9ucyI6WyJDQU5fTUFOQUdFX1VTRVJTIiwiQ0FOX01BTkFHRV9ST0xFUyIsIkNBTl9NQU5BR0VfQ0xFQU5JTkdfQVJFQVMiXSwiaWF0IjoxNzU3MjYyMTE3LCJleHAiOjE3NTcyNjM5MTd9.bZeWaKh9aCC4jXNC0RK0xpKZ8MWmIbilArT1R7jfnFac1APDleGQxXvXIkwIHks2OAulMaWqO42ucqV-fl84NTf9MnzmKTz_9KrbYfYbtP2MsFW-IUJJUdZpG_oPCzie80xYN5DjthpMbV58sT7DzW8rYqGS8nK64sHG4TQUgWDWEVZhwP0SsBCUM1aI96R_DDntLYj0bWx__C57b50aIbt1kDZrQ3hM9Zo5mYbsNwUBqefWq1rO-ENBK5HnVuCGvvUcDSJD6kaG0Gr0EpIyQoD9ETtU9wQuQvzMI4xQmggaGbJ9yVhh09nCsB8_ys7px1e9ewJwafjYvPyejq8WLQ';

  print('=== PRUEBA DE DECODIFICACIÓN JWT ===');
  
  final payload = JwtService.decodeToken(testJwt);
  
  if (payload != null) {
    print('✅ JWT decodificado exitosamente');
    print('ID Usuario: ${payload.sub}');
    print('Nickname: ${payload.nickname}');
    print('Roles: ${payload.roles}');
    print('Permisos: ${payload.permissions}');
    print('Expirado: ${payload.isExpired}');
    print('Fecha expiración: ${payload.expirationDate}');
  } else {
    print('❌ Error decodificando JWT');
  }
  
  print('=====================================');
}

// Función para probar desde main.dart temporalmente
void runJwtTest() {
  testJwtDecoding();
}
