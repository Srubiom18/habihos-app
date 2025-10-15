import 'package:flutter/material.dart';
import '../../screens/create_house_screen.dart';
import '../../screens/join_house_screen.dart';

/// Servicio que maneja la lógica de la pantalla home selector
class HomeSelectorService {
  static final HomeSelectorService _instance = HomeSelectorService._internal();
  factory HomeSelectorService() => _instance;
  HomeSelectorService._internal();

  /// Maneja la navegación a la pantalla de crear casa
  void navigateToCreateHouse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHouseScreen(),
      ),
    );
  }

  /// Maneja la funcionalidad de unirse a casa existente
  void handleJoinExistingHouse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JoinHouseScreen(),
      ),
    );
  }
}
