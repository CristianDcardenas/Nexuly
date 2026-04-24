import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { 
  ArrowLeft, 
  Calendar, 
  Clock, 
  MapPin, 
  User,
  Phone,
  MessageSquare,
  Shield,
  ShieldCheck,
  Award,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Navigation,
  Star,
  FileText
} from "lucide-react";

export function ProfessionalRequestDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState("");
  const [isAccepting, setIsAccepting] = useState(false);

  // Mock data
  const request = {
    id: 1,
    status: "pending" as const,
    service: {
      name: "Cuidado de adulto mayor",
      description: "Asistencia y cuidado integral para adulto mayor con movilidad reducida",
      duration: "4 horas",
      price: "$80,000"
    },
    schedule: {
      date: "23 de Abril, 2026",
      time: "14:00 - 18:00",
      isFlexible: true
    },
    location: {
      address: "Calle 45 #23-12, Barrio Centro",
      city: "Valledupar, Cesar",
      distance: "2.3 km",
      estimatedTime: "8 min en vehiculo"
    },
    user: {
      name: "Maria Fernanda Lopez",
      phone: "+57 300 123 4567",
      verificationLevel: "trusted" as const,
      memberSince: "Enero 2025",
      totalServices: 12,
      rating: 4.8,
      behaviorScore: "excellent" as const,
      notes: "Puntual y respetuosa en servicios anteriores"
    },
    additionalInfo: "Mi madre tiene 78 anos y necesita ayuda con su medicacion y ejercicios de rehabilitacion. Tiene diabetes controlada.",
    createdAt: "Hace 15 minutos"
  };

  const verificationConfig = {
    basic: { icon: Shield, label: "Basico", color: "text-gray-500", bgColor: "bg-gray-100" },
    verified: { icon: ShieldCheck, label: "Verificado", color: "text-blue-600", bgColor: "bg-blue-100" },
    trusted: { icon: Award, label: "Confiable", color: "text-green-600", bgColor: "bg-green-100" }
  };

  const behaviorConfig = {
    excellent: { label: "Excelente historial", color: "text-green-600 bg-green-50 border-green-200" },
    good: { label: "Buen historial", color: "text-blue-600 bg-blue-50 border-blue-200" },
    standard: { label: "Historial estandar", color: "text-gray-600 bg-gray-50 border-gray-200" },
    caution: { label: "Con incidencias", color: "text-amber-600 bg-amber-50 border-amber-200" }
  };

  const userVerification = verificationConfig[request.user.verificationLevel];
  const UserVerificationIcon = userVerification.icon;
  const userBehavior = behaviorConfig[request.user.behaviorScore];

  const handleAccept = () => {
    setIsAccepting(true);
    // Simular aceptacion
    setTimeout(() => {
      navigate("/professional/requests");
    }, 1500);
  };

  const handleReject = () => {
    // Simular rechazo
    setShowRejectModal(false);
    navigate("/professional/requests");
  };

  if (isAccepting) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl p-8 text-center max-w-sm w-full shadow-lg">
          <div className="w-20 h-20 bg-teal-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle2 className="w-10 h-10 text-teal-600" />
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Solicitud aceptada</h2>
          <p className="text-gray-500 mb-4">
            Has aceptado el servicio. El usuario sera notificado y podras ver los detalles en tu agenda.
          </p>
          <div className="bg-teal-50 rounded-xl p-4">
            <p className="text-sm text-teal-700">
              Recuerda llegar puntual y confirmar tu llegada en la app.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <div className="bg-gradient-to-r from-teal-600 to-emerald-600 text-white p-4 pb-20">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-semibold">Detalle de solicitud</h1>
            <p className="text-teal-100 text-sm">{request.createdAt}</p>
          </div>
        </div>
      </div>

      <div className="-mt-16 px-4 space-y-4">
        {/* Service Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h2 className="text-lg font-semibold text-gray-900">{request.service.name}</h2>
              <p className="text-sm text-gray-500">{request.service.description}</p>
            </div>
            <span className="px-3 py-1 bg-amber-100 text-amber-700 text-xs rounded-full">
              Pendiente
            </span>
          </div>

          <div className="grid grid-cols-2 gap-4 p-3 bg-gray-50 rounded-xl">
            <div>
              <p className="text-xs text-gray-500">Duracion</p>
              <p className="text-sm font-medium text-gray-900">{request.service.duration}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Tarifa</p>
              <p className="text-lg font-bold text-teal-600">{request.service.price}</p>
            </div>
          </div>
        </div>

        {/* Schedule Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Fecha y hora</h3>
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-teal-100 rounded-lg flex items-center justify-center">
                <Calendar className="w-5 h-5 text-teal-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-gray-900">{request.schedule.date}</p>
                <p className="text-xs text-gray-500">Fecha solicitada</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-teal-100 rounded-lg flex items-center justify-center">
                <Clock className="w-5 h-5 text-teal-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-gray-900">{request.schedule.time}</p>
                <p className="text-xs text-gray-500">
                  {request.schedule.isFlexible ? "Horario flexible" : "Horario fijo"}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Location Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Ubicacion</h3>
          <div className="flex items-start gap-3 mb-4">
            <div className="w-10 h-10 bg-teal-100 rounded-lg flex items-center justify-center flex-shrink-0">
              <MapPin className="w-5 h-5 text-teal-600" />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-900">{request.location.address}</p>
              <p className="text-xs text-gray-500">{request.location.city}</p>
              <div className="flex items-center gap-3 mt-2 text-xs text-gray-600">
                <span>{request.location.distance}</span>
                <span>|</span>
                <span>{request.location.estimatedTime}</span>
              </div>
            </div>
          </div>
          <button className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl border border-teal-600 text-teal-600 text-sm hover:bg-teal-50 transition-colors">
            <Navigation className="w-4 h-4" />
            Ver en mapa
          </button>
        </div>

        {/* User Info Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Informacion del usuario</h3>
          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 bg-gray-100 rounded-full flex items-center justify-center">
              <User className="w-7 h-7 text-gray-500" />
            </div>
            <div className="flex-1">
              <p className="font-medium text-gray-900">{request.user.name}</p>
              <div className="flex items-center gap-2 mt-1">
                <UserVerificationIcon className={`w-4 h-4 ${userVerification.color}`} />
                <span className={`text-xs ${userVerification.color}`}>{userVerification.label}</span>
                <span className="text-xs text-gray-400">|</span>
                <span className="text-xs text-gray-500">Desde {request.user.memberSince}</span>
              </div>
            </div>
          </div>

          {/* User Stats */}
          <div className="grid grid-cols-3 gap-3 mb-4">
            <div className="bg-gray-50 rounded-xl p-3 text-center">
              <p className="text-lg font-bold text-gray-900">{request.user.totalServices}</p>
              <p className="text-xs text-gray-500">Servicios</p>
            </div>
            <div className="bg-gray-50 rounded-xl p-3 text-center">
              <div className="flex items-center justify-center gap-1">
                <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
                <p className="text-lg font-bold text-gray-900">{request.user.rating}</p>
              </div>
              <p className="text-xs text-gray-500">Calificacion</p>
            </div>
            <div className={`rounded-xl p-3 text-center border ${userBehavior.color}`}>
              <p className="text-xs font-medium">{userBehavior.label}</p>
            </div>
          </div>

          {/* Behavior Note */}
          {request.user.notes && (
            <div className="bg-green-50 border border-green-200 rounded-xl p-3 mb-4">
              <p className="text-xs text-green-700">
                <span className="font-medium">Nota del sistema:</span> {request.user.notes}
              </p>
            </div>
          )}

          {/* Contact Buttons */}
          <div className="grid grid-cols-2 gap-3">
            <a
              href={`tel:${request.user.phone}`}
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
        </div>

        {/* Additional Info */}
        {request.additionalInfo && (
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-2">
              <FileText className="w-5 h-5 text-gray-500" />
              <h3 className="font-semibold text-gray-900">Notas del usuario</h3>
            </div>
            <p className="text-sm text-gray-600 leading-relaxed">{request.additionalInfo}</p>
          </div>
        )}

        {/* Warning */}
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3">
          <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm text-amber-800 font-medium">Recuerda</p>
            <p className="text-xs text-amber-700 mt-1">
              Al aceptar esta solicitud, te comprometes a prestar el servicio en la fecha y hora indicadas. 
              Las cancelaciones tardias pueden afectar tu calificacion.
            </p>
          </div>
        </div>
      </div>

      {/* Fixed Bottom Actions */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 p-4">
        <div className="max-w-md mx-auto flex gap-3">
          <button
            onClick={() => setShowRejectModal(true)}
            className="flex-1 py-3 rounded-xl border-2 border-red-500 text-red-600 font-medium hover:bg-red-50 transition-colors flex items-center justify-center gap-2"
          >
            <XCircle className="w-5 h-5" />
            Rechazar
          </button>
          <button
            onClick={handleAccept}
            className="flex-1 py-3 rounded-xl bg-teal-600 text-white font-medium hover:bg-teal-700 transition-colors flex items-center justify-center gap-2"
          >
            <CheckCircle2 className="w-5 h-5" />
            Aceptar
          </button>
        </div>
      </div>

      {/* Reject Modal */}
      {showRejectModal && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Rechazar solicitud</h3>
            <p className="text-sm text-gray-500 mb-4">
              Por favor indica el motivo del rechazo (opcional)
            </p>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Ej: No tengo disponibilidad en ese horario..."
              rows={3}
              className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none resize-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => setShowRejectModal(false)}
                className="flex-1 py-3 rounded-xl border border-gray-300 text-gray-700 font-medium"
              >
                Cancelar
              </button>
              <button
                onClick={handleReject}
                className="flex-1 py-3 rounded-xl bg-red-600 text-white font-medium"
              >
                Confirmar rechazo
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
