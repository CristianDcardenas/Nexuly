/**
 * Script de seed para poblar Firestore con datos de prueba.
 *
 * Uso:
 *   1. Descarga tu service account key desde Firebase Console:
 *      Project Settings → Service accounts → Generate new private key
 *   2. Guárdala en este directorio como `service-account.json`
 *      (ESTÁ EN .gitignore, NO la subas a git).
 *   3. `cd seed && npm install`
 *   4. `node seed.js`
 *
 * Qué crea:
 *   - 6 profesionales aprobados (diferentes especialidades, ubicaciones en Valledupar)
 *   - 12 servicios (2 por profesional)
 *   - 8 reviews públicas distribuidas
 *
 * Para limpiar antes de volver a correr: `node seed.js --clean`
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const GeoPoint = admin.firestore.GeoPoint;
const Timestamp = admin.firestore.Timestamp;

const now = () => Timestamp.now();

// Coordenadas base: Valledupar, Cesar
const VALLEDUPAR = { lat: 10.4631, lng: -73.2532 };

// Pequeña variación aleatoria en la posición
const jitter = (base, range = 0.02) => base + (Math.random() - 0.5) * range;

// ---------------------------------------------------------------------------
// DATOS
// ---------------------------------------------------------------------------

const professionals = [
  {
    uid: 'seed_prof_1',
    fullName: 'Ana María García',
    email: 'ana.garcia@nexuly.demo',
    phone: '+57 300 111 1111',
    bio: 'Enfermera profesional con 10 años de experiencia en cuidado domiciliario. Especializada en adultos mayores y pacientes post-operatorios.',
    specialties: ['enfermeria', 'cuidado_adulto_mayor'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: true,
    coverageType: 'radius',
    coverageRadiusKm: 10,
    ratingAvg: 4.9,
    ratingCount: 156,
    responseTimeAvgMin: 15,
    acceptanceRate: 0.92,
    completionRate: 0.98,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
  {
    uid: 'seed_prof_2',
    fullName: 'Carlos Mendoza',
    email: 'carlos.mendoza@nexuly.demo',
    phone: '+57 300 222 2222',
    bio: 'Especialista en cuidado de adultos mayores. 8 años acompañando familias con pacientes con Alzheimer y movilidad reducida.',
    specialties: ['cuidado_adulto_mayor', 'acompanamiento'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: true,
    coverageType: 'radius',
    coverageRadiusKm: 8,
    ratingAvg: 4.8,
    ratingCount: 124,
    responseTimeAvgMin: 20,
    acceptanceRate: 0.88,
    completionRate: 0.96,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
  {
    uid: 'seed_prof_3',
    fullName: 'Laura Sánchez',
    email: 'laura.sanchez@nexuly.demo',
    phone: '+57 300 333 3333',
    bio: 'Fisioterapeuta titulada con 12 años de experiencia. Rehabilitación post-quirúrgica, deportiva y neurológica a domicilio.',
    specialties: ['fisioterapia', 'rehabilitacion'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: false,
    coverageType: 'radius',
    coverageRadiusKm: 12,
    ratingAvg: 5.0,
    ratingCount: 89,
    responseTimeAvgMin: 10,
    acceptanceRate: 0.95,
    completionRate: 0.99,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
  {
    uid: 'seed_prof_4',
    fullName: 'Patricia Ruiz',
    email: 'patricia.ruiz@nexuly.demo',
    phone: '+57 300 444 4444',
    bio: 'Enfermera pediátrica. 15 años cuidando niños desde recién nacidos hasta adolescentes. Especialista en lactancia y primeros cuidados.',
    specialties: ['enfermeria', 'pediatria'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: true,
    coverageType: 'radius',
    coverageRadiusKm: 15,
    ratingAvg: 4.9,
    ratingCount: 203,
    responseTimeAvgMin: 12,
    acceptanceRate: 0.91,
    completionRate: 0.97,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
  {
    uid: 'seed_prof_5',
    fullName: 'María Fernández',
    email: 'maria.fernandez@nexuly.demo',
    phone: '+57 300 555 5555',
    bio: 'Enfermera a domicilio con 7 años de experiencia. Aplicación de inyecciones, curaciones, control de signos vitales y medicación.',
    specialties: ['enfermeria'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: true,
    coverageType: 'radius',
    coverageRadiusKm: 10,
    ratingAvg: 4.7,
    ratingCount: 98,
    responseTimeAvgMin: 18,
    acceptanceRate: 0.85,
    completionRate: 0.95,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
  {
    uid: 'seed_prof_6',
    fullName: 'Roberto Silva',
    email: 'roberto.silva@nexuly.demo',
    phone: '+57 300 666 6666',
    bio: 'Acompañante terapéutico. 5 años apoyando a personas con discapacidad y procesos de rehabilitación emocional.',
    specialties: ['acompanamiento', 'cuidado_adulto_mayor'],
    validationStatus: 'approved',
    isActive: true,
    isAvailable: true,
    coverageType: 'radius',
    coverageRadiusKm: 8,
    ratingAvg: 4.6,
    ratingCount: 76,
    responseTimeAvgMin: 25,
    acceptanceRate: 0.80,
    completionRate: 0.94,
    location: new GeoPoint(jitter(VALLEDUPAR.lat), jitter(VALLEDUPAR.lng)),
  },
];

// Servicios: 2 por profesional. Todos en COP.
const services = [
  // Ana María - Enfermería
  { professionalId: 'seed_prof_1', name: 'Control de signos vitales', category: 'enfermeria', price: 35000, durationMin: 60, description: 'Toma de tensión, pulso, temperatura y saturación de oxígeno.' },
  { professionalId: 'seed_prof_1', name: 'Aplicación de inyecciones', category: 'enfermeria', price: 25000, durationMin: 30, description: 'Aplicación intramuscular o subcutánea. Se requiere prescripción.' },
  // Carlos - Cuidado
  { professionalId: 'seed_prof_2', name: 'Cuidado de adulto mayor (4 horas)', category: 'cuidado', price: 80000, durationMin: 240, description: 'Acompañamiento, higiene, alimentación y medicación supervisada.' },
  { professionalId: 'seed_prof_2', name: 'Acompañamiento médico', category: 'cuidado', price: 50000, durationMin: 120, description: 'Acompañamiento a cita médica u hospital.' },
  // Laura - Fisioterapia
  { professionalId: 'seed_prof_3', name: 'Terapia física a domicilio', category: 'fisioterapia', price: 60000, durationMin: 60, description: 'Rehabilitación personalizada según diagnóstico.' },
  { professionalId: 'seed_prof_3', name: 'Rehabilitación post-operatoria', category: 'fisioterapia', price: 80000, durationMin: 90, description: 'Plan de recuperación guiado tras cirugía.' },
  // Patricia - Pediatría
  { professionalId: 'seed_prof_4', name: 'Consulta pediátrica domiciliaria', category: 'pediatria', price: 70000, durationMin: 45, description: 'Valoración integral del niño en casa.' },
  { professionalId: 'seed_prof_4', name: 'Asesoría de lactancia', category: 'pediatria', price: 55000, durationMin: 60, description: 'Orientación y apoyo para lactancia materna.' },
  // María Fernández - Enfermería
  { professionalId: 'seed_prof_5', name: 'Curaciones', category: 'enfermeria', price: 40000, durationMin: 45, description: 'Limpieza y curación de heridas.' },
  { professionalId: 'seed_prof_5', name: 'Toma de muestras', category: 'enfermeria', price: 30000, durationMin: 30, description: 'Toma de sangre u otras muestras para laboratorio.' },
  // Roberto - Acompañamiento
  { professionalId: 'seed_prof_6', name: 'Acompañamiento terapéutico (2h)', category: 'cuidado', price: 42000, durationMin: 120, description: 'Apoyo emocional y social.' },
  { professionalId: 'seed_prof_6', name: 'Asistencia en rehabilitación', category: 'cuidado', price: 48000, durationMin: 90, description: 'Apoyo en ejercicios y rutinas de rehabilitación.' },
];

const reviews = [
  { targetId: 'seed_prof_1', rating: 5, comment: 'Excelente atención, muy profesional y puntual. La recomiendo totalmente.', authorName: 'María L.' },
  { targetId: 'seed_prof_1', rating: 5, comment: 'Atendió a mi papá con mucho cariño y conocimiento. Volveré a contratarla.', authorName: 'Juan P.' },
  { targetId: 'seed_prof_2', rating: 5, comment: 'Carlos es muy paciente con mi abuela. Ella lo quiere mucho.', authorName: 'Laura G.' },
  { targetId: 'seed_prof_3', rating: 5, comment: 'Mi rehabilitación va excelente gracias a Laura. Muy profesional.', authorName: 'Pedro S.' },
  { targetId: 'seed_prof_4', rating: 5, comment: 'Dra. Patricia es maravillosa con los niños. Totalmente recomendada.', authorName: 'Ana R.' },
  { targetId: 'seed_prof_4', rating: 4, comment: 'Muy buena atención, aunque llegó 15 min tarde.', authorName: 'Carlos M.' },
  { targetId: 'seed_prof_5', rating: 5, comment: 'María es muy hábil aplicando inyecciones, casi no duele.', authorName: 'Rosa E.' },
  { targetId: 'seed_prof_6', rating: 4, comment: 'Buen acompañante, respetuoso y amable.', authorName: 'Diego T.' },
];

// ---------------------------------------------------------------------------
// LÓGICA DE SEED
// ---------------------------------------------------------------------------

const clean = process.argv.includes('--clean');

async function cleanCollections() {
  console.log('🧹 Limpiando datos de seed existentes...');
  const collectionsToClean = ['professionals', 'services', 'reviews'];
  for (const col of collectionsToClean) {
    const snap = await db.collection(col).get();
    const seedDocs = snap.docs.filter((d) => d.id.startsWith('seed_'));
    console.log(`   ${col}: ${seedDocs.length} docs a borrar`);
    const batch = db.batch();
    seedDocs.forEach((d) => batch.delete(d.ref));
    if (seedDocs.length > 0) await batch.commit();
  }
  console.log('✅ Limpieza completa');
}

async function seed() {
  console.log('🌱 Iniciando seed de Firestore...\n');

  if (clean) {
    await cleanCollections();
    console.log('');
  }

  // --- Profesionales ---
  console.log(`📝 Creando ${professionals.length} profesionales...`);
  for (const p of professionals) {
    await db.collection('professionals').doc(p.uid).set({
      uid: p.uid,
      full_name: p.fullName,
      email: p.email,
      phone: p.phone,
      bio: p.bio,
      specialties: p.specialties,
      validation_status: p.validationStatus,
      rejection_count: 0,
      is_active: p.isActive,
      is_available: p.isAvailable,
      do_not_disturb: false,
      location: p.location,
      coverage_type: p.coverageType,
      coverage_radius_km: p.coverageRadiusKm,
      coverage_zones: [],
      rating_avg: p.ratingAvg,
      rating_count: p.ratingCount,
      response_time_avg_min: p.responseTimeAvgMin,
      acceptance_rate: p.acceptanceRate,
      completion_rate: p.completionRate,
      created_at: now(),
      updated_at: now(),
    });
    console.log(`   ✓ ${p.fullName}`);
  }

  // --- Servicios ---
  console.log(`\n📝 Creando ${services.length} servicios...`);
  for (let i = 0; i < services.length; i++) {
    const s = services[i];
    const id = `seed_svc_${i + 1}`;
    await db.collection('services').doc(id).set({
      id,
      professional_id: s.professionalId,
      name: s.name,
      description: s.description,
      category: s.category,
      service_type: 'presencial',
      price: s.price,
      currency: 'COP',
      duration_min: s.durationMin,
      is_active: true,
      created_at: now(),
      updated_at: now(),
    });
    console.log(`   ✓ ${s.name} ($${s.price.toLocaleString()})`);
  }

  // --- Reviews ---
  console.log(`\n📝 Creando ${reviews.length} reseñas...`);
  for (let i = 0; i < reviews.length; i++) {
    const r = reviews[i];
    const id = `seed_rev_${i + 1}`;
    await db.collection('reviews').doc(id).set({
      id,
      request_id: `seed_req_${i + 1}`,
      author_id: `seed_user_${i + 1}`,
      target_id: r.targetId,
      author_role: 'user',
      target_role: 'professional',
      rating: r.rating,
      comment: r.comment,
      is_public: true,
      author_name: r.authorName, // extra, solo para display
      created_at: now(),
    });
    console.log(`   ✓ ${r.authorName} → ${r.targetId} (${r.rating}⭐)`);
  }

  console.log('\n✨ Seed completado exitosamente!');
  process.exit(0);
}

seed().catch((e) => {
  console.error('❌ Error:', e);
  process.exit(1);
});
