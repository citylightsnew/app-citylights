# 📱 Guía de Navegación - City Lights App

## 🎯 Resumen de Cambios

Se ha integrado completamente el **MainDashboardScreen** en la aplicación, reemplazando el dashboard antiguo y conectándolo con el sistema de autenticación mediante Provider.

## 🚀 Flujo de Navegación

### 1️⃣ Splash Screen (`/`)

- **Archivo**: `lib/screens/splash.dart`
- **Función**: Pantalla inicial con animación del logo
- **Comportamiento**:
  - ✅ Verifica si el usuario tiene sesión activa
  - ✅ Si tiene sesión y biometría → `BiometricAuthScreen`
  - ✅ Si tiene sesión sin biometría → `/dashboard` (MainDashboardScreen)
  - ✅ Si no tiene sesión → `/login`

### 2️⃣ Login Screen (`/login`)

- **Archivo**: `lib/screens/login.dart`
- **Función**: Autenticación de usuario
- **Comportamiento**:
  - Usuario ingresa email y contraseña
  - Navega a → `OtpVerificationScreen` (verificación 2FA)

### 3️⃣ OTP Verification Screen

- **Archivo**: `lib/screens/otp_verification.dart`
- **Función**: Verificación de código 2FA
- **Comportamiento**:
  - Usuario ingresa código de 6 dígitos
  - Opcionalmente habilita autenticación biométrica
  - Guarda sesión en `flutter_secure_storage`
  - **Actualiza el AuthProvider** con los datos del usuario
  - Navega a → `/dashboard` (MainDashboardScreen)

### 4️⃣ Main Dashboard Screen (`/dashboard`) ⭐

- **Archivo**: `lib/screens/main_dashboard_screen.dart`
- **Función**: Dashboard principal con módulos
- **Características**:
  - 🎨 UI/UX moderna con Material Design 3
  - 📊 12 módulos con tarjetas (cards) interactivas
  - 👤 Muestra información del usuario desde AuthProvider
  - 🔔 Notificaciones y navegación inferior
  - 🎯 Preparado para navegación a submódulos

## 📦 Módulos Disponibles

El dashboard incluye 12 módulos organizados en un grid 2x6:

| Módulo           | Icono             | Color              | Ruta            |
| ---------------- | ----------------- | ------------------ | --------------- |
| 🏢 Edificios     | building          | Azul (#2563EB)     | `/edificios`    |
| 🏠 Habitaciones  | doorOpen          | Púrpura (#8B5CF6)  | `/habitaciones` |
| 🚗 Garajes       | car               | Verde (#10B981)    | `/garajes`      |
| 🎯 Áreas Comunes | users             | Rosa (#EC4899)     | `/areas`        |
| 📅 Reservas      | calendarCheck     | Violeta (#8B5CF6)  | `/reservas`     |
| 💳 Pagos         | creditCard        | Verde (#10B981)    | `/pagos`        |
| 📄 Facturas      | fileInvoiceDollar | Naranja (#F59E0B)  | `/facturas`     |
| 👔 Empleados     | userTie           | Índigo (#6366F1)   | `/empleados`    |
| 💰 Nómina        | moneyBillWave     | Turquesa (#14B8A6) | `/nomina`       |
| 👥 Usuarios      | users             | Púrpura (#8B5CF6)  | `/users`        |
| 🔐 Roles         | userShield        | Rojo (#EF4444)     | `/roles`        |
| ⚙️ Configuración | gear              | Gris (#6B7280)     | `/settings`     |

## 🔧 Arquitectura Técnica

### Provider Setup

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MaterialApp(...)
)
```

### Rutas Nombradas

```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const MainDashboardScreen(),
}
```

### Estado de Autenticación

El `AuthProvider` mantiene:

- ✅ `User? user` - Datos del usuario actual
- ✅ `String? token` - Token de autenticación
- ✅ `bool isAuthenticated` - Estado de autenticación
- ✅ `bool isLoading` - Estado de carga

### Acceso al Usuario en MainDashboardScreen

```dart
final authProvider = Provider.of<AuthProvider>(context);
final user = authProvider.user;

// Mostrar nombre
Text('Hola, ${user?.name ?? "Usuario"}')

// Mostrar rol
Text(user?.role?.name ?? 'Usuario')
```

## 🎨 Personalización UI/UX

### Tema de la Aplicación

El dashboard usa el `AppTheme` configurado con:

- **Primary**: `#2563EB` (Azul brillante)
- **Secondary**: `#8B5CF6` (Púrpura vibrante)
- **Accent**: `#10B981` (Verde éxito)
- **Background**: `#0A0A0A` (Negro profundo)
- **Surface**: `#1A1A1A` (Gris oscuro)

### Componentes Clave

1. **SliverAppBar Expandible**: Header con gradiente y información del usuario
2. **Grid de Módulos**: 2 columnas con cards animadas
3. **NavigationBar**: Barra inferior con 4 opciones
4. **Cards Interactivas**: Con sombras, iconos y efectos hover

## 📝 Próximos Pasos

### 1. Implementar Pantallas de Módulos

Cada módulo necesita su propia pantalla:

```dart
// Ejemplo: lib/screens/edificios/edificios_screen.dart
class EdificiosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edificios')),
      body: // Implementar UI
    );
  }
}
```

### 2. Actualizar Navegación en MainDashboardScreen

```dart
onTap: () {
  Navigator.pushNamed(context, module.route);
}
```

### 3. Agregar Rutas en main.dart

```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const MainDashboardScreen(),
  '/edificios': (context) => const EdificiosScreen(),
  '/habitaciones': (context) => const HabitacionesScreen(),
  // ... más rutas
}
```

### 4. Implementar Servicios

Usar los servicios ya creados:

- `EdificioService` para edificios
- `BookingService` para reservas
- `PaymentService` para pagos
- etc.

## ✅ Testing

### Verificar Compilación

```bash
flutter analyze
```

### Ejecutar en Chrome (Web)

```bash
flutter run -d chrome
```

### Ejecutar en Android

```bash
flutter run -d <device_id>
```

## 🐛 Solución de Problemas

### Usuario no aparece en el Dashboard

**Problema**: El nombre del usuario muestra "Usuario" en lugar del nombre real.

**Solución**: Verificar que:

1. La sesión se guardó correctamente en `OtpVerificationScreen`
2. El `AuthProvider.loadStoredAuth()` se llamó después del login
3. Los datos están en `flutter_secure_storage`

### Navegación no funciona

**Problema**: Los botones de módulos no hacen nada.

**Solución**:

1. Verificar que las rutas estén definidas en `main.dart`
2. Crear las pantallas correspondientes
3. Actualizar el callback `onTap` en `_ModuleCard`

## 📚 Recursos

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Navigation](https://docs.flutter.dev/cookbook/navigation/named-routes)
- [Material Design 3](https://m3.material.io/)
- [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter)

---

**¡Dashboard listo para usar! 🎉**

El flujo completo de autenticación y navegación está funcionando. Ahora puedes empezar a implementar las pantallas individuales de cada módulo usando los servicios API ya creados.
