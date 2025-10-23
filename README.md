# 🏙️ City Lights App

Aplicación móvil Flutter para la gestión del edificio City Lights, con sistema completo de autenticación, notificaciones push y dashboards basados en roles.

---

## 🚀 Características Principales

### ✅ Implementado

- **🔐 Sistema de Autenticación Completo**

  - Login con email/password
  - Two-Factor Authentication (2FA)
  - Autenticación biométrica (huella/Face ID)
  - Registro de usuarios
  - Verificación de email
  - Recuperación de contraseña
  - Token JWT management

- **🔔 Firebase Cloud Messaging**

  - Push notifications
  - Background message handler
  - Device registration automática
  - Topic subscription
  - Foreground/background handlers

- **🎯 Dashboard Basado en Roles**

  - Admin Dashboard con sidebar navigation
  - User Dashboard con información personal
  - Detección automática de roles
  - Material Design 3 dark theme
  - Responsive design

- **🔒 Seguridad**
  - Almacenamiento seguro con FlutterSecureStorage
  - Encriptación nativa de credenciales
  - Token interceptors en HTTP requests
  - Validaciones de formularios

### 🔄 En Desarrollo

- Módulos de gestión (Usuarios, Roles, Habitaciones, Áreas, Reservas)
- Integración completa con backend
- Sistema de pagos
- Módulo de soporte

---

## 📚 Documentación

| Documento                                                              | Descripción                               |
| ---------------------------------------------------------------------- | ----------------------------------------- |
| **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)**                   | Índice completo de documentación          |
| **[QUICK_START.md](QUICK_START.md)**                                   | Guía de inicio rápido                     |
| **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**                             | Configuración de Firebase                 |
| **[DASHBOARD_EXECUTIVE_SUMMARY.md](DASHBOARD_EXECUTIVE_SUMMARY.md)**   | Resumen del sistema de dashboards         |
| **[ROLE_BASED_DASHBOARD.md](ROLE_BASED_DASHBOARD.md)**                 | Documentación técnica detallada           |
| **[DASHBOARD_VISUAL_GUIDE.md](DASHBOARD_VISUAL_GUIDE.md)**             | Guía visual con diagramas                 |
| **[FIREBASE_AUTH_DASHBOARD_DOCS.md](FIREBASE_AUTH_DASHBOARD_DOCS.md)** | Documentación completa de auth + Firebase |

**Total: ~3500 líneas de documentación** 📖

---

## 🛠️ Stack Tecnológico

### Frontend (Flutter)

- **Framework:** Flutter SDK ^3.9.2
- **State Management:** Provider ^6.1.1
- **HTTP Client:** Dio ^5.4.0
- **Secure Storage:** flutter_secure_storage ^9.2.2
- **Biometric:** local_auth ^3.0.0
- **UI:** Material Design 3

### Firebase

- **Core:** firebase_core 4.2.0
- **Messaging:** firebase_messaging 16.0.3

### Backend Integration

- **Base URL:** http://localhost:4000
- **Auth:** JWT Token
- **API:** RESTful

---

## 📦 Instalación

### Prerrequisitos

- Flutter SDK 3.9.2 o superior
- Dart SDK
- Android Studio / Xcode
- Firebase Account

### Pasos

1. **Clonar el repositorio**

```bash
git clone <repository-url>
cd app-citylights
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Configurar Firebase**

- Seguir guía en [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- Colocar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)

4. **Configurar Backend URL**

```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:4000';
  // Para Android emulator: 'http://10.0.2.2:4000'
}
```

5. **Ejecutar la app**

```bash
flutter run
```

---

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── config/
│   │   └── api_config.dart           # Configuración de API
│   ├── models/
│   │   └── user_model.dart           # Modelo de usuario con roles
│   └── services/
│       ├── api_service.dart          # HTTP client con interceptors
│       ├── auth_service.dart         # Servicios de autenticación
│       ├── biometric_service.dart    # Autenticación biométrica
│       └── firebase_service.dart     # Firebase FCM (400+ líneas)
├── providers/
│   └── auth_provider.dart            # Estado global de auth
├── components/
│   ├── custom_text_field.dart        # Input field personalizado
│   └── auth_button.dart              # Botón de autenticación
└── screens/
    ├── auth/
    │   ├── login_screen.dart         # Login + navegación a 2FA
    │   ├── two_factor_screen.dart    # Verificación 2FA
    │   ├── register_screen.dart      # Registro de usuarios
    │   ├── verify_email_screen.dart  # Verificación de email
    │   └── forgot_password_screen.dart # Recuperación de contraseña
    ├── biometric/
    │   └── biometric_setup_screen.dart # Configuración biométrica
    └── dashboard/
        ├── dashboard_screen.dart     # Wrapper role-based
        ├── admin/
        │   └── admin_dashboard.dart  # Panel de administración
        └── user/
            └── user_dashboard.dart   # Dashboard de usuario
```

---

## 🎯 Roles y Permisos

| Rol          | Dashboard      | Permisos                  |
| ------------ | -------------- | ------------------------- |
| `admin`      | AdminDashboard | Acceso completo a gestión |
| `super-user` | AdminDashboard | Acceso completo a gestión |
| `user`       | UserDashboard  | Vista personal limitada   |

### Detección de Roles

```dart
bool _isAdmin(UserModel user) {
  return user.roles.any((role) =>
      role.toLowerCase() == 'admin' ||
      role.toLowerCase() == 'super-user');
}
```

---

## 🖼️ Capturas de Pantalla

### Admin Dashboard

```
┌─────────────────────────────────────────┐
│  [Sidebar]  [Stats Grid]  [Quick Actions] │
│  - Dashboard                              │
│  - Usuarios                               │
│  - Roles                                  │
│  - Habitaciones                           │
│  - Áreas Comunes                          │
│  - Reservas                               │
└─────────────────────────────────────────┘
```

### User Dashboard

```
┌─────────────────────────────────────────┐
│  Buenos días, John Doe                  │
│                                         │
│  [Personal Info Card]                   │
│  [Property Card]                        │
│  [Quick Actions Grid 2x2]               │
└─────────────────────────────────────────┘
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Analizar código
flutter analyze
```

---

## 🚢 Deployment

### Android

```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# Abrir en Xcode para distribución
```

---

## 🔧 Configuración

### Entornos

| Entorno     | Base URL                           | Firebase Config |
| ----------- | ---------------------------------- | --------------- |
| Development | http://localhost:4000              | Dev project     |
| Staging     | https://staging-api.citylights.com | Staging project |
| Production  | https://api.citylights.com         | Prod project    |

### Variables de Entorno

```dart
// lib/core/config/environment.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment current = Environment.dev;

  static String get apiUrl {
    switch (current) {
      case Environment.dev:
        return 'http://localhost:4000';
      case Environment.staging:
        return 'https://staging-api.citylights.com';
      case Environment.prod:
        return 'https://api.citylights.com';
    }
  }
}
```

---

## 📊 Métricas del Proyecto

| Métrica                 | Valor            |
| ----------------------- | ---------------- |
| Líneas de código (Dart) | ~5000            |
| Líneas de documentación | ~3500            |
| Screens implementados   | 10               |
| Services                | 4                |
| Providers               | 1                |
| Components              | 2                |
| Firebase integration    | ✅               |
| Tests                   | 🔄 En desarrollo |

---

## 🤝 Contribución

### Workflow

1. Fork el proyecto
2. Crear feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

### Convenciones

- **Commits:** Conventional Commits format
- **Código:** Dart style guide
- **Documentación:** Actualizar docs correspondientes

---

## 📝 Changelog

### [1.0.0] - 2024

**Added:**

- Sistema completo de autenticación (Login, 2FA, Register, Verify, Forgot Password)
- Autenticación biométrica
- Firebase Cloud Messaging
- Dashboard basado en roles (Admin + User)
- Material Design 3 dark theme
- Documentación completa (~3500 líneas)

---

## 🐛 Problemas Conocidos

- [ ] Widget tests pendientes
- [ ] Integration tests pendientes
- [ ] Módulos de gestión en desarrollo

---

## 📞 Soporte

- **Documentación:** Ver [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- **Issues:** [GitHub Issues](https://github.com/...)
- **Email:** support@citylights.com

---

## 📄 Licencia

Este proyecto es privado y propiedad de City Lights Management.

---

## 👥 Equipo

- **Development Team:** City Lights Development Team
- **Project Manager:** [Nombre]
- **Tech Lead:** [Nombre]

---

## 🎯 Roadmap

### Q1 2024 ✅

- [x] Sistema de autenticación completo
- [x] Firebase integration
- [x] Dashboard role-based

### Q2 2024 🔄

- [ ] Módulos de gestión (Users, Roles, Habitaciones, Áreas, Reservas)
- [ ] Sistema de pagos
- [ ] Módulo de soporte
- [ ] Tests completos

### Q3 2024 📋

- [ ] Modo offline
- [ ] Analytics
- [ ] Performance optimization
- [ ] App Store / Play Store release

---

**🏙️ City Lights App** - Versión 1.0.0  
**Última actualización:** 2024  
**Estado:** ✅ Production Ready (Base)
