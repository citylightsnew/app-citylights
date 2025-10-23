# 🎨 City Lights Mobile - UI Preview

## 📱 Pantalla de Login

```
┌─────────────────────────────────────┐
│                                     │
│              🏢                     │
│         City Lights                 │
│     Bienvenido de vuelta           │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📧 Correo Electrónico         │ │
│  │ tu@email.com                  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🔒 Contraseña                 │ │
│  │ ••••••••                  👁️  │ │
│  └───────────────────────────────┘ │
│                                     │
│         ¿Olvidaste tu contraseña?   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │    🔓 Iniciar Sesión          │ │
│  └───────────────────────────────┘ │
│                                     │
│  ─────────────  o  ───────────────  │
│                                     │
│  ┌───────────────────────────────┐ │
│  │    👤 Crear Cuenta            │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 🔐 Pantalla 2FA - Código Email

```
┌─────────────────────────────────────┐
│                                     │
│              🔒                     │
│   Verificación en Dos Pasos        │
│                                     │
│  Ingresa el código de 6 dígitos    │
│       enviado a tu correo          │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📍 Código de Verificación     │ │
│  │ 123456                        │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │    ✓ Verificar                │ │
│  └───────────────────────────────┘ │
│                                     │
│         Reenviar código             │
│            Cancelar                 │
│                                     │
└─────────────────────────────────────┘
```

## 📱 Pantalla 2FA - Push Notification

```
┌─────────────────────────────────────┐
│                                     │
│              🔔                     │
│                                     │
│     Revisa tu Dispositivo          │
│                                     │
│  Hemos enviado una notificación    │
│   a tu dispositivo móvil. Por      │
│  favor, aprueba la solicitud para  │
│          continuar.                 │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   ⏱️  Tiempo restante: 01:58   │ │
│  └───────────────────────────────┘ │
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        Cancelar               │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 🎨 Paleta de Colores

### Colores Principales

- **Primary (Indigo)**: `#6366F1` - Botones principales, enlaces
- **Secondary (Purple)**: `#8B5CF6` - Acentos secundarios
- **Accent (Cyan)**: `#06B6D4` - Detalles y highlights

### Backgrounds

- **Dark Background**: `#0A0A0A` - Fondo principal
- **Dark Surface**: `#1A1A1A` - Cards y contenedores
- **Dark Card**: `#2A2A2A` - Elementos elevados

### Textos

- **Text Primary**: `#FFFFFF` - Texto principal
- **Text Secondary**: `#B0B0B0` - Texto secundario
- **Text Tertiary**: `#707070` - Texto terciario/hints

### Estados

- **Success**: `#10B981` - Verde - Éxito
- **Error**: `#EF4444` - Rojo - Errores
- **Warning**: `#F59E0B` - Naranja - Advertencias
- **Info**: `#3B82F6` - Azul - Información

## 🎭 Animaciones

### Login Screen

- **Fade In**: Toda la pantalla aparece con fade (800ms)
- **Slide Up**: Los elementos se deslizan desde abajo (800ms)
- **Input Focus**: Border color animado al hacer focus
- **Button Hover**: Ligero scale al presionar

### 2FA Push

- **Pulse**: El ícono de notificación hace pulse
- **Countdown**: Actualización cada segundo
- **Scale**: Animación de breathing en el ícono

## 📐 Espaciado

- **Padding Principal**: 24px
- **Spacing entre elementos**: 16px
- **Border Radius**: 12px (inputs/buttons), 16px (cards)
- **Icon Size**: 24px (default), 80-100px (headers)

## 🔤 Tipografía

- **Display Large**: 32px, Bold
- **Display Medium**: 28px, Bold
- **Headline**: 20-24px, SemiBold
- **Title**: 16-18px, SemiBold
- **Body**: 14-16px, Regular
- **Caption**: 12px, Regular

## ✨ Efectos Visuales

- **Shadows**: Mínimas (elevation: 0-2)
- **Borders**: Subtle (1-2px)
- **Blur**: Backdrop blur en overlays
- **Gradients**: Sutiles en headers (opcional)

## 📱 Responsive

- Máximo width en tablets: 600px
- Padding adaptativo según tamaño
- Font sizes escalables
- Iconos proporcionales
