import { useState } from "react";
import { useNavigate } from "react-router";
import { 
  ArrowLeft, 
  ArrowRight, 
  Upload, 
  FileText, 
  Camera, 
  CheckCircle2, 
  X,
  User,
  Briefcase,
  GraduationCap,
  Shield,
  MapPin,
  Clock,
  AlertCircle
} from "lucide-react";

type Step = 1 | 2 | 3 | 4 | 5;

interface DocumentFile {
  id: string;
  name: string;
  type: string;
  status: "uploading" | "uploaded" | "error";
  progress?: number;
}

interface FormData {
  // Personal Info
  fullName: string;
  email: string;
  phone: string;
  dateOfBirth: string;
  documentId: string;
  address: string;
  
  // Professional Info
  specialty: string;
  licenseNumber: string;
  yearsExperience: string;
  bio: string;
  services: string[];
  
  // Coverage
  coverageType: "radius" | "zones";
  coverageRadius: string;
  coverageZones: string[];
  
  // Availability
  availableDays: string[];
  workingHours: { start: string; end: string };
}

const SPECIALTIES = [
  "Enfermeria General",
  "Fisioterapia",
  "Cuidado de Adultos Mayores",
  "Pediatria",
  "Terapia Respiratoria",
  "Nutricion",
  "Psicologia",
  "Terapia Ocupacional"
];

const SERVICES = [
  "Cuidado de heridas",
  "Administracion de medicamentos",
  "Control de signos vitales",
  "Acompanamiento hospitalario",
  "Rehabilitacion fisica",
  "Cuidado post-operatorio",
  "Asistencia en higiene personal",
  "Terapia de lenguaje"
];

const DAYS = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo"];

const ZONES = ["Norte", "Sur", "Centro", "Oriente", "Occidente"];

export function ProfessionalRegister() {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState<Step>(1);
  const [documents, setDocuments] = useState<DocumentFile[]>([]);
  const [profilePhoto, setProfilePhoto] = useState<DocumentFile | null>(null);
  
  const [formData, setFormData] = useState<FormData>({
    fullName: "",
    email: "",
    phone: "",
    dateOfBirth: "",
    documentId: "",
    address: "",
    specialty: "",
    licenseNumber: "",
    yearsExperience: "",
    bio: "",
    services: [],
    coverageType: "radius",
    coverageRadius: "10",
    coverageZones: [],
    availableDays: [],
    workingHours: { start: "08:00", end: "18:00" }
  });

  const handleFileUpload = (type: "document" | "photo") => {
    // Simular subida de archivo
    const newFile: DocumentFile = {
      id: Date.now().toString(),
      name: type === "photo" ? "foto_perfil.jpg" : `documento_${documents.length + 1}.pdf`,
      type: type === "photo" ? "image/jpeg" : "application/pdf",
      status: "uploading",
      progress: 0
    };

    if (type === "photo") {
      setProfilePhoto(newFile);
      // Simular progreso
      setTimeout(() => setProfilePhoto(prev => prev ? { ...prev, progress: 50 } : null), 500);
      setTimeout(() => setProfilePhoto(prev => prev ? { ...prev, status: "uploaded", progress: 100 } : null), 1000);
    } else {
      setDocuments(prev => [...prev, newFile]);
      // Simular progreso
      setTimeout(() => {
        setDocuments(prev => prev.map(d => d.id === newFile.id ? { ...d, progress: 50 } : d));
      }, 500);
      setTimeout(() => {
        setDocuments(prev => prev.map(d => d.id === newFile.id ? { ...d, status: "uploaded", progress: 100 } : d));
      }, 1000);
    }
  };

  const removeDocument = (id: string) => {
    setDocuments(prev => prev.filter(d => d.id !== id));
  };

  const toggleService = (service: string) => {
    setFormData(prev => ({
      ...prev,
      services: prev.services.includes(service)
        ? prev.services.filter(s => s !== service)
        : [...prev.services, service]
    }));
  };

  const toggleDay = (day: string) => {
    setFormData(prev => ({
      ...prev,
      availableDays: prev.availableDays.includes(day)
        ? prev.availableDays.filter(d => d !== day)
        : [...prev.availableDays, day]
    }));
  };

  const toggleZone = (zone: string) => {
    setFormData(prev => ({
      ...prev,
      coverageZones: prev.coverageZones.includes(zone)
        ? prev.coverageZones.filter(z => z !== zone)
        : [...prev.coverageZones, zone]
    }));
  };

  const nextStep = () => {
    if (currentStep < 5) setCurrentStep((currentStep + 1) as Step);
  };

  const prevStep = () => {
    if (currentStep > 1) setCurrentStep((currentStep - 1) as Step);
  };

  const handleSubmit = () => {
    // Navegar a pantalla de confirmacion
    navigate("/professional-pending");
  };

  const steps = [
    { number: 1, title: "Personal", icon: User },
    { number: 2, title: "Profesional", icon: Briefcase },
    { number: 3, title: "Documentos", icon: FileText },
    { number: 4, title: "Cobertura", icon: MapPin },
    { number: 5, title: "Disponibilidad", icon: Clock }
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-violet-600 to-purple-600 text-white p-4 pb-24">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate("/login")} className="p-2 hover:bg-white/10 rounded-full">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-semibold">Registro de Profesional</h1>
            <p className="text-violet-100 text-sm">Completa tu perfil para comenzar</p>
          </div>
        </div>

        {/* Progress Steps */}
        <div className="flex items-center justify-between px-2">
          {steps.map((step, index) => (
            <div key={step.number} className="flex items-center">
              <div className="flex flex-col items-center">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                  currentStep >= step.number 
                    ? "bg-white text-violet-600" 
                    : "bg-white/20 text-white"
                }`}>
                  {currentStep > step.number ? (
                    <CheckCircle2 className="w-5 h-5" />
                  ) : (
                    <step.icon className="w-5 h-5" />
                  )}
                </div>
                <span className="text-xs mt-1 text-white/80">{step.title}</span>
              </div>
              {index < steps.length - 1 && (
                <div className={`w-8 h-0.5 mx-1 ${
                  currentStep > step.number ? "bg-white" : "bg-white/20"
                }`} />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Form Content */}
      <div className="bg-white rounded-t-3xl -mt-16 min-h-[calc(100vh-180px)] p-6">
        {/* Step 1: Personal Info */}
        {currentStep === 1 && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Informacion Personal</h2>
            
            {/* Profile Photo */}
            <div className="flex flex-col items-center mb-6">
              <div className="relative">
                <div className="w-24 h-24 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden border-4 border-violet-100">
                  {profilePhoto?.status === "uploaded" ? (
                    <div className="w-full h-full bg-violet-200 flex items-center justify-center">
                      <CheckCircle2 className="w-8 h-8 text-violet-600" />
                    </div>
                  ) : (
                    <User className="w-10 h-10 text-gray-400" />
                  )}
                </div>
                <button 
                  onClick={() => handleFileUpload("photo")}
                  className="absolute bottom-0 right-0 w-8 h-8 bg-violet-600 rounded-full flex items-center justify-center text-white shadow-lg"
                >
                  <Camera className="w-4 h-4" />
                </button>
              </div>
              <span className="text-sm text-gray-500 mt-2">Foto de perfil</span>
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-1 block">Nombre completo</label>
              <input
                type="text"
                value={formData.fullName}
                onChange={(e) => setFormData({...formData, fullName: e.target.value})}
                placeholder="Juan Carlos Perez"
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
              />
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-1 block">Correo electronico</label>
              <input
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                placeholder="correo@ejemplo.com"
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
              />
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-1 block">Telefono</label>
              <input
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({...formData, phone: e.target.value})}
                placeholder="+57 300 123 4567"
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-sm text-gray-700 mb-1 block">Fecha de nacimiento</label>
                <input
                  type="date"
                  value={formData.dateOfBirth}
                  onChange={(e) => setFormData({...formData, dateOfBirth: e.target.value})}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
              </div>
              <div>
                <label className="text-sm text-gray-700 mb-1 block">Documento ID</label>
                <input
                  type="text"
                  value={formData.documentId}
                  onChange={(e) => setFormData({...formData, documentId: e.target.value})}
                  placeholder="1234567890"
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
              </div>
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-1 block">Direccion</label>
              <input
                type="text"
                value={formData.address}
                onChange={(e) => setFormData({...formData, address: e.target.value})}
                placeholder="Calle 123 #45-67, Ciudad"
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
              />
            </div>
          </div>
        )}

        {/* Step 2: Professional Info */}
        {currentStep === 2 && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Informacion Profesional</h2>
            
            <div>
              <label className="text-sm text-gray-700 mb-1 block">Especialidad principal</label>
              <select
                value={formData.specialty}
                onChange={(e) => setFormData({...formData, specialty: e.target.value})}
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
              >
                <option value="">Selecciona una especialidad</option>
                {SPECIALTIES.map(spec => (
                  <option key={spec} value={spec}>{spec}</option>
                ))}
              </select>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-sm text-gray-700 mb-1 block">No. de licencia</label>
                <input
                  type="text"
                  value={formData.licenseNumber}
                  onChange={(e) => setFormData({...formData, licenseNumber: e.target.value})}
                  placeholder="LIC-12345"
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
              </div>
              <div>
                <label className="text-sm text-gray-700 mb-1 block">Anos de experiencia</label>
                <input
                  type="number"
                  value={formData.yearsExperience}
                  onChange={(e) => setFormData({...formData, yearsExperience: e.target.value})}
                  placeholder="5"
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
              </div>
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-1 block">Biografia profesional</label>
              <textarea
                value={formData.bio}
                onChange={(e) => setFormData({...formData, bio: e.target.value})}
                placeholder="Describe tu experiencia y enfoque profesional..."
                rows={3}
                className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none resize-none"
              />
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-2 block">Servicios que ofreces</label>
              <div className="flex flex-wrap gap-2">
                {SERVICES.map(service => (
                  <button
                    key={service}
                    onClick={() => toggleService(service)}
                    className={`px-3 py-2 rounded-full text-sm transition-colors ${
                      formData.services.includes(service)
                        ? "bg-violet-600 text-white"
                        : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                    }`}
                  >
                    {service}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Step 3: Documents */}
        {currentStep === 3 && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-2">Documentos de Verificacion</h2>
            <p className="text-sm text-gray-500 mb-4">
              Sube los siguientes documentos para verificar tu identidad y credenciales profesionales.
            </p>

            {/* Required Documents List */}
            <div className="space-y-3">
              <DocumentUploadCard
                title="Documento de identidad"
                description="Cedula o pasaporte (ambas caras)"
                icon={<Shield className="w-5 h-5" />}
                required
                onUpload={() => handleFileUpload("document")}
                uploaded={documents.length > 0}
              />
              <DocumentUploadCard
                title="Titulo profesional"
                description="Diploma o certificado de grado"
                icon={<GraduationCap className="w-5 h-5" />}
                required
                onUpload={() => handleFileUpload("document")}
                uploaded={documents.length > 1}
              />
              <DocumentUploadCard
                title="Tarjeta profesional"
                description="Licencia para ejercer"
                icon={<Briefcase className="w-5 h-5" />}
                required
                onUpload={() => handleFileUpload("document")}
                uploaded={documents.length > 2}
              />
              <DocumentUploadCard
                title="Certificado de antecedentes"
                description="Vigencia menor a 3 meses"
                icon={<FileText className="w-5 h-5" />}
                required
                onUpload={() => handleFileUpload("document")}
                uploaded={documents.length > 3}
              />
              <DocumentUploadCard
                title="Certificaciones adicionales"
                description="Cursos, especializaciones (opcional)"
                icon={<GraduationCap className="w-5 h-5" />}
                onUpload={() => handleFileUpload("document")}
                uploaded={documents.length > 4}
              />
            </div>

            {/* Uploaded Documents */}
            {documents.length > 0 && (
              <div className="mt-6">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Documentos subidos</h3>
                <div className="space-y-2">
                  {documents.map(doc => (
                    <div key={doc.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-violet-100 rounded-lg flex items-center justify-center">
                          <FileText className="w-5 h-5 text-violet-600" />
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">{doc.name}</p>
                          <p className="text-xs text-gray-500">
                            {doc.status === "uploading" ? `Subiendo... ${doc.progress}%` : "Subido correctamente"}
                          </p>
                        </div>
                      </div>
                      {doc.status === "uploaded" && (
                        <div className="flex items-center gap-2">
                          <CheckCircle2 className="w-5 h-5 text-green-500" />
                          <button onClick={() => removeDocument(doc.id)} className="p-1 hover:bg-gray-200 rounded">
                            <X className="w-4 h-4 text-gray-400" />
                          </button>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Info Alert */}
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3">
              <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm text-amber-800 font-medium">Importante</p>
                <p className="text-xs text-amber-700 mt-1">
                  Tus documentos seran revisados por nuestro equipo en un plazo de 24-48 horas. 
                  Te notificaremos cuando tu cuenta sea aprobada.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Step 4: Coverage */}
        {currentStep === 4 && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Area de Cobertura</h2>
            
            <div>
              <label className="text-sm text-gray-700 mb-2 block">Tipo de cobertura</label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  onClick={() => setFormData({...formData, coverageType: "radius"})}
                  className={`p-4 rounded-xl border-2 flex flex-col items-center gap-2 transition-colors ${
                    formData.coverageType === "radius"
                      ? "border-violet-600 bg-violet-50"
                      : "border-gray-200"
                  }`}
                >
                  <div className="w-12 h-12 rounded-full bg-violet-100 flex items-center justify-center">
                    <MapPin className="w-6 h-6 text-violet-600" />
                  </div>
                  <span className="text-sm font-medium">Por radio</span>
                  <span className="text-xs text-gray-500">Km desde tu ubicacion</span>
                </button>
                <button
                  onClick={() => setFormData({...formData, coverageType: "zones"})}
                  className={`p-4 rounded-xl border-2 flex flex-col items-center gap-2 transition-colors ${
                    formData.coverageType === "zones"
                      ? "border-violet-600 bg-violet-50"
                      : "border-gray-200"
                  }`}
                >
                  <div className="w-12 h-12 rounded-full bg-violet-100 flex items-center justify-center">
                    <MapPin className="w-6 h-6 text-violet-600" />
                  </div>
                  <span className="text-sm font-medium">Por zonas</span>
                  <span className="text-xs text-gray-500">Sectores especificos</span>
                </button>
              </div>
            </div>

            {formData.coverageType === "radius" ? (
              <div>
                <label className="text-sm text-gray-700 mb-2 block">
                  Radio de cobertura: {formData.coverageRadius} km
                </label>
                <input
                  type="range"
                  min="5"
                  max="50"
                  value={formData.coverageRadius}
                  onChange={(e) => setFormData({...formData, coverageRadius: e.target.value})}
                  className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-violet-600"
                />
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>5 km</span>
                  <span>50 km</span>
                </div>
              </div>
            ) : (
              <div>
                <label className="text-sm text-gray-700 mb-2 block">Selecciona las zonas</label>
                <div className="flex flex-wrap gap-2">
                  {ZONES.map(zone => (
                    <button
                      key={zone}
                      onClick={() => toggleZone(zone)}
                      className={`px-4 py-2 rounded-full text-sm transition-colors ${
                        formData.coverageZones.includes(zone)
                          ? "bg-violet-600 text-white"
                          : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                      }`}
                    >
                      {zone}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Map Placeholder */}
            <div className="h-48 bg-gray-100 rounded-xl flex items-center justify-center border-2 border-dashed border-gray-300">
              <div className="text-center">
                <MapPin className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                <p className="text-sm text-gray-500">Vista previa del mapa</p>
              </div>
            </div>
          </div>
        )}

        {/* Step 5: Availability */}
        {currentStep === 5 && (
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Disponibilidad</h2>
            
            <div>
              <label className="text-sm text-gray-700 mb-2 block">Dias disponibles</label>
              <div className="grid grid-cols-4 gap-2">
                {DAYS.map(day => (
                  <button
                    key={day}
                    onClick={() => toggleDay(day)}
                    className={`px-3 py-2 rounded-xl text-sm transition-colors ${
                      formData.availableDays.includes(day)
                        ? "bg-violet-600 text-white"
                        : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                    }`}
                  >
                    {day.substring(0, 3)}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-2 block">Horario de trabajo</label>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <span className="text-xs text-gray-500 mb-1 block">Desde</span>
                  <input
                    type="time"
                    value={formData.workingHours.start}
                    onChange={(e) => setFormData({
                      ...formData, 
                      workingHours: {...formData.workingHours, start: e.target.value}
                    })}
                    className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                  />
                </div>
                <div>
                  <span className="text-xs text-gray-500 mb-1 block">Hasta</span>
                  <input
                    type="time"
                    value={formData.workingHours.end}
                    onChange={(e) => setFormData({
                      ...formData, 
                      workingHours: {...formData.workingHours, end: e.target.value}
                    })}
                    className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                  />
                </div>
              </div>
            </div>

            {/* Summary Card */}
            <div className="bg-violet-50 rounded-xl p-4 mt-6">
              <h3 className="text-sm font-semibold text-violet-900 mb-3">Resumen de tu perfil</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Especialidad</span>
                  <span className="text-gray-900">{formData.specialty || "No seleccionada"}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Servicios</span>
                  <span className="text-gray-900">{formData.services.length} seleccionados</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Cobertura</span>
                  <span className="text-gray-900">
                    {formData.coverageType === "radius" 
                      ? `${formData.coverageRadius} km` 
                      : `${formData.coverageZones.length} zonas`}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Documentos</span>
                  <span className="text-gray-900">{documents.length} subidos</span>
                </div>
              </div>
            </div>

            {/* Terms */}
            <label className="flex items-start gap-2 text-sm text-gray-600">
              <input 
                type="checkbox" 
                className="w-4 h-4 rounded border-gray-300 text-violet-600 focus:ring-violet-500 mt-0.5" 
              />
              <span>
                Declaro que la informacion proporcionada es veridica y acepto los{" "}
                <button type="button" className="text-violet-600 underline">terminos y condiciones</button>
                {" "}para profesionales.
              </span>
            </label>
          </div>
        )}

        {/* Navigation Buttons */}
        <div className="flex gap-3 mt-8 pt-4 border-t border-gray-100">
          {currentStep > 1 && (
            <button
              onClick={prevStep}
              className="flex-1 py-3.5 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 transition-colors flex items-center justify-center gap-2"
            >
              <ArrowLeft className="w-4 h-4" />
              Anterior
            </button>
          )}
          {currentStep < 5 ? (
            <button
              onClick={nextStep}
              className="flex-1 bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3.5 rounded-xl hover:from-violet-700 hover:to-purple-700 transition-all shadow-lg shadow-violet-500/30 flex items-center justify-center gap-2"
            >
              Siguiente
              <ArrowRight className="w-4 h-4" />
            </button>
          ) : (
            <button
              onClick={handleSubmit}
              className="flex-1 bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3.5 rounded-xl hover:from-violet-700 hover:to-purple-700 transition-all shadow-lg shadow-violet-500/30"
            >
              Enviar solicitud
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

// Document Upload Card Component
function DocumentUploadCard({ 
  title, 
  description, 
  icon, 
  required, 
  onUpload,
  uploaded 
}: { 
  title: string;
  description: string;
  icon: React.ReactNode;
  required?: boolean;
  onUpload: () => void;
  uploaded?: boolean;
}) {
  return (
    <div className={`p-4 rounded-xl border-2 border-dashed transition-colors ${
      uploaded ? "border-green-300 bg-green-50" : "border-gray-200 hover:border-violet-300"
    }`}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
            uploaded ? "bg-green-100 text-green-600" : "bg-violet-100 text-violet-600"
          }`}>
            {uploaded ? <CheckCircle2 className="w-5 h-5" /> : icon}
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">
              {title}
              {required && <span className="text-red-500 ml-1">*</span>}
            </p>
            <p className="text-xs text-gray-500">{description}</p>
          </div>
        </div>
        {!uploaded && (
          <button 
            onClick={onUpload}
            className="p-2 bg-violet-100 rounded-lg text-violet-600 hover:bg-violet-200 transition-colors"
          >
            <Upload className="w-5 h-5" />
          </button>
        )}
      </div>
    </div>
  );
}
