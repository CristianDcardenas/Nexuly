import { useState } from "react";
import { Link } from "react-router";
import { Calendar, Clock, MapPin, MessageSquare, Star, ChevronRight, FileText, Activity } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const appointments = [
  {
    id: 1,
    professional: {
      name: "Dra. Ana María García",
      specialty: "Enfermería General",
      image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080"
    },
    date: "24 Mar 2026",
    time: "10:00 AM",
    status: "upcoming",
    service: "Aplicación de inyecciones",
    address: "Calle 15 #12-34, Valledupar",
    notes: "Aplicación de vitamina B12",
    tracking: {
      lastVisit: "18 Mar 2026",
      nextVisit: "24 Mar 2026",
      observations: "Paciente responde bien al tratamiento. Continuar con aplicaciones semanales.",
      vitals: {
        pressure: "120/80",
        temperature: "36.5°C",
        heartRate: "72 bpm"
      }
    }
  },
  {
    id: 2,
    professional: {
      name: "Lic. Carlos Mendoza",
      specialty: "Cuidado de Adultos Mayores",
      image: "https://images.unsplash.com/photo-1758206523685-6e69f80a11ba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbnVyc2UlMjBoZWFsdGhjYXJlfGVufDF8fHx8MTc3NDE4ODk3Nnww&ixlib=rb-4.1.0&q=80&w=1080"
    },
    date: "20 Mar 2026",
    time: "03:00 PM",
    status: "completed",
    service: "Acompañamiento terapéutico",
    address: "Av. Simón Bolívar #45-67, Valledupar",
    rating: 5,
    notes: "Acompañamiento para fisioterapia",
    tracking: {
      lastVisit: "20 Mar 2026",
      observations: "Paciente muestra mejoría en movilidad. Ejercicios completados satisfactoriamente.",
      vitals: {
        pressure: "130/85",
        temperature: "36.7°C",
        heartRate: "78 bpm"
      }
    }
  },
  {
    id: 3,
    professional: {
      name: "Ft. Laura Sánchez",
      specialty: "Fisioterapia",
      image: "https://images.unsplash.com/photo-1764314138160-5f04f4a50dae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNhbCUyMHRoZXJhcGlzdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzQyMjE5MzB8MA&ixlib=rb-4.1.0&q=80&w=1080"
    },
    date: "15 Mar 2026",
    time: "11:00 AM",
    status: "completed",
    service: "Sesión de fisioterapia",
    address: "Calle 20 #8-15, Valledupar",
    rating: 5,
    tracking: {
      lastVisit: "15 Mar 2026",
      observations: "Sesión enfocada en recuperación de movilidad de rodilla izquierda. Paciente presenta buena evolución.",
      recommendations: [
        "Continuar con ejercicios en casa",
        "Aplicar hielo 3 veces al día",
        "Evitar esfuerzos excesivos"
      ],
      vitals: {
        pressure: "118/78",
        temperature: "36.4°C",
        heartRate: "70 bpm"
      }
    }
  }
];

export function History() {
  const [selectedTab, setSelectedTab] = useState<"upcoming" | "completed">("upcoming");
  const [selectedAppointment, setSelectedAppointment] = useState<number | null>(null);

  const filteredAppointments = appointments.filter(apt => apt.status === selectedTab);
  const selectedApt = appointments.find(apt => apt.id === selectedAppointment);

  if (selectedAppointment && selectedApt) {
    return (
      <div className="p-4 space-y-4">
        {/* Header */}
        <button 
          onClick={() => setSelectedAppointment(null)}
          className="flex items-center gap-2 text-violet-600"
        >
          <ChevronRight className="w-5 h-5 rotate-180" />
          <span className="text-sm">Volver</span>
        </button>

        {/* Professional Info */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-3 mb-3">
            <ImageWithFallback 
              src={selectedApt.professional.image}
              alt={selectedApt.professional.name}
              className="w-16 h-16 rounded-xl object-cover"
            />
            <div>
              <h2 className="text-base text-gray-900">{selectedApt.professional.name}</h2>
              <p className="text-sm text-gray-600">{selectedApt.professional.specialty}</p>
            </div>
          </div>

          <div className="space-y-2 pt-3 border-t border-gray-100">
            <div className="flex items-center gap-2 text-sm">
              <Calendar className="w-4 h-4 text-gray-400" />
              <span className="text-gray-700">{selectedApt.date}</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Clock className="w-4 h-4 text-gray-400" />
              <span className="text-gray-700">{selectedApt.time}</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <MapPin className="w-4 h-4 text-gray-400" />
              <span className="text-gray-700">{selectedApt.address}</span>
            </div>
          </div>
        </div>

        {/* Tracking Information */}
        <div className="bg-gradient-to-br from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-100">
          <div className="flex items-center gap-2 mb-3">
            <Activity className="w-5 h-5 text-violet-600" />
            <h3 className="text-base text-gray-900">Seguimiento del Paciente</h3>
          </div>

          <div className="space-y-3">
            {selectedApt.tracking.nextVisit && (
              <div className="bg-white rounded-xl p-3">
                <p className="text-xs text-gray-600 mb-1">Próxima visita programada</p>
                <p className="text-sm text-gray-900">{selectedApt.tracking.nextVisit}</p>
              </div>
            )}

            <div className="bg-white rounded-xl p-3">
              <p className="text-xs text-gray-600 mb-1">Última visita</p>
              <p className="text-sm text-gray-900">{selectedApt.tracking.lastVisit}</p>
            </div>
          </div>
        </div>

        {/* Vital Signs */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h3 className="text-base mb-3 text-gray-900">Signos Vitales</h3>
          <div className="grid grid-cols-3 gap-3">
            <div className="text-center p-3 bg-red-50 rounded-xl">
              <p className="text-xs text-gray-600 mb-1">Presión</p>
              <p className="text-sm text-gray-900">{selectedApt.tracking.vitals.pressure}</p>
            </div>
            <div className="text-center p-3 bg-orange-50 rounded-xl">
              <p className="text-xs text-gray-600 mb-1">Temp.</p>
              <p className="text-sm text-gray-900">{selectedApt.tracking.vitals.temperature}</p>
            </div>
            <div className="text-center p-3 bg-pink-50 rounded-xl">
              <p className="text-xs text-gray-600 mb-1">Pulso</p>
              <p className="text-sm text-gray-900">{selectedApt.tracking.vitals.heartRate}</p>
            </div>
          </div>
        </div>

        {/* Observations */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-2 mb-3">
            <FileText className="w-5 h-5 text-gray-600" />
            <h3 className="text-base text-gray-900">Observaciones</h3>
          </div>
          <p className="text-sm text-gray-700 leading-relaxed">{selectedApt.tracking.observations}</p>
        </div>

        {/* Recommendations */}
        {selectedApt.tracking.recommendations && (
          <div className="bg-white rounded-2xl p-4 border border-gray-200">
            <h3 className="text-base mb-3 text-gray-900">Recomendaciones</h3>
            <div className="space-y-2">
              {selectedApt.tracking.recommendations.map((rec, index) => (
                <div key={index} className="flex items-start gap-2">
                  <div className="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <div className="w-2 h-2 bg-green-600 rounded-full" />
                  </div>
                  <p className="text-sm text-gray-700">{rec}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="grid grid-cols-2 gap-3">
          <Link 
            to={`/booking/${selectedApt.id}`}
            className="py-3 rounded-xl bg-violet-600 text-white text-center"
          >
            Programar nueva cita
          </Link>
          <Link 
            to={`/chat/${selectedApt.id}`}
            className="py-3 rounded-xl border border-violet-600 text-violet-600 text-center"
          >
            Contactar
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 space-y-4">
      {/* Header */}
      <div>
        <h1 className="text-xl mb-1 text-gray-900">Historial</h1>
        <p className="text-sm text-gray-600">Gestiona tus citas y seguimiento</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 bg-gray-100 p-1 rounded-xl">
        <button
          onClick={() => setSelectedTab("upcoming")}
          className={`flex-1 py-2 rounded-lg text-sm transition-colors ${
            selectedTab === "upcoming"
              ? "bg-white text-gray-900 shadow-sm"
              : "text-gray-600"
          }`}
        >
          Próximas ({appointments.filter(a => a.status === "upcoming").length})
        </button>
        <button
          onClick={() => setSelectedTab("completed")}
          className={`flex-1 py-2 rounded-lg text-sm transition-colors ${
            selectedTab === "completed"
              ? "bg-white text-gray-900 shadow-sm"
              : "text-gray-600"
          }`}
        >
          Completadas ({appointments.filter(a => a.status === "completed").length})
        </button>
      </div>

      {/* Appointments List */}
      <div className="space-y-3">
        {filteredAppointments.length === 0 ? (
          <div className="bg-white rounded-2xl p-8 border border-gray-200 text-center">
            <Calendar className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-sm text-gray-600">No hay citas {selectedTab === "upcoming" ? "próximas" : "completadas"}</p>
          </div>
        ) : (
          filteredAppointments.map((appointment) => (
            <div
              key={appointment.id}
              className="bg-white rounded-2xl p-4 border border-gray-200"
            >
              <div className="flex gap-3">
                <ImageWithFallback 
                  src={appointment.professional.image}
                  alt={appointment.professional.name}
                  className="w-20 h-20 rounded-xl object-cover flex-shrink-0"
                />
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <div className="flex-1 min-w-0">
                      <h3 className="text-sm truncate text-gray-900">{appointment.professional.name}</h3>
                      <p className="text-xs text-gray-600">{appointment.professional.specialty}</p>
                    </div>
                    {appointment.status === "upcoming" && (
                      <span className="px-2 py-0.5 rounded-full bg-violet-100 text-violet-700 text-xs whitespace-nowrap">
                        Próxima
                      </span>
                    )}
                  </div>

                  <div className="space-y-1 mb-3">
                    <div className="flex items-center gap-1 text-xs text-gray-600">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>{appointment.date}</span>
                      <span className="mx-1">•</span>
                      <Clock className="w-3.5 h-3.5" />
                      <span>{appointment.time}</span>
                    </div>
                    <div className="flex items-center gap-1 text-xs text-gray-600">
                      <FileText className="w-3.5 h-3.5" />
                      <span>{appointment.service}</span>
                    </div>
                  </div>

                  {appointment.status === "completed" && appointment.rating && (
                    <div className="flex items-center gap-0.5 mb-3">
                      {[...Array(5)].map((_, i) => (
                        <Star 
                          key={i}
                          className={`w-3.5 h-3.5 ${
                            i < appointment.rating! 
                              ? 'fill-yellow-400 text-yellow-400' 
                              : 'text-gray-300'
                          }`}
                        />
                      ))}
                    </div>
                  )}

                  <div className="flex gap-2">
                    <button
                      onClick={() => setSelectedAppointment(appointment.id)}
                      className="flex-1 py-2 rounded-lg bg-violet-600 text-white text-xs flex items-center justify-center gap-1"
                    >
                      <Activity className="w-3.5 h-3.5" />
                      Ver seguimiento
                    </button>
                    {appointment.status === "upcoming" && (
                      <Link 
                        to={`/chat/${appointment.id}`}
                        className="px-4 py-2 rounded-lg border border-gray-300 text-gray-700 text-xs flex items-center justify-center"
                      >
                        <MessageSquare className="w-3.5 h-3.5" />
                      </Link>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Quick Actions */}
      {selectedTab === "completed" && filteredAppointments.length > 0 && (
        <div className="bg-gradient-to-br from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-100">
          <h3 className="text-sm mb-2 text-gray-900">Continuidad de Cuidado</h3>
          <p className="text-xs text-gray-600 mb-3">
            Programa tu siguiente cita para mantener el seguimiento de tu tratamiento
          </p>
          <Link 
            to="/search"
            className="block w-full py-2 rounded-lg bg-violet-600 text-white text-sm text-center"
          >
            Buscar profesional
          </Link>
        </div>
      )}
    </div>
  );
}