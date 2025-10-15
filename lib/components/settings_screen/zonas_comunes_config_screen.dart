import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../services/common/snackbar_service.dart';
import '../../services/cleaning_rotation_service.dart';
import '../../models/api_models.dart';
import 'controllers/zonas_comunes_controller.dart';
import 'widgets/zonas_comunes_widgets.dart';
import 'widgets/zonas_comunes_dialogs.dart';
import 'zonas_comunes_edit_screen.dart';

/// Pantalla de configuración de zonas comunes del calendario de limpieza
class ZonasComunesConfigScreen extends StatefulWidget {
  const ZonasComunesConfigScreen({super.key});

  @override
  State<ZonasComunesConfigScreen> createState() => _ZonasComunesConfigScreenState();
}

class _ZonasComunesConfigScreenState extends State<ZonasComunesConfigScreen> {
  late final ZonasComunesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZonasComunesController();
    _loadData();
  }

  /// Carga los datos necesarios desde la API
  Future<void> _loadData() async {
    try {
      // Cargar tanto las zonas como el calendario
      await Future.wait([
        _controller.loadCleaningAreas(),
        _controller.loadCleaningCalendar(),
      ]);
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(
          context,
          'Error al cargar datos: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: UIConstants.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Zonas Comunes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UIConstants.textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: UIConstants.primaryColor,
            ),
                onPressed: _navigateToCreateZonaComun,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Información del calendario de limpieza
                CalendarInfoWidget(controller: _controller),
                
                // Contenido principal
                _buildContent(),
                
                const SizedBox(height: UIConstants.spacingLarge),
                
                // Sección de rotación
                _buildRotationSection(),
                
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye el contenido principal según el estado
  Widget _buildContent() {
    // Solo mostrar loader si es la carga inicial (no hay datos aún)
    if (_controller.isLoading && _controller.calendarData == null && _controller.zonasComunes.isEmpty) {
      return const LoadingWidget();
    }

    if (_controller.errorMessage != null && _controller.calendarData == null) {
      return ZonasComunesErrorWidget(
        message: _controller.errorMessage!,
        onRetry: _loadData,
      );
    }

    // Siempre mostrar la estructura de scroll horizontal, incluso si está vacía
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.screenPadding),
      child: Row(
        children: _buildZonasCards(),
      ),
    );
  }

  /// Construye las cards de zonas con información de usuarios asignados
  List<Widget> _buildZonasCards() {
    // Priorizar datos del calendario si están disponibles
    if (_controller.calendarData != null && _controller.calendarData!.zoneRotation.isNotEmpty) {
      final zones = _controller.calendarData!.zoneRotation;
      
      return zones.asMap().entries.map((entry) {
        final index = entry.key;
        final zone = entry.value;
        final isLastItem = index == zones.length - 1;
        final isSingleZone = zones.length == 1;
        
        return _buildZonaCard(
          zonaComun: null, // Usar datos del calendario
          calendarZone: zone,
          assignedUsers: zone.assignedUsers,
          isCurrent: zone.isCurrent,
          index: index,
          isLastItem: isLastItem,
          isSingleZone: isSingleZone,
          onEdit: () {
            // Para zonas del calendario, buscar la zona correspondiente
            final zonaCorrespondiente = _controller.zonasComunes.firstWhere(
              (z) => z.id == zone.cleaningAreaId,
              orElse: () => CleaningAreaResponse(
                id: zone.cleaningAreaId,
                name: zone.cleaningAreaName,
                description: zone.cleaningAreaDescription,
                color: zone.cleaningAreaColor,
                houseId: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            _navigateToEditZonaComun(zonaCorrespondiente);
          },
          onDelete: () {
            // Para zonas del calendario, buscar la zona correspondiente
            final zonaCorrespondiente = _controller.zonasComunes.firstWhere(
              (z) => z.id == zone.cleaningAreaId,
              orElse: () => CleaningAreaResponse(
                id: zone.cleaningAreaId,
                name: zone.cleaningAreaName,
                description: zone.cleaningAreaDescription,
                color: zone.cleaningAreaColor,
                houseId: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            _showRemoveZonaComunDialog(zonaCorrespondiente);
          },
        );
      }).toList();
    }
    
    // Fallback: usar zonas básicas si no hay datos del calendario
    if (_controller.zonasComunes.isEmpty) {
      return [_buildEmptyZonasCard()];
    }
    
    return _controller.zonasComunes.asMap().entries.map((entry) {
      final index = entry.key;
      final zonaComun = entry.value;
      final isLastItem = index == _controller.zonasComunes.length - 1;
      final isSingleZone = _controller.zonasComunes.length == 1;
      
        return _buildZonaCard(
          zonaComun: zonaComun,
          assignedUsers: [], // Sin usuarios asignados
          isCurrent: false,
          index: index,
          isLastItem: isLastItem,
          isSingleZone: isSingleZone,
                onEdit: () => _navigateToEditZonaComun(zonaComun),
          onDelete: () => _showRemoveZonaComunDialog(zonaComun),
        );
    }).toList();
  }

  /// Construye una card individual de zona
  Widget _buildZonaCard({
    CleaningAreaResponse? zonaComun,
    CleaningZoneRotationResponse? calendarZone,
    List<AssignedUserInfo> assignedUsers = const [],
    required bool isCurrent,
    required int index,
    required bool isLastItem,
    required bool isSingleZone,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    // Si solo hay una zona, ocupa todo el ancho. Si hay más, usa el ancho normal
    final cardWidth = isSingleZone 
        ? MediaQuery.of(context).size.width - (UIConstants.screenPadding * 2) // Todo el ancho disponible
        : MediaQuery.of(context).size.width - (UIConstants.screenPadding * 2) - 20; // Ancho normal con espacio para la siguiente
    
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(
        right: (isSingleZone || isLastItem) ? 0 : 20, // Sin margen si es la única zona o el último elemento
      ),
      child: ZonaComunCard(
        zonaComun: zonaComun,
        calendarZone: calendarZone,
        assignedUsers: assignedUsers,
        isCurrent: isCurrent,
        controller: _controller,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  /// Construye una card especial cuando no hay zonas comunes
  Widget _buildEmptyZonasCard() {
    return Container(
      width: MediaQuery.of(context).size.width - (UIConstants.screenPadding * 2),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'No hay zonas comunes',
            style: TextStyle(
              fontSize: UIConstants.textSizeLarge,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingSmall),
          
          // Descripción
          Text(
            'Crea tu primera zona común para comenzar a organizar las tareas de limpieza.',
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              color: UIConstants.textColor.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: UIConstants.spacingLarge),
          
          // Botón
          ElevatedButton.icon(
                onPressed: _navigateToCreateZonaComun,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear Zona'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingLarge,
                vertical: UIConstants.spacingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Muestra el diálogo para agregar una zona común
  /// Navega a la pantalla de creación de zona común
  void _navigateToCreateZonaComun() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ZonasComunesEditScreen(
          controller: _controller,
        ),
      ),
    );
    
    if (result == true) {
      _loadData(); // Recargar datos si se guardó exitosamente
    }
  }

  /// Muestra el diálogo para editar una zona común
  /// Navega a la pantalla de edición de zona común
  void _navigateToEditZonaComun(CleaningAreaResponse zonaComun) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ZonasComunesEditScreen(
          zonaComun: zonaComun,
          controller: _controller,
        ),
      ),
    );
    
    if (result == true) {
      _loadData(); // Recargar datos si se guardó exitosamente
    }
  }

  /// Muestra el diálogo para eliminar una zona común
  void _showRemoveZonaComunDialog(CleaningAreaResponse zonaComun) {
    showDialog(
      context: context,
      builder: (context) => DeleteZonaComunDialog(
        zonaComun: zonaComun,
        onConfirm: () => _deleteCleaningArea(zonaComun),
      ),
    );
  }

  /// Elimina una zona de limpieza usando la API
  Future<void> _deleteCleaningArea(CleaningAreaResponse zonaComun) async {
    try {
      await _controller.deleteCleaningArea(zonaComun.id.toString());
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(
          context,
          'Error al eliminar zona: ${e.toString()}',
        );
      }
    }
  }

  /// Construye la sección de rotación con información detallada
  Widget _buildRotationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.screenPadding),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rotación Automática',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: UIConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSmall),
                  Text(
                    _controller.rotationConfig?.frequencyDescription ?? 'Sin configuración',
                    style: TextStyle(
                      fontSize: UIConstants.textSizeSmall,
                      color: UIConstants.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _controller.isRotationActive,
                onChanged: (value) async {
                  try {
                    await _controller.toggleRotation(value);
                    if (mounted) {
                      setState(() {});
                    }
                  } catch (e) {
                    if (mounted) {
                      SnackBarService().showError(
                        context,
                        'Error al cambiar estado de rotación: ${e.toString()}',
                      );
                    }
                  }
                },
                activeColor: UIConstants.primaryColor,
              ),
            ],
          ),
          
          // Información de estado de rotación (siempre visible)
          const SizedBox(height: UIConstants.spacingLarge),
          _buildRotationInfo(),
          
            // Sección de configuración (solo visible si está activada)
            if (_controller.isRotationActive) ...[
              const SizedBox(height: UIConstants.spacingLarge),

              // Nuevos controles de rotación con milisegundos
              _buildRotationIntervalControls(),

              // Botones de acción adicionales
              const SizedBox(height: UIConstants.spacingLarge),
              _buildRotationActions(),
            ],
        ],
      ),
    );
  }

  /// Construye la información de estado de la rotación con cronómetro integrado
  Widget _buildRotationInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: UIConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: UIConstants.primaryColor,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                'Estado de Rotación',
                style: TextStyle(
                  fontSize: UIConstants.textSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: UIConstants.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.spacingMedium),
          
          // Cronómetro (SIEMPRE visible si está activa, sin condiciones adicionales)
          if (_controller.isRotationActive) ...[
            _buildCountdownSection(),
            const SizedBox(height: UIConstants.spacingMedium),
            Divider(color: UIConstants.primaryColor.withOpacity(0.2)),
            const SizedBox(height: UIConstants.spacingMedium),
          ],
          
          // Fechas de rotación (mostrar nextRotationDate del calendario)
          if (_controller.calendarData?.nextRotationDate != null) ..._buildRotationDates(),
          
          // Mensaje si no está activa
          if (!_controller.isRotationActive) ...[
            Text(
              'La rotación está desactivada',
              style: TextStyle(
                fontSize: UIConstants.textSizeSmall,
                color: UIConstants.textColor.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye la sección del cronómetro (cuenta regresiva real)
  Widget _buildCountdownSection() {
    // Usar el tiempo calculado por el controller (se actualiza cada segundo)
    final duration = _controller.timeUntilNextRotation;
    
    String countdownText;
    Color countdownColor;
    
    if (!_controller.isRotationCountdownActive) {
      countdownText = 'Calculando...';
      countdownColor = Colors.grey;
    } else if (duration.isNegative || duration.inSeconds <= 0) {
      countdownText = 'Rotación pendiente';
      countdownColor = Colors.red;
    } else {
      countdownText = _formatCountdownPrecise(duration);
      countdownColor = _getCountdownColorFromDuration(duration);
    }
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: countdownColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icono
          Icon(
            Icons.timer,
            color: countdownColor,
            size: 28,
          ),
          
          const SizedBox(width: UIConstants.spacingMedium),
          
          // Texto del countdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiempo restante:',
                  style: TextStyle(
                    fontSize: UIConstants.textSizeSmall,
                    fontWeight: FontWeight.w500,
                    color: UIConstants.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countdownText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: countdownColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador pulsante
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: countdownColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: countdownColor.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea el countdown con precisión (cuenta regresiva)
  String _formatCountdownPrecise(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Obtiene el color según la duración restante
  Color _getCountdownColorFromDuration(Duration duration) {
    if (duration.inSeconds < 30) {
      return Colors.red;
    } else if (duration.inMinutes < 2) {
      return Colors.orange;
    } else if (duration.inMinutes < 10) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  /// Construye las fechas de rotación
  List<Widget> _buildRotationDates() {
    final nextRotation = _controller.calendarData?.nextRotationDate;
    
    return [
      // Solo mostrar próxima rotación del calendario
      if (nextRotation != null) ...[
        _buildDateRow(
          'Fecha programada:',
          nextRotation,
          Icons.schedule,
        ),
      ],
    ];
  }

  /// Construye una fila de fecha
  Widget _buildDateRow(String label, DateTime date, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: UIConstants.textColor.withOpacity(0.5),
        ),
        const SizedBox(width: UIConstants.spacingSmall),
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.textSizeSmall,
            color: UIConstants.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: UIConstants.spacingSmall),
        Expanded(
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: UIConstants.textSizeSmall,
              fontWeight: FontWeight.w500,
              color: UIConstants.textColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }


  /// Construye los botones de acción para la rotación
  Widget _buildRotationActions() {
    return Row(
      children: [
        // Botón para procesar rotaciones pendientes
        if (_controller.hasPendingRotations)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _controller.processPendingRotations();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Rotaciones procesadas exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    SnackBarService().showError(
                      context,
                      'Error al procesar rotaciones: ${e.toString()}',
                    );
                  }
                }
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Procesar Rotaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingMedium,
                  vertical: UIConstants.spacingSmall,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Formatea una fecha para mostrar con precisión de tiempo
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    
    // Formatear fecha y hora
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    
    // Verificar si es el mismo día
    final isSameDay = now.year == date.year && 
                      now.month == date.month && 
                      now.day == date.day;
    
    final isYesterday = now.year == date.year && 
                        now.month == date.month && 
                        now.day - date.day == 1;
    
    final isTomorrow = now.year == date.year && 
                       now.month == date.month && 
                       date.day - now.day == 1;
    
    if (isSameDay) {
      return 'Hoy $hour:$minute:$second';
    } else if (isTomorrow) {
      return 'Mañana $hour:$minute:$second';
    } else if (isYesterday) {
      return 'Ayer $hour:$minute:$second';
    } else {
      return '$day/$month/$year $hour:$minute:$second';
    }
  }

  Widget _buildRotationIntervalControls() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurar Intervalo de Rotación',
            style: TextStyle(
              fontSize: UIConstants.textSizeMedium,
              fontWeight: FontWeight.w600,
              color: UIConstants.textColor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          
          // Botones predefinidos
          _buildPredefinedButtons(),
        ],
      ),
    );
  }

  Widget _buildPredefinedButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primera fila: 3 opciones (Diario, Semanal, Mensual)
        Row(
          children: [
            Expanded(
              child: _buildIntervalCard('Diario', Icons.today, 24 * 60 * 60 * 1000, 'DAILY'),
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Expanded(
              child: _buildIntervalCard('Semanal', Icons.date_range, 7 * 24 * 60 * 60 * 1000, 'WEEKLY'),
            ),
            const SizedBox(width: UIConstants.spacingSmall),
            Expanded(
              child: _buildIntervalCard('Mensual', Icons.calendar_month, 30 * 24 * 60 * 60 * 1000, 'MONTHLY'),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        // Segunda fila: Custom (1 Minuto para pruebas)
        SizedBox(
          width: double.infinity,
          child: _buildIntervalCard('Custom (1min)', Icons.tune, 60 * 1000, 'CUSTOM'),
        ),
      ],
    );
  }

  /// Construye una tarjeta redondeada para configurar intervalo
  Widget _buildIntervalCard(String label, IconData icon, int intervalMs, String frequency) {
    // Verificar si esta opción está actualmente activa
    final isActive = _controller.calendarData?.frequency?.toUpperCase() == frequency;
    
    return InkWell(
      onTap: () => _configureRotationInterval(intervalMs, frequency),
      borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingMedium),
        decoration: BoxDecoration(
          color: isActive 
              ? UIConstants.primaryColor.withOpacity(0.2) 
              : UIConstants.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          border: Border.all(
            color: isActive 
                ? UIConstants.primaryColor 
                : UIConstants.primaryColor.withOpacity(0.3),
            width: isActive ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isActive 
                  ? UIConstants.primaryColor 
                  : UIConstants.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.textSizeMedium,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive 
                    ? UIConstants.primaryColor 
                    : UIConstants.primaryColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            // Mostrar checkmark si está activo
            if (isActive) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: UIConstants.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _configureRotationInterval(int intervalMs, String frequency) async {
    try {
      await _controller.configureRotationInterval(intervalMs, frequency);
      if (mounted) {
        setState(() {});
        SnackBarService().showSuccess(
          context,
          'Intervalo de rotación configurado exitosamente',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService().showError(
          context,
          'Error al configurar intervalo: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

