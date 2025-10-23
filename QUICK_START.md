# 🚀 City Lights App - Guía de Ejecución

## ✅ Estado del Proyecto

**Módulos Completados:**

- ✅ Firebase Service (FCM, Device Registration)
- ✅ Login Screen (Email/Password, 2FA, Biometric)
- ✅ Register Screen
- ✅ Verify Email Screen
- ✅ Forgot Password Screen
- ✅ Dashboard Screen (Cards, User Info)
- ✅ Biometric Setup Screen

**Total de Archivos Implementados:** 20+

---

## 📋 Pre-requisitos

1. **Flutter SDK:** >= 3.9.2
2. **Dart SDK:** >= 3.9.2
3. **Android Studio / Xcode:** Para emuladores
4. **Backend corriendo:** `http://localhost:4000`
5. **Firebase Project:** Configurado (opcional para push)

---

## 🛠️ Instalación y Configuración

### **1. Clonar e Instalar Dependencias**

```bash
# Navegar al proyecto Flutter
cd /home/fabricio/Documentos/appCity/app-citylights

# Limpiar caché
flutter clean

# Instalar dependencias
flutter pub get

# Verificar que todo esté bien
flutter doctor
```

### **2. Configurar Backend URL**

Editar `lib/config/constants/api_constants.dart`:

```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:4000';

// Para dispositivo físico (reemplazar con tu IP)
static const String baseUrl = 'http://192.168.1.XXX:4000';

// Para iOS Simulator
static const String baseUrl = 'http://localhost:4000';
```

### **3. Configurar Firebase (OPCIONAL - Solo para Push Notifications)**

Si quieres probar notificaciones push, sigue la guía completa en:
📄 **FIREBASE_SETUP.md**

Resumen rápido:

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase
flutterfire configure
```

**NOTA:** Si no configuras Firebase, la app funcionará perfectamente SIN notificaciones push.

---

## ▶️ Ejecutar la Aplicación

### **Opción 1: Android Emulator**

```bash
# Listar emuladores disponibles
flutter emulators

# Ejecutar emulador (reemplazar con tu emulador)
flutter emulators --launch Pixel_5_API_34

# Ejecutar app en modo debug
flutter run
```

### **Opción 2: iOS Simulator**

```bash
# Instalar pods (primera vez)
cd ios
pod install
cd ..

# Ejecutar en simulator
flutter run
```

### **Opción 3: Dispositivo Físico**

```bash
# Android: Habilitar USB Debugging en el dispositivo
# iOS: Conectar vía cable y confiar en el dispositivo

# Listar dispositivos conectados
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

### **Opción 4: Hot Reload mientras desarrollas**

```bash
# Ejecutar con hot reload
flutter run

# Dentro de la app en ejecución:
# Presiona 'r' para hot reload
# Presiona 'R' para hot restart
# Presiona 'q' para quit
```

---

## 🧪 Probar Funcionalidades

### **1. Registro de Usuario**

1. Abrir app
2. Click "Crear Cuenta"
3. Completar formulario:
   - Nombre: "Juan"
   - Apellido: "Pérez"
   - Email: "juan@example.com"
   - Teléfono: "3001234567" (opcional)
   - Password: "password123"
   - Confirmar Password: "password123"
4. Aceptar términos
5. Click "Crear Cuenta"
6. **Backend debe enviar código de verificación por email**
7. Ingresar código de 6 dígitos
8. Click "Verificar Email"
9. Redirige a Login

### **2. Login Normal**

1. Ingresar email: "juan@example.com"
2. Ingresar password: "password123"
3. Click "Iniciar Sesión"
4. Si tiene 2FA habilitado → Ingresar código
5. Redirige a Dashboard

### **3. Login Biométrico**

1. En Login Screen → Click "Configurar Huella/Face ID"
2. Ingresar email y password
3. Click "Habilitar"
4. Autenticar con huella/face
5. Volver al Login
6. Click "Iniciar con Huella/Face ID"
7. Autenticar → Redirige a Dashboard

### **4. Recuperar Contraseña**

1. En Login Screen → Click "¿Olvidaste tu contraseña?"
2. Ingresar email
3. Click "Enviar Código"
4. **Backend debe enviar código por email**
5. Ingresar código de 6 dígitos
6. Ingresar nueva contraseña
7. Confirmar contraseña
8. Click "Restablecer Contraseña"
9. Redirige a Login

### **5. Dashboard**

1. Login exitoso → Automáticamente en Dashboard
2. Ver información del usuario
3. Ver cards de funcionalidades (Reservas, Pagos, Usuarios, Nómina)
4. Click en cualquier card → Muestra "Próximamente"
5. Pull down to refresh → Actualiza perfil
6. Click icono de campana → (Por implementar)
7. Click logout → Confirmar → Vuelve a Login

---

## 🔔 Probar Notificaciones Push (Si Firebase configurado)

### **Método 1: Firebase Console**

1. Firebase Console → Engage → Messaging
2. "Create your first campaign"
3. Title: "Test Push"
4. Body: "Testing notifications"
5. Target: Your app
6. Send

### **Método 2: Backend (NestJS)**

```typescript
// En tu backend
POST /devices/send-notification
{
  "userId": "user-id",
  "title": "New Booking",
  "body": "Your booking has been approved",
  "data": {
    "type": "booking_approved",
    "bookingId": "123"
  }
}
```

---

## 🐛 Troubleshooting

### **Error: "Connection refused" al hacer login**

**Causa:** Backend no está corriendo o URL incorrecta

**Solución:**

```bash
# Verificar que backend está corriendo
cd /home/fabricio/Documentos/appCity/client-gateway
pnpm run start:dev

# Verificar URL en api_constants.dart
# Android emulator: http://10.0.2.2:4000
```

### **Error: "Firebase not initialized"**

**Causa:** Firebase no configurado o falta google-services.json

**Solución:**

```bash
# Opción 1: Configurar Firebase (ver FIREBASE_SETUP.md)
flutterfire configure

# Opción 2: Comentar inicialización Firebase en main.dart
// await firebaseService.initialize(); // ← Comentar esta línea
```

### **Error: "Biometric authentication not available"**

**Causa:** Emulador no tiene biometría configurada

**Solución:**

```bash
# Android: Settings → Security → Fingerprint → Add fingerprint
# iOS: Settings → Face ID & Passcode → Setup Face ID
```

### **Error: "FCM Token is null"**

**Causa:** Firebase no configurado correctamente

**Solución:**

```bash
# Ver FIREBASE_SETUP.md
# O comentar registro de dispositivo en auth_provider.dart:
// _registerDeviceInFirebase(); // ← Comentar
```

### **Build failed en Android**

```bash
# Limpiar proyecto
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### **Build failed en iOS**

```bash
# Limpiar pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📱 Capturas de Pantalla (Para probar visualmente)

### **Login Screen**

- ✅ Header con logo/ícono
- ✅ Email field
- ✅ Password field con toggle visibility
- ✅ "¿Olvidaste tu contraseña?" link
- ✅ Botón "Iniciar Sesión"
- ✅ Botón "Iniciar con Huella" (si disponible)
- ✅ Botón "Crear Cuenta"

### **Register Screen**

- ✅ Header "Crear Cuenta"
- ✅ Nombre, Apellido fields
- ✅ Email, Teléfono fields
- ✅ Password con confirmación
- ✅ Checkbox de términos
- ✅ Botón "Crear Cuenta"
- ✅ Link "Iniciar Sesión"

### **Dashboard**

- ✅ Welcome header con nombre de usuario
- ✅ Card de información personal
- ✅ Grid 2x2 de funcionalidades
- ✅ Stats cards (Reservas, Pagos)
- ✅ AppBar con notificaciones y logout

---

## 📊 Endpoints Requeridos en Backend

```
POST /auth/register
POST /auth/verify-email
POST /auth/login
POST /auth/verify-2fa
POST /auth/check-2fa-status
POST /auth/resend-code
POST /auth/forgot-password
POST /auth/reset-password
GET  /auth/profile
POST /auth/logout

POST /devices/register
DELETE /devices/:deviceId
```

---

## 🎯 Próximos Pasos

Una vez que la app funcione correctamente:

1. **Probar todos los flujos de autenticación**
2. **Configurar Firebase para push notifications**
3. **Implementar módulo de Reservas** (Session 3)
4. **Implementar módulo de Pagos** (Session 4)
5. **Implementar gestión de Usuarios** (Session 5)
6. **Implementar módulo de Nómina** (Session 6)

---

## 📚 Documentación Adicional

- 📄 **FIREBASE_AUTH_DASHBOARD_DOCS.md** - Documentación completa de implementación
- 📄 **FIREBASE_SETUP.md** - Guía detallada de configuración Firebase
- 📄 **VISUAL_SUMMARY.md** - Resumen visual de arquitectura
- 📄 **LOGIN_DOCS.md** - Documentación del módulo de login
- 📄 **BIOMETRIC_DOCS.md** - Documentación de autenticación biométrica

---

## ✅ Checklist Final

```
[ ] Flutter instalado y funcionando
[ ] Backend corriendo en http://localhost:4000
[ ] Dependencias instaladas (flutter pub get)
[ ] URL de backend configurada
[ ] App ejecutándose en emulador/dispositivo
[ ] Registro de usuario funcional
[ ] Login funcional
[ ] Dashboard visible
[ ] (Opcional) Firebase configurado
[ ] (Opcional) Push notifications funcionando
```

---

## 🆘 Soporte

Si encuentras algún error:

1. Verificar logs con `flutter run -v`
2. Revisar documentación en archivos .md
3. Verificar que backend esté corriendo
4. Limpiar proyecto: `flutter clean && flutter pub get`

---

**¡La app está lista para usarse! 🎉**

Para continuar con el desarrollo, consulta **VISUAL_SUMMARY.md** para ver las próximas funcionalidades a implementar.
