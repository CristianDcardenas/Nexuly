# Seed de datos para Firestore

Script para poblar tu Firestore con 6 profesionales de prueba, 12 servicios y 8 reseñas.

## 🔑 Configuración (solo la primera vez)

1. Ve a Firebase Console: **Project Settings → Service accounts → Generate new private key**
2. Descarga el JSON y guárdalo en esta carpeta (`seed/`) como **`service-account.json`**
3. Instala dependencias:
   ```bash
   cd seed
   npm install
   ```

> ⚠️ El `service-account.json` da acceso total a tu Firebase. Nunca lo subas a git (ya está en `.gitignore`).

## 🌱 Correr el seed

```bash
# Primera vez (crea todo)
npm run seed

# Limpiar y re-crear
npm run seed:clean
```

Todos los docs creados tienen ID que empieza con `seed_` para que puedas identificarlos y limpiarlos fácilmente.

## 📋 Qué crea

| Colección | Docs |
|---|---|
| `professionals` | 6 profesionales aprobados, con ratings, ubicaciones en Valledupar |
| `services` | 12 servicios (2 por profesional) con precios en COP |
| `reviews` | 8 reseñas públicas distribuidas |

## 🗑️ Cómo borrar todo

```bash
npm run seed:clean
```

O manualmente en Firebase Console: busca documentos con ID que empiecen con `seed_`.
