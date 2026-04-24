import { Link } from "react-router";
import { useState } from "react";
import { Search as SearchIcon, SlidersHorizontal, MapPin, Star, Clock } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const allProfessionals = [
  {
    id: 1,
    name: "Dra. Ana María García",
    specialty: "Enfermería General",
    rating: 4.9,
    reviews: 156,
    distance: "2.3 km",
    price: 50000,
    available: true,
    verified: true,
    experience: "10 años",
    image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "enfermeria"
  },
  {
    id: 2,
    name: "Lic. Carlos Mendoza",
    specialty: "Cuidado de Adultos Mayores",
    rating: 4.8,
    reviews: 124,
    distance: "3.1 km",
    price: 45000,
    available: true,
    verified: true,
    experience: "8 años",
    image: "https://images.unsplash.com/photo-1758206523685-6e69f80a11ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbnVyc2UlMjBoZWFsdGhjYXJlfGVufDF8fHx8MTc3NDE4ODk3Nnww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "cuidado"
  },
  {
    id: 3,
    name: "Ft. Laura Sánchez",
    specialty: "Fisioterapia",
    rating: 5.0,
    reviews: 89,
    distance: "1.8 km",
    price: 60000,
    available: false,
    verified: true,
    experience: "12 años",
    image: "https://images.unsplash.com/photo-1764314138160-5f04f4a50dae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNhbCUyMHRoZXJhcGlzdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzQyMjE5MzB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "fisioterapia"
  },
  {
    id: 4,
    name: "Dra. Patricia Ruiz",
    specialty: "Enfermería Pediátrica",
    rating: 4.9,
    reviews: 203,
    distance: "4.2 km",
    price: 55000,
    available: true,
    verified: true,
    experience: "15 años",
    image: "https://images.unsplash.com/photo-1758654859751-7dfe0c8388a3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZWRpYXRyaWMlMjBudXJzZSUyMGNoaWxkcmVufGVufDF8fHx8MTc3NDIyMTkzMXww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "pediatria"
  },
  {
    id: 5,
    name: "Enf. María Fernández",
    specialty: "Enfermería a Domicilio",
    rating: 4.7,
    reviews: 98,
    distance: "2.8 km",
    price: 48000,
    available: true,
    verified: true,
    experience: "7 años",
    image: "https://images.unsplash.com/photo-1638202993928-7267aad84c31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwcHJvZmVzc2lvbmFsJTIwd29tYW58ZW58MXx8fHwxNzc0MDk1Njg5fDA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "enfermeria"
  },
  {
    id: 6,
    name: "Lic. Roberto Silva",
    specialty: "Acompañante Terapéutico",
    rating: 4.6,
    reviews: 76,
    distance: "3.5 km",
    price: 42000,
    available: true,
    verified: false,
    experience: "5 años",
    image: "https://images.unsplash.com/photo-1773227060446-93239a553f1f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjYXJlZ2l2ZXIlMjBlbGRlcmx5JTIwY2FyZXxlbnwxfHx8fDE3NzQyMjE5Mjl8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "cuidado"
  }
];

const categories = [
  { id: "todos", label: "Todos" },
  { id: "enfermeria", label: "Enfermería" },
  { id: "cuidado", label: "Cuidado" },
  { id: "fisioterapia", label: "Fisioterapia" },
  { id: "pediatria", label: "Pediatría" }
];

export function Search() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("todos");
  const [showFilters, setShowFilters] = useState(false);
  const [filterAvailable, setFilterAvailable] = useState(false);
  const [filterVerified, setFilterVerified] = useState(false);

  const filteredProfessionals = allProfessionals.filter((prof) => {
    const matchesSearch = prof.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         prof.specialty.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === "todos" || prof.category === selectedCategory;
    const matchesAvailable = !filterAvailable || prof.available;
    const matchesVerified = !filterVerified || prof.verified;
    
    return matchesSearch && matchesCategory && matchesAvailable && matchesVerified;
  });

  return (
    <div className="p-4 space-y-4">
      {/* Search Bar */}
      <div className="flex gap-2">
        <div className="flex-1 relative">
          <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar profesionales..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-500"
          />
        </div>
        <button 
          onClick={() => setShowFilters(!showFilters)}
          className={`px-4 py-3 rounded-xl border flex items-center gap-2 ${
            showFilters ? 'bg-violet-600 text-white border-violet-600' : 'bg-white border-gray-300 text-gray-700'
          }`}
        >
          <SlidersHorizontal className="w-5 h-5" />
        </button>
      </div>

      {/* Filters */}
      {showFilters && (
        <div className="bg-white rounded-2xl p-4 border border-gray-200 space-y-3">
          <div className="flex items-center justify-between">
            <label className="text-sm text-gray-700">Solo disponibles</label>
            <input
              type="checkbox"
              checked={filterAvailable}
              onChange={(e) => setFilterAvailable(e.target.checked)}
              className="w-5 h-5 rounded accent-violet-600"
            />
          </div>
          <div className="flex items-center justify-between">
            <label className="text-sm text-gray-700">Solo verificados</label>
            <input
              type="checkbox"
              checked={filterVerified}
              onChange={(e) => setFilterVerified(e.target.checked)}
              className="w-5 h-5 rounded accent-violet-600"
            />
          </div>
        </div>
      )}

      {/* Categories */}
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`px-4 py-2 rounded-full whitespace-nowrap text-sm transition-colors ${
              selectedCategory === cat.id
                ? 'bg-violet-600 text-white'
                : 'bg-white border border-gray-300 text-gray-700'
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* Results */}
      <div>
        <p className="text-sm text-gray-600 mb-3">
          {filteredProfessionals.length} profesionales encontrados
        </p>

        <div className="space-y-3">
          {filteredProfessionals.map((prof) => (
            <Link
              key={prof.id}
              to={`/profile/${prof.id}`}
              className="bg-white rounded-2xl p-4 flex gap-3 border border-gray-200 hover:shadow-md transition-shadow"
            >
              <div className="relative">
                <ImageWithFallback 
                  src={prof.image}
                  alt={prof.name}
                  className="w-24 h-24 rounded-xl object-cover"
                />
                {prof.verified && (
                  <div className="absolute -top-1 -right-1 w-6 h-6 bg-violet-600 rounded-full flex items-center justify-center">
                    <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </div>
                )}
              </div>
              
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm truncate text-gray-900">{prof.name}</h3>
                    <p className="text-xs text-gray-600">{prof.specialty}</p>
                  </div>
                  {prof.available ? (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-green-100 text-green-700 text-xs whitespace-nowrap">
                      <div className="w-1.5 h-1.5 rounded-full bg-green-500" />
                      Ahora
                    </span>
                  ) : (
                    <span className="px-2 py-0.5 rounded-full bg-gray-100 text-gray-600 text-xs whitespace-nowrap">
                      No disponible
                    </span>
                  )}
                </div>
                
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
                  <div className="flex items-center gap-1 text-gray-600">
                    <Clock className="w-3.5 h-3.5" />
                    <span className="text-xs">{prof.experience}</span>
                  </div>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-violet-600">${prof.price.toLocaleString()}/hora</span>
                  <button className="px-3 py-1 rounded-full bg-violet-600 text-white text-xs">
                    Ver perfil
                  </button>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}