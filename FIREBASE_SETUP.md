# 🔥 Configuración de Firebase para Flutter

## 📋 Prerequisitos

1. **Cuenta de Firebase**: Crear cuenta en [Firebase Console](https://console.firebase.google.com)
2. **Firebase CLI**: Instalar FlutterFire CLI
3. **Proyecto Flutter**: App City Lights ya configurada

---

## 🚀 Paso a Paso - Configuración Completa

### **1. Instalar Firebase CLI y FlutterFire**

```bash
# Instalar Firebase Tools (Node.js required)
npm install -g firebase-tools

# Login a Firebase
firebase login

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli
```

---

### **2. Crear Proyecto en Firebase Console**

1. Ir a https://console.firebase.google.com
2. Click "Agregar proyecto"
3. Nombre: `city-lights-app` o el que prefieras
4. Habilitar Google Analytics (opcional)
5. Click "Crear proyecto"

---

### **3. Configurar Firebase en Flutter (Automático)**

```bash
# En la raíz del proyecto Flutter
cd /home/fabricio/Documentos/appCity/app-citylights

# Configurar Firebase automáticamente
flutterfire configure
```

Este comando:

- ✅ Detecta tu proyecto Flutter
- ✅ Conecta con Firebase Console
- ✅ Crea apps para Android e iOS
- ✅ Descarga archivos de configuración
- ✅ Genera `firebase_options.dart`

---

### **4. Configurar Android**

#### **4.1. Archivo `android/build.gradle.kts`**

Agregar al final de `plugins {}`:

```kotlin
plugins {
    // ...existing plugins
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### **4.2. Archivo `android/app/build.gradle.kts`**

Agregar al final de `plugins {}`:

```kotlin
plugins {
    // ...existing plugins
    id("com.google.gms.google-services")
}
```

#### **4.3. Archivo `android/app/src/main/AndroidManifest.xml`**

Agregar permisos antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Agregar dentro de `<application>`:

```xml
<application>
    <!-- Configuración FCM -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="high_importance_channel" />

    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_notification" />

    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/notification_color" />
</application>
```

#### **4.4. Verificar que existe `android/app/google-services.json`**

Debe haber sido creado automáticamente por `flutterfire configure`.
Si no existe, descargarlo desde Firebase Console:

1. Firebase Console → Project Settings
2. Your Apps → Android
3. Download `google-services.json`
4. Colocar en `android/app/`

---

### **5. Configurar iOS**

#### **5.1. Archivo `ios/Runner/Info.plist`**

Agregar antes de `</dict>`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### **5.2. Archivo `ios/Runner/AppDelegate.swift`**

Reemplazar todo el contenido con:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Inicializar Firebase
    FirebaseApp.configure()

    // Configurar notificaciones
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

#### **5.3. Verificar que existe `ios/Runner/GoogleService-Info.plist`**

Debe haber sido creado automáticamente por `flutterfire configure`.
Si no existe, descargarlo desde Firebase Console:

1. Firebase Console → Project Settings
2. Your Apps → iOS
3. Download `GoogleService-Info.plist`
4. Colocar en `ios/Runner/`

#### **5.4. Configurar Capabilities en Xcode (iOS)**

1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Seleccionar proyecto "Runner"
3. Tab "Signing & Capabilities"
4. Click "+" → Agregar "Push Notifications"
5. Click "+" → Agregar "Background Modes"
6. Marcar: "Background fetch" y "Remote notifications"

---

### **6. Habilitar Cloud Messaging en Firebase Console**

1. Firebase Console → Build → Cloud Messaging
2. Click "Get Started" si es primera vez
3. (iOS) Subir APNs Certificate o APNs Auth Key:
   - Ir a Apple Developer → Certificates, Identifiers & Profiles
   - Crear APNs Auth Key
   - Descargar .p8 file
   - En Firebase Console → Cloud Messaging → Apple app configuration
   - Subir .p8 file con Team ID y Key ID

---

### **7. Probar Configuración**

```bash
# Limpiar y reconstruir
flutter clean
flutter pub get

# Ejecutar en Android
flutter run

# Ejecutar en iOS
cd ios
pod install
cd ..
flutter run
```

---

## 📱 Probar Notificaciones Push

### **Método 1: Desde Firebase Console**

1. Firebase Console → Engage → Messaging
2. Click "Create your first campaign"
3. Seleccionar "Firebase Notification messages"
4. Notification title: "Test Push"
5. Notification text: "Testing FCM"
6. Click "Next"
7. Target: Seleccionar tu app
8. Click "Next" → "Next" → "Publish"

### **Método 2: Desde Backend con cURL**

```bash
# Obtener Server Key de Firebase Console:
# Project Settings → Cloud Messaging → Server key

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test from Backend",
      "body": "This is a test notification"
    },
    "data": {
      "type": "test",
      "message": "Hello from server"
    }
  }'
```

### **Método 3: Desde tu Backend NestJS**

```typescript
// En tu backend (client-gateway o notification service)
import * as admin from "firebase-admin";

// Inicializar Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: "your-project-id",
    clientEmail: "your-client-email",
    privateKey: "your-private-key",
  }),
});

// Enviar notificación
await admin.messaging().send({
  token: "DEVICE_FCM_TOKEN",
  notification: {
    title: "New Booking",
    body: "Your booking has been approved",
  },
  data: {
    type: "booking_approved",
    bookingId: "123",
  },
});
```

---

## 🔍 Verificar Logs

### **Android**

```bash
# Ver logs de Firebase
adb logcat | grep -i firebase

# Ver logs de FCM
adb logcat | grep -i fcm
```

### **iOS**

```bash
# Ver logs en Xcode
# Window → Devices and Simulators → Open Console
# Filtrar por "Firebase" o "FCM"
```

---

## ❌ Troubleshooting

### **Error: "Default FirebaseApp is not initialized"**

**Solución:**

```dart
// Verificar que main.dart tiene:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ← Esto es crítico
  runApp(MyApp());
}
```

### **Error: "FCM Token is null"**

**Android:**

```xml
<!-- Verificar google-services.json existe en android/app/ -->
<!-- Verificar que build.gradle tiene el plugin -->
```

**iOS:**

```swift
// Verificar que AppDelegate.swift tiene:
Messaging.messaging().apnsToken = deviceToken
```

### **Error: "Permission denied" (iOS)**

**Solución:**

```swift
// Asegurarse de solicitar permisos
UNUserNotificationCenter.current().requestAuthorization(
  options: [.alert, .badge, .sound],
  completionHandler: { granted, error in
    print("Permission granted: \(granted)")
  }
)
```

### **Error: "Google services JSON is missing"**

**Solución:**

```bash
# Re-ejecutar configuración
flutterfire configure
```

---

## 📊 Verificar Estado de Firebase

### **En la App (Dart)**

```dart
// En cualquier parte después de inicialización
final fcmToken = await FirebaseMessaging.instance.getToken();
print('FCM Token: $fcmToken');

// Verificar permisos
final settings = await FirebaseMessaging.instance.requestPermission();
print('Permission: ${settings.authorizationStatus}');

// Verificar APNS token (iOS)
final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
print('APNS Token: $apnsToken');
```

---

## 🎯 Siguiente Paso

Una vez configurado Firebase exitosamente:

1. **Probar registro de dispositivo:**

   ```dart
   await FirebaseService().registerDevice(userId: 'test-user-123');
   ```

2. **Enviar notificación de prueba desde Firebase Console**

3. **Verificar que la app recibe la notificación:**

   - Foreground: Debe mostrar en consola
   - Background: Debe aparecer en bandeja de notificaciones
   - Tap: Debe abrir la app y ejecutar `onMessageOpenedApp`

4. **Integrar con backend:**
   - Backend debe guardar FCM tokens en la tabla `devices`
   - Backend debe enviar notificaciones usando Firebase Admin SDK

---

## 📚 Recursos

- [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

---

**¡Firebase está listo para usar! 🎉**
