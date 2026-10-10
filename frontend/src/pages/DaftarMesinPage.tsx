import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { BottomNav } from '../components/BottomNav';
import { apiService } from '../services/api';

export const DaftarMesinPage: React.FC = () => {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<'Semua' | 'Normal' | 'Gangguan' | 'Maintenance'>('Semua');
  const [activeUnit, setActiveUnit] = useState<{ kd_unit: string; nama_unit: string }>({
    kd_unit: '0283',
    nama_unit: 'ULD MUARA PAHU',
  });
  const [mesinList, setMesinList] = useState<any[]>([]);

  useEffect(() => {
    const saved = localStorage.getItem('pln_selected_unit') || localStorage.getItem('selected_unit');
    let kdUnit = '0283';
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed.kd_unit) {
          setActiveUnit(parsed);
          kdUnit = parsed.kd_unit;
        }
      } catch {
        // default
      }
    }

    const loadMachines = async () => {
      const data = await apiService.getMachines(kdUnit);
      if (data && data.length > 0) {
        setMesinList(data);
      }
    };
    loadMachines();
  }, []);

  const filteredMesin = mesinList.filter((m) => {
    const name = m.nama_mesin || m.kode || '';
    const matchQuery = name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (m.id_mesin || m.id || '').toString().includes(searchQuery);
    const status = (m.status || 'OPERASI').toUpperCase();

    if (selectedFilter === 'Semua') return matchQuery;
    if (selectedFilter === 'Normal') return matchQuery && (status === 'OPERASI' || status === 'NORMAL');
    if (selectedFilter === 'Gangguan') return matchQuery && (status === 'GANGGUAN' || status === 'RUSAK');
    if (selectedFilter === 'Maintenance') return matchQuery && (status === 'MAINTENANCE' || status === 'STANDBY');
    return matchQuery;
  });

  return (
    <div className="bg-background text-on-background min-h-screen pb-[100px]">
      <TopAppBar title="Pilih Mesin Pembangkit" />

      {/* Content Canvas */}
      <main className="pt-[64px] px-4 max-w-2xl mx-auto space-y-4">
        {/* Unit Location Header Badge */}
        <div className="mt-3 flex items-center justify-between p-3 bg-primary-fixed/40 border border-primary/20 rounded-xl">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary text-xl">factory</span>
            <div>
              <p className="text-[10px] font-extrabold uppercase text-on-surface-variant">Unit Layanan Aktif</p>
              <h2 className="text-sm font-extrabold text-primary">{activeUnit.nama_unit} ({activeUnit.kd_unit})</h2>
            </div>
          </div>
          <button
            onClick={() => navigate('/pilih-unit')}
            className="text-xs font-bold text-primary underline"
          >
            Ganti Unit
          </button>
        </div>

        {/* Search and Filter Section */}
        <section className="sticky top-[64px] bg-background z-40 py-2 border-b border-outline-variant/30 space-y-3">
          {/* Search Bar */}
          <div className="relative flex items-center">
            <span className="material-symbols-outlined absolute left-4 text-on-surface-variant">search</span>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari nomor seri, kode, atau merek mesin..."
              className="w-full h-12 pl-12 pr-4 bg-surface-container-lowest border border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary placeholder:text-on-surface-variant text-sm transition-all"
            />
          </div>

          {/* Filter Chips */}
          <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
            {(['Semua', 'Normal', 'Gangguan', 'Maintenance'] as const).map((filter) => (
              <button
                key={filter}
                onClick={() => setSelectedFilter(filter)}
                className={`whitespace-nowrap px-4 py-1.5 rounded-full text-xs font-bold transition-all ${
                  selectedFilter === filter
                    ? 'bg-primary text-on-primary shadow-sm'
                    : 'bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest'
                }`}
              >
                {filter}
              </button>
            ))}
          </div>
        </section>

        {/* Machine List */}
        <section className="space-y-3">
          {filteredMesin.map((mesin) => {
            const statusUpper = (mesin.status || 'OPERASI').toUpperCase();
            const isNormal = statusUpper === 'OPERASI' || statusUpper === 'NORMAL';
            const isGangguan = statusUpper === 'GANGGUAN' || statusUpper === 'RUSAK';

            return (
              <div
                key={mesin.id_mesin || mesin.id}
                onClick={() => navigate('/buat-har', { state: { mesinKode: mesin.nama_mesin || mesin.kode } })}
                className="bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden shadow-sm active:scale-[0.98] transition-transform flex relative group cursor-pointer"
              >
                {/* Status Strip */}
                <div
                  className={`w-1.5 h-full ${
                    isNormal ? 'bg-emerald-500' : isGangguan ? 'bg-red-500' : 'bg-amber-500'
                  }`}
                ></div>

                <div className="p-4 flex-1 flex flex-col gap-2">
                  <div className="flex justify-between items-start">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-surface-container rounded-lg flex items-center justify-center text-primary">
                        <span className="material-symbols-outlined">engineering</span>
                      </div>
                      <div>
                        <h3 className="font-bold text-sm leading-tight text-on-surface">
                          {mesin.nama_mesin || mesin.kode}
                        </h3>
                        <p className="text-on-surface-variant text-xs mt-0.5">
                          DT: <span className="font-bold text-primary">{mesin.dt ?? 800} kW</span> • s/n: {mesin.sn || 'SN-PLN-2026'}
                        </p>
                      </div>
                    </div>

                    <div
                      className={`px-2 py-0.5 rounded-full flex items-center gap-1 border ${
                        isNormal
                          ? 'bg-emerald-100 border-emerald-500/20 text-emerald-800'
                          : isGangguan
                          ? 'bg-red-100 border-red-500/20 text-red-800'
                          : 'bg-amber-100 border-amber-500/20 text-amber-800'
                      }`}
                    >
                      <span
                        className={`w-2 h-2 rounded-full ${
                          isNormal ? 'bg-emerald-500' : isGangguan ? 'bg-red-500 animate-pulse' : 'bg-amber-500'
                        }`}
                      ></span>
                      <span className="text-[10px] font-bold uppercase tracking-wider">
                        {mesin.status || 'OPERASI'}
                      </span>
                    </div>
                  </div>

                  <div className="flex justify-between items-end mt-2">
                    <div className="text-on-surface-variant flex items-center gap-1 text-xs">
                      <span className="material-symbols-outlined text-[16px]">fingerprint</span>
                      <span className="font-bold">ID: {mesin.id_mesin || mesin.id}</span>
                    </div>
                    <div className="flex items-center gap-1 text-primary font-bold text-xs">
                      <span>Buat Laporan HAR</span>
                      <span className="material-symbols-outlined text-base">chevron_right</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </section>
      </main>

      <BottomNav />
    </div>
  );
};
