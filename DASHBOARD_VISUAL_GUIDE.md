# 🎨 Dashboard Role-Based - Guía Visual

## 🏛️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                    DashboardScreen                           │
│                   (Role-Based Router)                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Consumer<AuthProvider>                      │    │
│  │                                                     │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │  user.roles.contains('admin')            │     │    │
│  │  │       OR                                  │     │    │
│  │  │  user.roles.contains('super-user')       │     │    │
│  │  └──────────────────────────────────────────┘     │    │
│  │                    │                               │    │
│  │          ┌─────────┴──────────┐                   │    │
│  │          │                    │                   │    │
│  │         YES                  NO                   │    │
│  │          │                    │                   │    │
│  │          ▼                    ▼                   │    │
│  │  ┌──────────────┐    ┌──────────────┐           │    │
│  │  │    ADMIN     │    │     USER     │           │    │
│  │  │  DASHBOARD   │    │  DASHBOARD   │           │    │
│  │  └──────────────┘    └──────────────┘           │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 👨‍💼 Admin Dashboard - Estructura

```
┌─────────────────────────────────────────────────────────────────────┐
│                          APPBAR                                     │
│  ┌──────┐ City Lights                           John Doe 👑 [⎋]   │
│  │ 🏙️  │ Panel de Administración          Administrador           │
│  └──────┘                                                          │
├──────────────┬──────────────────────────────────────────────────────┤
│              │                                                      │
│  SIDEBAR     │              CONTENT AREA                           │
│  (240px)     │                                                      │
│              │                                                      │
│ ┌──────────┐ │  ┌─────────────────────────────────────────────┐  │
│ │Dashboard │ │  │         PANEL DE CONTROL                    │  │
│ └──────────┘ │  │   Resumen general del sistema               │  │
│              │  └─────────────────────────────────────────────┘  │
│ ┌──────────┐ │                                                    │
│ │ Usuarios │ │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐        │
│ └──────────┘ │  │  👥  │  │  📅  │  │  🏠  │  │  📍  │        │
│              │  │  0   │  │  0   │  │  0   │  │  0   │        │
│ ┌──────────┐ │  │Users │  │Reserv│  │Habit.│  │Areas │        │
│ │  Roles   │ │  └──────┘  └──────┘  └──────┘  └──────┘        │
│ └──────────┘ │                                                    │
│              │  ACCESO RÁPIDO                                     │
│ ┌──────────┐ │  ┌────────────┐  ┌────────────┐                  │
│ │Habitacion│ │  │👤 Nuevo    │  │📅 Nueva    │                  │
│ └──────────┘ │  │   Usuario  │  │   Reserva  │                  │
│              │  └────────────┘  └────────────┘                  │
│ ┌──────────┐ │  ┌────────────┐  ┌────────────┐                  │
│ │  Áreas   │ │  │📍 Gestionar│  │🏠 Ver      │                  │
│ └──────────┘ │  │   Áreas    │  │   Habitac. │                  │
│              │  └────────────┘  └────────────┘                  │
│ ┌──────────┐ │                                                    │
│ │ Reservas │ │                                                    │
│ └──────────┘ │                                                    │
│              │                                                      │
└──────────────┴──────────────────────────────────────────────────────┘
```

### Menu Items del Admin

| ID             | Label           | Icon                             | Color   |
| -------------- | --------------- | -------------------------------- | ------- |
| `dashboard`    | Panel Principal | 📊 dashboard_outlined            | Primary |
| `users`        | Usuarios        | 👥 people_outline                | Blue    |
| `roles`        | Roles           | 🛡️ admin_panel_settings_outlined | Purple  |
| `habitaciones` | Habitaciones    | 🏠 apartment_outlined            | Orange  |
| `areas`        | Áreas Comunes   | 📍 place_outlined                | Green   |
| `reservas`     | Reservas        | 📅 event_outlined                | Red     |

---

## 👤 User Dashboard - Estructura

```
┌─────────────────────────────────────────────────────────────┐
│                        APPBAR                               │
│  ┌──────┐ City Lights                               [⎋]   │
│  │ 🏙️  │                                                   │
│  └──────┘                                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Buenos días 👋                                            │
│  John Doe                                                   │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │        📋 INFORMACIÓN PERSONAL                    │    │
│  │                                                    │    │
│  │  ✉️  Email       john.doe@example.com            │    │
│  │  📱  Teléfono    +1234567890                      │    │
│  │  🆔  ID          abc123xyz                        │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │        🏠 MI PROPIEDAD                            │    │
│  │                                                    │    │
│  │  🏠  Habitación  101                              │    │
│  │  🚗  Garajes     A1, A2                           │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
│  ACCIONES RÁPIDAS                                          │
│  ┌───────────────┐  ┌───────────────┐                    │
│  │   📅          │  │   📅          │                    │
│  │  Reservar     │  │  Mis          │                    │
│  │  Área Común   │  │  Reservas     │                    │
│  │               │  │               │                    │
│  └───────────────┘  └───────────────┘                    │
│  ┌───────────────┐  ┌───────────────┐                    │
│  │   🧾          │  │   💬          │                    │
│  │  Historial    │  │  Soporte      │                    │
│  │  de Pagos     │  │               │                    │
│  │               │  │               │                    │
│  └───────────────┘  └───────────────┘                    │
│                                                             │
│                    (Pull to Refresh ↓)                     │
└─────────────────────────────────────────────────────────────┘
```

### Quick Actions del User

| Acción          | Descripción                   | Icon               | Color  |
| --------------- | ----------------------------- | ------------------ | ------ |
| Reservar Área   | Reserva espacios del edificio | 📅 event_available | Green  |
| Mis Reservas    | Ver mis reservas activas      | 📅 calendar_today  | Blue   |
| Historial Pagos | Revisa tus pagos y facturas   | 🧾 receipt_long    | Orange |
| Soporte         | Contacta con administración   | 💬 support_agent   | Purple |

---

## 🔄 Flujo de Detección de Roles

```
┌─────────────────────────────────────────────────────────────┐
│                    USER LOGIN SUCCESS                        │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│             AuthProvider.user.roles                          │
│              (List<String>)                                  │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│     _isAdmin(user) Method                                   │
│     ┌─────────────────────────────────────────────────┐    │
│     │  user.roles.any((role) =>                       │    │
│     │    role.toLowerCase() == 'admin' ||             │    │
│     │    role.toLowerCase() == 'super-user'           │    │
│     │  )                                               │    │
│     └────────────────┬────────────────────────────────┘    │
└──────────────────────┼──────────────────────────────────────┘
                       │
          ┌────────────┴─────────────┐
          │                          │
         TRUE                      FALSE
          │                          │
          ▼                          ▼
┌──────────────────┐      ┌──────────────────┐
│  AdminDashboard  │      │  UserDashboard   │
│                  │      │                  │
│  • Sidebar Nav   │      │  • Welcome       │
│  • Stats Cards   │      │  • Personal Info │
│  • Quick Actions │      │  • Property      │
│  • Management    │      │  • Quick Actions │
└──────────────────┘      └──────────────────┘
```

---

## 📊 Comparación de Dashboards

| Característica    | Admin Dashboard  | User Dashboard   |
| ----------------- | ---------------- | ---------------- |
| **Sidebar**       | ✅ Sí (240px)    | ❌ No            |
| **Navigation**    | 6 secciones      | Pull-to-refresh  |
| **Stats**         | ✅ Grid 4x1      | ❌ No            |
| **Quick Actions** | 4 (horizontal)   | 4 (grid 2x2)     |
| **User Info**     | AppBar header    | Full card        |
| **Property Info** | ❌ No            | ✅ Card completa |
| **Logout**        | AppBar button    | AppBar button    |
| **Responsive**    | Tablet-optimized | Mobile-optimized |

---

## 🎨 Paleta de Colores

### Admin Dashboard

```
Stats Cards:
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│  BLUE  │  │ GREEN  │  │ PURPLE │  │ ORANGE │
│  #2196 │  │ #4CAF  │  │ #9C27  │  │ #FF98  │
│   F3   │  │  50    │  │  B0    │  │  00    │
└────────┘  └────────┘  └────────┘  └────────┘
 Usuarios    Reservas   Habitaciones  Áreas

Quick Actions:
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│  BLUE  │  │ GREEN  │  │ PURPLE │  │ ORANGE │
└────────┘  └────────┘  └────────┘  └────────┘
  Nuevo      Nueva      Gestionar      Ver
  Usuario    Reserva     Áreas      Habitaciones
```

### User Dashboard

```
Quick Actions Grid:
┌────────────┬────────────┐
│   GREEN    │    BLUE    │
│  Reservar  │    Mis     │
│   Área     │  Reservas  │
├────────────┼────────────┤
│   ORANGE   │   PURPLE   │
│ Historial  │  Soporte   │
│   Pagos    │            │
└────────────┴────────────┘
```

---

## 🔐 Matriz de Roles y Permisos

| Rol          | Admin Dashboard | User Dashboard | Gestión Usuarios | Gestión Reservas | Ver Propiedad  |
| ------------ | --------------- | -------------- | ---------------- | ---------------- | -------------- |
| `admin`      | ✅              | ❌             | ✅               | ✅               | ✅             |
| `super-user` | ✅              | ❌             | ✅               | ✅               | ✅             |
| `user`       | ❌              | ✅             | ❌               | ⚠️ Solo propias  | ✅ Solo propia |

**Leyenda:**

- ✅ = Acceso completo
- ❌ = Sin acceso
- ⚠️ = Acceso limitado

---

## 📱 Responsive Breakpoints

```
Admin Dashboard (Landscape):
┌─────────────────────────────────────────────────────────┐
│  Optimizado para:                                       │
│  • Tablets (768px+)                                     │
│  • Desktop (1024px+)                                    │
│  • Modo horizontal                                      │
│                                                          │
│  Layout:                                                │
│  [Sidebar: 240px] [Content: flex-1]                    │
└─────────────────────────────────────────────────────────┘

User Dashboard (Portrait):
┌───────────────────────────────┐
│  Optimizado para:             │
│  • Móviles (320px+)           │
│  • Tablets (768px+)           │
│  • Modo vertical              │
│                               │
│  Layout:                      │
│  [Content: 100%]              │
│  [Grid: 2 columnas]           │
└───────────────────────────────┘
```

---

## 🎯 Estado de Implementación

### ✅ Completado

- [x] DashboardScreen (wrapper con detección de roles)
- [x] AdminDashboard (sidebar + dashboard view)
- [x] UserDashboard (personal info + quick actions)
- [x] Lógica de detección de roles
- [x] AppBar personalizado por rol
- [x] Sistema de navegación en admin
- [x] Pull-to-refresh en user dashboard
- [x] Dialog de confirmación de logout
- [x] Tema oscuro Material Design 3
- [x] Documentación completa

### 🔄 En Progreso

- [ ] Módulo de Usuarios (admin)
- [ ] Módulo de Roles (admin)
- [ ] Módulo de Habitaciones (admin)
- [ ] Módulo de Áreas Comunes (admin)
- [ ] Módulo de Reservas (admin)
- [ ] Integración con API backend
- [ ] Fetch datos de habitación (user)
- [ ] Fetch datos de garajes (user)

### 📋 Pendiente

- [ ] Módulo de Reservas (user)
- [ ] Módulo de Pagos (user)
- [ ] Módulo de Soporte
- [ ] Notificaciones push integradas
- [ ] Modo offline
- [ ] Tests unitarios y de integración
- [ ] Analytics y métricas

---

## 🚀 Próximos Pasos

### 1. Implementar Módulo de Usuarios (Admin)

```dart
// Pantalla de lista de usuarios con búsqueda
class UsersView extends StatefulWidget {
  // - DataTable con usuarios
  // - Búsqueda y filtros
  // - Botón "Nuevo Usuario"
  // - Acciones: Editar, Eliminar, Roles
}
```

### 2. Integrar API Backend

```dart
// Service para obtener datos del dashboard
class DashboardService {
  Future<Map<String, int>> getAdminStats();
  Future<UserProperty> getUserProperty(String userId);
  Future<List<Booking>> getUserBookings(String userId);
}
```

### 3. Implementar Reservas

```dart
// Pantalla de reservas de áreas comunes
class BookingView extends StatefulWidget {
  // - Calendario de disponibilidad
  // - Formulario de reserva
  // - Lista de mis reservas
  // - Cancelar reserva
}
```

---

## 📚 Referencias

- **Material Design 3**: https://m3.material.io/
- **Flutter Provider**: https://pub.dev/packages/provider
- **City Lights Frontend**: `/frontend/src/pages/AdminDashboard.tsx`
- **City Lights Frontend**: `/frontend/src/pages/UserDashboard.tsx`

---

**Última actualización**: 2024  
**Versión**: 1.0.0  
**Estado**: ✅ Dashboards Base Implementados
