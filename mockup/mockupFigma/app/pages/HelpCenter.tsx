import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Search, ChevronRight, MessageCircle, Phone, Mail, FileQuestion, Calendar, CreditCard, User, Shield, Star } from "lucide-react";

interface FAQItem {
  id: string;
  question: string;
  answer: string;
  category: string;
}

export function HelpCenter() {
  const [searchQuery, setSearchQuery] = useState("");
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [expandedFaq, setExpandedFaq] = useState<string | null>(null);

  const categories = [
    { id: "bookings", name: "Reservaciones", icon: <Calendar className="w-5 h-5" />, color: "bg-violet-100 text-violet-600" },
    { id: "payments", name: "Pagos", icon: <CreditCard className="w-5 h-5" />, color: "bg-green-100 text-green-600" },
    { id: "account", name: "Mi cuenta", icon: <User className="w-5 h-5" />, color: "bg-blue-100 text-blue-600" },
    { id: "security", name: "Seguridad", icon: <Shield className="w-5 h-5" />, color: "bg-orange-100 text-orange-600" },
    { id: "reviews", name: "Resenas", icon: <Star className="w-5 h-5" />, color: "bg-yellow-100 text-yellow-600" },
    { id: "other", name: "Otros", icon: <FileQuestion className="w-5 h-5" />, color: "bg-gray-100 text-gray-600" },
  ];

  const faqs: FAQItem[] = [
    {
      id: "1",
      category: "bookings",
      question: "Como puedo cancelar una cita?",
      answer: "Puedes cancelar una cita desde la seccion 'Historial' de la app. Selecciona la cita que deseas cancelar y presiona 'Cancelar cita'. Las cancelaciones con mas de 24 horas de anticipacion son gratuitas."
    },
    {
      id: "2",
      category: "bookings",
      question: "Puedo reprogramar una cita?",
      answer: "Si, puedes reprogramar tu cita hasta 12 horas antes de la hora programada. Ve a 'Historial', selecciona la cita y elige 'Reprogramar'. Podras seleccionar una nueva fecha y hora disponible."
    },
    {
      id: "3",
      category: "payments",
      question: "Que metodos de pago aceptan?",
      answer: "Aceptamos tarjetas de credito y debito (Visa, Mastercard, American Express), transferencias bancarias y pagos en efectivo al finalizar el servicio (sujeto a disponibilidad del profesional)."
    },
    {
      id: "4",
      category: "payments",
      question: "Como solicito una factura?",
      answer: "Puedes solicitar tu factura desde la seccion 'Historial' seleccionando el servicio y presionando 'Solicitar factura'. Asegurate de tener tus datos fiscales actualizados en tu perfil."
    },
    {
      id: "5",
      category: "account",
      question: "Como actualizo mi informacion personal?",
      answer: "Ve a 'Perfil' > 'Tu informacion medica' para actualizar datos de salud, o a 'Configuracion de cuenta' para modificar tu email, telefono u otra informacion personal."
    },
    {
      id: "6",
      category: "security",
      question: "Olvide mi contrasena, que hago?",
      answer: "En la pantalla de inicio de sesion, presiona 'Olvide mi contrasena'. Te enviaremos un enlace a tu correo electronico para crear una nueva contrasena de forma segura."
    },
    {
      id: "7",
      category: "reviews",
      question: "Como califico a un profesional?",
      answer: "Despues de cada servicio, te pediremos que califiques tu experiencia. Tambien puedes hacerlo desde 'Historial', seleccionando el servicio completado y presionando 'Calificar'."
    },
    {
      id: "8",
      category: "other",
      question: "En que ciudades esta disponible Nexuly?",
      answer: "Actualmente operamos en Ciudad de Mexico, Guadalajara, Monterrey, Puebla y Queretaro. Estamos expandiendonos constantemente a nuevas ciudades."
    },
  ];

  const filteredFaqs = faqs.filter(faq => {
    const matchesSearch = faq.question.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          faq.answer.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = !activeCategory || faq.category === activeCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="text-lg font-medium">Centro de ayuda</h1>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Buscar en ayuda..."
            className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
          />
        </div>

        {/* Contact Options */}
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <h2 className="font-medium text-gray-900 mb-4">Contactar soporte</h2>
          <div className="grid grid-cols-3 gap-3">
            <button className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50">
              <div className="w-12 h-12 bg-violet-100 rounded-full flex items-center justify-center">
                <MessageCircle className="w-6 h-6 text-violet-600" />
              </div>
              <span className="text-xs text-gray-600">Chat</span>
            </button>
            <button className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50">
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <Phone className="w-6 h-6 text-green-600" />
              </div>
              <span className="text-xs text-gray-600">Llamar</span>
            </button>
            <button className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                <Mail className="w-6 h-6 text-blue-600" />
              </div>
              <span className="text-xs text-gray-600">Email</span>
            </button>
          </div>
          <p className="text-xs text-gray-500 text-center mt-4">
            Disponible de Lunes a Viernes, 8:00 AM - 8:00 PM
          </p>
        </div>

        {/* Categories */}
        <div>
          <h2 className="font-medium text-gray-900 mb-3">Categorias</h2>
          <div className="grid grid-cols-3 gap-2">
            {categories.map((category) => (
              <button
                key={category.id}
                onClick={() => setActiveCategory(activeCategory === category.id ? null : category.id)}
                className={`flex flex-col items-center gap-2 p-3 rounded-xl border transition-colors ${
                  activeCategory === category.id
                    ? "border-violet-600 bg-violet-50"
                    : "border-gray-200 bg-white hover:border-gray-300"
                }`}
              >
                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${category.color}`}>
                  {category.icon}
                </div>
                <span className={`text-xs ${
                  activeCategory === category.id ? "text-violet-600 font-medium" : "text-gray-600"
                }`}>
                  {category.name}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* FAQs */}
        <div>
          <h2 className="font-medium text-gray-900 mb-3">
            Preguntas frecuentes
            {activeCategory && (
              <span className="text-sm font-normal text-gray-500 ml-2">
                ({categories.find(c => c.id === activeCategory)?.name})
              </span>
            )}
          </h2>
          <div className="space-y-2">
            {filteredFaqs.map((faq) => (
              <div key={faq.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                <button
                  onClick={() => setExpandedFaq(expandedFaq === faq.id ? null : faq.id)}
                  className="w-full flex items-center justify-between p-4 text-left hover:bg-gray-50"
                >
                  <span className="font-medium text-gray-900 text-sm pr-4">{faq.question}</span>
                  <ChevronRight className={`w-5 h-5 text-gray-400 flex-shrink-0 transition-transform ${
                    expandedFaq === faq.id ? "rotate-90" : ""
                  }`} />
                </button>
                {expandedFaq === faq.id && (
                  <div className="px-4 pb-4 pt-0">
                    <p className="text-sm text-gray-600 leading-relaxed">{faq.answer}</p>
                  </div>
                )}
              </div>
            ))}
          </div>

          {filteredFaqs.length === 0 && (
            <div className="text-center py-8">
              <FileQuestion className="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-600">No se encontraron resultados</p>
              <p className="text-sm text-gray-500 mt-1">Intenta con otros terminos de busqueda</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
