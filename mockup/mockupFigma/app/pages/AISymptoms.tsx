import { useState } from "react";
import { Link, useNavigate } from "react-router";
import { ArrowLeft, Sparkles, AlertCircle, Heart, Brain, Thermometer, Activity } from "lucide-react";

const commonSymptoms = [
  { id: "dolor", label: "Dolor general", icon: AlertCircle },
  { id: "fiebre", label: "Fiebre", icon: Thermometer },
  { id: "movilidad", label: "Problemas de movilidad", icon: Activity },
  { id: "cardiovascular", label: "Cardiovascular", icon: Heart },
  { id: "neurologico", label: "Neurológico", icon: Brain },
];

const needsCategories = [
  "Cuidado postoperatorio",
  "Rehabilitación física",
  "Cuidado de adulto mayor",
  "Enfermería general",
  "Cuidado pediátrico",
  "Atención domiciliaria",
];

export function AISymptoms() {
  const navigate = useNavigate();
  const [selectedSymptoms, setSelectedSymptoms] = useState<string[]>([]);
  const [description, setDescription] = useState("");
  const [selectedNeeds, setSelectedNeeds] = useState<string[]>([]);

  const toggleSymptom = (id: string) => {
    setSelectedSymptoms(prev =>
      prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id]
    );
  };

  const toggleNeed = (need: string) => {
    setSelectedNeeds(prev =>
      prev.includes(need) ? prev.filter(n => n !== need) : [...prev, need]
    );
  };

  const handleAnalyze = () => {
    navigate("/ai-recommendations", {
      state: { symptoms: selectedSymptoms, description, needs: selectedNeeds }
    });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-br from-violet-500 to-purple-500 text-white p-4">
        <div className="flex items-center gap-3 mb-4">
          <Link to="/" className="p-2 rounded-full hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="flex-1">
            <h1 className="text-lg">Asistente IA</h1>
            <p className="text-sm text-violet-100">Recomendación de profesionales</p>
          </div>
        </div>

        <div className="bg-white/20 backdrop-blur-sm rounded-xl p-4 flex items-start gap-3">
          <Sparkles className="w-5 h-5 flex-shrink-0 mt-1" />
          <div>
            <p className="text-sm">
              Cuéntanos tus síntomas o necesidades y te recomendaremos a los profesionales más adecuados para ti.
            </p>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-6 pb-24">
        {/* Síntomas Comunes */}
        <div>
          <h2 className="text-base mb-3 text-gray-800">Síntomas principales</h2>
          <div className="grid grid-cols-2 gap-3">
            {commonSymptoms.map((symptom) => (
              <button
                key={symptom.id}
                onClick={() => toggleSymptom(symptom.id)}
                className={`p-4 rounded-xl border-2 transition-all ${
                  selectedSymptoms.includes(symptom.id)
                    ? "border-violet-500 bg-violet-50"
                    : "border-gray-200 bg-white"
                }`}
              >
                <symptom.icon
                  className={`w-6 h-6 mb-2 ${
                    selectedSymptoms.includes(symptom.id)
                      ? "text-violet-600"
                      : "text-gray-400"
                  }`}
                />
                <p className="text-sm text-gray-800">{symptom.label}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Tipo de necesidad */}
        <div>
          <h2 className="text-base mb-3 text-gray-800">Tipo de atención necesaria</h2>
          <div className="space-y-2">
            {needsCategories.map((need) => (
              <button
                key={need}
                onClick={() => toggleNeed(need)}
                className={`w-full p-3 rounded-xl border-2 text-left transition-all ${
                  selectedNeeds.includes(need)
                    ? "border-violet-500 bg-violet-50 text-violet-700"
                    : "border-gray-200 bg-white text-gray-700"
                }`}
              >
                <span className="text-sm">{need}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Descripción detallada */}
        <div>
          <h2 className="text-base mb-3 text-gray-800">Descripción detallada (opcional)</h2>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe con más detalle tus síntomas o necesidades..."
            className="w-full p-4 rounded-xl border-2 border-gray-200 bg-white text-sm resize-none focus:outline-none focus:border-violet-500"
            rows={4}
          />
          <p className="text-xs text-gray-500 mt-2">
            Cuanto más detallada sea tu descripción, mejor será la recomendación.
          </p>
        </div>

        {/* Botón de análisis */}
        <button
          onClick={handleAnalyze}
          disabled={selectedSymptoms.length === 0 && selectedNeeds.length === 0}
          className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white p-4 rounded-xl font-medium disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          <Sparkles className="w-5 h-5" />
          Obtener recomendaciones IA
        </button>
      </div>
    </div>
  );
}
