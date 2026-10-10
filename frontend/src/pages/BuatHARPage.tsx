import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { apiService } from '../services/api';

export const BuatHARPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const initialTimeSlot = (location.state as any)?.timeSlot || '08:00';
  const initialMesinKode = (location.state as any)?.mesinKode || '#01 PLTD';

  const [activeUnit] = useState<{ kd_unit: string; nama_unit: string }>(() => {
    const saved = typeof window !== 'undefined' ? (localStorage.getItem('pln_selected_unit') || localStorage.getItem('selected_unit')) : null;
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed.nama_unit) return parsed;
      } catch {}
    }
    return { kd_unit: '0283', nama_unit: 'ULD MUARA PAHU' };
  });

  const [step, setStep] = useState(1);
  const [jenisHAR, setJenisHAR] = useState('preventive');
  const [priority, setPriority] = useState('NORMAL');
  const [jamMulai, setJamMulai] = useState(initialTimeSlot);
  const [jamSelesai, setJamSelesai] = useState('11:30');
  const [deskripsiTemuan, setDeskripsiTemuan] = useState('Pemeriksaan berkala parameter logsheet WACB.');
  const [tindakan, setTindakan] = useState('Pembersihan elemen filter & monitoring tekanan oli.');
  const [hasilPekerjaan, setHasilPekerjaan] = useState('Normal');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const allHours = Array.from({ length: 25 }, (_, i) => {
    const h = i.toString().padStart(2, '0');
    return `${h}:00`;
  });

  const handleNextStep = async () => {
    if (step < 4) {
      setStep(step + 1);
    } else {
      setIsSubmitting(true);
      const msg = `jam : ${jamMulai}, kode mesin : DEUTZ #01, daya mampu : 450, beban : 380, stand kwh : 12450.5, stand bbm : 2800, tek oli : 4.2, status mesin : operasi`;
      try {
        await apiService.postLogsheet('05', msg);
      } catch (err) {
        console.error(err);
      } finally {
        setIsSubmitting(false);
        navigate('/detail-har');
      }
    }
  };

  return (
    <div className="bg-background text-on-surface font-body-md min-h-screen pb-32">
      <TopAppBar title="Buat HAR & Logsheet Baru" showBack />

      <main className="pt-20 px-4 max-w-2xl mx-auto space-y-6">
        {/* Step Indicator Bar */}
        <div className="overflow-x-auto pb-2 flex items-center gap-2 no-scrollbar">
          {[
            { num: 1, label: 'Informasi' },
            { num: 2, label: 'Checklist' },
            { num: 3, label: 'Tindakan' },
            { num: 4, label: 'Dokumentasi' },
          ].map((item, idx) => (
            <React.Fragment key={item.num}>
              {idx > 0 && <div className="w-8 h-px bg-outline-variant shrink-0"></div>}
              <div
                className={`flex items-center shrink-0 cursor-pointer ${
                  step === item.num ? 'opacity-100' : 'opacity-50'
                }`}
                onClick={() => setStep(item.num)}
              >
                <div
                  className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs ${
                    step === item.num
                      ? 'bg-primary text-on-primary shadow-sm'
                      : 'bg-surface-container-high text-on-surface-variant'
                  }`}
                >
                  {item.num}
                </div>
                <span
                  className={`ml-2 text-xs font-bold ${
                    step === item.num ? 'text-primary' : 'text-on-surface-variant'
                  }`}
                >
                  {item.label}
                </span>
              </div>
            </React.Fragment>
          ))}
        </div>

        {/* Step 1: Informasi */}
        {step === 1 && (
          <section className="bg-surface-container-lowest rounded-xl p-5 shadow-sm border border-outline-variant space-y-5">
            {/* Notice Free Time Selection */}
            <div className="p-3 bg-primary-fixed/30 border border-primary/20 rounded-xl flex items-center gap-2 text-xs font-bold text-primary">
              <span className="material-symbols-outlined text-base">access_time_filled</span>
              <span>Bebas Input Logsheet Semua Jam (00:00 - 24:00). Tanpa batasan jam real-time!</span>
            </div>

            {/* Unit & Mesin */}
            <div className="grid grid-cols-2 gap-4 bg-surface-container-low p-4 rounded-xl border border-dashed border-outline/50">
              <div>
                <p className="text-[10px] uppercase font-extrabold text-on-surface-variant tracking-wider">Unit</p>
                <p className="text-sm font-bold text-primary">{activeUnit.nama_unit}</p>
              </div>
              <div>
                <p className="text-[10px] uppercase font-extrabold text-on-surface-variant tracking-wider">Mesin</p>
                <p className="text-sm font-bold text-primary">{initialMesinKode}</p>
              </div>
            </div>

            {/* Date & Time Row */}
            <div className="grid grid-cols-2 gap-4">
              <div className="flex flex-col gap-1">
                <label className="text-xs font-bold text-on-surface-variant">Tanggal</label>
                <div className="relative">
                  <input
                    type="text"
                    readOnly
                    value="02 Agustus 2026"
                    className="w-full h-12 bg-surface-container-high border-none rounded-lg px-4 text-xs font-semibold focus:outline-none cursor-not-allowed text-on-surface"
                  />
                  <span className="material-symbols-outlined absolute right-3 top-3 text-on-surface-variant text-base">
                    calendar_today
                  </span>
                </div>
              </div>

              {/* Time Slot Selection (Bebas Input) */}
              <div className="flex flex-col gap-1">
                <label className="text-xs font-bold text-primary flex items-center justify-between">
                  <span>Jam Laporan (Bebas Jam)</span>
                  <span className="text-[10px] text-emerald-700 font-extrabold">Terpilih: {jamMulai}</span>
                </label>
                <div className="relative">
                  <select
                    value={jamMulai}
                    onChange={(e) => setJamMulai(e.target.value)}
                    className="w-full h-12 border border-primary rounded-lg px-4 text-xs font-bold text-primary focus:ring-2 focus:ring-primary focus:border-primary outline-none bg-surface-container-low"
                  >
                    {allHours.map((h) => (
                      <option key={h} value={h}>
                        Jam {h} {h === initialTimeSlot ? '(Pilihan Slot)' : ''}
                      </option>
                    ))}
                  </select>
                  <span className="material-symbols-outlined absolute right-3 top-3 pointer-events-none text-primary">
                    expand_more
                  </span>
                </div>
              </div>
            </div>

            {/* Manual Custom Time String */}
            <div className="flex flex-col gap-1">
              <label className="text-[11px] font-bold text-on-surface-variant">Ketik Jam Manual (Opsional)</label>
              <input
                type="text"
                value={jamMulai}
                onChange={(e) => setJamMulai(e.target.value)}
                placeholder="Contoh: 11:00 atau 07:30"
                className="w-full h-10 border border-outline-variant rounded-lg px-3 text-xs font-bold text-on-surface focus:ring-2 focus:ring-primary outline-none"
              />
            </div>

            {/* Jenis Pemeliharaan */}
            <div className="flex flex-col gap-1">
              <label className="text-xs font-bold text-on-surface-variant">Jenis Pemeliharaan</label>
              <div className="relative">
                <select
                  value={jenisHAR}
                  onChange={(e) => setJenisHAR(e.target.value)}
                  className="w-full h-12 border border-outline-variant rounded-lg px-4 appearance-none bg-transparent text-xs font-semibold focus:ring-2 focus:ring-primary outline-none"
                >
                  <option value="preventive">Preventive Maintenance (PM)</option>
                  <option value="corrective">Corrective Maintenance (CM)</option>
                  <option value="predictive">Predictive Maintenance (PdM)</option>
                </select>
                <span className="material-symbols-outlined absolute right-3 top-3 pointer-events-none text-on-surface-variant">
                  expand_more
                </span>
              </div>
            </div>

            {/* Priority Segmented Control */}
            <div className="flex flex-col gap-2">
              <label className="text-xs font-bold text-on-surface-variant">Prioritas Pekerjaan</label>
              <div className="flex p-1 bg-surface-container-high rounded-xl gap-1">
                {['LOW', 'NORMAL', 'HIGH', 'CRITICAL'].map((p) => (
                  <button
                    key={p}
                    type="button"
                    onClick={() => setPriority(p)}
                    className={`flex-1 py-2 px-1 rounded-lg text-[10px] font-bold transition-all ${
                      priority === p
                        ? 'bg-primary text-on-primary shadow-sm'
                        : 'text-on-surface-variant hover:bg-surface-container-highest'
                    }`}
                  >
                    {p}
                  </button>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* Step 2: Checklist */}
        {step === 2 && (
          <section className="bg-surface-container-lowest rounded-xl p-5 shadow-sm border border-outline-variant space-y-4">
            <h3 className="font-bold text-base text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">fact_check</span>
              Checklist Parameter Mesin Logsheet WACB (Jam {jamMulai})
            </h3>

            {[
              { title: 'Pemeriksaan Tekanan Oli Mesin', val: '4.2 bar (Normal)', icon: 'oil_barrel' },
              { title: 'Suhu Air Pendingin (Coolant)', val: '82°C (Normal)', icon: 'ac_unit' },
              { title: 'Ketersediaan Bahan Bakar (Solar)', val: 'Level 85%', icon: 'local_gas_station' },
              { title: 'Kondisi Baterai & Terminal', val: '24V / Bebas Korosi', icon: 'battery_charging_full' },
            ].map((chk, i) => (
              <div key={i} className="p-3 bg-surface-container-low rounded-xl border border-outline-variant/50 space-y-2">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="material-symbols-outlined text-primary">{chk.icon}</span>
                    <span className="text-xs font-bold text-on-surface">{chk.title}</span>
                  </div>
                  <span className="text-[11px] font-bold px-2 py-0.5 bg-emerald-100 text-emerald-800 rounded-full">
                    {chk.val}
                  </span>
                </div>
                <div className="grid grid-cols-4 gap-1 text-[10px] font-bold pt-1">
                  <button className="py-1 bg-emerald-500 text-white rounded">Baik</button>
                  <button className="py-1 bg-surface-container-high text-on-surface-variant rounded">Perlu PM</button>
                  <button className="py-1 bg-surface-container-high text-on-surface-variant rounded">Rusak</button>
                  <button className="py-1 bg-surface-container-high text-on-surface-variant rounded">N/A</button>
                </div>
              </div>
            ))}
          </section>
        )}

        {/* Step 3: Tindakan */}
        {step === 3 && (
          <section className="bg-surface-container-lowest rounded-xl p-5 shadow-sm border border-outline-variant space-y-4">
            <h3 className="font-bold text-base text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">report_problem</span>
              Temuan & Tindakan Pemeliharaan
            </h3>

            <div className="grid grid-cols-2 gap-3">
              <div className="bg-surface p-3 rounded-lg border border-outline-variant">
                <p className="text-[10px] font-bold text-on-surface-variant uppercase">Jam Laporan</p>
                <input
                  type="text"
                  value={jamMulai}
                  onChange={(e) => setJamMulai(e.target.value)}
                  className="w-full text-base font-bold text-primary bg-transparent outline-none"
                />
              </div>
              <div className="bg-surface p-3 rounded-lg border border-outline-variant">
                <p className="text-[10px] font-bold text-on-surface-variant uppercase">Jam Selesai</p>
                <input
                  type="text"
                  value={jamSelesai}
                  onChange={(e) => setJamSelesai(e.target.value)}
                  className="w-full text-base font-bold text-primary bg-transparent outline-none"
                />
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-xs font-bold text-on-surface-variant">Deskripsi Temuan</label>
              <textarea
                value={deskripsiTemuan}
                onChange={(e) => setDeskripsiTemuan(e.target.value)}
                placeholder="Contoh: Filter udara agak kotor, tekanan oli stabil 4.2 bar..."
                className="w-full min-h-[90px] p-3 rounded-lg bg-surface-container-low border border-outline-variant text-xs text-on-surface focus:border-primary outline-none"
              ></textarea>
            </div>

            <div className="space-y-1">
              <label className="text-xs font-bold text-on-surface-variant">Tindakan Pemeliharaan</label>
              <textarea
                value={tindakan}
                onChange={(e) => setTindakan(e.target.value)}
                placeholder="Contoh: Pembersihan filter udara dengan kompresor angin, topping up oli..."
                className="w-full min-h-[90px] p-3 rounded-lg bg-surface-container-low border border-outline-variant text-xs text-on-surface focus:border-primary outline-none"
              ></textarea>
            </div>

            <div className="space-y-2 pt-2">
              <label className="text-xs font-bold text-on-surface-variant">Hasil Akhir Pekerjaan</label>
              <div className="space-y-2">
                {['Normal', 'Perlu Monitoring', 'Perlu HAR Berat'].map((h) => (
                  <label
                    key={h}
                    onClick={() => setHasilPekerjaan(h)}
                    className={`flex items-center p-3 rounded-xl border cursor-pointer transition-colors ${
                      hasilPekerjaan === h
                        ? 'border-primary bg-primary-fixed/20'
                        : 'border-outline-variant bg-surface-container-lowest'
                    }`}
                  >
                    <input type="radio" checked={hasilPekerjaan === h} onChange={() => {}} className="text-primary" />
                    <span className="ml-3 text-xs font-bold text-on-surface">{h}</span>
                  </label>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* Step 4: Dokumentasi */}
        {step === 4 && (
          <section className="bg-surface-container-lowest rounded-xl p-5 shadow-sm border border-outline-variant space-y-4">
            <h3 className="font-bold text-base text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">photo_camera</span>
              Dokumentasi Foto Pekerjaan (Jam {jamMulai})
            </h3>

            <div className="grid grid-cols-2 gap-3">
              <div className="border-2 border-dashed border-outline-variant rounded-xl p-4 flex flex-col items-center justify-center gap-2 bg-surface-container-low hover:bg-surface-container-high cursor-pointer">
                <span className="material-symbols-outlined text-3xl text-primary">add_a_photo</span>
                <span className="text-xs font-bold text-primary">Foto Sebelum</span>
              </div>
              <div className="border-2 border-dashed border-outline-variant rounded-xl p-4 flex flex-col items-center justify-center gap-2 bg-surface-container-low hover:bg-surface-container-high cursor-pointer">
                <span className="material-symbols-outlined text-3xl text-primary">add_a_photo</span>
                <span className="text-xs font-bold text-primary">Foto Sesudah</span>
              </div>
            </div>

            <div className="p-3 bg-emerald-50 text-emerald-900 rounded-lg text-xs font-semibold border border-emerald-200">
              ✓ Payload terverifikasi dikirim untuk jam {jamMulai}. Siap diajukan ke WACB & Supervisor.
            </div>
          </section>
        )}
      </main>

      {/* Bottom Actions Shell */}
      <div className="fixed bottom-0 left-0 w-full bg-surface-container-lowest shadow-[0_-4px_10px_rgba(0,0,0,0.05)] p-4 z-50 border-t border-outline-variant/30">
        <div className="max-w-2xl mx-auto flex flex-col gap-2">
          <button
            onClick={handleNextStep}
            disabled={isSubmitting}
            className="w-full h-12 bg-primary text-on-primary rounded-lg font-bold flex items-center justify-center gap-2 active:scale-[0.98] transition-transform hover:bg-primary-container disabled:opacity-50"
          >
            {isSubmitting ? (
              <span className="animate-spin material-symbols-outlined">progress_activity</span>
            ) : (
              <>
                <span>{step === 4 ? `Simpan & Ajukan Logsheet (Jam ${jamMulai})` : 'Lanjut ke Step Berikutnya'}</span>
                <span className="material-symbols-outlined">arrow_forward</span>
              </>
            )}
          </button>
          <button
            onClick={() => navigate('/dashboard')}
            className="w-full h-10 bg-transparent border border-primary text-primary rounded-lg font-bold text-xs flex items-center justify-center gap-1 active:opacity-70"
          >
            <span className="material-symbols-outlined text-sm">save</span>
            <span>Simpan sebagai Draft</span>
          </button>
        </div>
      </div>
    </div>
  );
};
