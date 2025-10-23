# 🗺️ Roadmap - City Lights Mobile App

## ✅ Completado - Sesión 1: Login & Auth Foundation

### Estructura Base

- [x] Configuración de tema dark mode
- [x] Constantes de API
- [x] Modelos de datos (User, Auth)
- [x] Servicios core (API, Auth, Storage)
- [x] Provider de autenticación
- [x] Widgets reutilizables

### Login Flow

- [x] Pantalla de login
- [x] Validación de formularios
- [x] 2FA por email
- [x] 2FA por push notification con polling
- [x] Animaciones UI
- [x] Manejo de errores
- [x] Persistencia de sesión

---

## 🎯 Próxima Sesión: Register & Verification

### 1. Register Screen

- [ ] Formulario de registro completo
- [ ] Validación de contraseña fuerte
  - Mínimo 8 caracteres
  - Al menos 1 mayúscula
  - Al menos 1 número
  - Al menos 1 símbolo
- [ ] Confirmación de contraseña
- [ ] Términos y condiciones
- [ ] Campo de teléfono opcional

### 2. Email Verification Screen

- [ ] Pantalla de verificación
- [ ] Input de código OTP
- [ ] Timer de expiración
- [ ] Reenvío de código
- [ ] Validación automática

### 3. Forgot Password Flow

- [ ] Pantalla de recuperación
- [ ] Envío de código
- [ ] Verificación de código
- [ ] Nueva contraseña
- [ ] Confirmación

**Archivos a crear:**

```
lib/screens/auth/
  ├── register_screen.dart
  ├── verify_email_screen.dart
  ├── forgot_password_screen.dart
  └── reset_password_screen.dart
```

---

## 📱 Sesión 3: Dashboard & Navigation

### 1. Dashboard Base

- [ ] Bottom Navigation Bar
- [ ] Drawer lateral
- [ ] AppBar personalizado
- [ ] Manejo de roles (Admin, Trabajador, Usuario)

### 2. Home Screen

- [ ] Welcome card con nombre de usuario
- [ ] Estadísticas rápidas
- [ ] Accesos rápidos
- [ ] Notificaciones recientes

### 3. Profile Screen

- [ ] Información del usuario
- [ ] Editar perfil
- [ ] Cambiar contraseña
- [ ] Configuración de 2FA
- [ ] Logout

**Archivos a crear:**

```
lib/screens/
  ├── dashboard/
  │   ├── dashboard_screen.dart
  │   ├── home_screen.dart
  │   └── profile_screen.dart
  └── widgets/
      ├── custom_bottom_nav.dart
      ├── custom_drawer.dart
      └── custom_app_bar.dart
```

---

## 🏢 Sesión 4: Edificios & Habitaciones

### 1. Edificios

- [ ] Lista de edificios
- [ ] Detalle de edificio
- [ ] Crear edificio (Admin)
- [ ] Editar edificio (Admin)

### 2. Habitaciones

- [ ] Lista de habitaciones por edificio
- [ ] Detalle de habitación
- [ ] Asignar usuario a habitación (Admin)
- [ ] Mis habitaciones (Usuario)

### 3. Servicios & Models

```dart
// edificio_service.dart
// habitacion_service.dart
// edificio_model.dart
// habitacion_model.dart
```

**Archivos a crear:**

```
lib/
  ├── core/
  │   ├── models/
  │   │   ├── edificio_model.dart
  │   │   └── habitacion_model.dart
  │   └── services/
  │       ├── edificio_service.dart
  │       └── habitacion_service.dart
  ├── providers/
  │   ├── edificio_provider.dart
  │   └── habitacion_provider.dart
  └── screens/
      └── edificio/
          ├── edificios_screen.dart
          ├── edificio_detail_screen.dart
          ├── habitaciones_screen.dart
          └── widgets/
              ├── edificio_card.dart
              └── habitacion_card.dart
```

---

## 📅 Sesión 5: Reservas & Áreas Comunes

### 1. Áreas Comunes

- [ ] Lista de áreas comunes
- [ ] Filtros por tipo
- [ ] Calendario de disponibilidad
- [ ] Detalle de área

### 2. Reservas

- [ ] Crear reserva
- [ ] Mis reservas
- [ ] Cancelar reserva
- [ ] Aprobar/Rechazar (Admin/Trabajador)
- [ ] Calendario mensual
- [ ] Timeline diario

### 3. Bloqueos (Admin)

- [ ] Crear bloqueo
- [ ] Editar bloqueo
- [ ] Eliminar bloqueo

**Archivos a crear:**

```
lib/
  ├── core/
  │   ├── models/
  │   │   ├── area_comun_model.dart
  │   │   ├── reserva_model.dart
  │   │   └── bloqueo_model.dart
  │   └── services/
  │       └── booking_service.dart
  ├── providers/
  │   └── booking_provider.dart
  └── screens/
      └── booking/
          ├── areas_comunes_screen.dart
          ├── area_detail_screen.dart
          ├── crear_reserva_screen.dart
          ├── mis_reservas_screen.dart
          ├── calendario_screen.dart
          └── widgets/
              ├── area_card.dart
              ├── reserva_card.dart
              ├── calendario_widget.dart
              └── time_slot_picker.dart
```

---

## 💰 Sesión 6: Pagos & Facturas

### 1. Pagos

- [ ] Lista de pagos pendientes
- [ ] Historial de pagos
- [ ] Detalle de pago
- [ ] Pagar con Stripe
- [ ] Comprobantes

### 2. Facturas

- [ ] Generar factura
- [ ] Descargar factura PDF
- [ ] Historial de facturas
- [ ] Detalles de factura

**Archivos a crear:**

```
lib/
  ├── core/
  │   ├── models/
  │   │   ├── pago_model.dart
  │   │   └── factura_model.dart
  │   └── services/
  │       └── payments_service.dart
  ├── providers/
  │   └── payments_provider.dart
  └── screens/
      └── payments/
          ├── pagos_screen.dart
          ├── pago_detail_screen.dart
          ├── facturas_screen.dart
          └── widgets/
              ├── pago_card.dart
              ├── factura_card.dart
              └── stripe_checkout.dart
```

---

## 👥 Sesión 7: Gestión de Usuarios (Admin)

### 1. Usuarios

- [ ] Lista de usuarios
- [ ] Filtros y búsqueda
- [ ] Detalle de usuario
- [ ] Crear usuario
- [ ] Editar usuario
- [ ] Asignar roles
- [ ] Asignar habitaciones

### 2. Roles

- [ ] Lista de roles
- [ ] Crear rol
- [ ] Editar permisos
- [ ] Asignar a usuarios

**Archivos a crear:**

```
lib/
  ├── core/
  │   ├── models/
  │   │   ├── role_model.dart
  │   │   └── permission_model.dart
  │   └── services/
  │       ├── user_service.dart
  │       └── role_service.dart
  ├── providers/
  │   ├── user_provider.dart
  │   └── role_provider.dart
  └── screens/
      └── admin/
          ├── users_screen.dart
          ├── user_detail_screen.dart
          ├── roles_screen.dart
          └── widgets/
              ├── user_card.dart
              └── role_selector.dart
```

---

## 💼 Sesión 8: Nómina (Admin/Trabajador)

### 1. Empleados

- [ ] Lista de empleados
- [ ] Detalle de empleado
- [ ] Crear empleado
- [ ] Editar empleado

### 2. Pagos de Nómina

- [ ] Generar pago
- [ ] Historial de pagos
- [ ] Reportes

**Archivos a crear:**

```
lib/
  ├── core/
  │   ├── models/
  │   │   ├── empleado_model.dart
  │   │   └── pago_nomina_model.dart
  │   └── services/
  │       └── nomina_service.dart
  ├── providers/
  │   └── nomina_provider.dart
  └── screens/
      └── nomina/
          ├── empleados_screen.dart
          ├── empleado_detail_screen.dart
          ├── pagos_nomina_screen.dart
          └── widgets/
              ├── empleado_card.dart
              └── pago_nomina_card.dart
```

---

## 🔔 Sesión 9: Notificaciones Push

### 1. Firebase Setup

- [ ] Configurar Firebase
- [ ] FCM Token management
- [ ] Registrar dispositivo

### 2. Notificaciones

- [ ] Foreground notifications
- [ ] Background notifications
- [ ] Tap handlers
- [ ] Deep linking
- [ ] Badge count

### 3. Preferencias

- [ ] Activar/desactivar por tipo
- [ ] Sonidos personalizados

**Archivos a crear:**

```
lib/
  ├── core/
  │   └── services/
  │       ├── firebase_service.dart
  │       └── notification_service.dart
  ├── providers/
  │   └── notification_provider.dart
  └── screens/
      └── notifications/
          ├── notifications_screen.dart
          └── notification_settings_screen.dart
```

---

## 🔐 Sesión 10: Seguridad & Optimizaciones

### 1. Biometric Auth

- [ ] Configurar local_auth
- [ ] Login con huella/Face ID
- [ ] Configuración de preferencias

### 2. Offline Mode

- [ ] Cache de datos
- [ ] SQLite local
- [ ] Sincronización

### 3. Performance

- [ ] Image caching
- [ ] Lazy loading
- [ ] Pagination
- [ ] Optimización de builds

**Archivos a crear:**

```
lib/
  ├── core/
  │   └── services/
  │       ├── biometric_service.dart
  │       ├── cache_service.dart
  │       └── database_service.dart
  └── screens/
      └── settings/
          └── security_settings_screen.dart
```

---

## 🚀 Sesión 11: Testing & QA

### 1. Unit Tests

- [ ] Tests de servicios
- [ ] Tests de providers
- [ ] Tests de modelos

### 2. Widget Tests

- [ ] Tests de screens
- [ ] Tests de widgets

### 3. Integration Tests

- [ ] Flujos completos
- [ ] Login flow
- [ ] Booking flow

---

## 📦 Sesión 12: Build & Deploy

### 1. Android

- [ ] Firma de APK
- [ ] Build release
- [ ] Play Store setup

### 2. iOS

- [ ] Certificados
- [ ] Provisioning profiles
- [ ] App Store setup

### 3. CI/CD

- [ ] GitHub Actions
- [ ] Automated builds
- [ ] Automated tests

---

## 🎨 Extras Opcionales

### Features Adicionales

- [ ] Modo claro/oscuro toggle
- [ ] Múltiples idiomas (i18n)
- [ ] Chat entre usuarios
- [ ] Sistema de tickets
- [ ] Reportes y analytics
- [ ] Export PDF de reportes
- [ ] Galería de fotos
- [ ] Mapa de ubicación
- [ ] QR Scanner
- [ ] Compartir en redes sociales

---

## 📊 Métricas de Progreso

**Actual:** 1/12 sesiones (8.3%)

- ✅ Sesión 1: Login & Auth Foundation

**Próximo objetivo:** Sesión 2 (Register & Verification)

---

¿Por dónde quieres continuar? Puedo ayudarte con:

1. **Register Screen** - Formulario de registro completo
2. **Dashboard** - Estructura principal de navegación
3. **Áreas Comunes** - Gestión de reservas
4. Cualquier otra característica que necesites
