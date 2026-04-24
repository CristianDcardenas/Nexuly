import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Plus, Pencil, Trash2, AlertCircle, Pill, Stethoscope, Droplets, Activity } from "lucide-react";

interface MedicalCondition {
  id: string;
  name: string;
  diagnosedDate: string;
  notes?: string;
}

interface Medication {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
}

interface Allergy {
  id: string;
  name: string;
  severity: "mild" | "moderate" | "severe";
}

export function MedicalInfo() {
  const [activeTab, setActiveTab] = useState<"conditions" | "medications" | "allergies" | "vitals">("conditions");
  
  const [conditions] = useState<MedicalCondition[]>([
    { id: "1", name: "Hipertension arterial", diagnosedDate: "2020-03-15", notes: "Controlada con medicacion" },
    { id: "2", name: "Diabetes tipo 2", diagnosedDate: "2019-08-22" },
  ]);

  const [medications] = useState<Medication[]>([
    { id: "1", name: "Metformina", dosage: "500mg", frequency: "2 veces al dia" },
    { id: "2", name: "Losartan", dosage: "50mg", frequency: "1 vez al dia" },
  ]);

  const [allergies] = useState<Allergy[]>([
    { id: "1", name: "Penicilina", severity: "severe" },
    { id: "2", name: "Polen", severity: "mild" },
  ]);

  const [vitals] = useState({
    bloodType: "O+",
    height: "165 cm",
    weight: "68 kg",
    lastUpdated: "2024-01-15",
  });

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case "mild": return "bg-yellow-100 text-yellow-700";
      case "moderate": return "bg-orange-100 text-orange-700";
      case "severe": return "bg-red-100 text-red-700";
      default: return "bg-gray-100 text-gray-700";
    }
  };

  const getSeverityLabel = (severity: string) => {
    switch (severity) {
      case "mild": return "Leve";
      case "moderate": return "Moderada";
      case "severe": return "Severa";
      default: return severity;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="text-lg font-medium">Tu informacion medica</h1>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b border-gray-200 px-4">
        <div className="flex gap-1 overflow-x-auto">
          <button
            onClick={() => setActiveTab("conditions")}
            className={`flex items-center gap-2 px-4 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${
              activeTab === "conditions"
                ? "border-violet-600 text-violet-600"
                : "border-transparent text-gray-600 hover:text-gray-900"
            }`}
          >
            <Stethoscope className="w-4 h-4" />
            Condiciones
          </button>
          <button
            onClick={() => setActiveTab("medications")}
            className={`flex items-center gap-2 px-4 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${
              activeTab === "medications"
                ? "border-violet-600 text-violet-600"
                : "border-transparent text-gray-600 hover:text-gray-900"
            }`}
          >
            <Pill className="w-4 h-4" />
            Medicamentos
          </button>
          <button
            onClick={() => setActiveTab("allergies")}
            className={`flex items-center gap-2 px-4 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${
              activeTab === "allergies"
                ? "border-violet-600 text-violet-600"
                : "border-transparent text-gray-600 hover:text-gray-900"
            }`}
          >
            <AlertCircle className="w-4 h-4" />
            Alergias
          </button>
          <button
            onClick={() => setActiveTab("vitals")}
            className={`flex items-center gap-2 px-4 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${
              activeTab === "vitals"
                ? "border-violet-600 text-violet-600"
                : "border-transparent text-gray-600 hover:text-gray-900"
            }`}
          >
            <Activity className="w-4 h-4" />
            Signos vitales
          </button>
        </div>
      </div>

      <div className="p-4">
        {/* Conditions Tab */}
        {activeTab === "conditions" && (
          <div className="space-y-3">
            <div className="flex items-center justify-between mb-4">
              <p className="text-sm text-gray-600">Tus condiciones medicas diagnosticadas</p>
              <button className="flex items-center gap-1 text-sm text-violet-600 hover:text-violet-700">
                <Plus className="w-4 h-4" />
                Agregar
              </button>
            </div>

            {conditions.map((condition) => (
              <div key={condition.id} className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="font-medium text-gray-900">{condition.name}</h3>
                    <p className="text-sm text-gray-500 mt-1">
                      Diagnosticado: {new Date(condition.diagnosedDate).toLocaleDateString("es-ES", { year: "numeric", month: "long", day: "numeric" })}
                    </p>
                    {condition.notes && (
                      <p className="text-sm text-gray-600 mt-2 bg-gray-50 p-2 rounded-lg">{condition.notes}</p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button className="p-2 text-gray-400 hover:text-violet-600 hover:bg-violet-50 rounded-lg">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}

            {conditions.length === 0 && (
              <div className="text-center py-12">
                <Stethoscope className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                <p className="text-gray-600">No hay condiciones registradas</p>
                <p className="text-sm text-gray-500 mt-1">Agrega tus condiciones medicas para que tus profesionales de salud las conozcan</p>
              </div>
            )}
          </div>
        )}

        {/* Medications Tab */}
        {activeTab === "medications" && (
          <div className="space-y-3">
            <div className="flex items-center justify-between mb-4">
              <p className="text-sm text-gray-600">Medicamentos que tomas actualmente</p>
              <button className="flex items-center gap-1 text-sm text-violet-600 hover:text-violet-700">
                <Plus className="w-4 h-4" />
                Agregar
              </button>
            </div>

            {medications.map((medication) => (
              <div key={medication.id} className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                        <Pill className="w-5 h-5 text-violet-600" />
                      </div>
                      <div>
                        <h3 className="font-medium text-gray-900">{medication.name}</h3>
                        <p className="text-sm text-gray-500">{medication.dosage}</p>
                      </div>
                    </div>
                    <div className="mt-3 flex items-center gap-2">
                      <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-full">
                        {medication.frequency}
                      </span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button className="p-2 text-gray-400 hover:text-violet-600 hover:bg-violet-50 rounded-lg">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Allergies Tab */}
        {activeTab === "allergies" && (
          <div className="space-y-3">
            <div className="flex items-center justify-between mb-4">
              <p className="text-sm text-gray-600">Alergias conocidas</p>
              <button className="flex items-center gap-1 text-sm text-violet-600 hover:text-violet-700">
                <Plus className="w-4 h-4" />
                Agregar
              </button>
            </div>

            {allergies.map((allergy) => (
              <div key={allergy.id} className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                      <AlertCircle className="w-5 h-5 text-red-600" />
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-900">{allergy.name}</h3>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${getSeverityColor(allergy.severity)}`}>
                        {getSeverityLabel(allergy.severity)}
                      </span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button className="p-2 text-gray-400 hover:text-violet-600 hover:bg-violet-50 rounded-lg">
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Vitals Tab */}
        {activeTab === "vitals" && (
          <div className="space-y-4">
            <p className="text-sm text-gray-600 mb-4">Informacion basica de salud</p>

            <div className="bg-white rounded-xl p-4 border border-gray-200">
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center p-4 bg-red-50 rounded-xl">
                  <Droplets className="w-6 h-6 text-red-500 mx-auto mb-2" />
                  <p className="text-sm text-gray-600">Tipo de sangre</p>
                  <p className="text-xl font-bold text-gray-900">{vitals.bloodType}</p>
                </div>
                <div className="text-center p-4 bg-blue-50 rounded-xl">
                  <Activity className="w-6 h-6 text-blue-500 mx-auto mb-2" />
                  <p className="text-sm text-gray-600">Altura</p>
                  <p className="text-xl font-bold text-gray-900">{vitals.height}</p>
                </div>
                <div className="text-center p-4 bg-green-50 rounded-xl col-span-2">
                  <p className="text-sm text-gray-600">Peso</p>
                  <p className="text-xl font-bold text-gray-900">{vitals.weight}</p>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
                <p className="text-xs text-gray-500">
                  Ultima actualizacion: {new Date(vitals.lastUpdated).toLocaleDateString("es-ES")}
                </p>
                <button className="text-sm text-violet-600 hover:text-violet-700">
                  Actualizar
                </button>
              </div>
            </div>

            <div className="bg-violet-50 rounded-xl p-4 border border-violet-100">
              <p className="text-sm text-violet-800">
                Mantener tu informacion medica actualizada ayuda a los profesionales de salud a brindarte una mejor atencion.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
