import { RouterProvider } from 'react-router';
import { router } from './routes';
import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    // Set theme color for mobile browsers
    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', '#8b5cf6'); // violet-500
    } else {
      const meta = document.createElement('meta');
      meta.name = 'theme-color';
      meta.content = '#8b5cf6'; // violet-500
      document.head.appendChild(meta);
    }
  }, []);

  return <RouterProvider router={router} />;
}