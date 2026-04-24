import { useState } from "react";
import { useNavigate } from "react-router";
import { Mail, Lock, Eye, EyeOff, Shield, Users } from "lucide-react";

export function Login() {
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSignUp, setIsSignUp] = useState(false);
  const [accountType, setAccountType] = useState<"patient" | "professional">("patient");
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock authentication - in real app would validate credentials
    if (isSignUp && accountType === "professional") {
      navigate("/professional-register");
    } else if (!isSignUp && accountType === "professional") {
      // Professional login - redirect to professional dashboard
      navigate("/professional");
    } else {
      navigate("/");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-violet-500 via-purple-500 to-violet-600 flex flex-col">
      {/* Header with Logo */}
      <div className="p-6">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center">
            <span className="text-white font-bold text-lg">N</span>
          </div>
          <span className="text-2xl text-white">Nexuly</span>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col justify-between">
        {/* Top Section - Welcome */}
        <div className="px-6 pt-8">
          <h1 className="text-3xl text-white mb-2">
            {isSignUp ? "Crear cuenta" : "Bienvenido de nuevo"}
          </h1>
          <p className="text-violet-100 text-base">
            {isSignUp 
              ? "Regístrate para conectar con profesionales de salud"
              : "Inicia sesión para continuar"}
          </p>
        </div>

        {/* Form Card */}
        <div className="bg-white rounded-t-[32px] p-6 space-y-6">
          {/* User Type Selection */}
          <div>
              <label className="text-sm text-gray-700 mb-2 block">Tipo de cuenta</label>
              <div className="grid grid-cols-2 gap-3">
                <button 
                  type="button"
                  onClick={() => setAccountType("patient")}
                  className={`p-4 rounded-2xl border-2 flex flex-col items-center gap-2 transition-colors ${
                    accountType === "patient" 
                      ? "border-violet-600 bg-violet-50" 
                      : "border-gray-200 bg-white"
                  }`}
                >
                  <Users className={`w-6 h-6 ${accountType === "patient" ? "text-violet-600" : "text-gray-400"}`} />
                  <span className={`text-sm ${accountType === "patient" ? "text-violet-600" : "text-gray-600"}`}>Paciente</span>
                </button>
                <button 
                  type="button"
                  onClick={() => setAccountType("professional")}
                  className={`p-4 rounded-2xl border-2 flex flex-col items-center gap-2 transition-colors ${
                    accountType === "professional" 
                      ? "border-violet-600 bg-violet-50" 
                      : "border-gray-200 bg-white"
                  }`}
                >
                  <Shield className={`w-6 h-6 ${accountType === "professional" ? "text-violet-600" : "text-gray-400"}`} />
                  <span className={`text-sm ${accountType === "professional" ? "text-violet-600" : "text-gray-600"}`}>Profesional</span>
                </button>
              </div>
            </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {isSignUp && (
              <div>
                <label className="text-sm text-gray-700 mb-2 block">Nombre completo</label>
                <div className="relative">
                  <input
                    type="text"
                    placeholder="María García"
                    className="w-full px-4 py-3.5 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                  />
                </div>
              </div>
            )}

            <div>
              <label className="text-sm text-gray-700 mb-2 block">Correo electrónico</label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="correo@ejemplo.com"
                  className="w-full pl-12 pr-4 py-3.5 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
              </div>
            </div>

            <div>
              <label className="text-sm text-gray-700 mb-2 block">Contraseña</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-12 pr-12 py-3.5 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            {!isSignUp && (
              <div className="flex items-center justify-between">
                <label className="flex items-center gap-2 text-sm text-gray-600">
                  <input type="checkbox" className="w-4 h-4 rounded border-gray-300 text-violet-600 focus:ring-violet-500" />
                  Recordarme
                </label>
                <button type="button" className="text-sm text-violet-600">
                  ¿Olvidaste tu contraseña?
                </button>
              </div>
            )}

            {isSignUp && (
              <label className="flex items-start gap-2 text-sm text-gray-600">
                <input type="checkbox" className="w-4 h-4 rounded border-gray-300 text-violet-600 focus:ring-violet-500 mt-0.5" />
                <span>Acepto los <button type="button" className="text-violet-600 underline">términos y condiciones</button> y la <button type="button" className="text-violet-600 underline">política de privacidad</button></span>
              </label>
            )}

            <button
              type="submit"
              className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-4 rounded-xl hover:from-violet-700 hover:to-purple-700 transition-all shadow-lg shadow-violet-500/30"
            >
              {isSignUp ? "Crear cuenta" : "Iniciar sesión"}
            </button>
          </form>

          {/* Divider */}
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200" />
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-4 bg-white text-gray-500">o continúa con</span>
            </div>
          </div>

          {/* Social Login */}
          <div className="grid grid-cols-2 gap-3">
            <button className="flex items-center justify-center gap-2 px-4 py-3 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              <span className="text-sm text-gray-700">Google</span>
            </button>
            <button className="flex items-center justify-center gap-2 px-4 py-3 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors">
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
              </svg>
              <span className="text-sm text-gray-700">Facebook</span>
            </button>
          </div>

          {/* Toggle Sign Up/Login */}
          <div className="text-center pt-2">
            <p className="text-sm text-gray-600">
              {isSignUp ? "¿Ya tienes cuenta?" : "¿No tienes una cuenta?"}{" "}
              <button
                type="button"
                onClick={() => setIsSignUp(!isSignUp)}
                className="text-violet-600"
              >
                {isSignUp ? "Iniciar sesión" : "Regístrate"}
              </button>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
