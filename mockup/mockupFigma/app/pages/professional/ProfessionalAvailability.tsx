import { useState } from "react";
import { 
  Clock, 
  Calendar,
  ToggleLeft,
  ToggleRight,
  AlertCircle,
  CheckCircle2,
  Plus,
  Trash2,
  Moon
} from "lucide-react";

interface TimeBlock {
  id: string;
  start: string;
  end: string;
}

interface DaySchedule {
  day: string;
  dayShort: string;
  isActive: boolean;
  blocks: TimeBlock[];
}

export function ProfessionalAvailability() {
  const [isAvailable, setIsAvailable] = useState(true);
  const [doNotDisturb, setDoNotDisturb] = useState(false);
  const [schedule, setSchedule] = useState<DaySchedule[]>([
    { day: "Lunes", dayShort: "L", isActive: true, blocks: [{ id: "1", start: "08:00", end: "12:00" }, { id: "2", start: "14:00", end: "18:00" }] },
    { day: "Martes", dayShort: "M", isActive: true, blocks: [{ id: "3", start: "08:00", end: "12:00" }, { id: "4", start: "14:00", end: "18:00" }] },
    { day: "Miercoles", dayShort: "X", isActive: true, blocks: [{ id: "5", start: "08:00", end: "12:00" }, { id: "6", start: "14:00", end: "18:00" }] },
    { day: "Jueves", dayShort: "J", isActive: true, blocks: [{ id: "7", start: "08:00", end: "12:00" }, { id: "8", start: "14:00", end: "18:00" }] },
    { day: "Viernes", dayShort: "V", isActive: true, blocks: [{ id: "9", start: "08:00", end: "17:00" }] },
    { day: "Sabado", dayShort: "S", isActive: true, blocks: [{ id: "10", start: "09:00", end: "13:00" }] },
    { day: "Domingo", dayShort: "D", isActive: false, blocks: [] },
  ]);

  const [editingDay, setEditingDay] = useState<string | null>(null);

  const toggleDay = (dayName: string) => {
    setSchedule(prev => prev.map(d => 
      d.day === dayName 
        ? { 
            ...d, 
            isActive: !d.isActive,
            blocks: !d.isActive ? [{ id: Date.now().toString(), start: "08:00", end: "18:00" }] : d.blocks
          } 
        : d
    ));
  };

  const addBlock = (dayName: string) => {
    setSchedule(prev => prev.map(d => 
      d.day === dayName 
        ? { 
            ...d, 
            blocks: [...d.blocks, { id: Date.now().toString(), start: "09:00", end: "17:00" }]
          } 
        : d
    ));
  };

  const removeBlock = (dayName: string, blockId: string) => {
    setSchedule(prev => prev.map(d => 
      d.day === dayName 
        ? { ...d, blocks: d.blocks.filter(b => b.id !== blockId) } 
        : d
    ));
  };

  const updateBlock = (dayName: string, blockId: string, field: "start" | "end", value: string) => {
    setSchedule(prev => prev.map(d => 
      d.day === dayName 
        ? { 
            ...d, 
            blocks: d.blocks.map(b => 
              b.id === blockId ? { ...b, [field]: value } : b
            )
          } 
        : d
    ));
  };

  const totalHours = schedule.reduce((acc, day) => {
    if (!day.isActive) return acc;
    return acc + day.blocks.reduce((blockAcc, block) => {
      const start = parseInt(block.start.split(":")[0]);
      const end = parseInt(block.end.split(":")[0]);
      return blockAcc + (end - start);
    }, 0);
  }, 0);

  const activeDays = schedule.filter(d => d.isActive).length;

  return (
    <div className="p-4 space-y-6 pb-24">
      {/* Header */}
      <div>
        <h1 className="text-xl font-semibold text-gray-900">Disponibilidad</h1>
        <p className="text-sm text-gray-500">Configura tu horario de atencion</p>
      </div>

      {/* Status Cards */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Disponible</span>
            <button onClick={() => setIsAvailable(!isAvailable)}>
              {isAvailable ? (
                <ToggleRight className="w-8 h-8 text-teal-600" />
              ) : (
                <ToggleLeft className="w-8 h-8 text-gray-400" />
              )}
            </button>
          </div>
          <p className="text-xs text-gray-500">
            {isAvailable ? "Recibes solicitudes" : "No recibes solicitudes"}
          </p>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">No molestar</span>
            <button onClick={() => setDoNotDisturb(!doNotDisturb)}>
              {doNotDisturb ? (
                <ToggleRight className="w-8 h-8 text-violet-600" />
              ) : (
                <ToggleLeft className="w-8 h-8 text-gray-400" />
              )}
            </button>
          </div>
          <p className="text-xs text-gray-500">
            {doNotDisturb ? "Notificaciones silenciadas" : "Notificaciones activas"}
          </p>
        </div>
      </div>

      {/* Summary */}
      <div className="bg-gradient-to-r from-teal-500 to-emerald-600 rounded-2xl p-4 text-white">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-teal-100 text-sm">Resumen semanal</p>
            <p className="text-2xl font-bold">{totalHours} horas</p>
          </div>
          <div className="text-right">
            <p className="text-teal-100 text-sm">Dias activos</p>
            <p className="text-2xl font-bold">{activeDays}/7</p>
          </div>
        </div>
      </div>

      {/* Quick Week View */}
      <div className="flex justify-between gap-2">
        {schedule.map((day) => (
          <button
            key={day.day}
            onClick={() => setEditingDay(editingDay === day.day ? null : day.day)}
            className={`flex-1 py-3 rounded-xl text-center transition-colors ${
              day.isActive 
                ? editingDay === day.day 
                  ? "bg-teal-600 text-white" 
                  : "bg-teal-100 text-teal-700"
                : "bg-gray-100 text-gray-400"
            }`}
          >
            <span className="text-sm font-medium">{day.dayShort}</span>
          </button>
        ))}
      </div>

      {/* Day Details */}
      <div className="space-y-3">
        {schedule.map((day) => (
          <div 
            key={day.day} 
            className={`bg-white rounded-2xl border overflow-hidden transition-all ${
              editingDay === day.day ? "border-teal-500" : "border-gray-200"
            }`}
          >
            <div 
              className="p-4 flex items-center justify-between cursor-pointer"
              onClick={() => setEditingDay(editingDay === day.day ? null : day.day)}
            >
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                  day.isActive ? "bg-teal-100" : "bg-gray-100"
                }`}>
                  <Calendar className={`w-5 h-5 ${day.isActive ? "text-teal-600" : "text-gray-400"}`} />
                </div>
                <div>
                  <p className={`font-medium ${day.isActive ? "text-gray-900" : "text-gray-400"}`}>
                    {day.day}
                  </p>
                  {day.isActive && day.blocks.length > 0 && (
                    <p className="text-xs text-gray-500">
                      {day.blocks.map(b => `${b.start} - ${b.end}`).join(", ")}
                    </p>
                  )}
                  {!day.isActive && (
                    <p className="text-xs text-gray-400">No disponible</p>
                  )}
                </div>
              </div>
              <button
                onClick={(e) => { e.stopPropagation(); toggleDay(day.day); }}
              >
                {day.isActive ? (
                  <ToggleRight className="w-8 h-8 text-teal-600" />
                ) : (
                  <ToggleLeft className="w-8 h-8 text-gray-400" />
                )}
              </button>
            </div>

            {/* Expanded Edit View */}
            {editingDay === day.day && day.isActive && (
              <div className="px-4 pb-4 border-t border-gray-100 pt-4 space-y-3">
                {day.blocks.map((block, index) => (
                  <div key={block.id} className="flex items-center gap-2">
                    <div className="flex-1 flex items-center gap-2 bg-gray-50 rounded-xl p-2">
                      <Clock className="w-4 h-4 text-gray-400" />
                      <input
                        type="time"
                        value={block.start}
                        onChange={(e) => updateBlock(day.day, block.id, "start", e.target.value)}
                        className="bg-transparent outline-none text-sm"
                      />
                      <span className="text-gray-400">-</span>
                      <input
                        type="time"
                        value={block.end}
                        onChange={(e) => updateBlock(day.day, block.id, "end", e.target.value)}
                        className="bg-transparent outline-none text-sm"
                      />
                    </div>
                    {day.blocks.length > 1 && (
                      <button
                        onClick={() => removeBlock(day.day, block.id)}
                        className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                ))}
                <button
                  onClick={() => addBlock(day.day)}
                  className="w-full py-2 border-2 border-dashed border-gray-300 rounded-xl text-gray-500 text-sm flex items-center justify-center gap-2 hover:border-teal-500 hover:text-teal-600 transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  Agregar bloque horario
                </button>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Info */}
      <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3">
        <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
        <div>
          <p className="text-sm text-amber-800 font-medium">Horarios flexibles</p>
          <p className="text-xs text-amber-700 mt-1">
            Puedes agregar multiples bloques horarios por dia. Los usuarios solo veran 
            disponibilidad dentro de estos horarios al reservar.
          </p>
        </div>
      </div>

      {/* Vacation Mode */}
      <div className="bg-white rounded-2xl p-4 border border-gray-200">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-violet-100 rounded-lg flex items-center justify-center">
            <Moon className="w-5 h-5 text-violet-600" />
          </div>
          <div className="flex-1">
            <p className="font-medium text-gray-900">Modo vacaciones</p>
            <p className="text-xs text-gray-500">Pausar todas las solicitudes temporalmente</p>
          </div>
          <button className="px-4 py-2 border border-violet-600 text-violet-600 rounded-xl text-sm hover:bg-violet-50 transition-colors">
            Configurar
          </button>
        </div>
      </div>

      {/* Save Button */}
      <button className="w-full py-3 bg-teal-600 text-white rounded-xl font-medium hover:bg-teal-700 transition-colors flex items-center justify-center gap-2">
        <CheckCircle2 className="w-5 h-5" />
        Guardar cambios
      </button>
    </div>
  );
}
