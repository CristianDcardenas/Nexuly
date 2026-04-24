import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { Calendar as CalendarIcon, Clock, MapPin, ChevronLeft, ChevronRight, Check } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana María García",
  specialty: "Enfermería General",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  price: 50000
};

const timeSlots = [
  { time: "08:00 AM", available: true },
  { time: "09:00 AM", available: true },
  { time: "10:00 AM", available: false },
  { time: "11:00 AM", available: true },
  { time: "12:00 PM", available: true },
  { time: "01:00 PM", available: false },
  { time: "02:00 PM", available: true },
  { time: "03:00 PM", available: true },
  { time: "04:00 PM", available: true },
  { time: "05:00 PM", available: false },
  { time: "06:00 PM", available: true }
];

const services = [
  { id: "injection", name: "Aplicación de inyecciones", price: 15000 },
  { id: "vitals", name: "Toma de signos vitales", price: 10000 },
  { id: "wound", name: "Curaciones", price: 20000 },
  { id: "medication", name: "Administración de medicamentos", price: 15000 },
  { id: "iv", name: "Terapia intravenosa", price: 30000 }
];

export function Booking() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [currentMonth, setCurrentMonth] = useState(new Date(2026, 2)); // March 2026
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);
  const [selectedServices, setSelectedServices] = useState<string[]>([]);
  const [address, setAddress] = useState("");
  const [notes, setNotes] = useState("");

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    const days = [];
    
    // Add empty cells for days before the first day of the month
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }
    
    // Add the days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(new Date(year, month, day));
    }
    
    return days;
  };

  const monthNames = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];

  const isDateAvailable = (date: Date | null) => {
    if (!date) return false;
    const today = new Date(2026, 2, 22); // March 22, 2026
    return date >= today;
  };

  const toggleService = (serviceId: string) => {
    setSelectedServices(prev => 
      prev.includes(serviceId) 
        ? prev.filter(id => id !== serviceId)
        : [...prev, serviceId]
    );
  };

  const getTotalPrice = () => {
    const servicesCost = selectedServices.reduce((total, serviceId) => {
      const service = services.find(s => s.id === serviceId);
      return total + (service?.price || 0);
    }, 0);
    return professionalData.price + servicesCost;
  };

  const handleConfirmBooking = () => {
    navigate(`/booking-confirmation/${id}`);
  };

  return (
    <div className="p-4 space-y-6 pb-32">
      {/* Professional Info */}
      <div className="bg-white rounded-2xl p-4 border border-gray-200">
        <div className="flex items-center gap-3">
          <ImageWithFallback 
            src={professionalData.image}
            alt={professionalData.name}
            className="w-16 h-16 rounded-xl object-cover"
          />
          <div>
            <h2 className="text-base text-gray-900">{professionalData.name}</h2>
            <p className="text-sm text-gray-600">{professionalData.specialty}</p>
            <p className="text-sm text-violet-600 mt-1">${professionalData.price.toLocaleString()}/hora</p>
          </div>
        </div>
      </div>

      {/* Calendar */}
      <div className="bg-white rounded-2xl p-4 border border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base text-gray-900">Selecciona una fecha</h2>
          <div className="flex items-center gap-2">
            <button 
              onClick={() => setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1))}
              className="p-1 rounded-lg hover:bg-gray-100"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            <span className="text-sm font-medium min-w-[120px] text-center">
              {monthNames[currentMonth.getMonth()]} {currentMonth.getFullYear()}
            </span>
            <button 
              onClick={() => setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1))}
              className="p-1 rounded-lg hover:bg-gray-100"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Calendar Grid */}
        <div className="grid grid-cols-7 gap-1">
          {["D", "L", "M", "M", "J", "V", "S"].map((day, index) => (
            <div key={index} className="text-center text-xs text-gray-500 py-2">
              {day}
            </div>
          ))}
          {getDaysInMonth(currentMonth).map((date, index) => {
            const isAvailable = isDateAvailable(date);
            const isSelected = date && selectedDate && 
              date.toDateString() === selectedDate.toDateString();

            return (
              <button
                key={index}
                onClick={() => date && isAvailable && setSelectedDate(date)}
                disabled={!date || !isAvailable}
                className={`
                  aspect-square rounded-lg text-sm
                  ${!date ? 'invisible' : ''}
                  ${!isAvailable ? 'text-gray-300 cursor-not-allowed' : ''}
                  ${isSelected ? 'bg-violet-600 text-white' : ''}
                  ${isAvailable && !isSelected ? 'hover:bg-violet-50 text-gray-900' : ''}
                `}
              >
                {date?.getDate()}
              </button>
            );
          })}
        </div>
      </div>

      {/* Time Slots */}
      {selectedDate && (
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Selecciona una hora</h2>
          <div className="grid grid-cols-3 gap-2">
            {timeSlots.map((slot) => (
              <button
                key={slot.time}
                onClick={() => slot.available && setSelectedTime(slot.time)}
                disabled={!slot.available}
                className={`
                  py-2 px-3 rounded-lg text-sm
                  ${!slot.available ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : ''}
                  ${selectedTime === slot.time ? 'bg-violet-600 text-white' : ''}
                  ${slot.available && selectedTime !== slot.time ? 'border border-gray-300 hover:border-violet-600' : ''}
                `}
              >
                {slot.time}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Services */}
      {selectedTime && (
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Servicios adicionales (opcional)</h2>
          <div className="space-y-2">
            {services.map((service) => (
              <button
                key={service.id}
                onClick={() => toggleService(service.id)}
                className={`
                  w-full flex items-center justify-between p-3 rounded-xl border-2 transition-colors
                  ${selectedServices.includes(service.id) 
                    ? 'border-violet-600 bg-violet-50' 
                    : 'border-gray-200 hover:border-violet-300'
                  }
                `}
              >
                <div className="text-left">
                  <p className="text-sm text-gray-900">{service.name}</p>
                  <p className="text-xs text-gray-600">+${service.price.toLocaleString()}</p>
                </div>
                <div className={`
                  w-5 h-5 rounded-full border-2 flex items-center justify-center
                  ${selectedServices.includes(service.id) 
                    ? 'border-violet-600 bg-violet-600' 
                    : 'border-gray-300'
                  }
                `}>
                  {selectedServices.includes(service.id) && (
                    <Check className="w-3 h-3 text-white" />
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Address */}
      {selectedTime && (
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Dirección</h2>
          <div className="flex items-start gap-2">
            <MapPin className="w-5 h-5 text-gray-400 mt-2" />
            <input
              type="text"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              placeholder="Ingresa tu dirección completa"
              className="flex-1 py-2 px-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-500"
            />
          </div>
        </div>
      )}

      {/* Notes */}
      {selectedTime && (
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h2 className="text-base mb-3 text-gray-900">Notas adicionales (opcional)</h2>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Describe brevemente tu necesidad o alguna instrucción especial..."
            rows={4}
            className="w-full py-2 px-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-500 resize-none"
          />
        </div>
      )}

      {/* Confirmation Button */}
      {selectedDate && selectedTime && address && (
        <div className="fixed bottom-20 left-0 right-0 p-4 bg-white border-t border-gray-200">
          <div className="max-w-md mx-auto">
            <div className="flex items-center justify-between mb-3">
              <span className="text-sm text-gray-600">Total a pagar</span>
              <span className="text-xl text-gray-900">${getTotalPrice().toLocaleString()}</span>
            </div>
            <button
              onClick={handleConfirmBooking}
              className="w-full py-3 rounded-xl bg-violet-600 text-white"
            >
              Confirmar reserva
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
