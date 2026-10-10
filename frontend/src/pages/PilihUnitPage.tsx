import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { apiService } from '../services/api';

interface UnitItem {
  kd_unit: string;
  nama_unit: string;
  kd_region: string;
  kd_area: string;
  nama_area: string;
  latitude?: number;
  longitude?: number;
}

export const PilihUnitPage: React.FC = () => {
  const navigate = useNavigate();
  const [units, setUnits] = useState<UnitItem[]>([]);
  const [selectedKdUnit, setSelectedKdUnit] = useState<string>('0283'); // Default ULD MUARA PAHU
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    const loadUnits = async () => {
      const res = await apiService.getUnits('05');
      if (res.units && res.units.length > 0) {
        setUnits(res.units);
        // Check if there is already a saved unit in localStorage
        const saved = localStorage.getItem('pln_selected_unit') || localStorage.getItem('selected_unit');
        if (saved) {
          try {
            const parsed = JSON.parse(saved);
            if (parsed.kd_unit) {
              setSelectedKdUnit(parsed.kd_unit);
              return;
            }
          } catch {
            // default
          }
        }
        // If not, default to 0283 (Muara Pahu)
        const hasMuaraPahu = res.units.some((u: any) => u.kd_unit === '0283');
        if (hasMuaraPahu) {
          setSelectedKdUnit('0283');
        } else {
          setSelectedKdUnit(res.units[0].kd_unit);
        }
      }
    };
    loadUnits();
  }, []);

  const activeUnit = units.find((u) => u.kd_unit === selectedKdUnit) || {
    kd_unit: '0283',
    nama_unit: 'ULD MUARA PAHU',
    kd_region: '05',
    kd_area: '40',
    nama_area: 'SITE BONTANG',
    latitude: -0.3421,
    longitude: 115.8924,
  };

  const handleLanjutkan = () => {
    setIsLoading(true);
    localStorage.setItem('selected_unit', JSON.stringify(activeUnit));
    localStorage.setItem('pln_selected_unit', JSON.stringify(activeUnit));
    setTimeout(() => {
      setIsLoading(false);
      navigate('/dashboard');
    }, 500);
  };

  return (
    <div className="bg-background text-on-surface flex flex-col min-h-screen">
      <TopAppBar title="Pilih Unit Layanan" showBack />

      {/* Main Content */}
      <main className="flex-grow pt-[72px] pb-[100px] px-4 max-w-md mx-auto w-full">
        {/* Header Text */}
        <div className="mb-6">
          <h2 className="text-xl font-bold text-on-surface mb-1">Pilih Unit Pembangkit</h2>
          <p className="text-xs text-on-surface-variant">
            Pilih lokasi operasional PLTD sebelum memulai pemeliharaan (HAR) & logsheet WACB
          </p>
        </div>

        {/* Step Indicator */}
        <div className="flex items-center gap-2 mb-6">
          <div className="h-1.5 rounded-full flex-grow bg-primary"></div>
          <div className="h-1.5 rounded-full flex-grow bg-primary"></div>
          <div className="h-1.5 rounded-full flex-grow bg-outline-variant"></div>
        </div>

        {/* Selection Form Cluster */}
        <div className="space-y-4">
          {/* Region Dropdown */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-primary ml-1">Region / Wilayah Kerja</label>
            <div className="relative">
              <select
                disabled
                className="w-full h-12 bg-surface-container/60 border border-outline-variant rounded-lg px-4 text-sm text-on-surface appearance-none outline-none cursor-not-allowed font-semibold"
              >
                <option value="05">Kalimantan 3 (Kaltimra & Kalselteng)</option>
              </select>
              <span className="material-symbols-outlined absolute right-4 top-3 pointer-events-none text-on-surface-variant text-sm">
                lock
              </span>
            </div>
          </div>

          {/* Unit Dropdown */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-primary ml-1">Unit Layanan PLTD (ULD)</label>
            <div className="relative">
              <select
                value={selectedKdUnit}
                onChange={(e) => setSelectedKdUnit(e.target.value)}
                className="w-full h-12 bg-surface-container border border-outline-variant rounded-lg px-4 text-sm text-on-surface appearance-none focus:ring-2 focus:ring-primary focus:border-primary outline-none transition-all font-bold"
              >
                {units.map((u) => (
                  <option key={u.kd_unit} value={u.kd_unit}>
                    {u.nama_unit} ({u.kd_unit}) — {u.nama_area}
                  </option>
                ))}
              </select>
              <span className="material-symbols-outlined absolute right-4 top-3 pointer-events-none text-on-surface-variant">
                expand_more
              </span>
            </div>
          </div>
        </div>

        {/* Summary Card (Selected Unit) */}
        <div className="mt-6 p-4 bg-white border border-outline-variant rounded-xl shadow-sm relative overflow-hidden">
          <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-primary"></div>
          <div className="flex items-start gap-3">
            <div className="bg-primary/10 p-3 rounded-xl text-primary flex items-center justify-center">
              <span className="material-symbols-outlined text-2xl" style={{ fontVariationSettings: "'FILL' 1" }}>
                location_on
              </span>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base font-extrabold text-on-surface">{activeUnit.nama_unit}</h3>
                <span className="bg-primary-fixed text-primary text-[10px] font-black px-2 py-0.5 rounded-md">
                  {activeUnit.kd_unit}
                </span>
              </div>
              <p className="text-xs text-on-surface-variant mt-0.5">
                {activeUnit.nama_area}, Wilayah Kerja Kalimantan 3
              </p>
              <div className="mt-2 flex items-center gap-1.5">
                <span className="material-symbols-outlined text-sm text-emerald-600">verified</span>
                <span className="text-xs font-bold text-emerald-700">Geofence GPS 250m & WACB Sinkron Aktif</span>
              </div>
            </div>
          </div>

          {/* Map Coordinates Badge */}
          <div className="mt-4 p-3 rounded-lg bg-surface-container-low border border-outline-variant/40 flex items-center justify-between text-xs font-mono">
            <span className="text-on-surface-variant font-bold">Koordinat Sentral:</span>
            <span className="font-extrabold text-primary">
              {activeUnit.latitude ?? -0.3421}°, {activeUnit.longitude ?? 115.8924}°
            </span>
          </div>
        </div>
      </main>

      {/* Bottom Action Area */}
      <footer className="fixed bottom-0 left-0 w-full p-4 bg-surface border-t border-outline-variant/30 flex flex-col gap-3">
        <div className="max-w-md mx-auto w-full">
          <button
            onClick={handleLanjutkan}
            disabled={isLoading}
            className="w-full h-12 bg-primary text-on-primary rounded-lg font-bold flex items-center justify-center gap-2 active:scale-[0.98] transition-all shadow-md hover:bg-primary-container disabled:opacity-50"
          >
            {isLoading ? (
              <span className="animate-spin material-symbols-outlined">progress_activity</span>
            ) : (
              <>
                <span>Masuk ke Dashboard ({activeUnit.nama_unit})</span>
                <span className="material-symbols-outlined">chevron_right</span>
              </>
            )}
          </button>
        </div>
      </footer>
    </div>
  );
};
