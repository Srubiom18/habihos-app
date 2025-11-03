import 'dart:async';
import 'package:flutter/material.dart';
import '../services/home_screen/home_screen_services.dart';
import '../services/common/snackbar_service.dart';
import '../services/common/zones_update_notifier_service.dart';
import '../constants/ui_constants.dart';
import '../components/home_screen/home_screen_components.dart';
import '../components/home_screen/no_zones_configured_widget.dart';
import '../components/home_screen/dynamic_cleaning_layout_widget.dart';
import '../components/home_screen/action_button_widget.dart';
import '../interfaces/home_screen/cleaning_area.dart';
import '../interfaces/home_screen/notification.dart' as app_notification;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Servicios
  late final CleaningService _cleaningService;
  late final NotificationService _notificationService;
  late final TaskRotationService _taskRotationService;
  late final SnackBarService _snackBarService;

  // Estado de carga
  bool _isLoading = true;
  bool _hasInitialized = false;
  
  // Stream subscription para escuchar cambios en las zonas
  StreamSubscription<bool>? _zonesUpdateSubscription;
  
  // Controller para el sheet de notificaciones
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Getters para acceder a los datos de los servicios
  List<CleaningArea> get cleaningAreas => _cleaningService.getAllCleaningAreas();
  List<app_notification.NotificationImpl> get notifications => _notificationService.getAllNotifications();
  int get currentTaskIndex => _taskRotationService.currentTaskIndex;
  bool get isCompleted => _taskRotationService.isCompleted;
  
  // Variables para almacenar las áreas filtradas y ordenadas
  CleaningArea? _currentUserArea;
  List<CleaningArea> _otherAreas = [];
  
  
  // Getters para el estado del calendario
  bool get hasConfiguredZones => _cleaningService.hasConfiguredZones;
  String get calendarMessage => _cleaningService.calendarMessage;
  bool get isUsingAPIData => _cleaningService.isUsingAPIData;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupZonesUpdateListener();
    _loadCalendarData();
  }

  /// Configura el listener para cambios en las zonas
  void _setupZonesUpdateListener() {
    _zonesUpdateSubscription = ZonesUpdateNotifierService().onZonesUpdated.listen((hasUpdates) {
      if (hasUpdates && mounted && _hasInitialized) {
        _handleZonesUpdate();
      }
    });
  }

  /// Maneja la actualización de zonas
  Future<void> _handleZonesUpdate() async {
    try {
      // Forzar actualización del calendario
      await _cleaningService.forceUpdate();
      
      // Recargar las áreas específicas del usuario
      await _loadUserSpecificAreas();
      
      if (mounted) {
        setState(() {});
        
        // Marcar que las actualizaciones han sido procesadas
        ZonesUpdateNotifierService().markUpdatesAsProcessed();
      }
    } catch (e) {
      // Error silencioso - no mostrar mensaje al usuario
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Verificar si hay actualizaciones pendientes cuando se vuelve a la pantalla
    if (_hasInitialized && !_isLoading && ZonesUpdateNotifierService().hasPendingUpdates) {
      _handleZonesUpdate();
    }
  }

  void _initializeServices() {
    _cleaningService = CleaningService();
    _notificationService = NotificationService();
    _taskRotationService = TaskRotationService();
    _snackBarService = SnackBarService();
    
    // Configurar callbacks del servicio de rotación
    _taskRotationService.onTaskChanged = (newIndex) {
      if (mounted) {
        setState(() {});
      }
    };
    
    _taskRotationService.onTaskCompleted = (taskIndex) {
      if (mounted) {
        setState(() {});
      }
    };
  }

  /// Carga los datos del calendario desde la API
  Future<void> _loadCalendarData() async {
    try {
      await _cleaningService.initializeFromAPI();
      
      // Cargar las áreas filtradas y ordenadas según el usuario actual
      await _loadUserSpecificAreas();
      
      // Solo iniciar la rotación si hay zonas configuradas
      if (hasConfiguredZones) {
        _taskRotationService.startTaskRotation();
      }
    } catch (e) {
      // En caso de error, mostrar mensaje pero continuar con datos de ejemplo
      _snackBarService.showError(
        context,
        'Error al cargar el calendario: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasInitialized = true;
        });
      }
    }
  }

  /// Carga las áreas específicas del usuario (asignada y otras)
  Future<void> _loadUserSpecificAreas() async {
    try {
      // Obtener el área asignada al usuario actual
      _currentUserArea = await _cleaningService.getCurrentUserAssignedArea();
      
      // Obtener las otras áreas ordenadas
      _otherAreas = await _cleaningService.getOtherAreasForUser();
    } catch (e) {
      // Si hay error, usar la lógica original
      _currentUserArea = _cleaningService.getCurrentArea(currentTaskIndex);
      _otherAreas = _cleaningService.getOtherAreas(currentTaskIndex);
    }
  }



  void _markAsCompleted() {
    _taskRotationService.markCurrentTaskAsCompleted();
  }




  @override
  void dispose() {
    _zonesUpdateSubscription?.cancel();
    _taskRotationService.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildMainContent(),
      ),
    );
  }

  /// Construye el contenido principal de la pantalla
  Widget _buildMainContent() {
    // Si no hay zonas configuradas, mostrar el mensaje
    if (!hasConfiguredZones) {
      return _buildNoZonesContent();
    }

    // Si hay zonas configuradas, mostrar el contenido normal
    return _buildNormalContent();
  }

  /// Construye el contenido cuando no hay zonas configuradas
  Widget _buildNoZonesContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con nombre de casa y avatar
          HomeHeaderWidget(
            houseName: 'Casa de la Universidad', // Nombre estático
          ),
          
          // Contenido con padding
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.screenPadding,
              right: UIConstants.screenPadding,
              bottom: UIConstants.screenPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: UIConstants.spacingLarge),
                
                // Widget de no zonas configuradas
                NoZonesConfiguredWidget(
                  message: calendarMessage,
                  onConfigureZones: () {
                    // TODO: Navegar a la pantalla de configuración de zonas
                    _snackBarService.showInfo(
                      context,
                      'Funcionalidad de configuración próximamente',
                    );
                  },
                ),
                
                const SizedBox(height: UIConstants.spacingLarge),
                
                // Sección de notificaciones (mantener visible)
                NotificationsSectionWidget(
                  notifications: notifications,
                ),
                
                const SizedBox(height: UIConstants.spacingLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido normal cuando hay zonas configuradas
  Widget _buildNormalContent() {
    // Usar las áreas específicas del usuario si están disponibles, sino usar la lógica original
    final currentArea = _currentUserArea ?? _cleaningService.getCurrentArea(currentTaskIndex);
    final otherAreas = _otherAreas.isNotEmpty ? _otherAreas : _cleaningService.getOtherAreas(currentTaskIndex);
    
    return Stack(
      children: [
        // Contenido principal que queda detrás
        SingleChildScrollView(
          child: Column(
            children: [
              // Header con nombre de casa y avatar
              HomeHeaderWidget(
                houseName: 'Casa de la Universidad', // Nombre estático
              ),
              
              // Contenido con padding
              Padding(
                padding: const EdgeInsets.only(
                  left: UIConstants.screenPadding,
                  right: UIConstants.screenPadding,
                  bottom: UIConstants.screenPadding,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: UIConstants.spacingLarge),
                    
                    // Layout dinámico de áreas de limpieza
                    DynamicCleaningLayoutWidget(
                      currentArea: currentArea,
                      otherAreas: otherAreas,
                      isCompleted: isCompleted,
                    ),
                    
                    const SizedBox(height: UIConstants.spacingLarge),
                    
                    
                    // Botón de acción
                    ActionButtonWidget(
                      currentArea: currentArea,
                      isCompleted: isCompleted,
                      isValidIndex: _cleaningService.isValidIndex(currentTaskIndex),
                      onPressed: _markAsCompleted,
                    ),
                    
                    // Espacio extra para que el contenido no quede oculto por el sheet
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Panel deslizable de notificaciones con profundidad
        _buildNotificationsSheet(),
      ],
    );
  }

  /// Construye el panel deslizable de notificaciones
  Widget _buildNotificationsSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,          // Tamaño inicial fijo al 50%
      minChildSize: 0.2,              // Mínimo 20%
      maxChildSize: 0.85,             // Máximo 85%
      snap: true,                     // Snap automático activado
      snapSizes: const [0.2, 0.5, 0.85], // Snap points fijos
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: UIConstants.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(UIConstants.spacingXLarge),
              topRight: Radius.circular(UIConstants.spacingXLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle visual para indicar que es arrastrable
              _buildDragHandle(),
              
              // Contenido de notificaciones con scroll
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.screenPadding,
                  ),
                  children: [
                    const SizedBox(height: UIConstants.spacingSmall),
                    NotificationsSectionWidget(
                      notifications: notifications,
                    ),
                    const SizedBox(height: UIConstants.spacingLarge),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye el handle de arrastre
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: UIConstants.spacingMedium),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

}
