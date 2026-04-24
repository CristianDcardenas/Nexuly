import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Lock, Shield, Eye, Key, Smartphone, FileText, Trash2, Download } from "lucide-react";

export function Privacy() {
  const [showPasswordForm, setShowPasswordForm] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [shareData, setShareData] = useState(true);
  const [showActivity, setShowActivity] = useState(true);

  const [sessions] = useState([
    { id: "1", device: "iPhone 14 Pro", location: "Ciudad de Mexico", lastActive: "Ahora", current: true },
    { id: "2", device: "MacBook Pro", location: "Ciudad de Mexico", lastActive: "Hace 2 horas", current: false },
    { id: "3", device: "iPad Air", location: "Guadalajara", lastActive: "Hace 3 dias", current: false },
  ]);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="text-lg font-medium">Privacidad y seguridad</h1>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Security Section */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-3">Seguridad</h2>
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <button
              onClick={() => setShowPasswordForm(true)}
              className="w-full flex items-center justify-between p-4 hover:bg-gray-50"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                  <Key className="w-5 h-5 text-violet-600" />
                </div>
                <div className="text-left">
                  <h3 className="font-medium text-gray-900">Cambiar contrasena</h3>
                  <p className="text-sm text-gray-500">Ultima actualizacion hace 3 meses</p>
                </div>
              </div>
              <ArrowLeft className="w-5 h-5 text-gray-400 rotate-180" />
            </button>

            <div className="border-t border-gray-100">
              <div className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                    <Smartphone className="w-5 h-5 text-green-600" />
                  </div>
                  <div>
                    <h3 className="font-medium text-gray-900">Autenticacion de dos factores</h3>
                    <p className="text-sm text-gray-500">Proteccion adicional para tu cuenta</p>
                  </div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={twoFactorEnabled}
                    onChange={() => setTwoFactorEnabled(!twoFactorEnabled)}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-violet-600"></div>
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Active Sessions */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-3">Sesiones activas</h2>
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            {sessions.map((session, index) => (
              <div
                key={session.id}
                className={`flex items-center justify-between p-4 ${
                  index > 0 ? "border-t border-gray-100" : ""
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    session.current ? "bg-green-100" : "bg-gray-100"
                  }`}>
                    <Smartphone className={`w-5 h-5 ${
                      session.current ? "text-green-600" : "text-gray-600"
                    }`} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-medium text-gray-900 text-sm">{session.device}</h3>
                      {session.current && (
                        <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">
                          Este dispositivo
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-gray-500">
                      {session.location} · {session.lastActive}
                    </p>
                  </div>
                </div>
                {!session.current && (
                  <button className="text-sm text-red-600 hover:text-red-700">
                    Cerrar
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Privacy Settings */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-3">Privacidad</h2>
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div className="flex items-center justify-between p-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <Eye className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <h3 className="font-medium text-gray-900">Mostrar actividad</h3>
                  <p className="text-sm text-gray-500">Permitir que profesionales vean tu historial</p>
                </div>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={showActivity}
                  onChange={() => setShowActivity(!showActivity)}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-violet-600"></div>
              </label>
            </div>

            <div className="border-t border-gray-100">
              <div className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
                    <Shield className="w-5 h-5 text-orange-600" />
                  </div>
                  <div>
                    <h3 className="font-medium text-gray-900">Compartir datos anonimos</h3>
                    <p className="text-sm text-gray-500">Ayudar a mejorar el servicio</p>
                  </div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={shareData}
                    onChange={() => setShareData(!shareData)}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-violet-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-violet-600"></div>
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Data Management */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-3">Gestion de datos</h2>
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-50">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                  <Download className="w-5 h-5 text-gray-600" />
                </div>
                <div className="text-left">
                  <h3 className="font-medium text-gray-900">Descargar mis datos</h3>
                  <p className="text-sm text-gray-500">Obtener una copia de tu informacion</p>
                </div>
              </div>
              <ArrowLeft className="w-5 h-5 text-gray-400 rotate-180" />
            </button>

            <div className="border-t border-gray-100">
              <button
                onClick={() => setShowDeleteConfirm(true)}
                className="w-full flex items-center justify-between p-4 hover:bg-red-50"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                    <Trash2 className="w-5 h-5 text-red-600" />
                  </div>
                  <div className="text-left">
                    <h3 className="font-medium text-red-600">Eliminar cuenta</h3>
                    <p className="text-sm text-gray-500">Borrar permanentemente tu cuenta</p>
                  </div>
                </div>
                <ArrowLeft className="w-5 h-5 text-gray-400 rotate-180" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Change Password Modal */}
      {showPasswordForm && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl w-full max-w-lg p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-medium">Cambiar contrasena</h2>
              <button
                onClick={() => setShowPasswordForm(false)}
                className="p-2 hover:bg-gray-100 rounded-full"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
            </div>

            <form className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Contrasena actual
                </label>
                <input
                  type="password"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  placeholder="********"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nueva contrasena
                </label>
                <input
                  type="password"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  placeholder="Minimo 8 caracteres"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Confirmar nueva contrasena
                </label>
                <input
                  type="password"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                  placeholder="Repetir contrasena"
                />
              </div>

              <div className="pt-4 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowPasswordForm(false)}
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

      {/* Delete Account Confirmation */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm p-6">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Trash2 className="w-8 h-8 text-red-600" />
              </div>
              <h2 className="text-lg font-medium text-gray-900 mb-2">Eliminar cuenta</h2>
              <p className="text-sm text-gray-600">
                Esta accion es permanente y no se puede deshacer. Todos tus datos, historial y configuraciones seran eliminados.
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                className="flex-1 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button className="flex-1 py-3 bg-red-600 text-white rounded-xl hover:bg-red-700">
                Eliminar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
