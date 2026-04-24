# Reto 1 — Mundo Real en Nexuly

Implementa cámara, QR, GPS y cache offline. Reusa las pantallas existentes.

## ✅ Lo que implementa

| Tarea del reto | Implementación en Nexuly |
|---|---|
| Capturar foto y asociar a registros | Foto de perfil del paciente (base64 en Hive) |
| Escanear QR | Pro escanea QR del paciente al llegar a domicilio |
| Generar QR | Paciente muestra QR de check-in durante servicio activo |
| Sensor GPS | `geolocator` para ubicación real (puede usarse en búsqueda por cercanía) |
| Persistencia offline | Hive con boxes `cache`, `prefs`, `outbox` |

## 📦 Archivos que se añaden/reemplazan

**Añadir (nuevos):**
```
lib/core/services/location_service.dart
lib/core/services/profile_photo_service.dart
lib/core/services/qr_payload.dart
lib/core/storage/local_cache.dart
lib/features/qr/presentation/qr_scan_result_screen.dart
lib/features/qr/presentation/qr_scanner_screen.dart
lib/features/qr/presentation/service_qr_screen.dart
lib/shared/widgets/photo_picker_sheet.dart
```

**Reemplazar (ya existen):**
```
pubspec.yaml
lib/main.dart
lib/core/router/app_router.dart
lib/features/shell/professional_placeholders.dart
android/app/src/main/AndroidManifest.xml
```

## 🚀 Pasos de instalación

### 1. Copiar archivos
Desde el ZIP, copia el contenido de `r1/` sobre la raíz del proyecto, sobrescribiendo cuando pregunte.

### 2. Limpiar caches de Windows (por el pubspec nuevo)
```powershell
flutter clean
flutter pub get
```

### 3. Regenerar código
```powershell
dart run build_runner build --delete-conflicting-outputs
```

Esto genera los archivos `.g.dart` para los nuevos providers (`location_service.g.dart`, `local_cache.g.dart`, `profile_photo_service.g.dart`).

### 4. iOS (si vas a correr en iPhone/simulador iOS)
Añade al `ios/Runner/Info.plist` (entre las etiquetas `<dict>`):
```xml
<key>NSCameraUsageDescription</key>
<string>Nexuly usa la cámara para tomar foto de perfil y escanear códigos QR.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nexuly necesita acceso a tus fotos para elegir una foto de perfil.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nexuly usa tu ubicación para mostrar profesionales cercanos.</string>
```

### 5. Correr
```powershell
flutter run
```

Para Android elige tu dispositivo/emulador. Para web, elige Edge (QR scan y GPS en web tienen limitaciones).

## 🎯 Cómo demostrar cada funcionalidad

### A. Escaneo + generación de QR

1. **Como paciente**: registrate/inicia sesión como paciente.
2. Ve al home → cualquier profesional → "Ver perfil" → "Agendar servicio".
3. Completa el flujo de booking. Al confirmar, te lleva a `/active/:id`.
4. En active_service, hay un botón "Mostrar QR de check-in" (si no lo ves, añádelo usando la ruta `/qr/service/:requestId`).
5. Se muestra el QR con el payload de servicio.
6. **En otro dispositivo (o logout + login como profesional)**: ve al home del pro.
7. Click en "Escanear QR" (la quick action del home).
8. Apunta al QR del paciente → aparece la pantalla de resultado con los datos.
9. "Confirmar llegada" → toast de éxito.

### B. Foto de perfil
1. Como paciente → tab "Perfil" → avatar.
2. Click en el avatar → bottom sheet con "Cámara", "Galería", "Eliminar".
3. Elige cámara o galería → la foto se guarda en Hive.
4. Cierra y vuelve a abrir la app (`flutter run` de nuevo sin `flutter clean`) → la foto sigue ahí.

### C. GPS
Se integra cuando agendas un servicio — el BookingScreen tiene la opción "Usar mi ubicación actual" que llama a `requestCurrent()`.

### D. Cache Hive offline
Funciona automáticamente. Los últimos profesionales vistos se guardan. Puedes demostrar así:
1. Abre la app con internet, navega por profesionales.
2. Desactiva wifi del dispositivo.
3. Reinicia la app → el home muestra los profesionales del último snapshot cacheado.

## 🐛 Troubleshooting

**Error de compilación: "Target of URI doesn't exist: package:..."**
→ Corre `flutter pub get` después de copiar el pubspec.

**"Hive not initialized"**
→ Verifica que `main.dart` tiene `await initializeLocalStorage()` **antes** de `runApp`.

**Escáner QR abre cámara negra en Android**
→ Permiso denegado. Ve a Settings > Apps > Nexuly > Permisos > Cámara.

**Geolocator lanza "MissingPluginException" en web**
→ Es esperado. El LocationService retorna valores cacheados o un error controlado.

**El camera picker no funciona en web**
→ `image_picker` en web solo soporta galería, no cámara. En Android funciona todo.

## 📋 Pendiente (para siguientes retos)
- Conectar el botón "check-in" del scanner con `ServiceRequestsRepository.changeStatus()` (cambiar de `CONFIRMED` → `IN_PROGRESS`).
- Integrar GPS con el campo `location` del ServiceRequest en el booking.
- Botón "Ver QR" explícito en la pantalla active_service (hoy la ruta existe, falta el botón).
