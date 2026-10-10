import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { BottomNav } from '../components/BottomNav';
import { apiService } from '../services/api';

export const RiwayatHARPage: React.FC = () => {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [downloadToast, setDownloadToast] = useState(false);
  const [activeUnit, setActiveUnit] = useState<{ kd_unit: string; nama_unit: string }>({
    kd_unit: '0283',
    nama_unit: 'ULD MUARA PAHU',
  });
  const [historyItems, setHistoryItems] = useState<any[]>([]);

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

    const loadHAR = async () => {
      const data = await apiService.getHARReports(kdUnit);
      if (data && data.length > 0) {
        setHistoryItems(data);
      }
    };
    loadHAR();
  }, []);

  const filteredHistory = historyItems.filter((item) => {
    const num = item.har_number || item.id || '';
    const mesin = item.machine_name || item.unit_name || item.mesin || '';
    return num.toLowerCase().includes(searchQuery.toLowerCase()) ||
      mesin.toLowerCase().includes(searchQuery.toLowerCase());
  });

  const handleExportExcel = () => {
    setDownloadToast(true);
    // Connect with LOGSHEETWEBPLNNUSADAYA Excel endpoint
    try {
      window.open('http://127.0.0.1:8080/api/export/har/excel', '_blank');
    } catch {
      // fallback
    }
    setTimeout(() => setDownloadToast(false), 4000);
  };

  return (
    <div className="bg-background text-on-surface font-body-md min-h-screen pb-[100px]">
      <TopAppBar title="Riwayat HAR & Logsheet" />

      {/* Toast Notification */}
      {downloadToast && (
        <div className="fixed top-20 left-1/2 -translate-x-1/2 z-50 bg-emerald-700 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-2 border border-emerald-500 animate-bounce text-xs font-bold">
          <span className="material-symbols-outlined text-xl">download_done</span>
          <span>Laporan Excel (.xlsx) Berhasil Diunduh!</span>
        </div>
      )}

      <main className="pt-[64px] px-4 max-w-2xl mx-auto space-y-5">
        {/* Header Unit Info */}
        <div className="mt-3 flex items-center justify-between p-3 bg-primary-fixed/40 border border-primary/20 rounded-xl">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary text-xl">history_edu</span>
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

        {/* Search & Filter Section */}
        <section className="space-y-3">
          {/* Search Bar */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
              <span className="material-symbols-outlined text-outline">search</span>
            </div>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari nomor tiket HAR atau nama mesin..."
              className="w-full h-12 pl-12 pr-4 bg-surface-container-low border border-outline-variant rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-colors text-xs font-semibold text-on-surface"
            />
          </div>

          {/* Horizontal Action Bar */}
          <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1 items-center">
            <button
              onClick={() => navigate('/buat-har')}
              className="flex items-center gap-1.5 px-3.5 py-1.5 bg-primary text-on-primary rounded-full text-xs font-bold whitespace-nowrap shadow-xs active:scale-95 transition-transform"
            >
              <span className="material-symbols-outlined text-base">add</span>
              Buat HAR Baru
            </button>
            <button
              onClick={handleExportExcel}
              className="flex items-center gap-1.5 px-3.5 py-1.5 bg-emerald-600 text-white rounded-full text-xs font-bold whitespace-nowrap shadow-sm hover:bg-emerald-700 active:scale-95 transition-transform ml-auto"
            >
              <span className="material-symbols-outlined text-base">file_download</span>
              Export Excel (.xlsx)
            </button>
          </div>
        </section>

        {/* History List */}
        <section className="space-y-3">
          <h2 className="text-xs font-extrabold text-on-surface-variant uppercase tracking-wider">
            Daftar Pekerjaan HAR ({filteredHistory.length} Tiket)
          </h2>

          {filteredHistory.map((item) => {
            const isApproved = item.status === 'approved' || item.status === 'Selesai';
            return (
              <div
                key={item.id}
                onClick={() => navigate(`/detail-har/${item.id}`)}
                className="relative bg-surface rounded-xl shadow-sm border border-outline-variant overflow-hidden flex active:scale-[0.98] transition-transform cursor-pointer"
              >
                <div
                  className={`w-1.5 h-full ${isApproved ? 'bg-emerald-600' : 'bg-amber-500'}`}
                ></div>
                <div className="flex-1 p-4 flex flex-col gap-1">
                  <div className="flex justify-between items-start">
                    <span className="font-bold text-sm text-primary">{item.har_number || item.id}</span>
                    <div
                      className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-tighter border ${
                        isApproved
                          ? 'bg-green-100 border-green-200 text-green-800'
                          : 'bg-amber-100 border-amber-200 text-amber-800'
                      }`}
                    >
                      {isApproved ? 'Approved / Selesai' : 'Menunggu Approval'}
                    </div>
                  </div>
                  <p className="font-bold text-xs text-on-surface">
                    {item.machine_name || item.unit_name || item.mesin}
                  </p>
                  <div className="flex items-center justify-between text-on-surface-variant text-xs mt-1">
                    <div className="flex items-center gap-1">
                      <span className="material-symbols-outlined text-base">event</span>
                      <span>{item.date || item.tanggal || 'Agustus 2026'}</span>
                    </div>
                    <span className="text-[11px] font-semibold text-primary">
                      {item.maintenance_type || 'Preventive'}
                    </span>
                  </div>
                </div>
                <div className="flex items-center pr-4">
                  <span className="material-symbols-outlined text-outline">chevron_right</span>
                </div>
              </div>
            );
          })}
        </section>

        {/* Stats Visualization */}
        <section className="p-4 bg-surface-container rounded-2xl border border-outline-variant space-y-3">
          <h3 className="font-bold text-sm text-on-surface">Ringkasan Pemeliharaan Bulanan</h3>
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-surface p-3 rounded-xl shadow-sm border border-outline-variant">
              <p className="text-xs font-semibold text-on-surface-variant">Total HAR</p>
              <p className="text-2xl font-extrabold text-primary">24</p>
            </div>
            <div className="bg-surface p-3 rounded-xl shadow-sm border border-outline-variant">
              <p className="text-xs font-semibold text-on-surface-variant">Approved</p>
              <p className="text-2xl font-extrabold text-emerald-700">14</p>
            </div>
          </div>
          <div className="mt-2 flex items-center justify-center p-2">
            <div className="w-full h-2 bg-surface-container-high rounded-full overflow-hidden flex">
              <div className="h-full bg-emerald-500 w-[70%]"></div>
              <div className="h-full bg-orange-400 w-[20%]"></div>
              <div className="h-full bg-amber-400 w-[10%]"></div>
            </div>
          </div>
          <p className="text-[10px] text-center text-on-surface-variant">70% Selesai Approved • 20% Review • 10% Terjadwal</p>
        </section>
      </main>

      <BottomNav />
    </div>
  );
};
