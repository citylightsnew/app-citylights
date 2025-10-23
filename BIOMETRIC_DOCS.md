# 🔐 Autenticación Biométrica - Documentación

## 📱 Implementación Completa

### ✅ Archivos Creados

```
lib/
├── core/services/
│   └── biometric_service.dart          # Servicio de autenticación biométrica
├── screens/settings/
│   └── biometric_setup_screen.dart     # Pantalla de configuración
└── screens/auth/
    └── login_screen.dart               # Actualizado con botón biométrico
```

---

## 🎯 Funcionalidades

### 1. **BiometricService**

Servicio centralizado para manejar toda la lógica biométrica:

#### Métodos Principales:

- `isDeviceSupported()` - Verifica si el dispositivo soporta biométricos
- `canCheckBiometrics()` - Verifica si hay biométricos configurados
- `getAvailableBiometrics()` - Obtiene tipos disponibles (huella, face, iris)
- `authenticate()` - Autentica usando biométrico
- `enableBiometricLogin()` - Habilita y guarda credenciales
- `disableBiometricLogin()` - Deshabilita y borra credenciales
- `authenticateAndGetCredentials()` - Autent ica y devuelve credenciales para auto-login

#### Tipos Soportados:

- 🔒 **Fingerprint** - Huella Digital
- 👤 **Face ID** - Reconocimiento Facial (iOS)
- 👁️ **Iris** - Reconocimiento de Iris

---

### 2. **Almacenamiento Seguro**

#### StorageService - Nuevos Métodos:

```dart
// Guardar estado de biométrico
saveBiometricEnabled(bool enabled)

// Obtener estado
getBiometricEnabled() → bool?

// Guardar credenciales encriptadas
saveBiometricCredentials(email, password)

// Obtener credenciales
getBiometricCredentials() → Map<String, String>?

// Eliminar credenciales
deleteBiometricCredentials()
```

**Seguridad:**

- Credenciales guardadas con `FlutterSecureStorage`
- Encriptación a nivel de sistema
- Android: EncryptedSharedPreferences
- iOS: Keychain con accesibilidad `first_unlock`

---

### 3. **Pantalla de Configuración Biométrica**

#### Ubicación: `/biometric-setup`

**Features:**

- ✅ Detección automática de tipo de biométrico disponible
- ✅ Validación de soporte del dispositivo
- ✅ Formulario para ingresar credenciales
- ✅ Autenticación biométrica antes de guardar
- ✅ Habilitación/Deshabilitación fácil
- ✅ UI adaptativa según estado

**Estados:**

1. **No Soportado** - Mensaje de error si el dispositivo no tiene biométricos
2. **Deshabilitado** - Formulario para habilitar con email/password
3. **Habilitado** - Estado activo con opción de deshabilitar

---

### 4. **Login Screen Mejorado**

#### Nuevas Features:

**Botones Condicionales:**

1. **Si biométrico está habilitado:**

   - Botón "Iniciar con Huella Digital/Face ID"
   - Login automático después de autenticar
   - Soporte para 2FA si está configurado

2. **Si biométrico está disponible pero no habilitado:**

   - Enlace "Configurar Huella Digital/Face ID"
   - Navega a pantalla de configuración

3. **Si no está disponible:**
   - No muestra opciones biométricas

---

## 🎨 Flujo de Usuario

### **Primera Vez - Configuración**

```
1. Usuario abre app
2. Ve "Configurar Huella Digital" en Login
3. Click → Navega a BiometricSetupScreen
4. Ingresa email y contraseña
5. Sistema pide autenticación biométrica
6. Usuario autentica con huella/face
7. Credenciales guardadas (encriptadas)
8. ✅ Biométrico habilitado
```

### **Login Subsecuente**

```
1. Usuario abre app
2. Ve "Iniciar con Huella Digital"
3. Click → Sistema pide autenticación
4. Usuario autentica con huella/face
5. Sistema recupera credenciales guardadas
6. Login automático con credenciales
7. Si tiene 2FA → Flujo normal de 2FA
8. ✅ Acceso al dashboard
```

### **Deshabilitar**

```
1. Usuario en BiometricSetupScreen
2. Click "Deshabilitar"
3. Confirmación con diálogo
4. Credenciales eliminadas
5. ✅ Biométrico deshabilitado
```

---

## 🔒 Seguridad

### **Protección de Credenciales**

1. **Encriptación Nativa:**

   - Android: AES-256 con EncryptedSharedPreferences
   - iOS: Keychain con SecureEnclave

2. **Acceso Limitado:**

   - Solo después de autenticación biométrica
   - No expuestas en logs ni debug

3. **Limpieza Automática:**
   - Al deshabilitar biométrico
   - Al hacer logout
   - Al desinstalar app (KeyChain/Keystore)

### **Validación**

- Verifica que el dispositivo soporte biométricos
- Verifica que hay biométricos registrados
- Maneja errores de autenticación
- Timeout automático en polling

---

## 📱 Configuración de Plataformas

### **Android**

#### `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
  <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
</manifest>
```

#### `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 23  // Mínimo para biométricos
    }
}
```

### **iOS**

#### `ios/Runner/Info.plist`

```xml
<key>NSFaceIDUsageDescription</key>
<string>Necesitamos Face ID para autenticarte de forma segura</string>
```

---

## 🧪 Testing

### **Emulador Android**

```bash
# Registrar huella en emulador
adb -e emu finger touch <finger_id>

# Ejemplo:
adb -e emu finger touch 1
```

### **Simulador iOS**

1. Features → Face ID → Enrolled
2. Features → Face ID → Matching Face/Non-matching Face

### **Dispositivo Físico**

- Usar huella/face real configurada en el dispositivo
- Probar diferentes escenarios (cancelación, fallo, éxito)

---

## ⚠️ Manejo de Errores

### **Errores Comunes**

1. **NotAvailable**

   - Dispositivo no soporta biométricos
   - Mostrar mensaje: "Dispositivo no compatible"

2. **NotEnrolled**

   - No hay biométricos registrados
   - Mostrar: "Configura huella/face en ajustes del dispositivo"

3. **LockedOut**

   - Muchos intentos fallidos
   - Mostrar: "Bloqueado temporalmente, usa contraseña"

4. **PermanentlyLockedOut**

   - Bloqueado permanentemente
   - Mostrar: "Biométrico bloqueado, usa contraseña"

5. **UserCancel**
   - Usuario canceló
   - No mostrar error, solo log

---

## 🎯 Próximas Mejoras

### **Opcionales:**

- [ ] Configuración desde perfil de usuario
- [ ] Opción de requerir biométrico en cada sesión
- [ ] Estadísticas de uso de biométrico
- [ ] Fallback a PIN/Patrón
- [ ] Biométrico para acciones sensibles (pagos, etc.)
- [ ] Múltiples huellas registradas
- [ ] Biométrico para desbloquear app (no solo login)

---

## 📊 Ventajas vs Contraseña

| Feature       | Contraseña    | Biométrico   |
| ------------- | ------------- | ------------ |
| **Velocidad** | ⭐⭐          | ⭐⭐⭐⭐⭐   |
| **Seguridad** | ⭐⭐⭐        | ⭐⭐⭐⭐⭐   |
| **UX**        | ⭐⭐          | ⭐⭐⭐⭐⭐   |
| **Olvidable** | ❌ Sí         | ✅ No        |
| **Phishing**  | ❌ Vulnerable | ✅ Protegido |
| **Robo**      | ❌ Vulnerable | ✅ Protegido |

---

## 🚀 Uso en Código

### **Ejemplo Simple:**

```dart
final biometricService = BiometricService();

// Verificar disponibilidad
final isAvailable = await biometricService.canCheckBiometrics();

// Autenticar
final success = await biometricService.authenticate(
  localizedReason: 'Verifica tu identidad',
);

if (success) {
  // Usuario autenticado
}
```

### **Login Completo:**

```dart
// Autenticar y obtener credenciales
final credentials = await biometricService
    .authenticateAndGetCredentials();

if (credentials != null) {
  // Auto-login
  await authProvider.login(
    credentials['email']!,
    credentials['password']!,
  );
}
```

---

## 📝 Notas Importantes

1. **Privacidad:** Las credenciales nunca salen del dispositivo
2. **Offline:** Funciona sin conexión (autenticación local)
3. **Persistencia:** Las credenciales persisten entre sesiones
4. **Limpieza:** Se eliminan al desinstalar la app
5. **Compatible:** iOS 11+, Android 6.0+ (API 23+)

---

¿Listo para probar? 🚀

```bash
flutter run
```

Navega a la pantalla de login y verás las opciones de biométrico si tu dispositivo lo soporta.
