import { useState } from "react";
import { 
  Plus, 
  Edit2, 
  Trash2, 
  DollarSign, 
  Clock,
  ToggleLeft,
  ToggleRight,
  AlertCircle,
  CheckCircle2,
  X
} from "lucide-react";

interface Service {
  id: string;
  name: string;
  description: string;
  category: string;
  price: number;
  duration: number;
  isActive: boolean;
}

const categories = [
  "Enfermeria",
  "Cuidado de adultos mayores",
  "Fisioterapia",
  "Control de signos vitales",
  "Aplicacion de medicamentos",
  "Cuidado post-operatorio",
  "Terapia respiratoria",
  "Acompanamiento hospitalario"
];

export function ProfessionalServices() {
  const [services, setServices] = useState<Service[]>([
    {
      id: "1",
      name: "Cuidado de adulto mayor",
      description: "Asistencia integral para adultos mayores incluyendo higiene personal, alimentacion y compania",
      category: "Cuidado de adultos mayores",
      price: 80000,
      duration: 240,
      isActive: true
    },
    {
      id: "2",
      name: "Control de signos vitales",
      description: "Medicion y registro de presion arterial, frecuencia cardiaca, temperatura y saturacion",
      category: "Control de signos vitales",
      price: 35000,
      duration: 60,
      isActive: true
    },
    {
      id: "3",
      name: "Aplicacion de inyecciones",
      description: "Administracion de medicamentos via intramuscular o subcutanea",
      category: "Aplicacion de medicamentos",
      price: 25000,
      duration: 30,
      isActive: true
    },
    {
      id: "4",
      name: "Curacion de heridas",
      description: "Limpieza y cuidado de heridas quirurgicas o accidentales",
      category: "Enfermeria",
      price: 45000,
      duration: 45,
      isActive: false
    }
  ]);

  const [showModal, setShowModal] = useState(false);
  const [editingService, setEditingService] = useState<Service | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    category: "",
    price: "",
    duration: ""
  });

  const openAddModal = () => {
    setEditingService(null);
    setFormData({ name: "", description: "", category: "", price: "", duration: "" });
    setShowModal(true);
  };

  const openEditModal = (service: Service) => {
    setEditingService(service);
    setFormData({
      name: service.name,
      description: service.description,
      category: service.category,
      price: service.price.toString(),
      duration: service.duration.toString()
    });
    setShowModal(true);
  };

  const handleSave = () => {
    if (editingService) {
      setServices(prev => prev.map(s => 
        s.id === editingService.id 
          ? {
              ...s,
              name: formData.name,
              description: formData.description,
              category: formData.category,
              price: parseInt(formData.price),
              duration: parseInt(formData.duration)
            }
          : s
      ));
    } else {
      const newService: Service = {
        id: Date.now().toString(),
        name: formData.name,
        description: formData.description,
        category: formData.category,
        price: parseInt(formData.price),
        duration: parseInt(formData.duration),
        isActive: true
      };
      setServices(prev => [...prev, newService]);
    }
    setShowModal(false);
  };

  const toggleService = (id: string) => {
    setServices(prev => prev.map(s => 
      s.id === id ? { ...s, isActive: !s.isActive } : s
    ));
  };

  const deleteService = (id: string) => {
    setServices(prev => prev.filter(s => s.id !== id));
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(price);
  };

  const formatDuration = (minutes: number) => {
    if (minutes < 60) return `${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return mins > 0 ? `${hours}h ${mins}min` : `${hours}h`;
  };

  const activeServices = services.filter(s => s.isActive).length;

  return (
    <div className="p-4 space-y-6 pb-24">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-gray-900">Mis servicios</h1>
          <p className="text-sm text-gray-500">{activeServices} activos de {services.length} total</p>
        </div>
        <button
          onClick={openAddModal}
          className="flex items-center gap-2 px-4 py-2 bg-teal-600 text-white rounded-xl hover:bg-teal-700 transition-colors"
        >
          <Plus className="w-4 h-4" />
          Agregar
        </button>
      </div>

      {/* Info */}
      <div className="bg-teal-50 border border-teal-200 rounded-xl p-4 flex gap-3">
        <AlertCircle className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
        <div>
          <p className="text-sm text-teal-800 font-medium">Gestiona tus servicios</p>
          <p className="text-xs text-teal-700 mt-1">
            Define los servicios que ofreces, sus precios y duracion. Los usuarios veran 
            solo los servicios activos en tu perfil.
          </p>
        </div>
      </div>

      {/* Services List */}
      <div className="space-y-3">
        {services.map((service) => (
          <div 
            key={service.id} 
            className={`bg-white rounded-2xl p-4 border transition-colors ${
              service.isActive ? "border-gray-200" : "border-gray-100 opacity-60"
            }`}
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-medium text-gray-900">{service.name}</h3>
                  {!service.isActive && (
                    <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">
                      Inactivo
                    </span>
                  )}
                </div>
                <p className="text-xs text-gray-500 line-clamp-2">{service.description}</p>
              </div>
              <button
                onClick={() => toggleService(service.id)}
                className="ml-3"
              >
                {service.isActive ? (
                  <ToggleRight className="w-8 h-8 text-teal-600" />
                ) : (
                  <ToggleLeft className="w-8 h-8 text-gray-400" />
                )}
              </button>
            </div>

            <div className="flex items-center gap-4 mb-3">
              <span className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
                {service.category}
              </span>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-1 text-sm">
                  <DollarSign className="w-4 h-4 text-teal-600" />
                  <span className="font-semibold text-teal-600">{formatPrice(service.price)}</span>
                </div>
                <div className="flex items-center gap-1 text-sm text-gray-600">
                  <Clock className="w-4 h-4" />
                  <span>{formatDuration(service.duration)}</span>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => openEditModal(service)}
                  className="p-2 text-gray-500 hover:text-teal-600 hover:bg-teal-50 rounded-lg transition-colors"
                >
                  <Edit2 className="w-4 h-4" />
                </button>
                <button
                  onClick={() => deleteService(service.id)}
                  className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {services.length === 0 && (
        <div className="bg-white rounded-2xl p-8 text-center border border-gray-200">
          <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Plus className="w-8 h-8 text-gray-400" />
          </div>
          <p className="text-gray-900 font-medium mb-2">No tienes servicios</p>
          <p className="text-gray-500 text-sm mb-4">
            Agrega tus servicios para que los usuarios puedan encontrarte
          </p>
          <button
            onClick={openAddModal}
            className="px-6 py-2 bg-teal-600 text-white rounded-xl hover:bg-teal-700 transition-colors"
          >
            Agregar servicio
          </button>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">
                {editingService ? "Editar servicio" : "Nuevo servicio"}
              </h3>
              <button 
                onClick={() => setShowModal(false)}
                className="p-2 hover:bg-gray-100 rounded-full"
              >
                <X className="w-5 h-5 text-gray-500" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-sm text-gray-700 mb-1 block">Nombre del servicio</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="Ej: Cuidado de adulto mayor"
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none"
                />
              </div>

              <div>
                <label className="text-sm text-gray-700 mb-1 block">Descripcion</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder="Describe lo que incluye este servicio..."
                  rows={3}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none resize-none"
                />
              </div>

              <div>
                <label className="text-sm text-gray-700 mb-1 block">Categoria</label>
                <select
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none"
                >
                  <option value="">Selecciona una categoria</option>
                  {categories.map(cat => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-sm text-gray-700 mb-1 block">Precio (COP)</label>
                  <input
                    type="number"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    placeholder="50000"
                    className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none"
                  />
                </div>
                <div>
                  <label className="text-sm text-gray-700 mb-1 block">Duracion (min)</label>
                  <input
                    type="number"
                    value={formData.duration}
                    onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
                    placeholder="60"
                    className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-teal-500 focus:bg-white transition-colors outline-none"
                  />
                </div>
              </div>

              <button
                onClick={handleSave}
                disabled={!formData.name || !formData.category || !formData.price || !formData.duration}
                className="w-full py-3 bg-teal-600 text-white rounded-xl font-medium hover:bg-teal-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <CheckCircle2 className="w-5 h-5" />
                {editingService ? "Guardar cambios" : "Crear servicio"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
