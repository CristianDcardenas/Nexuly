import { Link, useParams } from "react-router";
import { MapPin, Star, Clock, Award, Shield, MessageSquare, Calendar, Heart, Navigation, CheckCircle2, FileText, ShieldCheck } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana Maria Garcia",
  specialty: "Enfermeria General",
  rating: 4.9,
  reviews: 156,
  distance: "2.3 km",
  price: 50000,
  available: true,
  verified: true,
  experience: "10 anos",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  description: "Enfermera profesional con mas de 10 anos de experiencia en atencion domiciliaria. Especializada en cuidados post-operatorios, terapia intravenosa y manejo de pacientes cronicos.",
  // Verification status data
  validationStatus: "approved" as const, // pending | in_review | approved | rejected
  documentsVerified: {
    identity: true,
    professionalDegree: true,
    professionalLicense: true,
    backgroundCheck: true,
  },
  licenseNumber: "ENF-2024-12345",
  licenseExpiry: "2027-12-31",
  certifications: [
    "Certificacion en Cuidados Intensivos",
    "Especializacion en Geriatria",
    "RCP Avanzado"
  ],
  services: [
    "Aplicación de inyecciones",
    "Toma de signos vitales",
    "Curaciones",
    "Administración de medicamentos",
    "Terapia intravenosa",
    "Cuidados post-operatorios"
  ],
  schedule: {
    available: "Lun - Vie: 8:00 AM - 6:00 PM",
    response: "Responde en menos de 1 hora"
  }
};

const reviews = [
  {
    id: 1,
    name: "María Rodríguez",
    rating: 5,
    date: "Hace 2 días",
    comment: "Excelente profesional, muy atenta y cuidadosa. Mi madre quedó muy contenta con el servicio."
  },
  {
    id: 2,
    name: "Juan Pérez",
    rating: 5,
    date: "Hace 1 semana",
    comment: "Muy puntual y profesional. Recomendada al 100%."
  },
  {
    id: 3,
    name: "Laura González",
    rating: 4,
    date: "Hace 2 semanas",
    comment: "Buen servicio, aunque me hubiera gustado más comunicación previa."
  }
];

export function Profile() {
  const { id } = useParams();

  return (
    <div className="pb-4">
      {/* Hero Section */}
      <div className="relative bg-gradient-to-br from-violet-500 to-purple-500 px-4 pt-4 pb-20">
        <button 
          onClick={() => window.history.back()}
          className="absolute top-4 left-4 w-8 h-8 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        
        <button className="absolute top-4 right-4 w-8 h-8 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white">
          <Heart className="w-5 h-5" />
        </button>
      </div>

      {/* Profile Card */}
      <div className="px-4 -mt-16">
        <div className="bg-white rounded-2xl shadow-lg p-4">
          <div className="flex gap-4">
            <div className="relative">
              <ImageWithFallback 
                src={professionalData.image}
                alt={professionalData.name}
                className="w-24 h-24 rounded-2xl object-cover"
              />
              {professionalData.verified && (
                <div className="absolute -top-2 -right-2 w-8 h-8 bg-violet-600 rounded-full flex items-center justify-center border-2 border-white">
                  <Shield className="w-4 h-4 text-white" />
                </div>
              )}
            </div>

            <div className="flex-1 min-w-0">
              <h1 className="text-lg mb-1 text-gray-900">{professionalData.name}</h1>
              <p className="text-sm text-gray-600 mb-2">{professionalData.specialty}</p>
              
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1">
                  <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                  <span className="text-sm">{professionalData.rating}</span>
                  <span className="text-sm text-gray-500">({professionalData.reviews})</span>
                </div>
                <div className="flex items-center gap-1 text-gray-600">
                  <MapPin className="w-4 h-4" />
                  <span className="text-sm">{professionalData.distance}</span>
                </div>
              </div>

              {professionalData.available && (
                <div className="mt-2 inline-flex items-center gap-1 px-2 py-1 rounded-full bg-green-100 text-green-700 text-xs">
                  <div className="w-2 h-2 rounded-full bg-green-500" />
                  Disponible ahora
                </div>
              )}
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-3 gap-3 mt-4 pt-4 border-t border-gray-100">
            <div className="text-center">
              <div className="w-10 h-10 bg-violet-100 rounded-xl flex items-center justify-center mx-auto mb-1">
                <Clock className="w-5 h-5 text-violet-600" />
              </div>
              <p className="text-xs text-gray-600">{professionalData.experience}</p>
              <p className="text-xs text-gray-500">Experiencia</p>
            </div>
            <div className="text-center">
              <div className="w-10 h-10 bg-yellow-100 rounded-xl flex items-center justify-center mx-auto mb-1">
                <Award className="w-5 h-5 text-yellow-600" />
              </div>
              <p className="text-xs text-gray-600">{professionalData.certifications.length}</p>
              <p className="text-xs text-gray-500">Certificados</p>
            </div>
            <div className="text-center">
              <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center mx-auto mb-1">
                <Star className="w-5 h-5 text-green-600" />
              </div>
              <p className="text-xs text-gray-600">{professionalData.reviews}</p>
              <p className="text-xs text-gray-500">Opiniones</p>
            </div>
          </div>
        </div>

        {/* About */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-2 text-gray-900">Sobre mí</h2>
          <p className="text-sm text-gray-600 leading-relaxed">{professionalData.description}</p>
        </div>

        {/* Services */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Servicios</h2>
          <div className="flex flex-wrap gap-2">
            {professionalData.services.map((service, index) => (
              <span 
                key={index}
                className="px-3 py-1.5 rounded-full bg-violet-50 text-violet-700 text-xs"
              >
                {service}
              </span>
            ))}
          </div>
        </div>

        {/* Professional Verification Status */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base text-gray-900">Verificacion profesional</h2>
            <span className="flex items-center gap-1 px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs">
              <ShieldCheck className="w-3 h-3" />
              Aprobado
            </span>
          </div>
          
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              <span className="text-xs text-gray-700">Identidad verificada</span>
            </div>
            <div className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              <span className="text-xs text-gray-700">Titulo profesional</span>
            </div>
            <div className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              <span className="text-xs text-gray-700">Tarjeta profesional</span>
            </div>
            <div className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              <span className="text-xs text-gray-700">Antecedentes</span>
            </div>
          </div>

          <div className="flex items-center justify-between text-sm pt-3 border-t border-gray-100">
            <div className="flex items-center gap-2 text-gray-600">
              <FileText className="w-4 h-4" />
              <span>Licencia: {professionalData.licenseNumber}</span>
            </div>
            <span className="text-xs text-gray-500">Vigente hasta 2027</span>
          </div>
        </div>

        {/* Certifications */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Certificaciones</h2>
          <div className="space-y-2">
            {professionalData.certifications.map((cert, index) => (
              <div key={index} className="flex items-center gap-2">
                <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                  <Award className="w-4 h-4 text-green-600" />
                </div>
                <span className="text-sm text-gray-700">{cert}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Availability */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Disponibilidad</h2>
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <Calendar className="w-4 h-4 text-gray-600" />
              <span className="text-sm text-gray-700">{professionalData.schedule.available}</span>
            </div>
            <div className="flex items-center gap-2">
              <MessageSquare className="w-4 h-4 text-gray-600" />
              <span className="text-sm text-gray-700">{professionalData.schedule.response}</span>
            </div>
          </div>
        </div>

        {/* Reviews */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base text-gray-900">Opiniones</h2>
            <button className="text-sm text-violet-600">Ver todas</button>
          </div>

          <div className="space-y-3">
            {reviews.map((review) => (
              <div key={review.id} className="pb-3 border-b border-gray-100 last:border-0 last:pb-0">
                <div className="flex items-center justify-between mb-2">
                  <div>
                    <p className="text-sm text-gray-900">{review.name}</p>
                    <p className="text-xs text-gray-500">{review.date}</p>
                  </div>
                  <div className="flex items-center gap-0.5">
                    {[...Array(5)].map((_, i) => (
                      <Star 
                        key={i}
                        className={`w-3.5 h-3.5 ${
                          i < review.rating 
                            ? 'fill-yellow-400 text-yellow-400' 
                            : 'text-gray-300'
                        }`}
                      />
                    ))}
                  </div>
                </div>
                <p className="text-sm text-gray-600">{review.comment}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Location and Route */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Ubicación</h2>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <MapPin className="w-4 h-4 text-gray-600" />
              <span className="text-sm text-gray-700">{professionalData.distance} de distancia</span>
            </div>
            <Link
              to={`/map-route/${professionalData.id}`}
              className="flex items-center gap-2 px-4 py-2 rounded-full bg-violet-100 text-violet-600 text-sm hover:bg-violet-200"
            >
              <Navigation className="w-4 h-4" />
              Ver ruta
            </Link>
          </div>
        </div>

        {/* Price and Actions */}
        <div className="mt-4 bg-white rounded-2xl p-4 border border-gray-200 sticky bottom-20">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-xs text-gray-600">Tarifa por hora</p>
              <p className="text-xl text-violet-600">${professionalData.price.toLocaleString()}</p>
            </div>
            <div className="flex gap-2">
              <Link
                to={`/chat/${professionalData.id}`}
                className="px-4 py-3 rounded-xl border border-violet-600 text-violet-600 flex items-center gap-2"
              >
                <MessageSquare className="w-5 h-5" />
              </Link>
              <Link
                to={`/booking/${professionalData.id}`}
                className="px-6 py-3 rounded-xl bg-violet-600 text-white"
              >
                Reservar
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
