import { useState } from "react";
import { Link } from "react-router";
import { 
  Calendar, 
  Clock, 
  MapPin, 
  User,
  ChevronRight,
  CheckCircle2,
  XCircle,
  Filter,
  Search
} from "lucide-react";

type RequestStatus = "pending" | "confirmed" | "completed" | "cancelled";
type TabType = "pending" | "confirmed" | "history";

interface ServiceRequest {
  id: number;
  userName: string;
  userTrustLevel: "basic" | "verified" | "trusted";
  service: string;
  date: string;
  time: string;
  location: string;
  price: string;
  distance: string;
  status: RequestStatus;
  createdAt: string;
}

const allRequests: ServiceRequest[] = [
  {
    id: 1,
    userName: "Maria Lopez",
    userTrustLevel: "trusted",
    service: "Cuidado de adulto mayor",
    date: "Hoy",
    time: "14:00 - 18:00",
    location: "Calle 45 #23-12, Valledupar",
    price: "$80,000",
    distance: "2.3 km",
    status: "pending",
    createdAt: "Hace 15 min"
  },
  {
    id: 2,
    userName: "Carlos Rodriguez",
    userTrustLevel: "verified",
    service: "Control de signos vitales",
    date: "Manana",
    time: "09:00 - 10:00",
    location: "Carrera 15 #78-90",
    price: "$35,000",
    distance: "4.1 km",
    status: "pending",
    createdAt: "Hace 1 hora"
  },
  {
    id: 3,
    userName: "Ana Martinez",
    userTrustLevel: "basic",
    service: "Aplicacion de inyecciones",
    date: "24 Abr",
    time: "11:00 - 12:00",
    location: "Av. Principal #12-34",
    price: "$25,000",
    distance: "1.5 km",
    status: "pending",
    createdAt: "Hace 2 horas"
  },
  {
    id: 4,
    userName: "Pedro Sanchez",
    userTrustLevel: "trusted",
    service: "Terapia de rehabilitacion",
    date: "Hoy",
    time: "10:00 - 12:00",
    location: "Calle 20 #15-30",
    price: "$120,000",
    distance: "3.0 km",
    status: "confirmed",
    createdAt: "Ayer"
  },
  {
    id: 5,
    userName: "Laura Gomez",
    userTrustLevel: "verified",
    service: "Cuidado post-operatorio",
    date: "Hoy",
    time: "15:00 - 19:00",
    location: "Carrera 8 #45-67",
    price: "$160,000",
    distance: "2.8 km",
    status: "confirmed",
    createdAt: "Hace 2 dias"
  },
  {
    id: 6,
    userName: "Roberto Diaz",
    userTrustLevel: "trusted",
    service: "Control de signos vitales",
    date: "20 Abr",
    time: "08:00 - 09:00",
    location: "Calle 50 #10-20",
    price: "$35,000",
    distance: "5.0 km",
    status: "completed",
    createdAt: "Hace 3 dias"
  },
  {
    id: 7,
    userName: "Sofia Herrera",
    userTrustLevel: "verified",
    service: "Aplicacion de inyecciones",
    date: "19 Abr",
    time: "16:00 - 17:00",
    location: "Av. Central #88-99",
    price: "$25,000",
    distance: "1.2 km",
    status: "completed",
    createdAt: "Hace 4 dias"
  }
];

const trustLevelConfig = {
  basic: { label: "Basico", color: "text-gray-500 bg-gray-100" },
  verified: { label: "Verificado", color: "text-blue-600 bg-blue-100" },
  trusted: { label: "Confiable", color: "text-green-600 bg-green-100" }
};

const statusConfig = {
  pending: { label: "Pendiente", color: "text-amber-600 bg-amber-100" },
  confirmed: { label: "Confirmado", color: "text-violet-600 bg-violet-100" },
  completed: { label: "Completado", color: "text-green-600 bg-green-100" },
  cancelled: { label: "Cancelado", color: "text-red-600 bg-red-100" }
};

export function ProfessionalRequests() {
  const [activeTab, setActiveTab] = useState<TabType>("pending");
  const [searchQuery, setSearchQuery] = useState("");

  const filteredRequests = allRequests.filter(request => {
    const matchesTab = 
      (activeTab === "pending" && request.status === "pending") ||
      (activeTab === "confirmed" && request.status === "confirmed") ||
      (activeTab === "history" && (request.status === "completed" || request.status === "cancelled"));
    
    const matchesSearch = 
      request.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      request.service.toLowerCase().includes(searchQuery.toLowerCase());

    return matchesTab && matchesSearch;
  });

  const tabs = [
    { key: "pending" as TabType, label: "Pendientes", count: allRequests.filter(r => r.status === "pending").length },
    { key: "confirmed" as TabType, label: "Confirmadas", count: allRequests.filter(r => r.status === "confirmed").length },
    { key: "history" as TabType, label: "Historial", count: allRequests.filter(r => r.status === "completed" || r.status === "cancelled").length }
  ];

  return (
    <div className="p-4 space-y-4">
      {/* Header */}
      <div>
        <h1 className="text-xl font-semibold text-gray-900">Solicitudes</h1>
        <p className="text-sm text-gray-500">Gestiona tus solicitudes de servicio</p>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Buscar por nombre o servicio..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-3 bg-white rounded-xl border border-gray-200 focus:border-violet-500 focus:ring-1 focus:ring-violet-500 outline-none"
        />
      </div>

      {/* Tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2">
        {tabs.map(tab => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`flex items-center gap-2 px-4 py-2 rounded-full text-sm whitespace-nowrap transition-colors ${
              activeTab === tab.key
                ? "bg-violet-600 text-white"
                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            {tab.label}
            <span className={`px-1.5 py-0.5 rounded-full text-xs ${
              activeTab === tab.key ? "bg-white/20" : "bg-gray-200"
            }`}>
              {tab.count}
            </span>
          </button>
        ))}
      </div>

      {/* Requests List */}
      <div className="space-y-3">
        {filteredRequests.length === 0 ? (
          <div className="bg-white rounded-2xl p-8 text-center border border-gray-200">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Calendar className="w-8 h-8 text-gray-400" />
            </div>
            <p className="text-gray-500">No hay solicitudes en esta categoria</p>
          </div>
        ) : (
          filteredRequests.map((request) => (
            <Link
              key={request.id}
              to={`/professional/request/${request.id}`}
              className="block bg-white rounded-2xl p-4 border border-gray-200 hover:shadow-md transition-shadow"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                    <User className="w-6 h-6 text-gray-500" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="text-sm font-medium text-gray-900">{request.userName}</p>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${trustLevelConfig[request.userTrustLevel].color}`}>
                        {trustLevelConfig[request.userTrustLevel].label}
                      </span>
                    </div>
                    <p className="text-xs text-gray-600">{request.service}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`text-xs px-2 py-1 rounded-full ${statusConfig[request.status].color}`}>
                    {statusConfig[request.status].label}
                  </span>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </div>
              
              <div className="flex items-center gap-4 text-xs text-gray-600 mb-3">
                <span className="flex items-center gap-1">
                  <Calendar className="w-3.5 h-3.5" />
                  {request.date}
                </span>
                <span className="flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5" />
                  {request.time}
                </span>
                <span className="flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5" />
                  {request.distance}
                </span>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <span className="text-sm font-semibold text-violet-600">{request.price}</span>
                  <span className="text-xs text-gray-400 ml-2">{request.createdAt}</span>
                </div>
                {request.status === "pending" && (
                  <div className="flex gap-2">
                    <button 
                      onClick={(e) => { e.preventDefault(); e.stopPropagation(); }}
                      className="px-3 py-1.5 bg-red-50 text-red-600 text-xs rounded-full hover:bg-red-100 transition-colors flex items-center gap-1"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      Rechazar
                    </button>
                    <button 
                      onClick={(e) => { e.preventDefault(); e.stopPropagation(); }}
                      className="px-3 py-1.5 bg-violet-600 text-white text-xs rounded-full hover:bg-violet-700 transition-colors flex items-center gap-1"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Aceptar
                    </button>
                  </div>
                )}
              </div>
            </Link>
          ))
        )}
      </div>
    </div>
  );
}
