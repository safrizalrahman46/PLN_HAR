import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [username, setUsername] = useState('kal3');
  const [password, setPassword] = useState('password');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage('');
    try {
      await apiService.login(username, password);
      navigate('/pilih-unit');
    } catch (err: any) {
      setErrorMessage(err?.response?.data?.detail || 'Username atau password salah.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-surface overflow-x-hidden relative">
      {/* Hero/Background Decoration Section */}
      <div className="fixed top-0 left-0 w-full h-[309px] overflow-hidden z-0">
        <div className="absolute inset-0 bg-primary opacity-90"></div>
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{
            backgroundImage: `url('https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=1200&q=80')`,
          }}
        ></div>
        <div className="absolute inset-0 bg-gradient-to-b from-primary/30 to-surface"></div>
      </div>

      {/* Main Content Container */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-4 pt-20 pb-10">
        {/* Brand Logo Area */}
        <div className="mb-6 text-center">
          <div className="bg-surface-container-lowest p-4 rounded-full shadow-sm inline-block mb-3 border border-outline-variant/30">
            <span
              className="material-symbols-outlined text-[48px] text-primary"
              style={{ fontVariationSettings: "'FILL' 1" }}
            >
              engineering
            </span>
          </div>
          <h1 className="text-3xl font-extrabold text-white drop-shadow-md tracking-tight">
            PLN Nusa Daya
          </h1>
          <p className="text-xs font-semibold text-primary-fixed uppercase tracking-wider mt-1">
            Sistem HAR & WACB Logsheet PLTD
          </p>
        </div>

        {/* Login Card */}
        <div className="w-full max-w-md bg-surface-container-lowest rounded-xl login-card relative overflow-hidden border border-outline-variant/30 px-6 py-8 sm:px-10">
          {/* Left Side Identity Strip */}
          <div className="status-strip"></div>

          <div className="mb-6">
            <h2 className="text-xl font-bold text-on-surface mb-1">Selamat Datang</h2>
            <p className="text-sm text-on-surface-variant">
              Masuk untuk mengakses sistem HAR PLN Nusa Daya
            </p>
          </div>

          {errorMessage && (
            <div className="mb-4 p-3 bg-error-container text-on-error-container rounded-lg text-sm font-semibold border border-error/20">
              {errorMessage}
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Username Field */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-on-surface-variant px-1" htmlFor="username">
                Username
              </label>
              <div className="relative flex items-center group">
                <span className="absolute left-4 material-symbols-outlined text-outline group-focus-within:text-primary">
                  person
                </span>
                <input
                  id="username"
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="Masukkan ID atau username"
                  className="w-full h-12 pl-12 pr-4 bg-surface-container-low border border-outline-variant rounded-lg text-sm text-on-surface focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                  required
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-on-surface-variant px-1" htmlFor="password">
                Kata Sandi
              </label>
              <div className="relative flex items-center group">
                <span className="absolute left-4 material-symbols-outlined text-outline group-focus-within:text-primary">
                  lock
                </span>
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Masukkan kata sandi"
                  className="w-full h-12 pl-12 pr-12 bg-surface-container-low border border-outline-variant rounded-lg text-sm text-on-surface focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 p-2 text-on-surface-variant hover:bg-surface-container-high rounded-full transition-colors"
                >
                  <span className="material-symbols-outlined text-[20px]">
                    {showPassword ? 'visibility_off' : 'visibility'}
                  </span>
                </button>
              </div>
            </div>

            {/* Remember Me & Quick Admin Fill */}
            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center cursor-pointer group">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-4 h-4 rounded border-outline-variant text-primary focus:ring-primary mr-2"
                />
                <span className="text-xs text-on-surface-variant group-hover:text-on-surface transition-colors">
                  Ingat saya
                </span>
              </label>
              <button
                type="button"
                onClick={() => {
                  setUsername('kal3');
                  setPassword('password');
                }}
                className="text-xs font-bold text-primary hover:underline"
              >
                Akun kal3
              </button>
            </div>

            {/* Action Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full h-12 mt-4 bg-primary text-on-primary rounded-lg font-bold hover:bg-primary-container hover:shadow-lg active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {isLoading ? (
                <span className="animate-spin material-symbols-outlined">progress_activity</span>
              ) : (
                <>
                  <span>Masuk</span>
                  <span className="material-symbols-outlined">login</span>
                </>
              )}
            </button>
          </form>

          {/* Maintenance System Notice */}
          <div className="mt-6 pt-4 border-t border-outline-variant flex items-center justify-center gap-2">
            <span className="material-symbols-outlined text-on-surface-variant text-[18px]">bolt</span>
            <span className="text-xs text-on-surface-variant font-medium">
              Sistem Pemeliharaan Mesin Terpadu
            </span>
          </div>
        </div>

        {/* Footer Identity */}
        <footer className="mt-auto pt-6 text-center">
          <p className="text-xs text-on-surface-variant/80">
            © 2026 <span className="font-semibold text-on-surface-variant">PLN Nusa Daya</span>. <br />
            Divisi HAR & Monitoring PLTD - Regional Kalimantan 3
          </p>
        </footer>
      </main>
    </div>
  );
};
