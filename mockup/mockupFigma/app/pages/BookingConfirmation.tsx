import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router";
import { CheckCircle2, Clock, Calendar, MapPin, User, Phone, Mail, X } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana María García",
  specialty: "Enfermería General",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  phone: "+57 300 123 4567",
  email: "ana.garcia@nexuly.com",
  rating: 4.9,
  experience: 8
};

const bookingData = {
  date: "24 Mar 2026",
  time: "10:00 AM",
  address: "Calle 15 #12-34, Valledupar",
  service: "Aplicación de inyecciones",
  additionalServices: ["Toma de signos vitales"],
  notes: "Aplicación de vitamina B12",
  totalPrice: 65000
};

type BookingStatus = "pending" | "accepted" | "rejected";

export function BookingConfirmation() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<BookingStatus>("pending");
  const [showRejectionModal, setShowRejectionModal] = useState(false);

  // Simular respuesta del profesional después de 3 segundos
  useEffect(() => {
    const timer = setTimeout(() => {
      // 90% de probabilidad de aceptación
      const isAccepted = Math.random() > 0.1;
      setStatus(isAccepted ? "accepted" : "rejected");
      
      if (!isAccepted) {
        setShowRejectionModal(true);
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

  // Si es aceptado, redirigir automáticamente después de 2 segundos
  useEffect(() => {
    if (status === "accepted") {
      const timer = setTimeout(() => {
        navigate(`/active-service/${id}`);
      }, 2000);

      return () => clearTimeout(timer);
    }
  }, [status, id, navigate]);

  const handleFindAlternative = () => {
    navigate("/search");
  };

  if (showRejectionModal && status === "rejected") {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl p-6 max-w-md w-full border border-gray-200">
          <div className="text-center mb-6">
            <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <X className="w-8 h-8 text-red-600" />
            </div>
            <h2 className="text-lg text-gray-900 mb-2">Profesional no disponible</h2>
            <p className="text-sm text-gray-600">
              Lo sentimos, {professionalData.name} no está disponible en este momento.
            </p>
          </div>

          <div className="bg-violet-50 rounded-xl p-4 mb-6 border border-violet-100">
            <h3 className="text-sm text-gray-900 mb-2">¿Qué te gustaría hacer?</h3>
            <p className="text-xs text-gray-600 mb-3">
              Encontramos 12 profesionales similares disponibles en tu zona
            </p>
          </div>

          <div className="space-y-3">
            <button
              onClick={handleFindAlternative}
              className="w-full py-3 rounded-xl bg-violet-600 text-white"
            >
              Ver profesionales disponibles
            </button>
            <button
              onClick={() => navigate("/history")}
              className="w-full py-3 rounded-xl border border-gray-300 text-gray-700"
            >
              Ir a mis citas
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-md mx-auto space-y-6 py-6">
        {/* Success Header */}
        <div className="text-center">
          <div className={`w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 transition-all duration-500 ${
            status === "accepted" ? "bg-green-100" : "bg-violet-100"
          }`}>
            {status === "accepted" ? (
              <CheckCircle2 className="w-10 h-10 text-green-600" />
            ) : (
              <Clock className="w-10 h-10 text-violet-600 animate-pulse" />
            )}
          </div>
          <h1 className="text-xl mb-2 text-gray-900">
            {status === "pending" && "Solicitud enviada"}
            {status === "accepted" && "¡Reserva confirmada!"}
          </h1>
          <p className="text-sm text-gray-600">
            {status === "pending" && "Esperando confirmación del profesional..."}
            {status === "accepted" && "El profesional aceptó tu solicitud"}
          </p>
        </div>

        {/* Professional Info */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-3 mb-4">
            <ImageWithFallback 
              src={professionalData.image}
              alt={professionalData.name}
              className="w-16 h-16 rounded-xl object-cover"
            />
            <div>
              <h2 className="text-base text-gray-900">{professionalData.name}</h2>
              <p className="text-sm text-gray-600">{professionalData.specialty}</p>
              <div className="flex items-center gap-2 mt-1">
                <div className="flex items-center gap-1">
                  <span className="text-sm text-yellow-500">★</span>
                  <span className="text-sm text-gray-700">{professionalData.rating}</span>
                </div>
                <span className="text-gray-300">•</span>
                <span className="text-sm text-gray-600">{professionalData.experience} años</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <a 
              href={`tel:${professionalData.phone}`}
              className="flex items-center justify-center gap-2 py-2 rounded-lg border border-gray-300 text-gray-700 text-sm"
            >
              <Phone className="w-4 h-4" />
              Llamar
            </a>
            <a 
              href={`mailto:${professionalData.email}`}
              className="flex items-center justify-center gap-2 py-2 rounded-lg border border-gray-300 text-gray-700 text-sm"
            >
              <Mail className="w-4 h-4" />
              Email
            </a>
          </div>
        </div>

        {/* Booking Details */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h3 className="text-base mb-3 text-gray-900">Detalles de la reserva</h3>
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <Calendar className="w-5 h-5 text-violet-600 mt-0.5" />
              <div>
                <p className="text-sm text-gray-900">{bookingData.date}</p>
                <p className="text-xs text-gray-600">{bookingData.time}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <MapPin className="w-5 h-5 text-violet-600 mt-0.5" />
              <div>
                <p className="text-sm text-gray-900">{bookingData.address}</p>
                <p className="text-xs text-gray-600">Servicio a domicilio</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <User className="w-5 h-5 text-violet-600 mt-0.5" />
              <div>
                <p className="text-sm text-gray-900">{bookingData.service}</p>
                {bookingData.additionalServices.length > 0 && (
                  <p className="text-xs text-gray-600">
                    + {bookingData.additionalServices.join(", ")}
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Notes */}
        {bookingData.notes && (
          <div className="bg-violet-50 rounded-2xl p-4 border border-violet-100">
            <h3 className="text-sm text-gray-900 mb-2">Notas adicionales</h3>
            <p className="text-sm text-gray-700">{bookingData.notes}</p>
          </div>
        )}

        {/* Total */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between">
            <span className="text-base text-gray-900">Total a pagar</span>
            <span className="text-xl text-violet-600">${bookingData.totalPrice.toLocaleString()}</span>
          </div>
          <p className="text-xs text-gray-600 mt-2">Pago en efectivo al finalizar el servicio</p>
        </div>

        {/* Status Message */}
        {status === "pending" && (
          <div className="bg-gradient-to-br from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-100">
            <div className="flex items-start gap-3">
              <Clock className="w-5 h-5 text-violet-600 mt-0.5 flex-shrink-0" />
              <div>
                <p className="text-sm text-gray-900 mb-1">Tiempo estimado de respuesta</p>
                <p className="text-xs text-gray-600">
                  El profesional tiene hasta 10 minutos para aceptar tu solicitud. Te notificaremos cuando confirme.
                </p>
              </div>
            </div>
          </div>
        )}

        {status === "accepted" && (
          <div className="bg-green-50 rounded-2xl p-4 border border-green-200">
            <div className="flex items-start gap-3">
              <CheckCircle2 className="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
              <div>
                <p className="text-sm text-gray-900 mb-1">¡Excelente!</p>
                <p className="text-xs text-gray-600">
                  {professionalData.name} confirmó tu reserva. Te redirigiremos al seguimiento en tiempo real...
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="space-y-3">
          {status === "accepted" ? (
            <button
              onClick={() => navigate(`/active-service/${id}`)}
              className="w-full py-3 rounded-xl bg-violet-600 text-white"
            >
              Ver seguimiento en tiempo real
            </button>
          ) : (
            <>
              <button
                onClick={() => navigate("/history")}
                className="w-full py-3 rounded-xl border border-gray-300 text-gray-700"
              >
                Ver mis citas
              </button>
              <button
                onClick={() => navigate("/")}
                className="w-full py-3 rounded-xl border border-gray-300 text-gray-700"
              >
                Volver al inicio
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
