import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HttpInterceptorService {
  // Realizar petición GET con token automático
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final token = await AuthService.getCurrentToken();
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    return http.get(Uri.parse(url), headers: requestHeaders);
  }
  
  // Realizar petición POST con token automático
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await AuthService.getCurrentToken();
    print('Token obtenido: ${token != null ? "Presente (${token.length} caracteres)" : "NULL"}');
    
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
      print('Headers con token: $requestHeaders');
    } else {
      print('Headers sin token: $requestHeaders');
    }
    
    return http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }
  
  // Realizar petición PUT con token automático
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await AuthService.getCurrentToken();
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    return http.put(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }
  
  // Realizar petición DELETE con token automático
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await AuthService.getCurrentToken();
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    
    return http.delete(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? json.encode(body) : null,
    );
  }
}
