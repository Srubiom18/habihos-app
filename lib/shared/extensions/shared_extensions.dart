/// Extensiones compartidas en toda la aplicación
/// 
/// Este archivo contiene extensiones útiles para tipos comunes
/// que pueden ser utilizadas en múltiples features.

import 'package:flutter/material.dart';

/// Extensiones para String
extension StringExtensions on String {
  /// Verifica si el string está vacío o solo contiene espacios
  bool get isBlank => trim().isEmpty;

  /// Verifica si el string no está vacío y no solo contiene espacios
  bool get isNotBlank => !isBlank;

  /// Capitaliza la primera letra del string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitaliza la primera letra de cada palabra
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.capitalize)
        .join(' ');
  }

  /// Remueve caracteres especiales
  String get removeSpecialCharacters {
    return replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Convierte a slug (URL-friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Trunca el string a una longitud máxima
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Verifica si es un email válido
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Verifica si es una contraseña válida (mínimo 6 caracteres)
  bool get isValidPassword {
    return length >= 6;
  }
}

/// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  /// Formatea la fecha a string legible (DD/MM/YYYY)
  String get formattedDate {
    return '${day.toString().padLeft(2, '0')}/'
           '${month.toString().padLeft(2, '0')}/'
           '$year';
  }

  /// Formatea la fecha y hora a string legible
  String get formattedDateTime {
    return '$formattedDate ${hour.toString().padLeft(2, '0')}:'
           '${minute.toString().padLeft(2, '0')}';
  }

  /// Verifica si la fecha es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si la fecha es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }

  /// Verifica si la fecha es mañana
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && 
           month == tomorrow.month && 
           day == tomorrow.day;
  }

  /// Obtiene el inicio del día
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Obtiene el final del día
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Obtiene el inicio de la semana (lunes)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return startOfDay.subtract(Duration(days: daysFromMonday));
  }

  /// Obtiene el final de la semana (domingo)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return endOfDay.add(Duration(days: daysToSunday));
  }
}

/// Extensiones para List
extension ListExtensions<T> on List<T> {
  /// Remueve duplicados de la lista
  List<T> get unique {
    return toSet().toList();
  }

  /// Obtiene el primer elemento o null si está vacía
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Obtiene el último elemento o null si está vacía
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Agrupa elementos por una función
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final Map<K, List<T>> grouped = {};
    
    for (final item in this) {
      final key = keyFunction(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    
    return grouped;
  }

  /// Verifica si la lista está vacía o nula
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Verifica si la lista no está vacía
  bool get isNotEmpty {
    return !isEmpty;
  }

  /// Obtiene un elemento por índice o null si está fuera de rango
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Agrega un elemento si no existe
  void addIfNotExists(T element) {
    if (!contains(element)) {
      add(element);
    }
  }

  /// Agrega múltiples elementos si no existen
  void addAllIfNotExists(Iterable<T> elements) {
    for (final element in elements) {
      addIfNotExists(element);
    }
  }
}

/// Extensiones para BuildContext
extension BuildContextExtensions on BuildContext {
  /// Obtiene el tamaño de pantalla
  Size get screenSize => MediaQuery.of(this).size;

  /// Obtiene el ancho de pantalla
  double get screenWidth => screenSize.width;

  /// Obtiene la altura de pantalla
  double get screenHeight => screenSize.height;

  /// Verifica si es una pantalla pequeña
  bool get isSmallScreen => screenWidth < 600;

  /// Verifica si es una pantalla mediana
  bool get isMediumScreen => screenWidth >= 600 && screenWidth <= 1200;

  /// Verifica si es una pantalla grande
  bool get isLargeScreen => screenWidth > 1200;

  /// Obtiene el tema actual
  ThemeData get theme => Theme.of(this);

  /// Obtiene los colores del tema actual
  ColorScheme get colorScheme => theme.colorScheme;

  /// Obtiene el estilo de texto del tema actual
  TextTheme get textTheme => theme.textTheme;

  /// Muestra un SnackBar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Muestra un SnackBar de error
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Muestra un SnackBar de información
  void showInfoSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.blue);
  }

  /// Navega a una nueva pantalla
  Future<T?> navigateTo<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navega reemplazando la pantalla actual
  Future<T?> navigateReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Navega removiendo todas las pantallas anteriores
  Future<T?> navigateAndClearStack<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Regresa a la pantalla anterior
  void goBack<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}

/// Extensiones para num (int y double)
extension NumExtensions on num {
  /// Convierte a string con formato de moneda
  String get asCurrency {
    return '\$${toStringAsFixed(2)}';
  }

  /// Convierte a string con formato de porcentaje
  String get asPercentage {
    return '${toStringAsFixed(1)}%';
  }

  /// Limita el valor entre un mínimo y máximo
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Verifica si el número está en un rango
  bool isInRange(num min, num max) {
    return this >= min && this <= max;
  }
}
