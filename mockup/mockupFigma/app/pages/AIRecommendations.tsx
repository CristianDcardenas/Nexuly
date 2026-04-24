import { Link, useLocation } from "react-router";
import { ArrowLeft, Sparkles, Star, MapPin, Navigation } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const recommendedProfessionals = [
  {
    id: 1,
    name: "Dra. Ana María García",
    specialty: "Enfermería General",
    rating: 4.9,
    reviews: 156,
    distance: "2.3 km",
    price: "$50,000",
    matchScore: 98,
    matchReason: "Especialista en cuidado postoperatorio con 15 años de experiencia",
    image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080"
  },
  {
    id: 3,
    name: "Ft. Laura Sánchez",
    specialty: "Fisioterapia",
    rating: 5.0,
    reviews: 89,
    distance: "1.8 km",
    price: "$60,000",
    matchScore: 95,
    matchReason: "Experta en rehabilitación física y terapia del dolor",
    image: "https://images.unsplash.com/photo-1764314138160-5f04f4a50dae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNhbCUyMHRoZXJhcGlzdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzQyMjE5MzB8MA&ixlib=rb-4.1.0&q=80&w=1080"
  },
  {
    id: 2,
    name: "Lic. Carlos Mendoza",
    specialty: "Cuidado de Adultos Mayores",
    rating: 4.8,
    reviews: 124,
    distance: "3.1 km",
    price: "$45,000",
    matchScore: 87,
    matchReason: "Certificado en atención geriátrica y cuidado domiciliario",
    image: "https://images.unsplash.com/photo-1758206523685-6e69f80a11ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbnVyc2UlMjBoZWFsdGhjYXJlfGVufDF8fHx8MTc3NDE4ODk3Nnww&ixlib=rb-4.1.0&q=80&w=1080"
  }
];

export function AIRecommendations() {
  const location = useLocation();
  const { symptoms, description, needs } = location.state || { symptoms: [], description: "", needs: [] };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-br from-violet-500 to-purple-500 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Link to="/ai-symptoms" className="p-2 rounded-full hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="flex-1">
            <h1 className="text-lg">Recomendaciones IA</h1>
            <p className="text-sm text-violet-100">Profesionales seleccionados para ti</p>
          </div>
        </div>

        <div className="bg-white/20 backdrop-blur-sm rounded-xl p-4">
          <div className="flex items-start gap-3 mb-3">
            <Sparkles className="w-5 h-5 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-sm mb-2">
                Hemos analizado tus necesidades y encontrado {recommendedProfessionals.length} profesionales altamente compatibles.
              </p>
            </div>
          </div>

          {/* Resumen de búsqueda */}
          <div className="space-y-1">
            {symptoms.length > 0 && (
              <p className="text-xs text-violet-100">
                Síntomas: {symptoms.length} seleccionados
              </p>
            )}
            {needs.length > 0 && (
              <p className="text-xs text-violet-100">
                Necesidades: {needs.join(", ")}
              </p>
            )}
          </div>
        </div>
      </div>

      <div className="p-4 space-y-3 pb-24">
        {/* Lista de profesionales recomendados */}
        {recommendedProfessionals.map((prof) => (
          <div
            key={prof.id}
            className="bg-white rounded-2xl p-4 border border-gray-200 shadow-sm"
          >
            {/* Match Score Badge */}
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-violet-600" />
                <span className="text-sm text-violet-600">
                  {prof.matchScore}% compatible
                </span>
              </div>
              <Link
                to={`/map-route/${prof.id}`}
                className="flex items-center gap-1 px-3 py-1.5 rounded-full bg-violet-50 text-violet-600 text-xs"
              >
                <Navigation className="w-3.5 h-3.5" />
                Ver ruta
              </Link>
            </div>

            {/* Professional Card */}
            <Link
              to={`/profile/${prof.id}`}
              className="flex gap-3"
            >
              <ImageWithFallback
                src={prof.image}
                alt={prof.name}
                className="w-20 h-20 rounded-xl object-cover"
              />
              <div className="flex-1 min-w-0">
                <h3 className="text-sm text-gray-900 mb-0.5">{prof.name}</h3>
                <p className="text-xs text-gray-600 mb-2">{prof.specialty}</p>

                <div className="flex items-center gap-3 mb-2">
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

                <div className="flex items-center justify-between">
                  <span className="text-sm text-violet-600">{prof.price}/hora</span>
                </div>
              </div>
            </Link>

            {/* AI Match Reason */}
            <div className="mt-3 pt-3 border-t border-gray-100">
              <p className="text-xs text-gray-600">
                <span className="font-medium">Por qué recomendamos:</span> {prof.matchReason}
              </p>
            </div>

            {/* Action Buttons */}
            <div className="mt-3 grid grid-cols-2 gap-2">
              <Link
                to={`/profile/${prof.id}`}
                className="px-4 py-2 rounded-full border-2 border-violet-600 text-violet-600 text-sm text-center"
              >
                Ver perfil
              </Link>
              <Link
                to={`/booking/${prof.id}`}
                className="px-4 py-2 rounded-full bg-violet-600 text-white text-sm text-center"
              >
                Reservar
              </Link>
            </div>
          </div>
        ))}

        {/* Refinar búsqueda */}
        <Link
          to="/ai-symptoms"
          className="w-full p-4 rounded-xl border-2 border-dashed border-gray-300 text-center text-sm text-gray-600 hover:border-violet-500 hover:text-violet-600 transition-colors"
        >
          Refinar búsqueda
        </Link>
      </div>
    </div>
  );
}
