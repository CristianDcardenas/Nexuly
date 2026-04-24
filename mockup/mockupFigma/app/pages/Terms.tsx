import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, FileText, Shield, Users, CreditCard, AlertTriangle, Scale } from "lucide-react";

export function Terms() {
  const [activeSection, setActiveSection] = useState("terms");

  const sections = [
    { id: "terms", name: "Terminos de uso", icon: <FileText className="w-5 h-5" /> },
    { id: "privacy", name: "Politica de privacidad", icon: <Shield className="w-5 h-5" /> },
    { id: "community", name: "Normas de la comunidad", icon: <Users className="w-5 h-5" /> },
    { id: "payments", name: "Politica de pagos", icon: <CreditCard className="w-5 h-5" /> },
    { id: "cancellation", name: "Politica de cancelacion", icon: <AlertTriangle className="w-5 h-5" /> },
    { id: "disputes", name: "Resolucion de disputas", icon: <Scale className="w-5 h-5" /> },
  ];

  const renderContent = () => {
    switch (activeSection) {
      case "terms":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">1. Aceptacion de los terminos</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Al acceder y utilizar la plataforma Nexuly, aceptas estar legalmente vinculado por estos Terminos de Uso. Si no estas de acuerdo con alguno de estos terminos, no debes utilizar nuestros servicios.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">2. Descripcion del servicio</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Nexuly es una plataforma que conecta a usuarios con profesionales de salud y cuidado a domicilio. Actuamos como intermediarios y no somos responsables directos de los servicios prestados por los profesionales.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">3. Registro de cuenta</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Para utilizar nuestros servicios, debes crear una cuenta proporcionando informacion veraz y actualizada. Eres responsable de mantener la confidencialidad de tu cuenta y contrasena.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">4. Uso aceptable</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Te comprometes a utilizar la plataforma solo para fines legitimos relacionados con la contratacion de servicios de salud. Esta prohibido el uso fraudulento, abusivo o que viole los derechos de terceros.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">5. Modificaciones</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Nos reservamos el derecho de modificar estos terminos en cualquier momento. Te notificaremos de cambios significativos a traves de la aplicacion o por correo electronico.
              </p>
            </div>
          </div>
        );
      case "privacy":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Informacion que recopilamos</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Recopilamos informacion personal como nombre, correo electronico, telefono, direccion e informacion medica relevante para la prestacion de servicios de salud.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Uso de la informacion</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Utilizamos tu informacion para facilitar la conexion con profesionales de salud, procesar pagos, mejorar nuestros servicios y enviarte comunicaciones relevantes.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Proteccion de datos</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Implementamos medidas de seguridad tecnicas y organizativas para proteger tu informacion personal contra acceso no autorizado, perdida o alteracion.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Tus derechos</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Tienes derecho a acceder, rectificar, eliminar y portar tu informacion personal. Puedes ejercer estos derechos contactandonos a traves de la aplicacion.
              </p>
            </div>
          </div>
        );
      case "community":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Respeto mutuo</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Esperamos que todos los usuarios traten a los profesionales y a otros usuarios con respeto y cortesia. No toleramos discriminacion, acoso o comportamiento abusivo.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Comunicacion apropiada</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Las comunicaciones a traves de la plataforma deben ser profesionales y relacionadas con los servicios contratados. El contenido inapropiado sera eliminado.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Resenas honestas</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Las resenas deben ser honestas y basadas en experiencias reales. Las resenas falsas o manipuladas resultan en la suspension de la cuenta.
              </p>
            </div>
          </div>
        );
      case "payments":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Metodos de pago</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Aceptamos tarjetas de credito/debito, transferencias bancarias y efectivo (cuando el profesional lo permita). Los pagos se procesan de forma segura.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Precios y tarifas</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Los precios de los servicios son establecidos por los profesionales. Nexuly cobra una comision por servicio que se incluye en el precio final mostrado.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Facturacion</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Puedes solicitar factura fiscal por cualquier servicio pagado. Las facturas se generan dentro de las 72 horas posteriores a la solicitud.
              </p>
            </div>
          </div>
        );
      case "cancellation":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Cancelacion por el usuario</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Puedes cancelar una cita sin costo hasta 24 horas antes del servicio. Las cancelaciones con menos de 24 horas pueden tener un cargo del 50% del valor del servicio.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Cancelacion por el profesional</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Si el profesional cancela, se te ofrecera reagendar sin costo adicional o un reembolso completo. Recibirás notificación inmediata de cualquier cancelacion.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Reembolsos</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Los reembolsos se procesan en 5-10 dias habiles dependiendo de tu institucion bancaria. El monto aparecerá en el mismo metodo de pago utilizado.
              </p>
            </div>
          </div>
        );
      case "disputes":
        return (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Proceso de resolucion</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                En caso de disputa, te recomendamos contactar primero al profesional a traves del chat de la aplicacion. Si no se resuelve, puedes escalar el caso a nuestro equipo de soporte.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Mediacion</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Nuestro equipo de soporte actuara como mediador imparcial para resolver conflictos. Evaluaremos la evidencia de ambas partes antes de tomar una decision.
              </p>
            </div>
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Decisiones finales</h3>
              <p className="text-sm text-gray-600 leading-relaxed">
                Las decisiones de Nexuly en disputas son definitivas en el contexto de la plataforma. Esto no limita tus derechos legales conforme a la legislacion aplicable.
              </p>
            </div>
          </div>
        );
      default:
        return null;
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
          <h1 className="text-lg font-medium">Terminos y condiciones</h1>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Section Selector */}
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <div className="flex p-2 gap-1 min-w-max">
              {sections.map((section) => (
                <button
                  key={section.id}
                  onClick={() => setActiveSection(section.id)}
                  className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm whitespace-nowrap transition-colors ${
                    activeSection === section.id
                      ? "bg-violet-100 text-violet-700"
                      : "text-gray-600 hover:bg-gray-100"
                  }`}
                >
                  {section.icon}
                  <span>{section.name}</span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center gap-3 mb-4 pb-4 border-b border-gray-100">
            <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
              {sections.find(s => s.id === activeSection)?.icon}
            </div>
            <div>
              <h2 className="font-medium text-gray-900">
                {sections.find(s => s.id === activeSection)?.name}
              </h2>
              <p className="text-xs text-gray-500">Ultima actualizacion: Enero 2024</p>
            </div>
          </div>

          {renderContent()}
        </div>

        {/* Footer */}
        <div className="bg-blue-50 rounded-xl p-4 border border-blue-100">
          <p className="text-sm text-blue-800">
            Si tienes preguntas sobre estos terminos, contactanos a traves del Centro de Ayuda o escribe a legal@nexuly.com
          </p>
        </div>
      </div>
    </div>
  );
}
