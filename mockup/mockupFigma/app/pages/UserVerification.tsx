import { useState } from "react";
import { useNavigate } from "react-router";
import { 
  ArrowLeft, 
  Shield, 
  ShieldCheck, 
  ShieldAlert,
  CheckCircle2, 
  Circle,
  Phone,
  Mail,
  CreditCard,
  Camera,
  FileText,
  Star,
  Award,
  Lock,
  ChevronRight,
  AlertCircle,
  Sparkles
} from "lucide-react";

type VerificationLevel = "basic" | "verified" | "trusted";

interface VerificationStep {
  id: string;
  title: string;
  description: string;
  icon: React.ElementType;
  completed: boolean;
  required: boolean;
}

export function UserVerification() {
  const navigate = useNavigate();
  
  // Mock user verification data
  const [currentLevel] = useState<VerificationLevel>("verified");
  const [completedSteps, setCompletedSteps] = useState<string[]>([
    "email",
    "phone",
    "photo"
  ]);

  const verificationLevels = {
    basic: {
      label: "Basico",
      color: "text-gray-600",
      bgColor: "bg-gray-100",
      borderColor: "border-gray-300",
      icon: Shield,
      description: "Cuenta creada con email verificado",
      benefits: ["Buscar profesionales", "Ver perfiles", "Guardar favoritos"]
    },
    verified: {
      label: "Verificado",
      color: "text-blue-600",
      bgColor: "bg-blue-100",
      borderColor: "border-blue-300",
      icon: ShieldCheck,
      description: "Identidad confirmada con telefono y foto",
      benefits: ["Reservar servicios", "Chat con profesionales", "Historial completo"]
    },
    trusted: {
      label: "Confiable",
      color: "text-violet-600",
      bgColor: "bg-violet-100",
      borderColor: "border-violet-300",
      icon: Award,
      description: "Usuario con historial positivo confirmado",
      benefits: ["Acceso a profesionales premium", "Descuentos exclusivos", "Prioridad en reservas", "Badge de confianza visible"]
    }
  };

  const verificationSteps: VerificationStep[] = [
    {
      id: "email",
      title: "Verificar correo electronico",
      description: "Confirma tu direccion de email",
      icon: Mail,
      completed: completedSteps.includes("email"),
      required: true
    },
    {
      id: "phone",
      title: "Verificar numero de telefono",
      description: "Confirma tu numero con codigo SMS",
      icon: Phone,
      completed: completedSteps.includes("phone"),
      required: true
    },
    {
      id: "photo",
      title: "Foto de perfil",
      description: "Sube una foto clara de tu rostro",
      icon: Camera,
      completed: completedSteps.includes("photo"),
      required: true
    },
    {
      id: "document",
      title: "Documento de identidad",
      description: "Verifica tu identidad con documento oficial",
      icon: FileText,
      completed: completedSteps.includes("document"),
      required: false
    },
    {
      id: "payment",
      title: "Metodo de pago",
      description: "Agrega un metodo de pago verificado",
      icon: CreditCard,
      completed: completedSteps.includes("payment"),
      required: false
    }
  ];

  const trustFactors = [
    { label: "Servicios completados", value: 12, target: 10, achieved: true },
    { label: "Calificacion promedio", value: 4.8, target: 4.5, achieved: true },
    { label: "Cancelaciones", value: 1, target: 3, achieved: true, inverted: true },
    { label: "Pagos a tiempo", value: 95, target: 90, achieved: true, suffix: "%" },
    { label: "Cuenta activa", value: 6, target: 3, achieved: true, suffix: " meses" },
  ];

  const handleVerifyStep = (stepId: string) => {
    if (!completedSteps.includes(stepId)) {
      setCompletedSteps([...completedSteps, stepId]);
    }
  };

  const completedRequired = verificationSteps.filter(s => s.required && s.completed).length;
  const totalRequired = verificationSteps.filter(s => s.required).length;
  const progress = (completedRequired / totalRequired) * 100;

  const currentLevelConfig = verificationLevels[currentLevel];
  const CurrentLevelIcon = currentLevelConfig.icon;

  return (
    <div className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <div className="bg-gradient-to-r from-violet-600 to-purple-600 text-white p-4 pb-20">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-xl font-semibold">Verificacion de cuenta</h1>
        </div>
      </div>

      <div className="-mt-16 px-4 space-y-4">
        {/* Current Level Card */}
        <div className="bg-white rounded-2xl p-6 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <div className={`w-16 h-16 ${currentLevelConfig.bgColor} rounded-2xl flex items-center justify-center`}>
              <CurrentLevelIcon className={`w-8 h-8 ${currentLevelConfig.color}`} />
            </div>
            <div>
              <span className={`text-xs px-2 py-1 rounded-full ${currentLevelConfig.bgColor} ${currentLevelConfig.color}`}>
                Nivel actual
              </span>
              <h2 className="text-xl font-semibold text-gray-900 mt-1">{currentLevelConfig.label}</h2>
              <p className="text-sm text-gray-500">{currentLevelConfig.description}</p>
            </div>
          </div>

          {/* Progress */}
          <div className="mb-4">
            <div className="flex justify-between text-sm mb-2">
              <span className="text-gray-600">Progreso de verificacion</span>
              <span className="text-violet-600 font-medium">{completedRequired}/{totalRequired} completados</span>
            </div>
            <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
              <div 
                className="h-full bg-gradient-to-r from-violet-500 to-purple-500 rounded-full transition-all"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>

          {/* Benefits */}
          <div className="pt-4 border-t border-gray-100">
            <p className="text-xs text-gray-500 mb-2">Beneficios de tu nivel:</p>
            <div className="space-y-1">
              {currentLevelConfig.benefits.map((benefit, index) => (
                <div key={index} className="flex items-center gap-2 text-sm text-gray-700">
                  <CheckCircle2 className="w-4 h-4 text-green-500" />
                  <span>{benefit}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Level Progress */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-4">Niveles de verificacion</h3>
          <div className="relative">
            {/* Progress Line */}
            <div className="absolute left-6 top-6 bottom-6 w-0.5 bg-gray-200" />
            <div 
              className="absolute left-6 top-6 w-0.5 bg-violet-500 transition-all"
              style={{ 
                height: currentLevel === "basic" ? "0%" : 
                        currentLevel === "verified" ? "50%" : "100%" 
              }}
            />

            <div className="space-y-6">
              {(["basic", "verified", "trusted"] as VerificationLevel[]).map((level, index) => {
                const config = verificationLevels[level];
                const LevelIcon = config.icon;
                const isActive = level === currentLevel;
                const isCompleted = 
                  (currentLevel === "verified" && level === "basic") ||
                  (currentLevel === "trusted" && (level === "basic" || level === "verified"));

                return (
                  <div key={level} className="flex items-start gap-4">
                    <div className={`relative z-10 w-12 h-12 rounded-full flex items-center justify-center ${
                      isCompleted || isActive ? config.bgColor : "bg-gray-100"
                    }`}>
                      {isCompleted ? (
                        <CheckCircle2 className={`w-6 h-6 ${config.color}`} />
                      ) : (
                        <LevelIcon className={`w-6 h-6 ${isActive ? config.color : "text-gray-400"}`} />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <h4 className={`font-medium ${isActive || isCompleted ? "text-gray-900" : "text-gray-500"}`}>
                          {config.label}
                        </h4>
                        {isActive && (
                          <span className="text-xs px-2 py-0.5 bg-violet-100 text-violet-600 rounded-full">
                            Tu nivel
                          </span>
                        )}
                      </div>
                      <p className="text-sm text-gray-500">{config.description}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Verification Steps */}
        <div className="bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-4">Pasos de verificacion</h3>
          <div className="space-y-3">
            {verificationSteps.map((step) => {
              const StepIcon = step.icon;
              return (
                <div
                  key={step.id}
                  onClick={() => !step.completed && handleVerifyStep(step.id)}
                  className={`flex items-center justify-between p-4 rounded-xl transition-colors ${
                    step.completed 
                      ? "bg-green-50 border border-green-200" 
                      : "bg-gray-50 hover:bg-gray-100 cursor-pointer"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                      step.completed ? "bg-green-100" : "bg-violet-100"
                    }`}>
                      {step.completed ? (
                        <CheckCircle2 className="w-5 h-5 text-green-600" />
                      ) : (
                        <StepIcon className="w-5 h-5 text-violet-600" />
                      )}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {step.title}
                        {step.required && <span className="text-red-500 ml-1">*</span>}
                      </p>
                      <p className="text-xs text-gray-500">{step.description}</p>
                    </div>
                  </div>
                  {!step.completed && (
                    <ChevronRight className="w-5 h-5 text-gray-400" />
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Trust Factors (for Trusted level) */}
        {currentLevel === "verified" && (
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-4">
              <Sparkles className="w-5 h-5 text-violet-600" />
              <h3 className="font-semibold text-gray-900">Progreso hacia nivel Confiable</h3>
            </div>
            <p className="text-sm text-gray-500 mb-4">
              Completa estos objetivos para desbloquear el nivel Confiable
            </p>
            <div className="space-y-3">
              {trustFactors.map((factor, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    {factor.achieved ? (
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                    ) : (
                      <Circle className="w-5 h-5 text-gray-300" />
                    )}
                    <span className="text-sm text-gray-700">{factor.label}</span>
                  </div>
                  <span className={`text-sm font-medium ${
                    factor.achieved ? "text-green-600" : "text-gray-500"
                  }`}>
                    {factor.value}{factor.suffix || ""} / {factor.target}{factor.suffix || ""}
                  </span>
                </div>
              ))}
            </div>

            <div className="mt-4 pt-4 border-t border-gray-100">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-gray-600">Progreso total</span>
                <span className="text-sm font-medium text-violet-600">
                  {trustFactors.filter(f => f.achieved).length}/{trustFactors.length} completados
                </span>
              </div>
              <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-gradient-to-r from-violet-500 to-purple-500 rounded-full"
                  style={{ width: `${(trustFactors.filter(f => f.achieved).length / trustFactors.length) * 100}%` }}
                />
              </div>
            </div>
          </div>
        )}

        {/* Trust Badges Info */}
        <div className="bg-violet-50 rounded-2xl p-4">
          <div className="flex gap-3">
            <Award className="w-6 h-6 text-violet-600 flex-shrink-0" />
            <div>
              <h4 className="font-medium text-violet-900">Etiquetas de confianza</h4>
              <p className="text-sm text-violet-700 mt-1">
                Los usuarios con nivel Confiable reciben una etiqueta visible en su perfil 
                que indica a los profesionales que son usuarios responsables y puntuales.
              </p>
            </div>
          </div>
        </div>

        {/* Security Note */}
        <div className="bg-gray-100 rounded-xl p-4 flex gap-3">
          <Lock className="w-5 h-5 text-gray-500 flex-shrink-0" />
          <p className="text-sm text-gray-600">
            Tu informacion de verificacion esta protegida y encriptada. 
            Solo se usa para confirmar tu identidad y no se comparte con terceros.
          </p>
        </div>
      </div>
    </div>
  );
}
