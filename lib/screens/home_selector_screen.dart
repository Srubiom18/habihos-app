import 'package:flutter/material.dart';
import '../components/home_selector_screen/home_selector_screen_components.dart';
import '../services/home/home_selector_service.dart';
import '../constants/ui_constants.dart';

/// Pantalla que permite al usuario configurar su casa o unirse a una existente
class HomeSelectorScreen extends StatefulWidget {
  const HomeSelectorScreen({super.key});

  @override
  State<HomeSelectorScreen> createState() => _HomeSelectorScreenState();
}

class _HomeSelectorScreenState extends State<HomeSelectorScreen> {
  final _homeSelectorService = HomeSelectorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header de bienvenida
              const WelcomeHeaderWidget(),
              
              const SizedBox(height: 40),
              
              // Botones de acción
              ActionButtonsWidget(
                onCreateHouse: () => _homeSelectorService.navigateToCreateHouse(context),
                onJoinHouse: () => _homeSelectorService.handleJoinExistingHouse(context),
              ),
              
              const SizedBox(height: 30),
              
              // Información adicional
              const InfoCardWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
