import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Bell, Calendar, MessageSquare, CreditCard, Star, Megaphone } from "lucide-react";

interface NotificationSetting {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  push: boolean;
  email: boolean;
  sms: boolean;
}

export function Notifications() {
  const [settings, setSettings] = useState<NotificationSetting[]>([
    {
      id: "appointments",
      title: "Recordatorios de citas",
      description: "Recibe recordatorios antes de tus citas programadas",
      icon: <Calendar className="w-5 h-5 text-violet-600" />,
      push: true,
      email: true,
      sms: true,
    },
    {
      id: "messages",
      title: "Mensajes",
      description: "Notificaciones de nuevos mensajes de profesionales",
      icon: <MessageSquare className="w-5 h-5 text-blue-600" />,
      push: true,
      email: false,
      sms: false,
    },
    {
      id: "payments",
      title: "Pagos y facturacion",
      description: "Confirmaciones de pago y recordatorios de cobro",
      icon: <CreditCard className="w-5 h-5 text-green-600" />,
      push: true,
      email: true,
      sms: false,
    },
    {
      id: "reviews",
      title: "Solicitudes de resena",
      description: "Recordatorios para calificar servicios recibidos",
      icon: <Star className="w-5 h-5 text-yellow-600" />,
      push: true,
      email: false,
      sms: false,
    },
    {
      id: "promotions",
      title: "Promociones y ofertas",
      description: "Ofertas especiales y descuentos exclusivos",
      icon: <Megaphone className="w-5 h-5 text-orange-600" />,
      push: false,
      email: true,
      sms: false,
    },
  ]);

  const [quietHours, setQuietHours] = useState({
    enabled: true,
    start: "22:00",
    end: "08:00",
  });

  const toggleSetting = (id: string, channel: "push" | "email" | "sms") => {
    setSettings(settings.map(setting => {
      if (setting.id === id) {
        return { ...setting, [channel]: !setting[channel] };
      }
      return setting;
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="text-lg font-medium">Notificaciones</h1>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Quiet Hours */}
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                <Bell className="w-5 h-5 text-gray-600" />
              </div>
              <div>
                <h3 className="font-medium text-gray-900">Horas de silencio</h3>
                <p className="text-sm text-gray-500">Pausar notificaciones push</p>
              </div>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={quietHours.enabled}
                onChange={() => setQuietHours({ ...quietHours, enabled: !quietHours.enabled })}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-violet-600"></div>
            </label>
          </div>

          {quietHours.enabled && (
            <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-100">
              <div>
                <label className="block text-sm text-gray-600 mb-1">Desde</label>
                <input
                  type="time"
                  value={quietHours.start}
                  onChange={(e) => setQuietHours({ ...quietHours, start: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                />
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Hasta</label>
                <input
                  type="time"
                  value={quietHours.end}
                  onChange={(e) => setQuietHours({ ...quietHours, end: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                />
              </div>
            </div>
          )}
        </div>

        {/* Notification Categories */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-3">Tipos de notificaciones</h2>

          {/* Header Labels */}
          <div className="flex items-center justify-end gap-4 px-4 mb-2">
            <span className="text-xs text-gray-500 w-12 text-center">Push</span>
            <span className="text-xs text-gray-500 w-12 text-center">Email</span>
            <span className="text-xs text-gray-500 w-12 text-center">SMS</span>
          </div>

          <div className="space-y-2">
            {settings.map((setting) => (
              <div key={setting.id} className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gray-50 rounded-full flex items-center justify-center flex-shrink-0">
                    {setting.icon}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-medium text-gray-900 text-sm">{setting.title}</h3>
                    <p className="text-xs text-gray-500 truncate">{setting.description}</p>
                  </div>
                  <div className="flex items-center gap-4">
                    <label className="relative inline-flex items-center cursor-pointer w-12 justify-center">
                      <input
                        type="checkbox"
                        checked={setting.push}
                        onChange={() => toggleSetting(setting.id, "push")}
                        className="sr-only peer"
                      />
                      <div className="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-violet-600"></div>
                    </label>
                    <label className="relative inline-flex items-center cursor-pointer w-12 justify-center">
                      <input
                        type="checkbox"
                        checked={setting.email}
                        onChange={() => toggleSetting(setting.id, "email")}
                        className="sr-only peer"
                      />
                      <div className="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-violet-600"></div>
                    </label>
                    <label className="relative inline-flex items-center cursor-pointer w-12 justify-center">
                      <input
                        type="checkbox"
                        checked={setting.sms}
                        onChange={() => toggleSetting(setting.id, "sms")}
                        className="sr-only peer"
                      />
                      <div className="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-violet-600"></div>
                    </label>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Info */}
        <div className="bg-blue-50 rounded-xl p-4 border border-blue-100">
          <p className="text-sm text-blue-800">
            Las notificaciones de emergencia y seguridad siempre estaran activas para proteger tu cuenta.
          </p>
        </div>
      </div>
    </div>
  );
}
