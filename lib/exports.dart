/// Archivo de exportación principal de la aplicación
/// 
/// Este archivo centraliza todas las exportaciones para facilitar
/// los imports en toda la aplicación. Organizado por categorías
/// para mejor mantenibilidad.
/// 
/// SIGUE LA NUEVA REGLA: "LAYERED COMPONENT ARCHITECTURE"
/// Ver DEVELOPMENT_RULES.md para más detalles.

// === CONFIGURACIÓN GLOBAL ===
export 'config/routes.dart';
export 'config/di.dart';
export 'config/env.dart';

// === UTILIDADES COMPARTIDAS ===
export 'shared/widgets/shared_widgets.dart';
export 'shared/utils/shared_utils.dart';
export 'shared/extensions/shared_extensions.dart';

// === CONSTANTES ===
export 'constants/ui_constants.dart';

// === FEATURES (NUEVA ESTRUCTURA) ===
// Notifications Feature
export 'features/notifications/components.dart';
export 'features/notifications/services.dart';

// === SERVICIOS LEGACY (MIGRAR GRADUALMENTE) ===
export 'services/auth_service.dart';
export 'services/house_service.dart';
export 'services/jwt_service.dart';
export 'services/http_interceptor_service.dart';
export 'services/home_screen/home_screen_services.dart';
export 'services/common/snackbar_service.dart';
export 'services/common/user_context_service.dart';
export 'services/auth/auth_logic_service.dart';
export 'services/house/house_creation_service.dart';
export 'services/home/home_selector_service.dart';

// === INTERFACES LEGACY (MIGRAR GRADUALMENTE) ===
export 'interfaces/home_screen/home_screen_interfaces.dart' hide NotificationType;

// === MODELOS LEGACY (MIGRAR GRADUALMENTE) ===
export 'models/api_models.dart';
export 'models/auth_models.dart';

// === COMPONENTES LEGACY (MIGRAR GRADUALMENTE) ===
export 'components/home_screen/home_screen_components.dart';
export 'components/auth_screen/auth_screen_components.dart';
export 'components/create_house_screen/create_house_screen_components.dart';
export 'components/settings_screen/settings_screen_components.dart';
export 'components/common/app_header.dart';
export 'components/common/dot_indicators.dart';

// === PANTALLAS ===
export 'screens/home_screen.dart';
export 'screens/auth_screen.dart';
export 'screens/home_selector_screen.dart';
export 'screens/house_chat_screen.dart';
export 'screens/shopping_list_screen.dart';
export 'screens/personal_space_screen.dart';
export 'screens/create_house_screen.dart';
export 'screens/settings_screen.dart';
