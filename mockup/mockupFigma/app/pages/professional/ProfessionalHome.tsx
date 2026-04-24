import { Link } from "react-router";
import { 
  Calendar, 
  Clock, 
  DollarSign, 
  TrendingUp, 
  Star, 
  MapPin, 
  User,
  ChevronRight,
  CheckCircle2,
  XCircle,
  Bell,
  Activity
} from "lucide-react";

const stats = {
  todayEarnings: "$180,000",
  weekEarnings: "$850,000",
  monthEarnings: "$3,200,000",
  completedServices: 12,
  pendingRequests: 3,
  rating: 4.9,
  totalReviews: 156
};

const pendingRequests = [
  {
    id: 1,
    userName: "Maria Lopez",
    userTrustLevel: "trusted" as const,
    service: "Cuidado de adulto mayor",
    date: "Hoy",
    time: "14:00 - 18:00",
    location: "Calle 45 #23-12",
    price: "$80,000",
    distance: "2.3 km"
  },
  {
    id: 2,
    userName: "Carlos Rodriguez",
    userTrustLevel: "verified" as const,
    service: "Control de signos vitales",
    date: "Manana",
    time: "09:00 - 10:00",
    location: "Carrera 15 #78-90",
    price: "$35,000",
    distance: "4.1 km"
  },
  {
    id: 3,
    userName: "Ana Martinez",
    userTrustLevel: "basic" as const,
    service: "Aplicacion de inyecciones",
    date: "24 Abr",
    time: "11:00 - 12:00",
    location: "Av. Principal #12-34",
    price: "$25,000",
    distance: "1.5 km"
  }
];

const upcomingServices = [
  {
    id: 4,
    userName: "Pedro Sanchez",
    service: "Terapia de rehabilitacion",
    date: "Hoy",
    time: "10:00 - 12:00",
    status: "confirmed" as const
  },
  {
    id: 5,
    userName: "Laura Gomez",
    service: "Cuidado post-operatorio",
    date: "Hoy",
    time: "15:00 - 19:00",
    status: "confirmed" as const
  }
];

const trustLevelConfig = {
  basic: { label: "Basico", color: "text-gray-500 bg-gray-100" },
  verified: { label: "Verificado", color: "text-blue-600 bg-blue-100" },
  trusted: { label: "Confiable", color: "text-green-600 bg-green-100" }
};

export function ProfessionalHome() {
  return (
    <div className="p-4 space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-br from-violet-500 to-purple-500 rounded-2xl p-6 text-white">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-xl font-semibold">Hola, Dra. Ana</h1>
            <p className="text-violet-100 text-sm">Tienes {stats.pendingRequests} solicitudes pendientes</p>
          </div>
          <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
            <Activity className="w-6 h-6" />
          </div>
        </div>

        {/* Toggle Availability */}
        <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-green-400 animate-pulse"></div>
            <span className="text-sm">Disponible para recibir solicitudes</span>
          </div>
          <button className="text-xs bg-white/20 px-3 py-1 rounded-full hover:bg-white/30 transition-colors">
            Cambiar
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
              <DollarSign className="w-4 h-4 text-green-600" />
            </div>
            <span className="text-xs text-gray-500">Hoy</span>
          </div>
          <p className="text-lg font-bold text-gray-900">{stats.todayEarnings}</p>
          <p className="text-xs text-green-600 flex items-center gap-1">
            <TrendingUp className="w-3 h-3" />
            +15% vs ayer
          </p>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-8 h-8 bg-violet-100 rounded-lg flex items-center justify-center">
              <Calendar className="w-4 h-4 text-violet-600" />
            </div>
            <span className="text-xs text-gray-500">Este mes</span>
          </div>
          <p className="text-lg font-bold text-gray-900">{stats.completedServices}</p>
          <p className="text-xs text-gray-500">servicios completados</p>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-8 h-8 bg-amber-100 rounded-lg flex items-center justify-center">
              <Star className="w-4 h-4 text-amber-600" />
            </div>
            <span className="text-xs text-gray-500">Calificacion</span>
          </div>
          <p className="text-lg font-bold text-gray-900">{stats.rating}</p>
          <p className="text-xs text-gray-500">{stats.totalReviews} resenas</p>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-8 h-8 bg-violet-100 rounded-lg flex items-center justify-center">
              <DollarSign className="w-4 h-4 text-violet-600" />
            </div>
            <span className="text-xs text-gray-500">Mes</span>
          </div>
          <p className="text-lg font-bold text-gray-900">{stats.monthEarnings}</p>
          <p className="text-xs text-green-600 flex items-center gap-1">
            <TrendingUp className="w-3 h-3" />
            +8% vs anterior
          </p>
        </div>
      </div>

      {/* Upcoming Services Today */}
      {upcomingServices.length > 0 && (
        <div>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-semibold text-gray-900">Servicios de hoy</h2>
            <span className="text-xs text-gray-500">{upcomingServices.length} confirmados</span>
          </div>
          <div className="space-y-3">
            {upcomingServices.map((service) => (
              <Link
                key={service.id}
                to={`/professional/active-service/${service.id}`}
                className="block bg-gradient-to-r from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-200 hover:shadow-md transition-shadow"
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                      <User className="w-5 h-5 text-violet-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">{service.userName}</p>
                      <p className="text-xs text-gray-600">{service.service}</p>
                    </div>
                  </div>
                  <span className="px-2 py-1 bg-violet-100 text-violet-700 text-xs rounded-full">
                    {service.status === "confirmed" ? "Confirmado" : service.status}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-xs text-gray-600">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-3.5 h-3.5" />
                    {service.date}
                  </span>
                  <span className="flex items-center gap-1">
                    <Clock className="w-3.5 h-3.5" />
                    {service.time}
                  </span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Pending Requests */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-semibold text-gray-900">Solicitudes pendientes</h2>
          <Link to="/professional/requests" className="text-sm text-violet-600">Ver todas</Link>
        </div>
        <div className="space-y-3">
          {pendingRequests.map((request) => (
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
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium text-gray-900">{request.userName}</p>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${trustLevelConfig[request.userTrustLevel].color}`}>
                        {trustLevelConfig[request.userTrustLevel].label}
                      </span>
                    </div>
                    <p className="text-xs text-gray-600">{request.service}</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
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
                <span className="text-sm font-semibold text-violet-600">{request.price}</span>
                <div className="flex gap-2">
                  <button 
                    onClick={(e) => { e.preventDefault(); e.stopPropagation(); }}
                    className="px-4 py-1.5 bg-red-50 text-red-600 text-xs rounded-full hover:bg-red-100 transition-colors flex items-center gap-1"
                  >
                    <XCircle className="w-3.5 h-3.5" />
                    Rechazar
                  </button>
                  <button 
                    onClick={(e) => { e.preventDefault(); e.stopPropagation(); }}
                    className="px-4 py-1.5 bg-violet-600 text-white text-xs rounded-full hover:bg-violet-700 transition-colors flex items-center gap-1"
                  >
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    Aceptar
                  </button>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Link 
          to="/professional/availability" 
          className="bg-white border border-gray-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 hover:shadow-md transition-shadow"
        >
          <Clock className="w-8 h-8 text-violet-600" />
          <span className="text-sm text-gray-700">Mis horarios</span>
        </Link>
        <Link 
          to="/professional/services" 
          className="bg-white border border-gray-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 hover:shadow-md transition-shadow"
        >
          <Bell className="w-8 h-8 text-violet-600" />
          <span className="text-sm text-gray-700">Mis servicios</span>
        </Link>
      </div>
    </div>
  );
}
