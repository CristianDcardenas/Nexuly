import { Outlet, useLocation, Link } from "react-router";
import { Home, Calendar, Clock, Settings, User } from "lucide-react";

export function ProfessionalLayout() {
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === '/professional') return location.pathname === '/professional';
    return location.pathname.startsWith(path);
  };

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-10">
        <div className="max-w-md mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-gradient-to-br from-violet-500 to-purple-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">N</span>
            </div>
            <div>
              <span className="font-semibold text-lg text-gray-900">Nexuly</span>
              <span className="text-xs text-violet-600 ml-1 font-medium">Pro</span>
            </div>
          </div>
          <div className="flex items-center gap-1">
            <Link to="/professional/notifications" className="p-2 rounded-full hover:bg-gray-100 relative">
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
              <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            </Link>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <div className="max-w-md mx-auto pb-20">
          <Outlet />
        </div>
      </main>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto flex justify-around py-2">
          <Link to="/professional" className="flex flex-col items-center p-2 flex-1">
            <Home className={`w-6 h-6 ${isActive('/professional') && !location.pathname.includes('/professional/') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/professional') && !location.pathname.includes('/professional/') ? 'text-violet-600' : 'text-gray-600'}`}>Inicio</span>
          </Link>
          <Link to="/professional/requests" className="flex flex-col items-center p-2 flex-1">
            <Calendar className={`w-6 h-6 ${isActive('/professional/requests') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/professional/requests') ? 'text-violet-600' : 'text-gray-600'}`}>Solicitudes</span>
          </Link>
          <Link to="/professional/availability" className="flex flex-col items-center p-2 flex-1">
            <Clock className={`w-6 h-6 ${isActive('/professional/availability') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/professional/availability') ? 'text-violet-600' : 'text-gray-600'}`}>Horarios</span>
          </Link>
          <Link to="/professional/services" className="flex flex-col items-center p-2 flex-1">
            <Settings className={`w-6 h-6 ${isActive('/professional/services') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/professional/services') ? 'text-violet-600' : 'text-gray-600'}`}>Servicios</span>
          </Link>
          <Link to="/professional/profile" className="flex flex-col items-center p-2 flex-1">
            <User className={`w-6 h-6 ${isActive('/professional/profile') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/professional/profile') ? 'text-violet-600' : 'text-gray-600'}`}>Perfil</span>
          </Link>
        </div>
      </nav>
    </div>
  );
}
