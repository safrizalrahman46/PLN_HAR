import React from 'react';
import { useNavigate } from 'react-router-dom';

interface TopAppBarProps {
  title?: string;
  showBack?: boolean;
  onBack?: () => void;
}

export const TopAppBar: React.FC<TopAppBarProps> = ({ title = 'PLN Nusa Daya', showBack = false, onBack }) => {
  const navigate = useNavigate();

  return (
    <header className="fixed top-0 left-0 w-full z-50 flex justify-between items-center h-[64px] px-4 bg-surface shadow-sm border-b border-outline-variant/30">
      <div className="flex items-center gap-3">
        {showBack ? (
          <button 
            onClick={onBack || (() => navigate(-1))}
            className="p-2 text-primary active:opacity-80 transition-opacity hover:bg-surface-container-high rounded-full"
          >
            <span className="material-symbols-outlined">arrow_back</span>
          </button>
        ) : (
          <button className="p-2 text-primary active:opacity-80 transition-opacity hover:bg-surface-container-high rounded-full">
            <span className="material-symbols-outlined">menu</span>
          </button>
        )}
        <h1 className="font-bold text-lg text-primary">{title}</h1>
      </div>
      <div className="relative">
        <button className="p-2 text-primary active:opacity-80 transition-opacity hover:bg-surface-container-high rounded-full relative">
          <span className="material-symbols-outlined">notifications</span>
          <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-error rounded-full border-2 border-surface"></span>
        </button>
      </div>
    </header>
  );
};
