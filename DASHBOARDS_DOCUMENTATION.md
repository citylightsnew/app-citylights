# 🎨 Sistema de Dashboards Multi-Rol

Este documento describe el sistema de dashboards separados por roles implementado en la aplicación CityLights.

## 📋 Arquitectura

El sistema utiliza un **router** inteligente que detecta el rol del usuario y lo redirige automáticamente al dashboard correspondiente.

### Estructura de Archivos

```
lib/screens/dashboards/
├── dashboard_router.dart      # Router principal (detecta el rol)
├── admin_dashboard.dart        # Dashboard para administradores
├── staff_dashboard.dart        # Dashboard para personal
└── resident_dashboard.dart     # Dashboard para residentes
```

## 🎯 Dashboard Router

**Archivo:** `dashboard_router.dart`

### Funcionalidad

- Carga automática del usuario actual
- Detección del rol del usuario
- Redirección al dashboard apropiado
- Manejo de estados de carga y error

### Roles Soportados

```dart
switch (role.name.toLowerCase()) {
  case 'admin':
    return AdminDashboard(userName: userName, user: user);
  case 'staff':
    return StaffDashboard(userName: userName, user: user);
  case 'resident':
  default:
    return ResidentDashboard(userName: userName, user: user);
}
```

## 👨‍💼 Admin Dashboard

**Archivo:** `admin_dashboard.dart`
**Color Principal:** Púrpura (#8B5CF6)

### Características

#### 📊 Estadísticas Rápidas

- **Usuarios Totales:** Muestra total de usuarios registrados con tendencia
- **Reservas Activas:** Reservas en curso con porcentaje de cambio
- **Pagos Pendientes:** Pagos por cobrar con tendencia
- **Espacios Disponibles:** Áreas comunes disponibles

#### ⚡ Acciones Rápidas

- **Gestión de Usuarios:** Crear, editar, eliminar usuarios
- **Configuración de Roles:** Administrar permisos
- **Gestión de Reservas:** Ver y administrar todas las reservas
- **Gestión de Pagos:** Revisar y procesar pagos

#### 📈 Actividad Reciente

- Feed en tiempo real de las últimas acciones
- Nuevo usuario registrado
- Pago recibido
- Reserva creada

#### 🏢 Gestión de Edificios

- **Edificio A:** Vista general y estadísticas
- **Edificio B:** Vista general y estadísticas
- **Áreas Comunes:** Gestión de espacios compartidos

### Características Especiales

- ✅ Prompt automático para configurar 2FA
- 🎨 Gradientes púrpura/azul
- 📱 Interfaz responsive
- ⚡ Animaciones fluidas
- 🔒 Confirmación de cierre de sesión

## 👷 Staff Dashboard

**Archivo:** `staff_dashboard.dart`
**Color Principal:** Naranja (#FF9800)

### Características

#### 📊 Resumen del Día

- **Tareas:** Total y pendientes del día
- **Reservas:** Reservas programadas para hoy

#### 📝 Tareas Pendientes

- Lista priorizada de tareas
- **Alta prioridad:** Solicitudes urgentes (rojo)
- **Media prioridad:** Tareas importantes (naranja)
- **Baja prioridad:** Tareas regulares (verde)
- Información de ubicación para cada tarea

#### 🛠️ Herramientas de Trabajo

Grid de acceso rápido:

- **Reservas:** Gestión de reservas
- **Inspección:** Lista de verificación
- **Reportes:** Generación de informes
- **Residentes:** Directorio de contactos
- **Pagos:** Seguimiento de pagos
- **Chat:** Comunicación interna

#### 📋 Actividad Reciente

- Reservas confirmadas
- Nuevas solicitudes
- Tareas completadas
- Historial de acciones

### Características Especiales

- ✅ Prompt de configuración 2FA
- 🎨 Gradientes naranja/amarillo
- 🔔 Sistema de prioridades visual
- 📍 Información de ubicación
- ⏰ Timestamps de actividad

## 🏠 Resident Dashboard

**Archivo:** `resident_dashboard.dart`
**Color Principal:** Azul (#2563EB) / Cyan

### Características

#### ⚡ Acciones Rápidas

Grid de acceso directo:

- **Nueva Reserva:** Crear reserva de espacios
- **Mis Pagos:** Ver historial y estado de pagos
- **Notificaciones:** Centro de notificaciones
- **Mi Perfil:** Configuración de cuenta

#### 📅 Mis Reservas

- Vista de reservas activas
- **Estado: Confirmada** (verde)
- **Estado: Pendiente** (naranja)
- Información de fecha y hora
- Acceso rápido a detalles

#### 🎯 Servicios Disponibles

Lista de servicios accesibles:

- **Áreas Comunes:** Reserva de espacios compartidos
- **Mantenimiento:** Solicitud de reparaciones
- **Pagos en Línea:** Gestión de cuotas y pagos

### Características Especiales

- ✅ Prompt de seguridad 2FA
- 🎨 Gradientes azul/cyan
- 📱 Interfaz amigable
- 🔄 Estados visuales de reservas
- 🎯 Enfoque en servicios esenciales

## 🎨 Diseño UI/UX Compartido

Todos los dashboards comparten:

### Paleta de Colores Oscura

```dart
// Fondo principal
const backgroundColor = Color(0xFF0A0A0A);

// Cards y superficies
const cardGradient = LinearGradient(
  colors: [Color(0xFF1F1F2E), Color(0xFF16162A)],
);

// Bordes
border: Border.all(color: Colors.white.withValues(alpha: 0.1));
```

### Componentes Comunes

#### 🎭 AppBar Personalizado

- Header con gradiente
- Icono del rol con gradiente
- Badge del rol (Admin/Staff/Resident)
- Botón de logout con confirmación
- Saludo contextual (Buenos días/tardes/noches)

#### 🃏 Cards

- Glassmorphism effect
- Bordes sutiles con alpha 0.1
- Gradientes de fondo
- Border radius 20px
- Sombras suaves

#### 🎪 Animaciones

```dart
AnimationController + FadeTransition
- Duración: 800ms
- Curve: easeOut
- Fade in al cargar
```

#### 🎨 Iconos

- Contenedores con gradientes de color
- Border radius 12-16px
- Padding 10-12px
- Colores según el tipo de acción

### Interacciones

#### Botones de Acción

- Material InkWell para ripple effect
- Border radius consistente
- Hover states implícitos
- Feedback táctil

#### Diálogos

- Fondo oscuro (#1F1F2E)
- Border radius 20px
- Botones con colores semánticos
- Confirmaciones para acciones críticas

## 🔒 Seguridad

### Sistema 2FA

Todos los dashboards incluyen:

- Detección de primer login
- Prompt automático para configurar 2FA
- Diálogo no dismissible en primer login
- Navegación a `TwoFactorSetupScreen`

### Cierre de Sesión

```dart
Future<void> _handleLogout() async {
  // 1. Confirmar con diálogo
  // 2. Llamar AuthService.logout()
  // 3. Limpiar tokens y datos
  // 4. Redirigir a LoginScreen
  // 5. Limpiar stack de navegación
}
```

## 🔄 Flujo de Navegación

```
LoginScreen
    ↓
DashboardRouter
    ↓
┌───────────┬───────────┬───────────┐
│   Admin   │   Staff   │ Resident  │
│ Dashboard │ Dashboard │ Dashboard │
└───────────┴───────────┴───────────┘
```

## 🚀 Uso

### Desde el Login

```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) => DashboardRouter(
      userName: user.name,
      user: user,
    ),
  ),
);
```

### Navegación Directa (si ya tienes el usuario)

```dart
// Admin
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminDashboard(
      userName: user.name,
      user: user,
    ),
  ),
);

// Staff
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StaffDashboard(
      userName: user.name,
      user: user,
    ),
  ),
);

// Resident
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ResidentDashboard(
      userName: user.name,
      user: user,
    ),
  ),
);
```

## ✨ Mejoras Futuras

### Funcionalidades Pendientes

- [ ] Conectar las acciones rápidas con las pantallas correspondientes
- [ ] Implementar navegación a perfiles y configuraciones
- [ ] Agregar notificaciones push
- [ ] Sistema de chat integrado
- [ ] Gráficos interactivos en estadísticas
- [ ] Filtros y búsqueda en listas
- [ ] Modo offline con sincronización
- [ ] Temas personalizables por usuario
- [ ] Widgets arrastrables en el dashboard
- [ ] Shortcuts de teclado para acciones rápidas

### Optimizaciones

- [ ] Lazy loading de datos
- [ ] Caché de imágenes y datos
- [ ] Paginación en listas largas
- [ ] Reducir rebuilds innecesarios
- [ ] Optimizar animaciones

## 📱 Responsive Design

Todos los dashboards están diseñados para funcionar en:

- 📱 Móviles (portrait/landscape)
- 📱 Tablets
- 💻 Desktop (web/windows/macos/linux)

### Breakpoints Sugeridos

```dart
// Mobile: < 600px
// Tablet: 600px - 1024px
// Desktop: > 1024px
```

## 🎯 Conclusión

El sistema de dashboards multi-rol proporciona:

- ✅ Separación clara de funcionalidades por rol
- ✅ UI/UX consistente y profesional
- ✅ Tema oscuro moderno con glassmorphism
- ✅ Animaciones fluidas y atractivas
- ✅ Seguridad con 2FA integrado
- ✅ Experiencia personalizada según el usuario
- ✅ Código mantenible y escalable

---

**Creado:** 2024  
**Versión:** 1.0.0  
**Framework:** Flutter 3.x  
**Diseño:** Material Design 3 + Dark Theme
