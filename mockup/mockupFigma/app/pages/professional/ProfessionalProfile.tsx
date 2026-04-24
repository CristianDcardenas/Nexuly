import { Link, useNavigate } from "react-router";
import { 
  User, 
  Star, 
  MapPin, 
  Calendar,
  ChevronRight,
  Settings,
  Bell,
  Shield,
  HelpCircle,
  FileText,
  LogOut,
  Camera,
  Award,
  TrendingUp,
  DollarSign,
  Edit2
} from "lucide-react";

export function ProfessionalProfile() {
  const navigate = useNavigate();

  // Mock data
  const professional = {
    name: "Dra. Ana Maria Garcia",
    specialty: "Enfermeria General",
    email: "ana.garcia@email.com",
    phone: "+57 300 123 4567",
    memberSince: "Marzo 2025",
    rating: 4.9,
    totalReviews: 156,
    completedServices: 243,
    totalEarnings: "$12,450,000",
    verificationStatus: "approved" as const,
    coverageRadius: "10 km",
    bio: "Enfermera profesional con 8 anos de experiencia en cuidado domiciliario y atencion de adultos mayores."
  };

  const stats = [
    { label: "Servicios", value: professional.completedServices, icon: Calendar },
    { label: "Calificacion", value: professional.rating, icon: Star },
    { label: "Resenas", value: professional.totalReviews, icon: Award }
  ];

  const menuSections = [
    {
      title: "Mi perfil",
      items: [
        { icon: Edit2, label: "Editar perfil", description: "Actualiza tu informacion", path: "/professional/edit-profile" },
        { icon: MapPin, label: "Area de cobertura", description: professional.coverageRadius, path: "/professional/coverage" },
        { icon: FileText, label: "Mis documentos", description: "Ver documentos verificados", path: "/professional/documents" },
      ]
    },
    {
      title: "Configuracion",
      items: [
        { icon: Bell, label: "Notificaciones", description: "Configurar alertas", path: "/professional/notifications-settings" },
        { icon: Shield, label: "Seguridad", description: "Contrasena y acceso", path: "/professional/security" },
        { icon: Settings, label: "Preferencias", description: "Idioma, tema y mas", path: "/professional/preferences" },
      ]
    },
    {
      title: "Finanzas",
      items: [
        { icon: DollarSign, label: "Mis ganancias", description: "Historial de pagos", path: "/professional/earnings" },
        { icon: TrendingUp, label: "Estadisticas", description: "Metricas de rendimiento", path: "/professional/stats" },
      ]
    },
    {
      title: "Soporte",
      items: [
        { icon: HelpCircle, label: "Centro de ayuda", description: "Preguntas frecuentes", path: "/help" },
        { icon: FileText, label: "Terminos y condiciones", description: "Acuerdos legales", path: "/terms" },
      ]
    }
  ];

  return (
    <div className="pb-24">
      {/* Header */}
      <div className="bg-gradient-to-br from-teal-500 to-emerald-600 p-6 pb-20">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-xl font-semibold text-white">Mi perfil</h1>
          <button className="p-2 bg-white/10 rounded-full">
            <Settings className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Profile Card */}
        <div className="flex items-center gap-4">
          <div className="relative">
            <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center">
              <User className="w-10 h-10 text-white" />
            </div>
            <button className="absolute bottom-0 right-0 w-7 h-7 bg-white rounded-full flex items-center justify-center shadow-lg">
              <Camera className="w-4 h-4 text-teal-600" />
            </button>
          </div>
          <div className="text-white">
            <h2 className="text-lg font-semibold">{professional.name}</h2>
            <p className="text-teal-100 text-sm">{professional.specialty}</p>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-xs px-2 py-0.5 bg-white/20 rounded-full">
                Verificado
              </span>
              <span className="text-xs text-teal-100">
                Desde {professional.memberSince}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Stats Card */}
      <div className="px-4 -mt-12">
        <div className="bg-white rounded-2xl p-4 shadow-lg grid grid-cols-3 gap-4">
          {stats.map((stat, index) => (
            <div key={index} className="text-center">
              <div className="flex items-center justify-center gap-1 mb-1">
                {stat.label === "Calificacion" && (
                  <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
                )}
                <span className="text-xl font-bold text-gray-900">{stat.value}</span>
              </div>
              <p className="text-xs text-gray-500">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Earnings Summary */}
      <div className="px-4 mt-4">
        <div className="bg-gradient-to-r from-emerald-50 to-teal-50 rounded-2xl p-4 border border-teal-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-teal-700">Ganancias totales</p>
              <p className="text-2xl font-bold text-teal-800">{professional.totalEarnings}</p>
            </div>
            <Link 
              to="/professional/earnings" 
              className="px-4 py-2 bg-teal-600 text-white rounded-xl text-sm hover:bg-teal-700 transition-colors"
            >
              Ver detalle
            </Link>
          </div>
        </div>
      </div>

      {/* Bio */}
      <div className="px-4 mt-4">
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-semibold text-gray-900">Acerca de mi</h3>
            <button className="text-sm text-teal-600">Editar</button>
          </div>
          <p className="text-sm text-gray-600 leading-relaxed">{professional.bio}</p>
        </div>
      </div>

      {/* Menu Sections */}
      <div className="px-4 mt-4 space-y-4">
        {menuSections.map((section, sectionIndex) => (
          <div key={sectionIndex}>
            <h3 className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-2 px-1">
              {section.title}
            </h3>
            <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden">
              {section.items.map((item, itemIndex) => (
                <Link
                  key={itemIndex}
                  to={item.path}
                  className={`flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors ${
                    itemIndex !== section.items.length - 1 ? "border-b border-gray-100" : ""
                  }`}
                >
                  <div className="w-10 h-10 bg-teal-100 rounded-xl flex items-center justify-center">
                    <item.icon className="w-5 h-5 text-teal-600" />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900">{item.label}</p>
                    <p className="text-xs text-gray-500">{item.description}</p>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </Link>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Logout */}
      <div className="px-4 mt-6">
        <button 
          onClick={() => navigate("/login")}
          className="w-full flex items-center justify-center gap-2 py-3 border border-red-200 text-red-600 rounded-xl hover:bg-red-50 transition-colors"
        >
          <LogOut className="w-5 h-5" />
          Cerrar sesion
        </button>
      </div>

      {/* Version */}
      <p className="text-center text-xs text-gray-400 mt-4">
        Nexuly Pro v1.0.0
      </p>
    </div>
  );
}
