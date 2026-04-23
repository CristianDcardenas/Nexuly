# Nexuly — Backend (Fase 1)

Plataforma móvil de servicios de salud domiciliarios. Este paquete contiene la
base del backend de la app Flutter: modelos, repositorios, reglas de Firestore
e índices.

## 🧱 Stack

- **Flutter** (Dart SDK ^3.11.1)
- **Firebase**: Auth, Firestore, Storage, Messaging, App Check, Cloud Functions
- **Riverpod** (state management + inyección de dependencias)
- **Freezed + json_serializable** (modelos inmutables)
- **go_router** (navegación declarativa, se usa desde la Fase 4)

---

## 📁 Estructura

```
lib/
├── core/
│   ├── constants/        # Nombres de colecciones Firestore
│   ├── enums/            # Enums del dominio (estados, roles, tipos)
│   ├── errors/           # Failures tipados
│   ├── extensions/
│   ├── providers/        # Providers globales de Firebase (Riverpod)
│   └── utils/            # Converters (Timestamp, GeoPoint)
├── data/
│   ├── models/           # 10 modelos Firestore con Freezed
│   └── repositories/     # CRUD tipado por colección
├── features/             # (se irá llenando por feature: auth, chat, ...)
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   ├── profile/
│   ├── professionals/
│   ├── services/
│   ├── requests/
│   ├── chat/
│   ├── reviews/
│   └── notifications/
├── shared/
│   └── widgets/
├── firebase_options.dart # (generado por FlutterFire CLI — no versionar)
└── main.dart

firestore/
├── firestore.rules       # Security rules
├── firestore.indexes.json# Índices compuestos
└── storage.rules         # Storage rules
```

---

## 🚀 Instalación

### 1. Reemplazar archivos en tu proyecto VS Code

Copia todo el contenido de este paquete sobre tu proyecto `nexuly_app/`. Los
archivos a reemplazar son:

- `pubspec.yaml` → con Firebase BoM actualizado y deps nuevas
- `analysis_options.yaml`
- `firebase.json`
- `lib/main.dart`

Y a añadir (no existían):
- Toda la carpeta `lib/core/`
- Toda la carpeta `lib/data/`
- La carpeta `firestore/` en la raíz
- `build.yaml`
- `.gitignore`

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Generar código (Freezed, json_serializable, Riverpod)

Los archivos `*.freezed.dart` y `*.g.dart` NO están incluidos en el paquete
porque se generan automáticamente. Ejecuta:

```bash
dart run build_runner build --delete-conflicting-outputs
```

O durante desarrollo, déjalo corriendo en modo watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

> ⚠️ Si VS Code te muestra errores rojos en los modelos, es porque todavía no
> has corrido `build_runner`. Se solucionan todos solos en cuanto termines
> el comando.

### 4. Verificar que compila

```bash
flutter analyze
flutter run
```

Deberías ver una pantalla con "Backend inicializado".

---

## ☁️ Deploy a Firebase

### Requisitos

- [Firebase CLI](https://firebase.google.com/docs/cli) instalado y logueado
  (`firebase login`).
- Estar en el directorio raíz del proyecto (donde está `firebase.json`).

### Deploy de reglas e índices

```bash
# Solo reglas de Firestore
firebase deploy --only firestore:rules

# Solo índices (puede tardar varios minutos en "BUILDING")
firebase deploy --only firestore:indexes

# Reglas de Storage
firebase deploy --only storage

# Todo de una vez
firebase deploy --only firestore,storage
```

---

## 🔑 Configuración pendiente en Firebase Console

Antes del próximo paso (autenticación), asegúrate de tener configurado:

1. **Región de Firestore**: si aún no la creaste, elige una cercana a Colombia.
   Recomendación: `southamerica-east1` (São Paulo) o `us-east1`. **No se puede
   cambiar después**.

2. **Authentication → Métodos habilitados**:
   - Email/Password ✓
   - Google ✓
   - Apple (solo iOS, opcional)

3. **App Check** (recomendado activar desde ya):
   - Android: Play Integrity
   - iOS: DeviceCheck / App Attest
   - Debug token para desarrollo

4. **Cloud Functions**: el plan debe ser **Blaze** (pago por uso, con free tier).

5. **Custom Claims para admin**: cuando definas los primeros administradores,
   se les asignará `role: 'admin'` mediante un script de Node.js con
   Firebase Admin SDK. Lo haremos al llegar al módulo admin.

---

## 🧪 Comandos útiles

```bash
# Limpiar archivos generados
dart run build_runner clean

# Regenerar desde cero
dart run build_runner build --delete-conflicting-outputs

# Chequear deps desactualizadas
flutter pub outdated

# Upgrade seguro
flutter pub upgrade
```

---

## 🗺️ Roadmap

- [x] **Fase 1** — Estructura, modelos, repositorios, rules, índices
- [ ] **Fase 2** — Autenticación (Email + Google, flujo "Soy paciente / Soy profesional")
- [ ] **Fase 3** — Onboarding y perfiles (usuario, profesional con documentos)
- [ ] **Fase 4** — Navegación (go_router) + shell
- [ ] **Fase 5** — Catálogo de servicios + búsqueda de profesionales
- [ ] **Fase 6** — Flujo de solicitud + confirmación + status_history
- [ ] **Fase 7** — Chat con Cloud Functions triggers
- [ ] **Fase 8** — Reviews (bidireccionales) y user_behavior
- [ ] **Fase 9** — Notificaciones push (FCM) y Cloud Functions
- [ ] **Fase 10** — IA de recomendaciones
- [ ] **Fase 11** — Panel admin (web/mobile)

---

## 🆘 Troubleshooting

**"Target of URI doesn't exist: 'xxx.freezed.dart'"**
→ Corre `dart run build_runner build --delete-conflicting-outputs`.

**"Error: The argument type 'Element' can't be assigned to 'Element2'"** (al correr build_runner)
→ Conflicto de versiones entre `analyzer` y paquetes de generación de código.
   Solución: `dart pub cache clean -f`, luego `flutter clean`, y vuelve a correr
   `flutter pub get` seguido del build.

**"FirebaseException: permission-denied"**
→ Deploya las rules con `firebase deploy --only firestore:rules`.

**"The query requires an index..."**
→ Deploya los índices con `firebase deploy --only firestore:indexes`.
   Firestore te dará además un link directo para crearlo desde la consola.

**Errores de versión entre paquetes Firebase**
→ Todos los paquetes Firebase deben ser compatibles. Si algún `pub get` falla,
   corre `flutter pub upgrade firebase_core` y vuelve a intentar.
