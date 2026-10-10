import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { BottomNav } from '../components/BottomNav';
import { apiService } from '../services/api';

export const DashboardPage: React.FC = () => {
  const navigate = useNavigate();
  const [activeShift, setActiveShift] = useState<'ALL' | 'PAGI' | 'SIANG' | 'SORE' | 'MALAM'>('ALL');
  const [activeUnit, setActiveUnit] = useState<{ kd_unit: string; nama_unit: string; nama_area?: string }>({
    kd_unit: '0283',
    nama_unit: 'ULD MUARA PAHU',
    nama_area: 'SITE BONTANG',
  });
  const [stats, setStats] = useState<any>({
    har_stats: { total: 24, pending_approval: 4, in_progress: 6, completed: 14 },
    machine_stats: { total: 10, normal: 8, gangguan: 2 },
  });
  const [harList, setHarList] = useState<any[]>([]);
  const [amcList, setAmcList] = useState<any[]>([]);

  useEffect(() => {
    // 1. Read selected unit
    const saved = localStorage.getItem('pln_selected_unit') || localStorage.getItem('selected_unit');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed.kd_unit && parsed.nama_unit) {
          setActiveUnit(parsed);
        }
      } catch {
        // default
      }
    }

    // 2. Load dynamic data
    const loadData = async () => {
      const kdUnit = saved ? JSON.parse(saved).kd_unit : '0283';
      const [statsData, harData, amcData] = await Promise.all([
        apiService.getDashboardStats(kdUnit),
        apiService.getHARReports(kdUnit),
        apiService.getAMCReports(),
      ]);
      if (statsData) setStats(statsData);
      if (harData) setHarList(harData);
      if (amcData) setAmcList(amcData);
    };

    loadData();
  }, []);

  // WACB 24-Hour Slots
  const slotsData = Array.from({ length: 24 }, (_, i) => {
    const hour = (i + 1).toString().padStart(2, '0');
    const slot = `${hour}:00`;
    let status: 'wacb' | 'draft' | 'empty' = 'empty';
    if ([1, 2, 3, 4, 8, 9, 10, 14].includes(i + 1)) status = 'wacb';
    else if ([5, 11, 15].includes(i + 1)) status = 'draft';

    let shift: 'PAGI' | 'SIANG' | 'SORE' | 'MALAM' = 'MALAM';
    if (i >= 6 && i < 12) shift = 'PAGI';
    else if (i >= 12 && i < 16) shift = 'SIANG';
    else if (i >= 16 && i < 22) shift = 'SORE';

    return { slot, status, shift, hourNum: i + 1 };
  });

  const filteredSlots = slotsData.filter((item) => {
    if (activeShift === 'ALL') return true;
    return item.shift === activeShift;
  });

  const filledCount = slotsData.filter((s) => s.status === 'wacb').length;
  const currentUnitAmc = amcList.filter(
    (a) => a.unit_pembangkit?.toLowerCase().includes(activeUnit.nama_unit?.toLowerCase().replace('uld ', ''))
  );

  return (
    <div className="bg-surface text-on-surface min-h-screen pb-[100px]">
      <TopAppBar title="PLN Nusa Daya HAR" />

      {/* Main Canvas */}
      <main className="mt-[64px] px-4 pt-4 max-w-2xl mx-auto space-y-6">
        {/* Welcome Section */}
        <section>
          <div className="flex flex-col gap-1.5">
            <h1 className="text-xl font-bold text-on-surface">Selamat Datang, Supervisor / Teknisi</h1>
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-on-surface-variant text-xs">Divisi Harkat & Pemeliharaan</span>
              <span className="w-1 h-1 rounded-full bg-outline"></span>
              {/* Unit Switcher Button */}
              <button
                onClick={() => navigate('/pilih-unit')}
                className="flex items-center text-primary font-bold text-xs bg-primary-fixed px-3 py-1 rounded-full border border-primary/20 hover:bg-primary-container hover:text-white transition-all shadow-xs"
              >
                <span className="material-symbols-outlined text-[14px] mr-1">location_on</span>
                {activeUnit.nama_unit} ({activeUnit.kd_unit})
                <span className="material-symbols-outlined text-[14px] ml-1">sync_alt</span>
              </button>
            </div>
          </div>
        </section>

        {/* AMC Disruption Alert Banner if any */}
        {currentUnitAmc.length > 0 && (
          <section className="bg-red-50 border-2 border-red-300 rounded-xl p-4 text-red-900 shadow-sm space-y-2">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-red-600">warning</span>
              <span className="text-xs font-black uppercase tracking-wider text-red-700">
                Peringatan Gangguan AMC KIT KALTIMRA 2026
              </span>
            </div>
            {currentUnitAmc.map((amc, idx) => (
              <div key={idx} className="bg-white/90 p-2.5 rounded-lg border border-red-200 text-xs">
                <div className="flex justify-between font-bold">
                  <span>{amc.merk} {amc.tipe} (DT: {amc.dtp} kW)</span>
                  <span className="bg-red-600 text-white text-[10px] px-2 py-0.5 rounded font-black">{amc.status}</span>
                </div>
                <p className="text-gray-700 mt-1">{amc.indikasi_gangguan}</p>
                <p className="text-gray-500 text-[10px] mt-0.5">PIC: {amc.pic}</p>
              </div>
            ))}
          </section>
        )}

        {/* Summary Grid (Bento Style) */}
        <section className="grid grid-cols-2 gap-3">
          {/* Total Card */}
          <div className="col-span-2 p-4 bg-surface-container-low rounded-xl custom-shadow flex items-center justify-between border-l-4 border-primary border border-outline-variant/30">
            <div>
              <p className="text-on-surface-variant text-xs font-semibold">Total HAR & Logsheet</p>
              <p className="text-3xl font-extrabold text-primary">{stats.har_stats?.total || 24}</p>
            </div>
            <div className="bg-primary-container p-3 rounded-xl text-white flex items-center justify-center">
              <span className="material-symbols-outlined text-2xl" style={{ fontVariationSettings: "'FILL' 1" }}>
                analytics
              </span>
            </div>
          </div>

          {/* Approval Card */}
          <div className="p-4 bg-surface-container-low rounded-xl custom-shadow flex flex-col gap-1 border-l-4 border-secondary-container border border-outline-variant/30">
            <p className="text-on-surface-variant text-xs font-semibold">Menunggu Approval</p>
            <div className="flex items-baseline gap-1.5">
              <p className="text-2xl font-bold text-secondary">{stats.har_stats?.pending_approval || 4}</p>
              <span className="text-on-surface-variant text-[10px]">Tiket HAR</span>
            </div>
          </div>

          {/* In Progress Card */}
          <div className="p-4 bg-surface-container-low rounded-xl custom-shadow flex flex-col gap-1 border-l-4 border-primary-container border border-outline-variant/30">
            <p className="text-on-surface-variant text-xs font-semibold">Sedang Dikerjakan</p>
            <div className="flex items-baseline gap-1.5">
              <p className="text-2xl font-bold text-primary-container">{stats.har_stats?.in_progress || 6}</p>
              <span className="text-on-surface-variant text-[10px]">Tiket HAR</span>
            </div>
          </div>

          {/* Done Card */}
          <div className="col-span-2 p-4 bg-surface-container-low rounded-xl custom-shadow flex items-center justify-between border-l-4 border-emerald-600 border border-outline-variant/30">
            <div>
              <p className="text-on-surface-variant text-xs font-semibold">Selesai / Approved</p>
              <p className="text-2xl font-bold text-emerald-700">{stats.har_stats?.completed || 14}</p>
            </div>
            <div className="bg-emerald-100 p-2.5 rounded-full flex items-center justify-center">
              <span className="material-symbols-outlined text-emerald-700 text-xl" style={{ fontVariationSettings: "'FILL' 1" }}>
                check_circle
              </span>
            </div>
          </div>
        </section>

        {/* 24-Hour Logsheet Matrix View */}
        <section className="bg-surface-container-lowest p-4 rounded-xl custom-shadow border border-outline-variant/40 space-y-4">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-base font-bold text-on-surface">Matriks WACB 24 Jam</h2>
              <p className="text-xs text-on-surface-variant">
                Terisi: <span className="font-bold text-primary">{filledCount} dari 24 jam</span>
              </p>
            </div>
            <button
              onClick={() => navigate('/buat-har')}
              className="bg-primary text-on-primary px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1 active:scale-95 transition-transform"
            >
              <span className="material-symbols-outlined text-base">add</span>
              Input Baru
            </button>
          </div>

          {/* Filter Shifts */}
          <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
            {(['ALL', 'PAGI', 'SIANG', 'SORE', 'MALAM'] as const).map((shift) => (
              <button
                key={shift}
                onClick={() => setActiveShift(shift)}
                className={`px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap transition-colors ${
                  activeShift === shift
                    ? 'bg-primary text-on-primary'
                    : 'bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest'
                }`}
              >
                {shift === 'ALL' ? 'Semua Shift' : `Shift ${shift}`}
              </button>
            ))}
          </div>

          {/* Slots Grid */}
          <div className="grid grid-cols-4 sm:grid-cols-6 gap-2">
            {filteredSlots.map(({ slot, status }) => (
              <button
                key={slot}
                onClick={() => navigate('/buat-har', { state: { timeSlot: slot } })}
                className={`flex flex-col items-center justify-center p-2 rounded-lg border text-xs font-bold transition-all active:scale-95 ${
                  status === 'wacb'
                    ? 'bg-emerald-100 border-emerald-500 text-emerald-900 shadow-sm'
                    : status === 'draft'
                    ? 'bg-amber-100 border-amber-500 text-amber-900'
                    : 'bg-surface-container-low border-outline-variant text-on-surface-variant hover:border-primary'
                }`}
              >
                <span>{slot}</span>
                <span className="text-[9px] mt-0.5">
                  {status === 'wacb' ? '🟢 WACB' : status === 'draft' ? '🟡 Draft' : '🔴 Kosong'}
                </span>
              </button>
            ))}
          </div>

          {/* Legend */}
          <div className="flex items-center justify-around pt-2 text-[11px] border-t border-outline-variant/30 text-on-surface-variant">
            <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-emerald-500"></span> WACB Terkirim</span>
            <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-amber-500"></span> Draft</span>
            <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-slate-400"></span> Belum Diisi</span>
          </div>
        </section>

        {/* Recent Activity Section */}
        <section>
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-base font-bold text-on-surface">Daftar Tiket HAR Terbaru</h2>
            <button
              onClick={() => navigate('/riwayat-har')}
              className="text-primary font-semibold text-xs hover:underline"
            >
              Lihat Semua
            </button>
          </div>
          <div className="flex flex-col gap-3">
            {harList.slice(0, 3).map((item, idx) => (
              <div
                key={item.id || idx}
                onClick={() => navigate(`/detail-har/${item.id || 1}`)}
                className="bg-surface-container-lowest p-4 rounded-xl custom-shadow border-l-4 border-primary-container border border-outline-variant relative group active:bg-surface-container-high transition-colors cursor-pointer"
              >
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <span className="text-primary font-bold text-xs">{item.har_number}</span>
                    <h3 className="font-bold text-sm text-on-surface">{item.machine_name || item.unit_name}</h3>
                  </div>
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider ${
                    item.maintenance_type === 'corrective'
                      ? 'bg-red-100 text-red-700'
                      : 'bg-primary-container/10 text-primary-container'
                  }`}>
                    {item.maintenance_type || 'Preventive'}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <div className={`flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                    item.status === 'approved'
                      ? 'bg-emerald-100 text-emerald-800'
                      : 'bg-amber-100 text-amber-800'
                  }`}>
                    <span className={`w-2 h-2 rounded-full ${item.status === 'approved' ? 'bg-emerald-600' : 'bg-amber-600 animate-pulse'}`}></span>
                    {item.status === 'approved' ? 'Disetujui / Selesai' : 'Menunggu Approval'}
                  </div>
                  <span className="material-symbols-outlined text-outline">chevron_right</span>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Quick Links Card */}
        <section className="grid grid-cols-2 gap-3">
          <button
            onClick={() => navigate('/daftar-mesin')}
            className="p-3 bg-surface-container-low rounded-xl border border-outline-variant/40 flex items-center gap-2.5 text-left hover:border-primary active:scale-95 transition-all"
          >
            <span className="material-symbols-outlined text-primary text-2xl">precision_manufacturing</span>
            <div>
              <p className="text-xs font-bold text-on-surface">Data Mesin</p>
              <p className="text-[10px] text-on-surface-variant">Pembangkit PLTD</p>
            </div>
          </button>
          <button
            onClick={() => navigate('/riwayat-har')}
            className="p-3 bg-surface-container-low rounded-xl border border-outline-variant/40 flex items-center gap-2.5 text-left hover:border-primary active:scale-95 transition-all"
          >
            <span className="material-symbols-outlined text-emerald-600 text-2xl">table_view</span>
            <div>
              <p className="text-xs font-bold text-on-surface">Export Excel</p>
              <p className="text-[10px] text-on-surface-variant">Download .xlsx</p>
            </div>
          </button>
        </section>
      </main>

      <BottomNav />
    </div>
  );
};
