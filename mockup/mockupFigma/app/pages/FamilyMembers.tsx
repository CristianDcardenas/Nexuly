import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Plus, Pencil, Trash2, User, Calendar, Phone, Heart } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

interface FamilyMember {
  id: string;
  name: string;
  relationship: string;
  birthDate: string;
  phone?: string;
  avatar?: string;
  isPrimary?: boolean;
}

export function FamilyMembers() {
  const [showAddForm, setShowAddForm] = useState(false);
  const [newMember, setNewMember] = useState({
    name: "",
    relationship: "",
    birthDate: "",
    phone: "",
  });

  const [members] = useState<FamilyMember[]>([
    {
      id: "1",
      name: "Carlos Gonzalez",
      relationship: "Esposo",
      birthDate: "1978-05-12",
      phone: "+52 55 1234 5678",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
    },
    {
      id: "2",
      name: "Sofia Gonzalez",
      relationship: "Hija",
      birthDate: "2010-09-23",
      avatar: "https://images.unsplash.com/photo-1595152772835-219674b2a8a6?w=150",
    },
    {
      id: "3",
      name: "Miguel Gonzalez",
      relationship: "Hijo",
      birthDate: "2015-03-08",
    },
    {
      id: "4",
      name: "Rosa Martinez",
      relationship: "Madre",
      birthDate: "1950-11-30",
      phone: "+52 55 9876 5432",
      isPrimary: true,
    },
  ]);

  const calculateAge = (birthDate: string) => {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    return age;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // In real app, would save to database
    setShowAddForm(false);
    setNewMember({ name: "", relationship: "", birthDate: "", phone: "" });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
              <ArrowLeft className="w-5 h-5" />
            </Link>
            <h1 className="text-lg font-medium">Miembros de la familia</h1>
          </div>
          <button
            onClick={() => setShowAddForm(true)}
            className="p-2 rounded-full hover:bg-gray-100 text-violet-600"
          >
            <Plus className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="p-4">
        <p className="text-sm text-gray-600 mb-4">
          Agrega a los miembros de tu familia para agendar citas a su nombre y gestionar su salud.
        </p>

        {/* Family Members List */}
        <div className="space-y-3">
          {members.map((member) => (
            <div key={member.id} className="bg-white rounded-xl p-4 border border-gray-200">
              <div className="flex items-start gap-3">
                <div className="w-14 h-14 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                  {member.avatar ? (
                    <ImageWithFallback
                      src={member.avatar}
                      alt={member.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center bg-violet-100">
                      <User className="w-6 h-6 text-violet-600" />
                    </div>
                  )}
                </div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h3 className="font-medium text-gray-900 truncate">{member.name}</h3>
                    {member.isPrimary && (
                      <span className="text-xs bg-violet-100 text-violet-700 px-2 py-0.5 rounded-full flex-shrink-0">
                        Cuidador primario
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-violet-600">{member.relationship}</p>

                  <div className="mt-2 flex flex-wrap gap-3 text-sm text-gray-500">
                    <div className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      <span>{calculateAge(member.birthDate)} anos</span>
                    </div>
                    {member.phone && (
                      <div className="flex items-center gap-1">
                        <Phone className="w-4 h-4" />
                        <span>{member.phone}</span>
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex flex-col gap-1">
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

        {members.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Heart className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="font-medium text-gray-900 mb-2">No hay miembros agregados</h3>
            <p className="text-sm text-gray-500 mb-4">
              Agrega a los miembros de tu familia para gestionar su salud
            </p>
            <button
              onClick={() => setShowAddForm(true)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-violet-600 text-white rounded-full text-sm hover:bg-violet-700"
            >
              <Plus className="w-4 h-4" />
              Agregar miembro
            </button>
          </div>
        )}

        {/* Info Card */}
        <div className="mt-6 bg-blue-50 rounded-xl p-4 border border-blue-100">
          <p className="text-sm text-blue-800">
            Los miembros de tu familia podran recibir servicios de salud a domicilio. Tu seras responsable de la gestion de sus citas y pagos.
          </p>
        </div>
      </div>

      {/* Add Member Modal */}
      {showAddForm && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl w-full max-w-lg p-6 animate-slide-up">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-medium">Agregar miembro</h2>
              <button
                onClick={() => setShowAddForm(false)}
                className="p-2 hover:bg-gray-100 rounded-full"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nombre completo
                </label>
                <input
                  type="text"
                  value={newMember.name}
                  onChange={(e) => setNewMember({ ...newMember, name: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  placeholder="Juan Perez"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Relacion
                </label>
                <select
                  value={newMember.relationship}
                  onChange={(e) => setNewMember({ ...newMember, relationship: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  required
                >
                  <option value="">Seleccionar...</option>
                  <option value="Esposo/a">Esposo/a</option>
                  <option value="Hijo/a">Hijo/a</option>
                  <option value="Padre">Padre</option>
                  <option value="Madre">Madre</option>
                  <option value="Abuelo/a">Abuelo/a</option>
                  <option value="Hermano/a">Hermano/a</option>
                  <option value="Otro">Otro</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha de nacimiento
                </label>
                <input
                  type="date"
                  value={newMember.birthDate}
                  onChange={(e) => setNewMember({ ...newMember, birthDate: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefono (opcional)
                </label>
                <input
                  type="tel"
                  value={newMember.phone}
                  onChange={(e) => setNewMember({ ...newMember, phone: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  placeholder="+52 55 1234 5678"
                />
              </div>

              <div className="pt-4 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowAddForm(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 bg-violet-600 text-white rounded-xl hover:bg-violet-700"
                >
                  Guardar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
