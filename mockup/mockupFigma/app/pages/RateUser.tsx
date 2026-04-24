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
  CheckCircle2,
  Shield,
  ShieldCheck,
  Award
} from "lucide-react";

type TrustLabel = "excellent" | "good" | "needs_improvement" | "problematic";

interface UserReviewData {
  punctuality: number;
  communication: number;
  respect: number;
  cleanliness: number;
  overallExperience: number;
  wouldWorkAgain: boolean | null;
  trustLabel: TrustLabel | null;
  privateNotes: string;
  publicComment: string;
}

export function RateUser() {
  const navigate = useNavigate();
  const { id } = useParams();
  
  // Mock service data
  const serviceData = {
    serviceName: "Cuidado de adulto mayor",
    date: "22 de Abril, 2026",
    time: "09:00 - 13:00",
    location: "Calle 45 #23-12, Bogota",
    user: {
      name: "Maria Fernanda Lopez",
      verificationLevel: "verified" as const,
      totalServices: 8,
      memberSince: "Enero 2026"
    }
  };

  const [reviewData, setReviewData] = useState<UserReviewData>({
    punctuality: 0,
    communication: 0,
    respect: 0,
    cleanliness: 0,
    overallExperience: 0,
    wouldWorkAgain: null,
    trustLabel: null,
    privateNotes: "",
    publicComment: ""
  });

  const [submitted, setSubmitted] = useState(false);

  const ratingCategories = [
    { key: "punctuality", label: "Puntualidad", description: "Estuvo a tiempo para el servicio" },
    { key: "communication", label: "Comunicacion", description: "Comunicacion clara y oportuna" },
    { key: "respect", label: "Respeto", description: "Trato respetuoso durante el servicio" },
    { key: "cleanliness", label: "Condiciones del lugar", description: "Ambiente adecuado para el servicio" },
    { key: "overallExperience", label: "Experiencia general", description: "Calificacion general del servicio" },
  ];

  const trustLabels = [
    { 
      value: "excellent" as TrustLabel, 
      label: "Excelente", 
      description: "Usuario ejemplar, altamente recomendable",
      color: "bg-green-100 text-green-700 border-green-300"
    },
    { 
      value: "good" as TrustLabel, 
      label: "Bueno", 
      description: "Usuario confiable, sin problemas",
      color: "bg-blue-100 text-blue-700 border-blue-300"
    },
    { 
      value: "needs_improvement" as TrustLabel, 
      label: "Puede mejorar", 
      description: "Algunos aspectos a mejorar",
      color: "bg-amber-100 text-amber-700 border-amber-300"
    },
    { 
      value: "problematic" as TrustLabel, 
      label: "Problematico", 
      description: "Tuve dificultades con este usuario",
      color: "bg-red-100 text-red-700 border-red-300"
    },
  ];

  const quickComments = [
    "Muy puntual y respetuoso",
    "Excelente comunicacion",
    "Lugar limpio y ordenado",
    "Paciente muy colaborador",
    "Fue un placer trabajar aqui"
  ];

  const handleRatingChange = (category: string, value: number) => {
    setReviewData(prev => ({
      ...prev,
      [category]: value
    }));
  };

  const handleSubmit = () => {
    setSubmitted(true);
    // In real app, this would submit to the backend
    setTimeout(() => {
      navigate("/");
    }, 2000);
  };

  const averageRating = () => {
    const ratings = [
      reviewData.punctuality,
      reviewData.communication,
      reviewData.respect,
      reviewData.cleanliness,
      reviewData.overallExperience
    ].filter(r => r > 0);
    
    if (ratings.length === 0) return 0;
    return (ratings.reduce((a, b) => a + b, 0) / ratings.length).toFixed(1);
  };

  const verificationConfig = {
    basic: { icon: Shield, label: "Basico", color: "text-gray-500" },
    verified: { icon: ShieldCheck, label: "Verificado", color: "text-blue-600" },
    trusted: { icon: Award, label: "Confiable", color: "text-violet-600" }
  };

  const userVerification = verificationConfig[serviceData.user.verificationLevel];
  const UserVerificationIcon = userVerification.icon;

  if (submitted) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl p-8 text-center max-w-sm w-full shadow-lg">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle2 className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Evaluacion enviada</h2>
          <p className="text-gray-500 mb-6">
            Gracias por tu evaluacion. Esta informacion ayuda a mantener la calidad de la plataforma.
          </p>
          <div className="bg-violet-50 rounded-xl p-4">
            <p className="text-sm text-violet-700">
              Tu evaluacion del usuario es privada y solo sera visible para el equipo de Nexuly.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-violet-600 to-purple-600 text-white p-4 pb-20">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-semibold">Evaluar usuario</h1>
            <p className="text-violet-100 text-sm">Tu opinion ayuda a mejorar la comunidad</p>
          </div>
        </div>
      </div>

      <div className="-mt-16 px-4 space-y-4">
        {/* Service Summary Card */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 bg-violet-100 rounded-full flex items-center justify-center">
              <User className="w-7 h-7 text-violet-600" />
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-gray-900">{serviceData.user.name}</h3>
              <div className="flex items-center gap-2 mt-1">
                <UserVerificationIcon className={`w-4 h-4 ${userVerification.color}`} />
                <span className={`text-xs ${userVerification.color}`}>{userVerification.label}</span>
                <span className="text-xs text-gray-400">|</span>
                <span className="text-xs text-gray-500">{serviceData.user.totalServices} servicios</span>
              </div>
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
            <div className="flex items-center gap-1 text-xs text-gray-500">
              <MapPin className="w-3.5 h-3.5" />
              {serviceData.location}
            </div>
          </div>
        </div>

        {/* Rating Categories */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-4">Calificacion detallada</h3>
          <div className="space-y-5">
            {ratingCategories.map((category) => (
              <div key={category.key}>
                <div className="flex justify-between items-center mb-2">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{category.label}</p>
                    <p className="text-xs text-gray-500">{category.description}</p>
                  </div>
                  <span className="text-sm font-medium text-violet-600">
                    {reviewData[category.key as keyof UserReviewData] || "-"}/5
                  </span>
                </div>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      onClick={() => handleRatingChange(category.key, star)}
                      className="flex-1 flex items-center justify-center p-2"
                    >
                      <Star
                        className={`w-7 h-7 transition-colors ${
                          star <= (reviewData[category.key as keyof UserReviewData] as number)
                            ? "fill-amber-400 text-amber-400"
                            : "text-gray-300"
                        }`}
                      />
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>

          {/* Average Rating */}
          <div className="mt-6 pt-4 border-t border-gray-100 flex items-center justify-between">
            <span className="text-sm text-gray-600">Calificacion promedio</span>
            <div className="flex items-center gap-2">
              <Star className="w-5 h-5 fill-amber-400 text-amber-400" />
              <span className="text-lg font-bold text-gray-900">{averageRating()}</span>
            </div>
          </div>
        </div>

        {/* Would Work Again */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">¿Trabajarias de nuevo con este usuario?</h3>
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

        {/* Trust Label (Private) */}
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
            <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">Solo admin</span>
          </div>
          <p className="text-sm text-gray-500 mb-3">
            Comparte detalles adicionales con el equipo de Nexuly
          </p>
          <textarea
            value={reviewData.privateNotes}
            onChange={(e) => setReviewData(prev => ({ ...prev, privateNotes: e.target.value }))}
            placeholder="Describe cualquier situacion relevante que debamos conocer..."
            rows={3}
            className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none resize-none"
          />
        </div>

        {/* Public Comment (Optional) */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-1">Comentario publico (opcional)</h3>
          <p className="text-sm text-gray-500 mb-3">
            Un breve agradecimiento que el usuario podra ver
          </p>
          
          {/* Quick Comments */}
          <div className="flex flex-wrap gap-2 mb-3">
            {quickComments.map((comment, index) => (
              <button
                key={index}
                onClick={() => setReviewData(prev => ({ 
                  ...prev, 
                  publicComment: prev.publicComment ? `${prev.publicComment} ${comment}` : comment 
                }))}
                className="px-3 py-1.5 bg-violet-50 text-violet-700 rounded-full text-xs hover:bg-violet-100 transition-colors"
              >
                {comment}
              </button>
            ))}
          </div>

          <textarea
            value={reviewData.publicComment}
            onChange={(e) => setReviewData(prev => ({ ...prev, publicComment: e.target.value }))}
            placeholder="Gracias por la experiencia..."
            rows={2}
            className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none resize-none"
          />
        </div>

        {/* Info Alert */}
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3">
          <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm text-amber-800 font-medium">Importante</p>
            <p className="text-xs text-amber-700 mt-1">
              Tu evaluacion del usuario es mayormente privada. Solo el comentario publico 
              (si decides agregarlo) sera visible para el usuario. Las etiquetas de confianza 
              y notas privadas solo son visibles para el equipo de Nexuly.
            </p>
          </div>
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={reviewData.overallExperience === 0}
          className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-4 rounded-xl hover:from-violet-700 hover:to-purple-700 transition-all shadow-lg shadow-violet-500/30 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Enviar evaluacion
        </button>
      </div>
    </div>
  );
}
