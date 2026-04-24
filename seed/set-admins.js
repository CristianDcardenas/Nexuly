/**
 * Configura exactamente los administradores permitidos de Nexuly.
 *
 * Uso:
 *   cd seed
 *   npm run set-admins -- admin1@email.com admin2@email.com
 *
 * Requiere `service-account.json` en este directorio.
 * Los usuarios deben existir previamente en Firebase Auth.
 */

import admin from 'firebase-admin';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const serviceAccount = require('./service-account.json');

const emails = process.argv.slice(2).map((email) => email.trim().toLowerCase());

if (emails.length !== 2 || emails.some((email) => !email.includes('@'))) {
  console.error('Uso: npm run set-admins -- admin1@email.com admin2@email.com');
  console.error('Debes pasar exactamente dos correos.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

try {
  const users = await Promise.all(
    emails.map((email) => admin.auth().getUserByEmail(email)),
  );

  await Promise.all(
    users.map((user) => admin.auth().setCustomUserClaims(user.uid, {
      role: 'admin',
    })),
  );

  console.log('Administradores configurados:');
  for (const user of users) {
    console.log(`- ${user.email} (${user.uid})`);
  }
  console.log('Cierra sesion y vuelve a iniciar para refrescar el token.');
  process.exit(0);
} catch (error) {
  console.error('No se pudieron configurar los administradores:', error);
  process.exit(1);
}
