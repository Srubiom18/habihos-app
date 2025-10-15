import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/home_selector_screen.dart';
import 'screens/house_chat_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/personal_space_screen.dart';
// import 'components/common/dot_indicators.dart'; // Comentado temporalmente
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Casa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainScreen(),
        '/home-selector': (context) => const HomeSelectorScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
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
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // No tiene casa activa - ir a home selector
            Navigator.pushReplacementNamed(context, '/home-selector');
          }
        }
      } else {
        // Usuario no autenticado - ir a auth
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    } catch (e) {
      // Error al verificar - ir a auth por defecto
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  // int _currentPage = 1; // Inicia en 1 (Home) - Comentado temporalmente

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

  // void _onPageChanged(int page) {
  //   setState(() {
  //     _currentPage = page;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Contenido principal con PageView que ocupa toda la pantalla
          PageView(
            controller: _pageController,
            // onPageChanged: _onPageChanged, // Comentado temporalmente
            children: const [
              PersonalSpaceScreen(), // Índice 0
              HomeScreen(),          // Índice 1 (inicial)
              ShoppingListScreen(),  // Índice 2
              HouseChatScreen(),     // Índice 3
            ],
          ),
          
          // Indicadores flotantes en la parte inferior con efecto blur
          // TODO: Dot indicators comentados temporalmente
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