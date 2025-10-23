# 🎯 Dashboard Basado en Roles - City Lights App

## 📋 Descripción General

El sistema de dashboard implementa una arquitectura basada en roles que replica la funcionalidad del frontend web. Los usuarios ven diferentes interfaces según sus roles asignados:

- **Administradores y Super-Usuarios**: Panel completo de administración con sidebar de navegación
- **Usuarios Regulares**: Dashboard simplificado con información personal y acciones rápidas

---

## 🏗️ Arquitectura

```
lib/screens/dashboard/
├── dashboard_screen.dart       # Wrapper que enruta según rol
├── admin/
│   └── admin_dashboard.dart    # Panel de administración completo
└── user/
    └── user_dashboard.dart     # Dashboard de usuario regular
```

### Flujo de Navegación

```
DashboardScreen (Wrapper)
    ├── Consumer<AuthProvider>
    ├── user.roles contains 'admin' || 'super-user'
    │   └── AdminDashboard
    └── else
        └── UserDashboard
```

---

## 🔐 Detección de Roles

### Lógica de Detección (dashboard_screen.dart)

```dart
bool _isAdmin(UserModel user) {
  return user.roles.any((role) =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'super-user');
}
```

### Roles Soportados

| Rol          | Descripción            | Dashboard      |
| ------------ | ---------------------- | -------------- |
| `admin`      | Administrador completo | AdminDashboard |
| `super-user` | Super administrador    | AdminDashboard |
| `user`       | Usuario regular        | UserDashboard  |

---

## 👨‍💼 Admin Dashboard

### Características

1. **AppBar con información del administrador**

   - Logo de City Lights
   - Nombre y apellido del usuario
   - Indicador de rol (🛡️ Administrador)
   - Botón de logout

2. **Sidebar de navegación (240px)**

   - Dashboard (Panel Principal)
   - Usuarios
   - Roles
   - Habitaciones
   - Áreas Comunes
   - Reservas

3. **Vista de Dashboard Principal**

   - Grid de estadísticas (4 cards):
     - Usuarios
     - Reservas
     - Habitaciones
     - Áreas Comunes
   - Acciones rápidas:
     - Nuevo Usuario
     - Nueva Reserva
     - Gestionar Áreas
     - Ver Habitaciones

4. **Vistas Secundarias**
   - Usuarios: Próximamente
   - Roles: Próximamente
   - Habitaciones: Próximamente
   - Áreas Comunes: Próximamente
   - Reservas: Próximamente

### Componentes del Admin Dashboard

#### MenuItem

```dart
class MenuItem {
  final String id;          // 'dashboard', 'users', etc.
  final String label;       // 'Panel Principal', 'Usuarios', etc.
  final IconData icon;      // Icons.dashboard_outlined, etc.
}
```

#### \_StatCard

```dart
class _StatCard {
  final String title;       // 'Usuarios', 'Reservas', etc.
  final String value;       // Número de elementos
  final IconData icon;      // Icono representativo
  final Color color;        // Color del tema (blue, green, etc.)
}
```

#### \_QuickAction

```dart
class _QuickAction {
  final String title;       // 'Nuevo Usuario', etc.
  final IconData icon;      // Icono de la acción
  final Color color;        // Color del tema
  final VoidCallback onTap; // Handler del clic
}
```

### Navegación en Admin Dashboard

```dart
String _activeView = 'dashboard';  // Estado actual

void _changeView(String viewId) {
  setState(() {
    _activeView = viewId;
  });
}

Widget _buildContent(ThemeData theme) {
  switch (_activeView) {
    case 'dashboard':
      return _buildDashboardView(theme);
    case 'users':
      return _buildComingSoon(theme, 'Gestión de Usuarios');
    // ... otras vistas
  }
}
```

### Colores del Admin Dashboard

| Elemento      | Color                    |
| ------------- | ------------------------ |
| Usuarios      | Blue (`Colors.blue`)     |
| Reservas      | Green (`Colors.green`)   |
| Habitaciones  | Purple (`Colors.purple`) |
| Áreas Comunes | Orange (`Colors.orange`) |

---

## 👤 User Dashboard

### Características

1. **AppBar simplificado**

   - Logo de City Lights
   - Botón de logout

2. **Header de bienvenida con saludo dinámico**

   - "Buenos días" (6:00 - 11:59)
   - "Buenas tardes" (12:00 - 18:59)
   - "Buenas noches" (19:00 - 5:59)
   - Nombre completo del usuario

3. **Card de información personal**

   - Email
   - Teléfono
   - ID de usuario

4. **Card de propiedad (si está asignada)**

   - Número de habitación
   - Garajes asignados

5. **Grid de acciones rápidas (2x2)**
   - Reservar Área Común
   - Mis Reservas
   - Historial de Pagos
   - Soporte

### Pull-to-Refresh

El User Dashboard incluye funcionalidad de pull-to-refresh para actualizar datos:

```dart
RefreshIndicator(
  onRefresh: _handleRefresh,
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: // ... contenido
  ),
)
```

### Acciones Rápidas

```dart
class _QuickAction {
  final String title;       // 'Reservar Área Común'
  final String subtitle;    // Descripción corta
  final IconData icon;      // Icono
  final Color color;        // Color del tema
  final VoidCallback onTap; // Handler
}
```

| Acción              | Color  | Icono                    |
| ------------------- | ------ | ------------------------ |
| Reservar Área Común | Green  | event_available_outlined |
| Mis Reservas        | Blue   | calendar_today_outlined  |
| Historial de Pagos  | Orange | receipt_long_outlined    |
| Soporte             | Purple | support_agent_outlined   |

---

## 🎨 Diseño y UI/UX

### Tema Oscuro (Material Design 3)

Ambos dashboards utilizan el tema oscuro configurado globalmente:

```dart
ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
)
```

### Componentes Reutilizables

#### Cards

- Elevación: 2
- Border radius: 16px
- Padding: 24px

#### Botones y ListTiles

- Border radius: 12px
- Iconos con colores temáticos
- Hover effects (InkWell)

#### Iconos

- Outlined style para consistencia
- Tamaños: 20-28px según contexto
- Con background circular de color temático con opacity 0.1

---

## 🔄 Ciclo de Vida

### Inicialización

1. Usuario completa login + 2FA
2. AuthProvider guarda usuario con roles
3. Navegación a `/dashboard`
4. DashboardScreen lee `authProvider.user`
5. Evalúa roles con `_isAdmin()`
6. Renderiza AdminDashboard o UserDashboard

### Logout

```dart
Future<void> _handleLogout() async {
  final confirmed = await showDialog<bool>(
    // ... diálogo de confirmación
  );

  if (confirmed == true && mounted) {
    await context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
```

---

## 📊 Estado y Datos

### User Dashboard - Estado Local

```dart
Map<String, dynamic>? _habitacionData;  // Datos de la habitación
List<dynamic> _garajesData = [];        // Lista de garajes
```

### Admin Dashboard - Estado Local

```dart
String _activeView = 'dashboard';  // Vista activa del sidebar
```

### AuthProvider - Estado Global

```dart
UserModel? user;                    // Usuario autenticado
List<String> roles;                 // Roles del usuario
String? token;                      // JWT token
```

---

## 🚀 Próximas Implementaciones

### Admin Dashboard

- [ ] Módulo de Usuarios
  - Lista de usuarios con búsqueda
  - Crear nuevo usuario
  - Editar usuario
  - Asignar roles
- [ ] Módulo de Roles
  - Gestión de permisos
  - Crear/editar roles
- [ ] Módulo de Habitaciones
  - Lista de habitaciones
  - Asignar a usuarios
  - Estado de ocupación
- [ ] Módulo de Áreas Comunes
  - Lista de áreas
  - Configuración de disponibilidad
  - Ver reservas
- [ ] Módulo de Reservas
  - Calendario de reservas
  - Aprobar/rechazar reservas
  - Reportes

### User Dashboard

- [ ] Integración con API
  - Fetch habitación asignada
  - Fetch garajes asignados
  - Actualizar datos personales
- [ ] Módulo de Reservas
  - Ver áreas disponibles
  - Crear nueva reserva
  - Cancelar reserva
  - Ver historial
- [ ] Módulo de Pagos
  - Ver facturas pendientes
  - Historial de pagos
  - Descargar comprobantes

---

## 🧪 Testing

### Casos de Prueba

1. **Test de Rol Admin**

```dart
// Usuario con rol 'admin' debe ver AdminDashboard
final user = UserModel(roles: ['admin']);
expect(_isAdmin(user), true);
```

2. **Test de Rol Super-User**

```dart
// Usuario con rol 'super-user' debe ver AdminDashboard
final user = UserModel(roles: ['super-user']);
expect(_isAdmin(user), true);
```

3. **Test de Usuario Regular**

```dart
// Usuario con rol 'user' debe ver UserDashboard
final user = UserModel(roles: ['user']);
expect(_isAdmin(user), false);
```

4. **Test de Múltiples Roles**

```dart
// Usuario con múltiples roles incluyendo admin
final user = UserModel(roles: ['user', 'admin']);
expect(_isAdmin(user), true);
```

---

## 📝 Notas Técnicas

### Performance

- **DashboardScreen es StatelessWidget**: No mantiene estado propio
- **Consumer<AuthProvider>**: Solo reconstruye cuando cambia authProvider
- **Sidebar en AdminDashboard**: Usa ListView para scroll eficiente
- **GridView con shrinkWrap**: Para contenido estático sin scroll

### Accesibilidad

- Todos los botones tienen tooltips
- Iconos con labels descriptivos
- Contraste de colores según Material Design 3
- Tamaños táctiles mínimos de 48x48px

### Responsive Design

- AdminDashboard optimizado para tablets (landscape)
- UserDashboard optimizado para móviles (portrait)
- Grid adapta columnas según espacio disponible

---

## 🔗 Integración con Backend

### Endpoints Requeridos

#### Admin Dashboard

```
GET  /api/admin/stats              # Estadísticas generales
GET  /api/admin/users              # Lista de usuarios
POST /api/admin/users              # Crear usuario
GET  /api/admin/habitaciones       # Lista de habitaciones
GET  /api/admin/areas-comunes      # Lista de áreas
GET  /api/admin/reservas           # Lista de reservas
```

#### User Dashboard

```
GET  /api/users/me                 # Datos del usuario
GET  /api/users/me/habitacion      # Habitación asignada
GET  /api/users/me/garajes         # Garajes asignados
GET  /api/users/me/reservas        # Reservas del usuario
GET  /api/users/me/pagos           # Historial de pagos
```

---

## 🎯 Conclusión

El sistema de dashboard basado en roles proporciona una experiencia diferenciada según el perfil del usuario:

- **Administradores**: Panel completo con sidebar de navegación y gestión avanzada
- **Usuarios**: Dashboard simplificado enfocado en información personal y acciones cotidianas

La arquitectura modular permite fácil extensión y mantenimiento, mientras que el uso de Material Design 3 asegura una UI moderna y consistente.

---

**Última actualización**: ${DateTime.now().toString().split('.')[0]}  
**Versión**: 1.0.0  
**Autor**: City Lights Development Team
