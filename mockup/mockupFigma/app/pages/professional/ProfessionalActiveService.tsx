import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { 
  ArrowLeft,
  MapPin, 
  Phone, 
  MessageSquare, 
  Navigation, 
  Clock, 
  CheckCircle2, 
  User,
  Play,
  Square,
  AlertCircle,
  FileText
} from "lucide-react";

type ServiceStatus = "confirmed" | "on-way" | "arrived" | "in-progress" | "completed";

const statusConfig = {
  confirmed: {
    title: "Servicio confirmado",
    description: "Inicia cuando estes listo para partir",
    color: "teal",
    action: "Iniciar viaje"
  },
  "on-way": {
    title: "En camino",
    description: "El usuario ha sido notificado de tu llegada",
    color: "blue",
    action: "He llegado"
  },
  arrived: {
    title: "Has llegado",
    description: "Confirma con el usuario para iniciar el servicio",
    color: "violet",
    action: "Iniciar servicio"
  },
  "in-progress": {
    title: "Servicio en progreso",
    description: "Registra cuando termines la atencion",
    color: "orange",
    action: "Finalizar servicio"
  },
  completed: {
    title: "Servicio completado",
    description: "Excelente trabajo!",
    color: "green",
    action: "Evaluar usuario"
  }
};

export function ProfessionalActiveService() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [status, setStatus] = useState<ServiceStatus>("confirmed");
  const [notes, setNotes] = useState("");
  const [showNotesModal, setShowNotesModal] = useState(false);

  // Mock data
  const serviceData = {
    service: "Cuidado de adulto mayor",
    date: "23 Abril 2026",
    time: "14:00 - 18:00",
    duration: "4 horas",
    price: "$80,000"
  };

  const userData = {
    name: "Maria Fernanda Lopez",
    phone: "+57 300 123 4567",
    address: "Calle 45 #23-12, Barrio Centro",
    city: "Valledupar, Cesar",
    notes: "Mi madre tiene 78 anos y necesita ayuda con su medicacion y ejercicios de rehabilitacion."
  };

  const handleStatusChange = () => {
    const transitions: Record<ServiceStatus, ServiceStatus | null> = {
      confirmed: "on-way",
      "on-way": "arrived",
      arrived: "in-progress",
      "in-progress": "completed",
      completed: null
    };

    const nextStatus = transitions[status];
    if (nextStatus) {
      setStatus(nextStatus);
    } else {
      // Go to rate user
      navigate(`/professional/rate-user/${id}`);
    }
  };

  const currentConfig = statusConfig[status];
  const progress = {
    confirmed: 0,
    "on-way": 25,
    arrived: 50,
    "in-progress": 75,
    completed: 100
  }[status];

  return (
    <div className="min-h-screen bg-gray-50 pb-32">
      {/* Header */}
      <div className="bg-gradient-to-r from-teal-600 to-emerald-600 text-white p-4 pb-20">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-semibold">Servicio activo</h1>
            <p className="text-teal-100 text-sm">{serviceData.service}</p>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="bg-white/20 rounded-full h-2 mb-2">
          <div 
            className="bg-white rounded-full h-full transition-all duration-500"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="flex justify-between text-xs text-teal-100">
          <span>Inicio</span>
          <span>Completado</span>
        </div>
      </div>

      <div className="-mt-12 px-4 space-y-4">
        {/* Status Card */}
        <div className={`bg-white rounded-2xl p-4 shadow-sm border-2 border-${currentConfig.color}-200`}>
          <div className="flex items-center gap-3 mb-3">
            <div className={`w-12 h-12 bg-${currentConfig.color}-100 rounded-full flex items-center justify-center`}>
              {status === "completed" ? (
                <CheckCircle2 className={`w-6 h-6 text-${currentConfig.color}-600`} />
              ) : status === "in-progress" ? (
                <Play className={`w-6 h-6 text-${currentConfig.color}-600`} />
              ) : (
                <Navigation className={`w-6 h-6 text-${currentConfig.color}-600`} />
              )}
            </div>
            <div>
              <h2 className="font-semibold text-gray-900">{currentConfig.title}</h2>
              <p className="text-sm text-gray-500">{currentConfig.description}</p>
            </div>
          </div>

          {/* Timeline */}
          <div className="flex items-center gap-2 mb-4">
            {(["confirmed", "on-way", "arrived", "in-progress", "completed"] as ServiceStatus[]).map((s, index) => (
              <div 
                key={s}
                className={`flex-1 h-1.5 rounded-full ${
                  (["confirmed", "on-way", "arrived", "in-progress", "completed"].indexOf(status) >= index)
                    ? "bg-teal-600"
                    : "bg-gray-200"
                }`}
              />
            ))}
          </div>

          {status !== "completed" && (
            <button
              onClick={handleStatusChange}
              className={`w-full py-3 rounded-xl font-medium transition-colors flex items-center justify-center gap-2 ${
                status === "in-progress"
                  ? "bg-orange-600 hover:bg-orange-700 text-white"
                  : "bg-teal-600 hover:bg-teal-700 text-white"
              }`}
            >
              {status === "in-progress" ? (
                <Square className="w-5 h-5" />
              ) : (
                <Play className="w-5 h-5" />
              )}
              {currentConfig.action}
            </button>
          )}
        </div>

        {/* Service Details */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Detalles del servicio</h3>
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-gray-50 rounded-xl p-3">
              <p className="text-xs text-gray-500">Fecha</p>
              <p className="text-sm font-medium text-gray-900">{serviceData.date}</p>
            </div>
            <div className="bg-gray-50 rounded-xl p-3">
              <p className="text-xs text-gray-500">Horario</p>
              <p className="text-sm font-medium text-gray-900">{serviceData.time}</p>
            </div>
            <div className="bg-gray-50 rounded-xl p-3">
              <p className="text-xs text-gray-500">Duracion</p>
              <p className="text-sm font-medium text-gray-900">{serviceData.duration}</p>
            </div>
            <div className="bg-gray-50 rounded-xl p-3">
              <p className="text-xs text-gray-500">Tarifa</p>
              <p className="text-sm font-bold text-teal-600">{serviceData.price}</p>
            </div>
          </div>
        </div>

        {/* User Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Usuario</h3>
          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 bg-gray-100 rounded-full flex items-center justify-center">
              <User className="w-7 h-7 text-gray-500" />
            </div>
            <div className="flex-1">
              <p className="font-medium text-gray-900">{userData.name}</p>
              <p className="text-sm text-gray-500">{userData.phone}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 mb-4">
            <a
              href={`tel:${userData.phone}`}
              className="flex items-center justify-center gap-2 py-2.5 rounded-xl bg-teal-600 text-white text-sm"
            >
              <Phone className="w-4 h-4" />
              Llamar
            </a>
            <button className="flex items-center justify-center gap-2 py-2.5 rounded-xl border border-teal-600 text-teal-600 text-sm">
              <MessageSquare className="w-4 h-4" />
              Mensaje
            </button>
          </div>

          {/* Location */}
          <div className="bg-gray-50 rounded-xl p-3 mb-3">
            <div className="flex items-start gap-3">
              <MapPin className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-gray-900">{userData.address}</p>
                <p className="text-xs text-gray-500">{userData.city}</p>
              </div>
            </div>
          </div>

          <button className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl border border-gray-300 text-gray-700 text-sm hover:bg-gray-50 transition-colors">
            <Navigation className="w-4 h-4" />
            Abrir en Google Maps
          </button>
        </div>

        {/* User Notes */}
        {userData.notes && (
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-2">
              <FileText className="w-5 h-5 text-gray-500" />
              <h3 className="font-semibold text-gray-900">Notas del usuario</h3>
            </div>
            <p className="text-sm text-gray-600 leading-relaxed">{userData.notes}</p>
          </div>
        )}

        {/* Service Notes */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <h3 className="font-semibold text-gray-900">Notas del servicio</h3>
            <button 
              onClick={() => setShowNotesModal(true)}
              className="text-sm text-teal-600"
            >
              {notes ? "Editar" : "Agregar"}
            </button>
          </div>
          {notes ? (
            <p className="text-sm text-gray-600">{notes}</p>
          ) : (
            <p className="text-sm text-gray-400 italic">
              Registra observaciones importantes del servicio...
            </p>
          )}
        </div>

        {/* Warning */}
        {status === "in-progress" && (
          <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3">
            <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm text-amber-800 font-medium">Servicio en curso</p>
              <p className="text-xs text-amber-700 mt-1">
                Recuerda registrar cualquier observacion importante antes de finalizar el servicio.
              </p>
            </div>
          </div>
        )}

        {/* Completed Actions */}
        {status === "completed" && (
          <div className="space-y-3">
            <div className="bg-green-50 border border-green-200 rounded-xl p-4 flex gap-3">
              <CheckCircle2 className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm text-green-800 font-medium">Servicio completado</p>
                <p className="text-xs text-green-700 mt-1">
                  Excelente trabajo! No olvides evaluar al usuario.
                </p>
              </div>
            </div>

            <button
              onClick={() => navigate(`/professional/rate-user/${id}`)}
              className="w-full py-3 bg-teal-600 text-white rounded-xl font-medium hover:bg-teal-700 transition-colors"
            >
              Evaluar usuario
            </button>

            <button
              onClick={() => navigate("/professional")}
              className="w-full py-3 border border-gray-300 text-gray-700 rounded-xl font-medium hover:bg-gray-50 transition-colors"
            >
              Volver al inicio
            </button>
          </div>
        )}
      </div>

      {/* Notes Modal */}
      {showNotesModal && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Notas del servicio</h3>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Registra observaciones, procedimientos realizados, recomendaciones..."
              rows={5}
              className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none resize-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => setShowNotesModal(false)}
                className="flex-1 py-3 border border-gray-300 text-gray-700 rounded-xl font-medium"
              >
                Cancelar
              </button>
              <button
                onClick={() => setShowNotesModal(false)}
                className="flex-1 py-3 bg-teal-600 text-white rounded-xl font-medium"
              >
                Guardar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
