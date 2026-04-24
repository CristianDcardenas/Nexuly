/**
 * Asigna el custom claim role=admin a un usuario de Firebase Auth.
 *
 * Uso:
 *   cd seed
 *   node set-admin.js correo@ejemplo.com
 *
 * Requiere `service-account.json` en este directorio, igual que seed.js.
 */

import admin from 'firebase-admin';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const serviceAccount = require('./service-account.json');

const email = process.argv[2];

if (!email) {
  console.error('Uso: node set-admin.js correo@ejemplo.com');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

try {
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { role: 'admin' });
  console.log(`Admin habilitado para ${email} (${user.uid})`);
  console.log('Cierra sesion y vuelve a iniciar para refrescar el token.');
  process.exit(0);
} catch (error) {
  console.error('No se pudo asignar el rol admin:', error);
  process.exit(1);
}
