/// Configuración de rutas de la aplicación
/// 
/// Este archivo centraliza todas las rutas de navegación
/// para evitar acoplamiento entre pantallas.

import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/home_selector_screen.dart';
import '../screens/house_chat_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../screens/personal_space_screen.dart';
import '../screens/create_house_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/join_house_screen.dart';
import '../services/auth_service.dart';

/// Rutas de la aplicación
class AppRoutes {
  // Constructor privado para evitar instanciación
  AppRoutes._();

  // Rutas principales
  static const String initial = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String homeSelector = '/home-selector';
  static const String personalSpace = '/personal-space';
  static const String houseChat = '/house-chat';
  static const String shoppingList = '/shopping-list';
  static const String createHouse = '/create-house';
  static const String settings = '/settings';
  static const String joinHouse = '/join-house';

  // Rutas de configuración
  static const String participantsConfig = '/settings/participants';
  static const String zonasComunesConfig = '/settings/zonas-comunes';
  static const String subscriptionConfig = '/settings/subscription';
  static const String colorSchemeConfig = '/settings/color-scheme';
  static const String avatarConfig = '/settings/avatar';

  /// Mapa de rutas de la aplicación
  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (context) => const InitialScreen(),
      auth: (context) => const AuthScreen(),
      home: (context) => const MainScreen(),
      homeSelector: (context) => const HomeSelectorScreen(),
      personalSpace: (context) => const PersonalSpaceScreen(),
      houseChat: (context) => const HouseChatScreen(),
      shoppingList: (context) => const ShoppingListScreen(),
      createHouse: (context) => const CreateHouseScreen(),
      settings: (context) => const SettingsScreen(),
      joinHouse: (context) => const JoinHouseScreen(),
    };
  }

  /// Navega a una ruta específica
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navega reemplazando la ruta actual
  static Future<T?> navigateReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, routeName, arguments: arguments);
  }

  /// Navega removiendo todas las rutas anteriores
  static Future<T?> navigateAndClearStack<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Regresa a la ruta anterior
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Regresa a una ruta específica
  static void goBackTo(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}

/// Pantalla inicial que verifica automáticamente el token y navega según corresponda
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Verificar si el usuario está autenticado
      final isAuthenticated = await AuthService.isAuthenticated();
      
      if (isAuthenticated) {
        // Usuario autenticado - verificar si tiene casa activa
        final hasActiveHouse = await AuthService.hasActiveHouse();
        
        if (mounted) {
          if (hasActiveHouse) {
            // Tiene casa activa - ir directo al home
            AppRoutes.navigateReplacement(context, AppRoutes.home);
          } else {
            // No tiene casa activa - ir a home selector
            AppRoutes.navigateReplacement(context, AppRoutes.homeSelector);
          }
        }
      } else {
        // Usuario no autenticado - ir a auth
        if (mounted) {
          AppRoutes.navigateReplacement(context, AppRoutes.auth);
        }
      }
    } catch (e) {
      // Error al verificar - ir a auth por defecto
      if (mounted) {
        AppRoutes.navigateReplacement(context, AppRoutes.auth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Verificando sesión...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla principal con navegación por pestañas
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentPage = 1; // Inicia en 1 (Home)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Inicia en la Home
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Contenido principal con PageView que ocupa toda la pantalla
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              PersonalSpaceScreen(), // Índice 0
              HomeScreen(),          // Índice 1 (inicial)
              ShoppingListScreen(),  // Índice 2
              HouseChatScreen(),     // Índice 3
            ],
          ),
          
          // Indicadores flotantes en la parte inferior con efecto blur
          // TODO: Implementar DotIndicators cuando esté disponible
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: DotIndicators(
          //     currentPage: _currentPage,
          //     totalPages: 4,
          //     pageController: _pageController,
          //   ),
          // ),
        ],
      ),
    );
  }
}
