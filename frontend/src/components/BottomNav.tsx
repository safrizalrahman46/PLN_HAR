import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

export const BottomNav: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { path: '/dashboard', label: 'Home', icon: 'home' },
    { path: '/daftar-mesin', label: 'HAR', icon: 'engineering' },
    { path: '/riwayat-har', label: 'Riwayat', icon: 'history' },
    { path: '/pilih-unit', label: 'Profil', icon: 'person' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center h-[80px] px-2 bg-surface-container shadow-md border-t border-outline-variant/30">
      {navItems.map((item) => {
        const isActive = location.pathname === item.path;
        return (
          <button
            key={item.path}
            onClick={() => navigate(item.path)}
            className={`flex flex-col items-center justify-center transition-transform duration-100 ${
              isActive
                ? 'bg-secondary-container text-on-secondary-container rounded-xl px-4 py-2 font-bold shadow-sm active-nav-glow'
                : 'text-on-surface-variant p-2 hover:bg-surface-container-high rounded-xl'
            }`}
          >
            <span
              className="material-symbols-outlined text-2xl"
              style={{ fontVariationSettings: isActive ? "'FILL' 1" : "'FILL' 0" }}
            >
              {item.icon}
            </span>
            <span className="text-xs font-semibold mt-0.5">{item.label}</span>
          </button>
        );
      })}
    </nav>
  );
};
