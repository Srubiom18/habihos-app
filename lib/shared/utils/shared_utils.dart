/// Utilidades compartidas en toda la aplicación
/// 
/// Este archivo contiene funciones de utilidad comunes que pueden ser
/// utilizadas en múltiples features para mantener consistencia.

import 'package:flutter/material.dart';

/// Utilidades para validación de datos
class ValidationUtils {
  /// Valida si un email tiene formato correcto
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Valida si una contraseña cumple los requisitos mínimos
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Valida si un string no está vacío
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Valida si un string tiene longitud mínima
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.trim().length >= minLength;
  }
}

/// Utilidades para formateo de datos
class FormatUtils {
  /// Formatea una fecha a string legible
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  /// Formatea una fecha y hora a string legible
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea un número de teléfono
  static String formatPhoneNumber(String phone) {
    // Remover caracteres no numéricos
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return phone; // Retornar original si no tiene formato esperado
  }

  /// Capitaliza la primera letra de cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
}

/// Utilidades para manejo de strings
class StringUtils {
  /// Trunca un string a una longitud máxima
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// Remueve caracteres especiales de un string
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Convierte un string a slug (URL-friendly)
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }
}

/// Utilidades para manejo de errores
class ErrorUtils {
  /// Obtiene un mensaje de error amigable para el usuario
  static String getFriendlyErrorMessage(dynamic error) {
    if (error is String) return error;
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Tiempo de espera agotado. Verifica tu conexión.';
    }
    
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Sesión expirada. Inicia sesión nuevamente.';
    }
    
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'No tienes permisos para realizar esta acción.';
    }
    
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Recurso no encontrado.';
    }
    
    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Error del servidor. Intenta más tarde.';
    }
    
    return 'Ha ocurrido un error inesperado. Intenta nuevamente.';
  }
}

/// Utilidades para manejo de listas
class ListUtils {
  /// Remueve duplicados de una lista
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// Agrupa elementos de una lista por una función
  static Map<K, List<T>> groupBy<T, K>(List<T> list, K Function(T) keyFunction) {
    final Map<K, List<T>> grouped = {};
    
    for (final item in list) {
      final key = keyFunction(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    
    return grouped;
  }

  /// Verifica si una lista está vacía o nula
  static bool isEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  /// Obtiene el primer elemento de una lista o null si está vacía
  static T? firstOrNull<T>(List<T> list) {
    return list.isNotEmpty ? list.first : null;
  }
}

/// Utilidades para manejo de context
class ContextUtils {
  /// Obtiene el tamaño de pantalla
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Verifica si es una pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context).width < 600;
  }

  /// Verifica si es una pantalla grande
  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context).width > 1200;
  }

  /// Obtiene el ancho disponible para contenido
  static double getContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize.width > 800 ? 800 : screenSize.width;
  }
}
