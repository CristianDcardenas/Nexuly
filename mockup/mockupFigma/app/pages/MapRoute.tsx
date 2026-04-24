import { Link, useParams } from "react-router";
import { ArrowLeft, Navigation, MapPin, Clock, Phone, MessageSquare, Star } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionals = {
  "1": {
    name: "Dra. Ana María García",
    specialty: "Enfermería General",
    rating: 4.9,
    phone: "+57 300 123 4567",
    image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
    address: "Calle 15 #10-25, Valledupar",
    userAddress: "Av. Simón Bolívar #45-12, Valledupar"
  },
  "2": {
    name: "Lic. Carlos Mendoza",
    specialty: "Cuidado de Adultos Mayores",
    rating: 4.8,
    phone: "+57 301 234 5678",
    image: "https://images.unsplash.com/photo-1758206523685-6e69f80a11ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbnVyc2UlMjBoZWFsdGhjYXJlfGVufDF8fHx8MTc3NDE4ODk3Nnww&ixlib=rb-4.1.0&q=80&w=1080",
    address: "Carrera 9 #20-10, Valledupar",
    userAddress: "Av. Simón Bolívar #45-12, Valledupar"
  },
  "3": {
    name: "Ft. Laura Sánchez",
    specialty: "Fisioterapia",
    rating: 5.0,
    phone: "+57 302 345 6789",
    image: "https://images.unsplash.com/photo-1764314138160-5f04f4a50dae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNhbCUyMHRoZXJhcGlzdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzQyMjE5MzB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    address: "Calle 18 #5-30, Valledupar",
    userAddress: "Av. Simón Bolívar #45-12, Valledupar"
  }
};

export function MapRoute() {
  const { id } = useParams<{ id: string }>();
  const professional = professionals[id as keyof typeof professionals];

  if (!professional) {
    return <div>Profesional no encontrado</div>;
  }

  return (
    <div className="h-screen flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 p-4 z-10">
        <div className="flex items-center gap-3">
          <Link to="/" className="p-2 rounded-full hover:bg-gray-100">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="flex-1">
            <h1 className="text-base">Ruta de navegación</h1>
            <p className="text-xs text-gray-600">Tiempo estimado: 15 min</p>
          </div>
        </div>
      </div>

      {/* Map Area */}
      <div className="flex-1 relative bg-gray-200">
        {/* Mapa simulado con SVG */}
        <svg className="w-full h-full" viewBox="0 0 400 600" xmlns="http://www.w3.org/2000/svg">
          {/* Background */}
          <rect width="400" height="600" fill="#e5e7eb"/>

          {/* Streets */}
          <line x1="0" y1="200" x2="400" y2="200" stroke="#9ca3af" strokeWidth="8"/>
          <line x1="0" y1="400" x2="400" y2="400" stroke="#9ca3af" strokeWidth="8"/>
          <line x1="150" y1="0" x2="150" y2="600" stroke="#9ca3af" strokeWidth="8"/>
          <line x1="300" y1="0" x2="300" y2="600" stroke="#9ca3af" strokeWidth="8"/>

          {/* Route Path */}
          <path
            d="M 100 450 L 150 450 L 150 200 L 300 200 L 300 150"
            fill="none"
            stroke="#8b5cf6"
            strokeWidth="6"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray="10,5"
          />

          {/* Route Overlay */}
          <path
            d="M 100 450 L 150 450 L 150 200 L 300 200 L 300 150"
            fill="none"
            stroke="#a78bfa"
            strokeWidth="4"
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* User Location (Starting Point) */}
          <circle cx="100" cy="450" r="20" fill="#22c55e" opacity="0.3"/>
          <circle cx="100" cy="450" r="12" fill="#22c55e"/>
          <circle cx="100" cy="450" r="6" fill="white"/>

          {/* Professional Location (Destination) */}
          <g>
            <circle cx="300" cy="150" r="25" fill="#8b5cf6" opacity="0.2"/>
            <circle cx="300" cy="150" r="18" fill="#8b5cf6"/>
            <path d="M 300 140 L 300 155 M 295 150 L 305 150" stroke="white" strokeWidth="2.5" strokeLinecap="round"/>
          </g>

          {/* Waypoint markers */}
          <circle cx="150" cy="450" r="6" fill="#8b5cf6"/>
          <circle cx="150" cy="200" r="6" fill="#8b5cf6"/>
          <circle cx="300" cy="200" r="6" fill="#8b5cf6"/>

          {/* Buildings (for context) */}
          <rect x="50" y="250" width="60" height="80" fill="#d1d5db" opacity="0.5"/>
          <rect x="320" y="220" width="50" height="60" fill="#d1d5db" opacity="0.5"/>
          <rect x="180" y="100" width="70" height="70" fill="#d1d5db" opacity="0.5"/>
          <rect x="50" y="100" width="60" height="60" fill="#d1d5db" opacity="0.5"/>
        </svg>

        {/* Distance overlay */}
        <div className="absolute top-4 left-4 right-4">
          <div className="bg-white rounded-xl p-3 shadow-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Navigation className="w-5 h-5 text-violet-600" />
                <div>
                  <p className="text-sm">2.3 km</p>
                  <p className="text-xs text-gray-600">15 min en auto</p>
                </div>
              </div>
              <div className="text-right">
                <p className="text-sm">Llegada estimada</p>
                <p className="text-xs text-gray-600">11:45 AM</p>
              </div>
            </div>
          </div>
        </div>

        {/* Turn by turn instructions */}
        <div className="absolute bottom-4 left-4 right-4">
          <div className="bg-white rounded-t-xl p-4 shadow-lg">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                <Navigation className="w-5 h-5 text-violet-600" />
              </div>
              <div className="flex-1">
                <p className="text-sm">En 200 m, gira a la derecha</p>
                <p className="text-xs text-gray-600">hacia Calle 15</p>
              </div>
            </div>

            {/* Route steps */}
            <div className="space-y-2 pt-3 border-t border-gray-100">
              <div className="flex items-center gap-2 text-xs text-gray-600">
                <div className="w-1.5 h-1.5 rounded-full bg-violet-600" />
                <span>Inicio - Av. Simón Bolívar</span>
              </div>
              <div className="flex items-center gap-2 text-xs text-gray-600">
                <div className="w-1.5 h-1.5 rounded-full bg-violet-400" />
                <span>Continúa por Calle 15 (800 m)</span>
              </div>
              <div className="flex items-center gap-2 text-xs text-gray-600">
                <div className="w-1.5 h-1.5 rounded-full bg-violet-400" />
                <span>Gira a la izquierda en Carrera 10</span>
              </div>
              <div className="flex items-center gap-2 text-xs text-gray-600">
                <div className="w-1.5 h-1.5 rounded-full bg-violet-600" />
                <span>Destino - {professional.address}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Professional Info Bottom Sheet */}
      <div className="bg-white border-t border-gray-200 p-4">
        <div className="flex gap-3 mb-3">
          <ImageWithFallback
            src={professional.image}
            alt={professional.name}
            className="w-16 h-16 rounded-xl object-cover"
          />
          <div className="flex-1">
            <h3 className="text-sm">{professional.name}</h3>
            <p className="text-xs text-gray-600 mb-1">{professional.specialty}</p>
            <div className="flex items-center gap-1">
              <Star className="w-3.5 h-3.5 fill-yellow-400 text-yellow-400" />
              <span className="text-xs">{professional.rating}</span>
            </div>
          </div>
        </div>

        {/* Location Info */}
        <div className="space-y-2 mb-3 p-3 bg-gray-50 rounded-lg">
          <div className="flex items-start gap-2">
            <MapPin className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-xs text-gray-500">Tu ubicación</p>
              <p className="text-xs">{professional.userAddress}</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <Navigation className="w-4 h-4 text-violet-600 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-xs text-gray-500">Destino</p>
              <p className="text-xs">{professional.address}</p>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="grid grid-cols-3 gap-2">
          <Link
            to={`/chat/${id}`}
            className="flex flex-col items-center gap-1 p-3 rounded-xl bg-gray-100 hover:bg-gray-200"
          >
            <MessageSquare className="w-5 h-5 text-gray-600" />
            <span className="text-xs text-gray-600">Chat</span>
          </Link>
          <a
            href={`tel:${professional.phone}`}
            className="flex flex-col items-center gap-1 p-3 rounded-xl bg-gray-100 hover:bg-gray-200"
          >
            <Phone className="w-5 h-5 text-gray-600" />
            <span className="text-xs text-gray-600">Llamar</span>
          </a>
          <button className="flex flex-col items-center gap-1 p-3 rounded-xl bg-violet-600 text-white">
            <Navigation className="w-5 h-5" />
            <span className="text-xs">Iniciar</span>
          </button>
        </div>
      </div>
    </div>
  );
}
