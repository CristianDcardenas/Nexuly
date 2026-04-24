import { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router";
import { MapPin, Phone, MessageSquare, Navigation, Clock, CheckCircle2, User } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana María García",
  specialty: "Enfermería General",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  phone: "+57 300 123 4567",
  rating: 4.9
};

const bookingData = {
  date: "24 Mar 2026",
  time: "10:00 AM",
  address: "Calle 15 #12-34, Valledupar",
  service: "Aplicación de inyecciones"
};

type ServiceStatus = "on-way" | "arrived" | "in-progress" | "completed";

const statusInfo = {
  "on-way": {
    title: "En camino",
    description: "El profesional está en camino a tu ubicación",
    icon: Navigation,
    color: "violet",
    estimatedTime: "15 minutos"
  },
  "arrived": {
    title: "Ha llegado",
    description: "El profesional llegó a tu domicilio",
    icon: MapPin,
    color: "blue",
    estimatedTime: "Ahora"
  },
  "in-progress": {
    title: "Servicio en progreso",
    description: "El profesional está realizando la atención",
    icon: User,
    color: "orange",
    estimatedTime: "30 minutos aprox."
  },
  "completed": {
    title: "Servicio completado",
    description: "La atención se completó exitosamente",
    icon: CheckCircle2,
    color: "green",
    estimatedTime: "Finalizado"
  }
};

export function ActiveService() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<ServiceStatus>("on-way");
  const [progress, setProgress] = useState(0);

  // Simular progresión del servicio
  useEffect(() => {
    const stages: ServiceStatus[] = ["on-way", "arrived", "in-progress", "completed"];
    const delays = [5000, 3000, 8000, 0]; // Tiempos en ms para cada etapa
    
    let currentStage = 0;
    let timeout: NodeJS.Timeout;

    const advanceStage = () => {
      if (currentStage < stages.length - 1) {
        currentStage++;
        setStatus(stages[currentStage]);
        setProgress((currentStage / (stages.length - 1)) * 100);
        
        if (currentStage < stages.length - 1) {
          timeout = setTimeout(advanceStage, delays[currentStage]);
        } else {
          // Al completar, esperar 2 segundos y redirigir a calificación
          setTimeout(() => {
            navigate(`/rating/${id}`);
          }, 2000);
        }
      }
    };

    // Iniciar la primera transición
    timeout = setTimeout(advanceStage, delays[0]);

    return () => clearTimeout(timeout);
  }, [id, navigate]);

  const currentStatus = statusInfo[status];
  const StatusIcon = currentStatus.icon;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Map Placeholder */}
      <div className="relative h-[40vh] bg-gradient-to-br from-violet-100 to-purple-100 border-b border-gray-200">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <div className={`w-24 h-24 rounded-full bg-white shadow-lg flex items-center justify-center mx-auto mb-4 ${
              status === "on-way" ? "animate-pulse" : ""
            }`}>
              <StatusIcon className={`w-12 h-12 text-${currentStatus.color}-600`} />
            </div>
            <div className="bg-white rounded-2xl px-6 py-3 shadow-lg">
              <p className="text-lg text-gray-900 mb-1">{currentStatus.title}</p>
              <p className="text-sm text-gray-600">{currentStatus.estimatedTime}</p>
            </div>
          </div>
        </div>

        {/* Progress Indicator */}
        <div className="absolute bottom-0 left-0 right-0 bg-white">
          <div className="h-1 bg-gray-200">
            <div 
              className="h-full bg-violet-600 transition-all duration-1000 ease-out"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Status Card */}
        <div className={`bg-gradient-to-br from-${currentStatus.color}-50 to-${currentStatus.color}-100 rounded-2xl p-4 border border-${currentStatus.color}-200`}>
          <div className="flex items-start gap-3">
            <StatusIcon className={`w-6 h-6 text-${currentStatus.color}-600 mt-0.5 flex-shrink-0`} />
            <div className="flex-1">
              <h2 className="text-base text-gray-900 mb-1">{currentStatus.title}</h2>
              <p className="text-sm text-gray-700">{currentStatus.description}</p>
            </div>
          </div>
        </div>

        {/* Professional Card */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-3 mb-4">
            <ImageWithFallback 
              src={professionalData.image}
              alt={professionalData.name}
              className="w-16 h-16 rounded-xl object-cover"
            />
            <div className="flex-1">
              <h3 className="text-base text-gray-900">{professionalData.name}</h3>
              <p className="text-sm text-gray-600">{professionalData.specialty}</p>
              <div className="flex items-center gap-1 mt-1">
                <span className="text-sm text-yellow-500">★</span>
                <span className="text-sm text-gray-700">{professionalData.rating}</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <a
              href={`tel:${professionalData.phone}`}
              className="flex items-center justify-center gap-2 py-2.5 rounded-xl bg-violet-600 text-white text-sm"
            >
              <Phone className="w-4 h-4" />
              Llamar
            </a>
            <button
              onClick={() => navigate(`/chat/${id}`)}
              className="flex items-center justify-center gap-2 py-2.5 rounded-xl border border-violet-600 text-violet-600 text-sm"
            >
              <MessageSquare className="w-4 h-4" />
              Chat
            </button>
          </div>
        </div>

        {/* Service Details */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h3 className="text-base mb-3 text-gray-900">Detalles del servicio</h3>
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <Clock className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-900">{bookingData.date}</p>
                <p className="text-xs text-gray-600">{bookingData.time}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <MapPin className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm text-gray-900">{bookingData.address}</p>
                <p className="text-xs text-gray-600">Servicio a domicilio</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <User className="w-5 h-5 text-gray-400" />
              <p className="text-sm text-gray-900">{bookingData.service}</p>
            </div>
          </div>
        </div>

        {/* Timeline */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h3 className="text-base mb-4 text-gray-900">Estado del servicio</h3>
          <div className="space-y-4">
            {(["on-way", "arrived", "in-progress", "completed"] as ServiceStatus[]).map((stage, index) => {
              const stageInfo = statusInfo[stage];
              const StageIcon = stageInfo.icon;
              const isCompleted = ["on-way", "arrived", "in-progress", "completed"].indexOf(status) >= index;
              const isCurrent = status === stage;

              return (
                <div key={stage} className="flex items-start gap-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 transition-all ${
                    isCompleted 
                      ? `bg-${stageInfo.color}-100` 
                      : "bg-gray-100"
                  }`}>
                    <StageIcon className={`w-5 h-5 ${
                      isCompleted 
                        ? `text-${stageInfo.color}-600` 
                        : "text-gray-400"
                    }`} />
                  </div>
                  <div className="flex-1 pt-1">
                    <p className={`text-sm ${
                      isCurrent ? "text-gray-900 font-medium" : isCompleted ? "text-gray-700" : "text-gray-500"
                    }`}>
                      {stageInfo.title}
                    </p>
                    {isCurrent && (
                      <p className="text-xs text-gray-600 mt-0.5">{stageInfo.description}</p>
                    )}
                  </div>
                  {isCompleted && (
                    <CheckCircle2 className={`w-5 h-5 text-${stageInfo.color}-600 flex-shrink-0`} />
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Safety Info */}
        <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl p-4 border border-blue-100">
          <h3 className="text-sm text-gray-900 mb-2">Tu seguridad es importante</h3>
          <p className="text-xs text-gray-600 leading-relaxed">
            Todos nuestros profesionales están verificados y certificados. Si tienes alguna emergencia durante el servicio, contacta inmediatamente al 123.
          </p>
        </div>

        {/* Action Button */}
        {status === "completed" && (
          <button
            onClick={() => navigate(`/rating/${id}`)}
            className="w-full py-3 rounded-xl bg-violet-600 text-white"
          >
            Calificar servicio
          </button>
        )}
      </div>
    </div>
  );
}
