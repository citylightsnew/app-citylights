# City Lights Mobile App - Configuración

## 🚀 Inicio Rápido

### 1. Instalar Dependencias

```bash
cd app-citylights
flutter pub get
```

### 2. Configurar URL de API

Edita el archivo `lib/config/constants/api_constants.dart` y actualiza la URL base:

**Para Emulador Android:**

```dart
static const String baseUrl = 'http://10.0.2.2:4000';
```

**Para iOS Simulator:**

```dart
static const String baseUrl = 'http://localhost:4000';
```

**Para Dispositivo Físico (mismo WiFi):**

```dart
static const String baseUrl = 'http://192.168.1.X:4000'; // Tu IP local
```

### 3. Ejecutar la App

```bash
# Verificar dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release
```

## 📱 Emuladores Recomendados

### Android

- **Pixel 6 Pro** - API 33 (Android 13)
- **Pixel 4** - API 30 (Android 11)

### iOS

- **iPhone 14 Pro**
- **iPhone 13**

## 🔧 Comandos Útiles

```bash
# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar análisis estático
flutter analyze

# Formatear código
flutter format .

# Ver logs
flutter logs

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 🐛 Solución de Problemas Comunes

### Error: "Unable to connect to the server"

**Solución:**

1. Verifica que el backend esté corriendo en `http://localhost:4000`
2. Actualiza la URL en `api_constants.dart` según tu entorno
3. Para Android emulator, usa `10.0.2.2` en lugar de `localhost`

### Error: "Flutter Secure Storage not working"

**Android:**

```bash
flutter clean
flutter pub get
```

**iOS:**
Asegúrate de tener configurado el Keychain Access en `ios/Runner/Info.plist`

### Error de compilación en Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## 📋 Checklist Pre-Deploy

- [ ] Actualizar URL de producción en `api_constants.dart`
- [ ] Configurar Firebase (si usas push notifications)
- [ ] Actualizar versión en `pubspec.yaml`
- [ ] Generar iconos: `flutter pub run flutter_launcher_icons`
- [ ] Build release: `flutter build apk --release`
- [ ] Probar en dispositivo físico

## 🔐 Variables de Entorno

Actualmente las URLs están hardcodeadas. Para usar variables de entorno:

1. Instalar `flutter_dotenv`
2. Crear archivo `.env`
3. Cargar en `main.dart`

## 📦 Build de Producción

### Android (APK)

```bash
flutter build apk --release
```

Archivo generado: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle - Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🎯 Features Actuales

- ✅ Login con email/password
- ✅ 2FA por email
- ✅ 2FA por push notification
- ✅ Tema dark mode
- ✅ Almacenamiento seguro de tokens
- ✅ Validación de formularios
- ✅ Animaciones UI

## 📚 Recursos

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Material 3 Design](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Package](https://pub.dev/packages/dio)
