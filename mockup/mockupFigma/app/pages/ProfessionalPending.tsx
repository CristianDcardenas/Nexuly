import { useState } from "react";
import { useNavigate } from "react-router";
import { Clock, FileText, CheckCircle2, XCircle, MessageSquare, Bell, HelpCircle } from "lucide-react";

type VerificationStatus = "pending" | "in_review" | "approved" | "rejected";

export function ProfessionalPending() {
  const navigate = useNavigate();
  
  // Mock status - in real app this would come from the backend
  // For demo: click status card to cycle through states
  const [status, setStatus] = useState<VerificationStatus>("approved");
  const submittedDate = "20 Abril 2026";
  const estimatedReview = "22 Abril 2026";

  const documents = [
    { name: "Documento de identidad", status: "verified" as const },
    { name: "Titulo profesional", status: "pending" as const },
    { name: "Tarjeta profesional", status: "pending" as const },
    { name: "Certificado de antecedentes", status: "verified" as const },
  ];

  const getStatusConfig = (status: VerificationStatus) => {
    switch (status) {
      case "pending":
        return {
          icon: Clock,
          color: "text-amber-600",
          bgColor: "bg-amber-100",
          borderColor: "border-amber-200",
          title: "Solicitud Pendiente",
          description: "Tu solicitud ha sido recibida y esta en cola para revision.",
          badgeColor: "bg-amber-100 text-amber-700"
        };
      case "in_review":
        return {
          icon: FileText,
          color: "text-blue-600",
          bgColor: "bg-blue-100",
          borderColor: "border-blue-200",
          title: "En Revision",
          description: "Nuestro equipo esta revisando tu documentacion.",
          badgeColor: "bg-blue-100 text-blue-700"
        };
      case "approved":
        return {
          icon: CheckCircle2,
          color: "text-green-600",
          bgColor: "bg-green-100",
          borderColor: "border-green-200",
          title: "Cuenta Aprobada",
          description: "Felicidades! Tu cuenta ha sido verificada exitosamente.",
          badgeColor: "bg-green-100 text-green-700"
        };
      case "rejected":
        return {
          icon: XCircle,
          color: "text-red-600",
          bgColor: "bg-red-100",
          borderColor: "border-red-200",
          title: "Solicitud Rechazada",
          description: "Tu solicitud no fue aprobada. Por favor revisa los detalles.",
          badgeColor: "bg-red-100 text-red-700"
        };
    }
  };

  const config = getStatusConfig(status);
  const StatusIcon = config.icon;

  // Demo function to cycle through statuses
  const cycleStatus = () => {
    const statuses: VerificationStatus[] = ["pending", "in_review", "approved", "rejected"];
    const currentIndex = statuses.indexOf(status);
    const nextIndex = (currentIndex + 1) % statuses.length;
    setStatus(statuses[nextIndex]);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-violet-600 to-purple-600 text-white p-6 pb-20">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center">
              <span className="text-white font-bold text-lg">N</span>
            </div>
            <span className="text-xl font-semibold">Nexuly</span>
          </div>
          <button className="p-2 bg-white/10 rounded-full">
            <Bell className="w-5 h-5" />
          </button>
        </div>
        <h1 className="text-2xl font-semibold">Estado de Verificacion</h1>
        <p className="text-violet-100 mt-1">Sigue el progreso de tu solicitud</p>
      </div>

      {/* Main Content */}
      <div className="bg-white rounded-t-3xl -mt-12 min-h-[calc(100vh-180px)] p-6">
        {/* Status Card - Click to cycle through statuses for demo */}
        <div 
          onClick={cycleStatus}
          className={`rounded-2xl border-2 ${config.borderColor} p-6 mb-6 cursor-pointer hover:shadow-md transition-shadow`}
        >
          <div className="flex items-center gap-4 mb-4">
            <div className={`w-16 h-16 ${config.bgColor} rounded-2xl flex items-center justify-center`}>
              <StatusIcon className={`w-8 h-8 ${config.color}`} />
            </div>
            <div>
              <span className={`text-xs px-2 py-1 rounded-full ${config.badgeColor}`}>
                {status === "pending" ? "Pendiente" : 
                 status === "in_review" ? "En revision" :
                 status === "approved" ? "Aprobado" : "Rechazado"}
              </span>
              <h2 className="text-xl font-semibold text-gray-900 mt-1">{config.title}</h2>
            </div>
          </div>
          <p className="text-gray-600">{config.description}</p>
          
          {/* Timeline */}
          <div className="mt-6 space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">Solicitud enviada</p>
                <p className="text-xs text-gray-500">{submittedDate}</p>
              </div>
              <CheckCircle2 className="w-5 h-5 text-green-500" />
            </div>
            <div className="flex items-center gap-3">
              <div className={`w-3 h-3 rounded-full ${status !== "pending" ? "bg-green-500" : "bg-gray-300"}`}></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">Revision de documentos</p>
                <p className="text-xs text-gray-500">Estimado: {estimatedReview}</p>
              </div>
              {status !== "pending" && <CheckCircle2 className="w-5 h-5 text-green-500" />}
            </div>
            <div className="flex items-center gap-3">
              <div className={`w-3 h-3 rounded-full ${status === "approved" ? "bg-green-500" : "bg-gray-300"}`}></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">Verificacion completada</p>
                <p className="text-xs text-gray-500">Pendiente</p>
              </div>
            </div>
          </div>
        </div>

        {/* Documents Status */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Estado de Documentos</h3>
          <div className="space-y-3">
            {documents.map((doc, index) => (
              <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                    doc.status === "verified" ? "bg-green-100" : "bg-amber-100"
                  }`}>
                    <FileText className={`w-5 h-5 ${
                      doc.status === "verified" ? "text-green-600" : "text-amber-600"
                    }`} />
                  </div>
                  <span className="text-sm font-medium text-gray-900">{doc.name}</span>
                </div>
                <span className={`text-xs px-2 py-1 rounded-full ${
                  doc.status === "verified" 
                    ? "bg-green-100 text-green-700" 
                    : "bg-amber-100 text-amber-700"
                }`}>
                  {doc.status === "verified" ? "Verificado" : "Pendiente"}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="space-y-3">
          <button 
            onClick={() => navigate("/help")}
            className="w-full flex items-center justify-between p-4 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-violet-100 rounded-lg flex items-center justify-center">
                <HelpCircle className="w-5 h-5 text-violet-600" />
              </div>
              <div className="text-left">
                <p className="text-sm font-medium text-gray-900">Centro de ayuda</p>
                <p className="text-xs text-gray-500">Preguntas frecuentes</p>
              </div>
            </div>
          </button>
          
          <button className="w-full flex items-center justify-between p-4 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-violet-100 rounded-lg flex items-center justify-center">
                <MessageSquare className="w-5 h-5 text-violet-600" />
              </div>
              <div className="text-left">
                <p className="text-sm font-medium text-gray-900">Contactar soporte</p>
                <p className="text-xs text-gray-500">Resuelve tus dudas</p>
              </div>
            </div>
          </button>
        </div>

        {/* Info */}
        <div className="mt-6 bg-violet-50 rounded-xl p-4">
          <p className="text-sm text-violet-800">
            <span className="font-medium">Tiempo estimado:</span> La revision de documentos 
            normalmente toma entre 24-48 horas habiles. Te notificaremos por correo electronico 
            y notificacion push cuando haya actualizaciones.
          </p>
        </div>

        {/* Action buttons based on status */}
        {status === "approved" && (
          <button 
            onClick={() => navigate("/professional")}
            className="w-full mt-6 py-4 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-xl font-medium hover:from-violet-700 hover:to-purple-700 transition-colors"
          >
            Ir a mi panel de profesional
          </button>
        )}

        {status === "rejected" && (
          <button 
            onClick={() => navigate("/professional-register")}
            className="w-full mt-6 py-4 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-xl font-medium hover:from-violet-700 hover:to-purple-700 transition-colors"
          >
            Volver a enviar documentos
          </button>
        )}

        {/* Logout */}
        <button 
          onClick={() => navigate("/login")}
          className="w-full mt-4 py-3 text-gray-500 hover:text-gray-700 transition-colors text-sm"
        >
          Cerrar sesion
        </button>
      </div>
    </div>
  );
}
