import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { 
  ArrowLeft, 
  Star, 
  Clock, 
  Calendar, 
  MapPin,
  User,
  ThumbsUp,
  ThumbsDown,
  AlertCircle,
  CheckCircle2
} from "lucide-react";

type TrustLabel = "excellent" | "good" | "needs_improvement" | "problematic";

interface UserReviewData {
  punctuality: boolean | null;
  communication: boolean | null;
  respect: boolean | null;
  conditions: boolean | null;
  wouldWorkAgain: boolean | null;
  trustLabel: TrustLabel | null;
  privateNotes: string;
}

export function ProfessionalRateUser() {
  const navigate = useNavigate();
  const { id } = useParams();
  
  // Mock service data
  const serviceData = {
    serviceName: "Cuidado de adulto mayor",
    date: "23 de Abril, 2026",
    time: "14:00 - 18:00",
    location: "Calle 45 #23-12, Valledupar",
    earnings: "$80,000",
    user: {
      name: "Maria Fernanda Lopez",
      totalServices: 12,
      memberSince: "Enero 2026"
    }
  };

  const [reviewData, setReviewData] = useState<UserReviewData>({
    punctuality: null,
    communication: null,
    respect: null,
    conditions: null,
    wouldWorkAgain: null,
    trustLabel: null,
    privateNotes: ""
  });

  const [submitted, setSubmitted] = useState(false);

  const booleanQuestions = [
    { key: "punctuality", label: "Puntualidad", question: "El usuario estuvo a tiempo para el servicio?" },
    { key: "communication", label: "Comunicacion", question: "La comunicacion fue clara y oportuna?" },
    { key: "respect", label: "Respeto", question: "El usuario fue respetuoso durante el servicio?" },
    { key: "conditions", label: "Condiciones", question: "El lugar estaba en condiciones adecuadas?" },
  ];

  const trustLabels = [
    { 
      value: "excellent" as TrustLabel, 
      label: "Excelente", 
      description: "Usuario ejemplar, altamente recomendable",
      color: "border-green-500 bg-green-50 text-green-700"
    },
    { 
      value: "good" as TrustLabel, 
      label: "Bueno", 
      description: "Usuario confiable, sin problemas",
      color: "border-blue-500 bg-blue-50 text-blue-700"
    },
    { 
      value: "needs_improvement" as TrustLabel, 
      label: "Puede mejorar", 
      description: "Algunos aspectos a mejorar",
      color: "border-amber-500 bg-amber-50 text-amber-700"
    },
    { 
      value: "problematic" as TrustLabel, 
      label: "Problematico", 
      description: "Tuve dificultades con este usuario",
      color: "border-red-500 bg-red-50 text-red-700"
    },
  ];

  const handleBooleanChange = (key: string, value: boolean) => {
    setReviewData(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const handleSubmit = () => {
    setSubmitted(true);
    setTimeout(() => {
      navigate("/professional");
    }, 2000);
  };

  const allQuestionsAnswered = 
    reviewData.punctuality !== null &&
    reviewData.communication !== null &&
    reviewData.respect !== null &&
    reviewData.conditions !== null &&
    reviewData.wouldWorkAgain !== null;

  if (submitted) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl p-8 text-center max-w-sm w-full shadow-lg">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle2 className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Evaluacion enviada</h2>
          <p className="text-gray-500 mb-4">
            Gracias por tu evaluacion. Esta informacion ayuda a mantener la calidad de la plataforma.
          </p>
          <div className="bg-teal-50 rounded-xl p-4">
            <p className="text-sm text-teal-700">
              Has ganado <span className="font-bold">{serviceData.earnings}</span> por este servicio.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-teal-600 to-emerald-600 text-white p-4 pb-20">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-semibold">Evaluar usuario</h1>
            <p className="text-teal-100 text-sm">Tu opinion es confidencial</p>
          </div>
        </div>
      </div>

      <div className="-mt-16 px-4 space-y-4">
        {/* Service Summary Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 bg-teal-100 rounded-full flex items-center justify-center">
              <User className="w-7 h-7 text-teal-600" />
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-gray-900">{serviceData.user.name}</h3>
              <p className="text-xs text-gray-500">{serviceData.user.totalServices} servicios en Nexuly</p>
            </div>
          </div>
          
          <div className="bg-gray-50 rounded-xl p-3 space-y-2">
            <p className="text-sm font-medium text-gray-900">{serviceData.serviceName}</p>
            <div className="flex items-center gap-4 text-xs text-gray-500">
              <span className="flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5" />
                {serviceData.date}
              </span>
              <span className="flex items-center gap-1">
                <Clock className="w-3.5 h-3.5" />
                {serviceData.time}
              </span>
            </div>
          </div>

          <div className="mt-3 p-3 bg-green-50 rounded-xl">
            <p className="text-sm text-green-700">
              Ganancia: <span className="font-bold">{serviceData.earnings}</span>
            </p>
          </div>
        </div>

        {/* Boolean Questions */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-4">Evaluacion rapida</h3>
          <div className="space-y-4">
            {booleanQuestions.map((question) => (
              <div key={question.key} className="border-b border-gray-100 pb-4 last:border-0 last:pb-0">
                <p className="text-sm text-gray-700 mb-3">{question.question}</p>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    onClick={() => handleBooleanChange(question.key, true)}
                    className={`p-3 rounded-xl border-2 flex items-center justify-center gap-2 transition-colors ${
                      reviewData[question.key as keyof UserReviewData] === true
                        ? "border-green-500 bg-green-50"
                        : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <ThumbsUp className={`w-5 h-5 ${
                      reviewData[question.key as keyof UserReviewData] === true ? "text-green-600" : "text-gray-400"
                    }`} />
                    <span className={`text-sm ${
                      reviewData[question.key as keyof UserReviewData] === true ? "text-green-700 font-medium" : "text-gray-600"
                    }`}>
                      Si
                    </span>
                  </button>
                  <button
                    onClick={() => handleBooleanChange(question.key, false)}
                    className={`p-3 rounded-xl border-2 flex items-center justify-center gap-2 transition-colors ${
                      reviewData[question.key as keyof UserReviewData] === false
                        ? "border-red-500 bg-red-50"
                        : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <ThumbsDown className={`w-5 h-5 ${
                      reviewData[question.key as keyof UserReviewData] === false ? "text-red-600" : "text-gray-400"
                    }`} />
                    <span className={`text-sm ${
                      reviewData[question.key as keyof UserReviewData] === false ? "text-red-700 font-medium" : "text-gray-600"
                    }`}>
                      No
                    </span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Would Work Again */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Trabajarias de nuevo con este usuario?</h3>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => setReviewData(prev => ({ ...prev, wouldWorkAgain: true }))}
              className={`p-4 rounded-xl border-2 flex flex-col items-center gap-2 transition-colors ${
                reviewData.wouldWorkAgain === true
                  ? "border-green-500 bg-green-50"
                  : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <ThumbsUp className={`w-6 h-6 ${
                reviewData.wouldWorkAgain === true ? "text-green-600" : "text-gray-400"
              }`} />
              <span className={`text-sm ${
                reviewData.wouldWorkAgain === true ? "text-green-700 font-medium" : "text-gray-600"
              }`}>
                Si, sin duda
              </span>
            </button>
            <button
              onClick={() => setReviewData(prev => ({ ...prev, wouldWorkAgain: false }))}
              className={`p-4 rounded-xl border-2 flex flex-col items-center gap-2 transition-colors ${
                reviewData.wouldWorkAgain === false
                  ? "border-red-500 bg-red-50"
                  : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <ThumbsDown className={`w-6 h-6 ${
                reviewData.wouldWorkAgain === false ? "text-red-600" : "text-gray-400"
              }`} />
              <span className={`text-sm ${
                reviewData.wouldWorkAgain === false ? "text-red-700 font-medium" : "text-gray-600"
              }`}>
                Prefiero no
              </span>
            </button>
          </div>
        </div>

        {/* Trust Label */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="font-semibold text-gray-900">Etiqueta de confianza</h3>
            <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">Privado</span>
          </div>
          <p className="text-sm text-gray-500 mb-4">
            Esta evaluacion es interna y no sera visible para el usuario
          </p>
          <div className="space-y-2">
            {trustLabels.map((label) => (
              <button
                key={label.value}
                onClick={() => setReviewData(prev => ({ ...prev, trustLabel: label.value }))}
                className={`w-full p-3 rounded-xl border-2 text-left transition-colors ${
                  reviewData.trustLabel === label.value
                    ? label.color
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <p className="text-sm font-medium">{label.label}</p>
                <p className="text-xs opacity-75">{label.description}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Private Notes */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="font-semibold text-gray-900">Notas privadas</h3>
            <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">Opcional</span>
          </div>
          <p className="text-sm text-gray-500 mb-3">
            Comparte detalles adicionales con el equipo de Nexuly
          </p>
          <textarea
            value={reviewData.privateNotes}
            onChange={(e) => setReviewData(prev => ({ ...prev, privateNotes: e.target.value }))}
            placeholder="Describe cualquier situacion relevante..."
            rows={3}
            className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none resize-none"
          />
        </div>

        {/* Info Alert */}
        <div className="bg-teal-50 border border-teal-200 rounded-xl p-4 flex gap-3">
          <AlertCircle className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm text-teal-800 font-medium">Tu evaluacion es privada</p>
            <p className="text-xs text-teal-700 mt-1">
              Esta informacion solo es visible para el equipo de Nexuly y se usa para 
              mejorar la seguridad de la plataforma. El usuario no vera tu evaluacion.
            </p>
          </div>
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!allQuestionsAnswered}
          className="w-full bg-gradient-to-r from-teal-600 to-emerald-600 text-white py-4 rounded-xl hover:from-teal-700 hover:to-emerald-700 transition-all shadow-lg shadow-teal-500/30 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Enviar evaluacion
        </button>
      </div>
    </div>
  );
}
