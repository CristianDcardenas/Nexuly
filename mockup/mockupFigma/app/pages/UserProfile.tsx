import { Link } from "react-router";
import { Settings, ChevronRight, Heart, Users, FileText, Bell, Lock, HelpCircle, LogOut, CreditCard, ShieldCheck, Award, Star, CheckCircle2 } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

export function UserProfile() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-6 border-b border-gray-200">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl">Perfil</h1>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Settings className="w-6 h-6 text-gray-600" />
          </button>
        </div>

        {/* User Info */}
        <div className="flex flex-col items-center">
          <div className="relative">
            <div className="w-24 h-24 rounded-full bg-gray-200 mb-3 overflow-hidden">
              <ImageWithFallback
                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=150"
                alt="María González"
                className="w-full h-full object-cover"
              />
            </div>
            {/* Verification Badge */}
            <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center border-2 border-white">
              <ShieldCheck className="w-4 h-4 text-white" />
            </div>
          </div>
          <h2 className="text-xl mb-1">Maria Gonzalez</h2>
          <p className="text-sm text-gray-600 mb-2">maria.gonzalez@email.com</p>
          
          {/* Verification & Trust Badges */}
          <div className="flex items-center gap-2 mt-1">
            <span className="flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs">
              <ShieldCheck className="w-3 h-3" />
              Verificado
            </span>
            <span className="flex items-center gap-1 px-2 py-1 bg-amber-100 text-amber-700 rounded-full text-xs">
              <Star className="w-3 h-3 fill-amber-500" />
              4.9
            </span>
          </div>
        </div>
      </div>

      {/* Verification Progress Section */}
      <div className="px-4 pt-4">
        <Link
          to="/user-verification"
          className="block bg-gradient-to-r from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-100"
        >
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                <Award className="w-5 h-5 text-violet-600" />
              </div>
              <div>
                <h3 className="text-sm font-medium text-gray-900">Nivel de verificacion: Verificado</h3>
                <p className="text-xs text-gray-500">Completa mas pasos para subir de nivel</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-violet-400" />
          </div>
          
          {/* Progress Bar */}
          <div className="mb-2">
            <div className="flex justify-between text-xs mb-1">
              <span className="text-gray-500">Progreso hacia Confiable</span>
              <span className="text-violet-600 font-medium">75%</span>
            </div>
            <div className="h-2 bg-white rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-violet-500 to-purple-500 rounded-full" style={{ width: "75%" }} />
            </div>
          </div>
          
          {/* Completed Steps */}
          <div className="flex items-center gap-4 text-xs text-gray-500">
            <span className="flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3 text-green-500" />
              Email verificado
            </span>
            <span className="flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3 text-green-500" />
              Telefono verificado
            </span>
          </div>
        </Link>
      </div>

      <div className="p-4 space-y-4">
        {/* Personal Information Section */}
        <div className="bg-white rounded-2xl overflow-hidden border border-gray-200">
          <Link
            to="/medical-info"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-b border-gray-100"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
                <Heart className="w-5 h-5 text-violet-600" />
              </div>
              <span className="text-sm">Tu información médica</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>

          <Link
            to="/family-members"
            className="flex items-center justify-between p-4 hover:bg-gray-50"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <Users className="w-5 h-5 text-blue-600" />
              </div>
              <span className="text-sm">Miembros de la familia</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>
        </div>

        {/* Saved Professionals */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <h3 className="text-base mb-3">Guardados</h3>
          <div className="text-center py-6">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
              <Heart className="w-8 h-8 text-gray-400" />
            </div>
            <p className="text-sm text-gray-600 mb-2">No has guardado ninguna clínica o especialista</p>
            <p className="text-xs text-gray-500 mb-4">Cuando guardes los perfiles de clínicas o especialistas, los verás aquí</p>
            <Link
              to="/search"
              className="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-full text-sm hover:bg-gray-200"
            >
              <Search className="w-4 h-4" />
              Encontrar especialistas
            </Link>
          </div>
        </div>

        {/* Account Settings */}
        <div className="bg-white rounded-2xl overflow-hidden border border-gray-200">
          <h3 className="text-base px-4 pt-4 pb-3">Configuración de cuenta</h3>

          <Link
            to="/payment-methods"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-t border-gray-100"
          >
            <div className="flex items-center gap-3">
              <CreditCard className="w-5 h-5 text-gray-600" />
              <span className="text-sm">Métodos de pago</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>

          <Link
            to="/notifications"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-t border-gray-100"
          >
            <div className="flex items-center gap-3">
              <Bell className="w-5 h-5 text-gray-600" />
              <span className="text-sm">Notificaciones</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>

          <Link
            to="/privacy"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-t border-gray-100"
          >
            <div className="flex items-center gap-3">
              <Lock className="w-5 h-5 text-gray-600" />
              <span className="text-sm">Privacidad y seguridad</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>
        </div>

        {/* Support */}
        <div className="bg-white rounded-2xl overflow-hidden border border-gray-200">
          <h3 className="text-base px-4 pt-4 pb-3">Soporte</h3>

          <Link
            to="/help"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-t border-gray-100"
          >
            <div className="flex items-center gap-3">
              <HelpCircle className="w-5 h-5 text-gray-600" />
              <span className="text-sm">Centro de ayuda</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>

          <Link
            to="/terms"
            className="flex items-center justify-between p-4 hover:bg-gray-50 border-t border-gray-100"
          >
            <div className="flex items-center gap-3">
              <FileText className="w-5 h-5 text-gray-600" />
              <span className="text-sm">Términos y condiciones</span>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </Link>
        </div>

        {/* Logout */}
        <Link
          to="/login"
          className="w-full bg-white rounded-2xl p-4 border border-gray-200 hover:bg-gray-50 flex items-center justify-center gap-2 text-red-600"
        >
          <LogOut className="w-5 h-5" />
          <span className="text-sm">Cerrar sesión</span>
        </Link>

        {/* App Version */}
        <div className="text-center py-4">
          <p className="text-xs text-gray-500">Nexuly v1.0.0</p>
        </div>
      </div>
    </div>
  );
}

function Search({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
      />
    </svg>
  );
}
