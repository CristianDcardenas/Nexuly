import { Link } from "react-router";
import { MapPin, Star, Clock, Heart, Activity, Baby, Users, Sparkles, Navigation } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionals = [
  {
    id: 1,
    name: "Dra. Ana María García",
    specialty: "Enfermería General",
    rating: 4.9,
    reviews: 156,
    distance: "2.3 km",
    price: "$50,000",
    available: true,
    image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080"
  },
  {
    id: 2,
    name: "Lic. Carlos Mendoza",
    specialty: "Cuidado de Adultos Mayores",
    rating: 4.8,
    reviews: 124,
    distance: "3.1 km",
    price: "$45,000",
    available: true,
    image: "https://images.unsplash.com/photo-1758206523685-6e69f80a11ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbnVyc2UlMjBoZWFsdGhjYXJlfGVufDF8fHx8MTc3NDE4ODk3Nnww&ixlib=rb-4.1.0&q=80&w=1080"
  },
  {
    id: 3,
    name: "Ft. Laura Sánchez",
    specialty: "Fisioterapia",
    rating: 5.0,
    reviews: 89,
    distance: "1.8 km",
    price: "$60,000",
    available: false,
    image: "https://images.unsplash.com/photo-1764314138160-5f04f4a50dae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNhbCUyMHRoZXJhcGlzdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzQyMjE5MzB8MA&ixlib=rb-4.1.0&q=80&w=1080"
  }
];

const services = [
  { icon: Heart, label: "Enfermería", color: "bg-red-100 text-red-600" },
  { icon: Users, label: "Cuidado", color: "bg-violet-100 text-violet-600" },
  { icon: Activity, label: "Fisioterapia", color: "bg-green-100 text-green-600" },
  { icon: Baby, label: "Pediatría", color: "bg-purple-100 text-purple-600" }
];

export function Home() {
  return (
    <div className="p-4 space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-br from-violet-500 to-purple-500 rounded-2xl p-6 text-white">
        <h1 className="text-xl mb-1">¡Hola, María! 👋</h1>
        <p className="text-violet-50 text-sm mb-4">¿Qué servicio necesitas hoy?</p>

        <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 flex items-center gap-2 mb-3">
          <MapPin className="w-5 h-5" />
          <div className="flex-1">
            <p className="text-xs text-violet-100">Ubicación actual</p>
            <p className="text-sm">Valledupar, Cesar</p>
          </div>
          <button className="text-xs underline">Cambiar</button>
        </div>

        {/* AI Assistant Button */}
        <Link
          to="/ai-symptoms"
          className="bg-white/30 backdrop-blur-sm rounded-xl p-3 flex items-center gap-3 hover:bg-white/40 transition-colors"
        >
          <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
            <Sparkles className="w-5 h-5" />
          </div>
          <div className="flex-1">
            <p className="text-sm">Asistente IA</p>
            <p className="text-xs text-violet-100">Encuentra el profesional ideal para ti</p>
          </div>
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
          </svg>
        </Link>
      </div>

      {/* Services Grid */}
      <div>
        <h2 className="text-base mb-3 text-gray-800">Servicios</h2>
        <div className="grid grid-cols-4 gap-3">
          {services.map((service, index) => (
            <Link 
              key={index} 
              to="/search"
              className="flex flex-col items-center gap-2"
            >
              <div className={`w-14 h-14 rounded-2xl ${service.color} flex items-center justify-center`}>
                <service.icon className="w-6 h-6" />
              </div>
              <span className="text-xs text-gray-700 text-center">{service.label}</span>
            </Link>
          ))}
        </div>
      </div>

      {/* Recommended Professionals */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base text-gray-800">Recomendados para ti</h2>
          <Link to="/search" className="text-sm text-violet-600">Ver todos</Link>
        </div>

        <div className="space-y-3">
          {professionals.map((prof) => (
            <Link
              key={prof.id}
              to={`/profile/${prof.id}`}
              className="bg-white rounded-2xl p-4 flex gap-3 border border-gray-200 hover:shadow-md transition-shadow"
            >
              <ImageWithFallback 
                src={prof.image}
                alt={prof.name}
                className="w-20 h-20 rounded-xl object-cover"
              />
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm truncate text-gray-900">{prof.name}</h3>
                    <p className="text-xs text-gray-600">{prof.specialty}</p>
                  </div>
                  {prof.available && (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-green-100 text-green-700 text-xs whitespace-nowrap">
                      <div className="w-1.5 h-1.5 rounded-full bg-green-500" />
                      Disponible
                    </span>
                  )}
                </div>
                
                <div className="flex items-center gap-3 mt-2">
                  <div className="flex items-center gap-1">
                    <Star className="w-3.5 h-3.5 fill-yellow-400 text-yellow-400" />
                    <span className="text-xs">{prof.rating}</span>
                    <span className="text-xs text-gray-500">({prof.reviews})</span>
                  </div>
                  <div className="flex items-center gap-1 text-gray-600">
                    <MapPin className="w-3.5 h-3.5" />
                    <span className="text-xs">{prof.distance}</span>
                  </div>
                </div>
                
                <div className="flex items-center justify-between mt-2">
                  <span className="text-sm text-violet-600">{prof.price}/hora</span>
                  <div className="flex items-center gap-2">
                    <Link
                      to={`/map-route/${prof.id}`}
                      className="p-1.5 rounded-full bg-violet-100 text-violet-600 hover:bg-violet-200"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <Navigation className="w-3.5 h-3.5" />
                    </Link>
                    <span className="px-3 py-1 rounded-full bg-violet-600 text-white text-xs">
                      Ver perfil
                    </span>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Link to="/history" className="bg-white border border-gray-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 hover:shadow-md transition-shadow">
          <Clock className="w-8 h-8 text-violet-600" />
          <span className="text-sm text-gray-700">Historial</span>
        </Link>
        <Link to="/booking/1" className="bg-white border border-gray-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 hover:shadow-md transition-shadow">
          <Activity className="w-8 h-8 text-violet-600" />
          <span className="text-sm text-gray-700">Próximas citas</span>
        </Link>
      </div>
    </div>
  );
}