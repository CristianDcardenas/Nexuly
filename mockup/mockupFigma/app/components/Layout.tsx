import { Outlet, useLocation, Link } from "react-router";
import { Home, Search, Calendar, MessageSquare, User, Sparkles } from "lucide-react";

export function Layout() {
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-10">
        <div className="max-w-md mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-gradient-to-br from-violet-500 to-purple-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">N</span>
            </div>
            <span className="font-semibold text-lg">Nexuly</span>
          </div>
          <div className="flex items-center gap-1">
            <Link to="/ai-symptoms" className="p-2 rounded-full hover:bg-violet-50">
              <Sparkles className="w-5 h-5 text-violet-600" />
            </Link>
            <button className="p-2 rounded-full hover:bg-gray-100">
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
            </button>
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
          <Link to="/" className="flex flex-col items-center p-2 flex-1">
            <Home className={`w-6 h-6 ${isActive('/') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/') ? 'text-violet-600' : 'text-gray-600'}`}>Inicio</span>
          </Link>
          <Link to="/search" className="flex flex-col items-center p-2 flex-1">
            <Search className={`w-6 h-6 ${isActive('/search') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/search') ? 'text-violet-600' : 'text-gray-600'}`}>Buscar</span>
          </Link>
          <Link to="/booking/1" className="flex flex-col items-center p-2 flex-1">
            <Calendar className={`w-6 h-6 ${isActive('/booking') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/booking') ? 'text-violet-600' : 'text-gray-600'}`}>Reservas</span>
          </Link>
          <Link to="/history" className="flex flex-col items-center p-2 flex-1">
            <MessageSquare className={`w-6 h-6 ${isActive('/history') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/history') ? 'text-violet-600' : 'text-gray-600'}`}>Historial</span>
          </Link>
          <Link to="/user-profile" className="flex flex-col items-center p-2 flex-1">
            <User className={`w-6 h-6 ${isActive('/user-profile') ? 'text-violet-600' : 'text-gray-400'}`} />
            <span className={`text-xs mt-1 ${isActive('/user-profile') ? 'text-violet-600' : 'text-gray-600'}`}>Perfil</span>
          </Link>
        </div>
      </nav>
    </div>
  );
}
