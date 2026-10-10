import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { TopAppBar } from '../components/TopAppBar';
import { BottomNav } from '../components/BottomNav';
import { apiService } from '../services/api';

export const DetailHARPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [ticketStatus, setTicketStatus] = useState<'submitted' | 'approved'>('submitted');
  const [toastMessage, setToastMessage] = useState('');
  const [isApproving, setIsApproving] = useState(false);
  const [unitName, setUnitName] = useState('ULD MUARA PAHU');
  const [ticketNumber, setTicketNumber] = useState('HAR-2026-00021');
  const [expandedSections, setExpandedSections] = useState<Record<string, boolean>>({
    info: true,
    checklist: true,
    findings: true,
    docs: false,
  });

  useEffect(() => {
    const saved = localStorage.getItem('pln_selected_unit') || localStorage.getItem('selected_unit');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed.nama_unit) setUnitName(parsed.nama_unit);
      } catch {
        // default
      }
    }
    if (id) {
      setTicketNumber(`HAR-2026-000${id.padStart(2, '0')}`);
    }
  }, [id]);

  const toggleSection = (key: string) => {
    setExpandedSections((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const triggerToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3500);
  };

  const handleApprove = async () => {
    setIsApproving(true);
    await apiService.approveHAR(id || '21');
    setTicketStatus('approved');
    setIsApproving(false);
    triggerToast('Tiket HAR Berhasil Disetujui oleh Supervisor!');
  };

  const isApproved = ticketStatus === 'approved';

  return (
    <div className="bg-background text-on-surface min-h-screen pb-[120px]">
      <TopAppBar title="Detail HAR & Logsheet" showBack />

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-20 left-1/2 -translate-x-1/2 z-50 bg-emerald-600 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-2 border border-emerald-400 animate-bounce text-xs font-bold">
          <span className="material-symbols-outlined text-xl">check_circle</span>
          <span>{toastMessage}</span>
        </div>
      )}

      <main className="pt-[64px] px-4 max-w-2xl mx-auto space-y-5">
        {/* Header Status Section */}
        <section className="mt-4">
          <div className="flex justify-between items-start mb-3">
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-extrabold text-on-surface">{ticketNumber}</h2>
                <span className="bg-primary-fixed text-primary text-[10px] font-black px-2 py-0.5 rounded">
                  {unitName}
                </span>
              </div>
              <p className="text-xs text-on-surface-variant mt-0.5">
                Preventive Maintenance • Pembangkit Diesel Terpasang
              </p>
            </div>
            {isApproved ? (
              <span className="bg-emerald-100 text-emerald-800 border border-emerald-300 px-3 py-1 rounded-full text-xs font-extrabold flex items-center gap-1">
                <span className="material-symbols-outlined text-sm">verified</span>
                Disetujui / Selesai
              </span>
            ) : (
              <span className="bg-amber-100 text-amber-900 border border-amber-300 px-3 py-1 rounded-full text-xs font-bold flex items-center gap-1">
                <span className="material-symbols-outlined text-sm">pending_actions</span>
                Menunggu Approval
              </span>
            )}
          </div>

          {/* Timeline / Step Indicator */}
          <div className="bg-surface-container rounded-xl p-4 border border-outline-variant/30">
            <div className="relative flex justify-between items-center">
              {/* Progress Line */}
              <div className="absolute top-4 left-0 w-full h-[2px] bg-outline-variant z-0"></div>
              <div
                className="absolute top-4 left-0 h-[2px] bg-primary transition-all duration-500 z-0"
                style={{ width: isApproved ? '100%' : '66%' }}
              ></div>

              {/* Steps */}
              <div className="relative z-10 flex flex-col items-center gap-1">
                <div className="w-8 h-8 rounded-full bg-primary text-on-primary flex items-center justify-center shadow-sm">
                  <span className="material-symbols-outlined text-sm" style={{ fontVariationSettings: "'FILL' 1" }}>
                    check_circle
                  </span>
                </div>
                <span className="text-[10px] font-bold text-on-surface">Dibuat</span>
              </div>
              <div className="relative z-10 flex flex-col items-center gap-1">
                <div className="w-8 h-8 rounded-full bg-primary text-on-primary flex items-center justify-center shadow-sm">
                  <span className="material-symbols-outlined text-sm" style={{ fontVariationSettings: "'FILL' 1" }}>
                    check_circle
                  </span>
                </div>
                <span className="text-[10px] font-bold text-on-surface">Diajukan</span>
              </div>
              <div className="relative z-10 flex flex-col items-center gap-1">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold shadow-sm ${
                  isApproved ? 'bg-primary text-on-primary' : 'bg-surface-container-highest border-2 border-primary text-primary'
                }`}>
                  <span className="material-symbols-outlined text-sm">
                    {isApproved ? 'check_circle' : 'rate_review'}
                  </span>
                </div>
                <span className="text-[10px] font-extrabold text-primary">Review</span>
              </div>
              <div className="relative z-10 flex flex-col items-center gap-1">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold shadow-sm ${
                  isApproved ? 'bg-emerald-600 text-white ring-2 ring-emerald-300' : 'bg-surface-container-high text-on-surface-variant'
                }`}>
                  <span className="material-symbols-outlined text-sm">verified</span>
                </div>
                <span className={`text-[10px] font-bold ${isApproved ? 'text-emerald-700' : 'text-on-surface-variant'}`}>
                  Approval
                </span>
              </div>
            </div>
          </div>
        </section>

        {/* Expandable Content Sections */}
        <div className="space-y-3">
          {/* Section: Informasi HAR & Mesin */}
          <div className="bg-surface-container-lowest rounded-xl shadow-sm border-l-4 border-primary border border-outline-variant overflow-hidden">
            <button
              onClick={() => toggleSection('info')}
              className="w-full flex items-center justify-between p-4 text-left font-bold text-sm text-on-surface"
            >
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-primary">settings_suggest</span>
                <span>Informasi HAR & Mesin Pembangkit</span>
              </div>
              <span className="material-symbols-outlined text-on-surface-variant">
                {expandedSections.info ? 'expand_less' : 'expand_more'}
              </span>
            </button>
            {expandedSections.info && (
              <div className="px-4 pb-4 border-t border-outline-variant/20 pt-3 grid grid-cols-2 gap-y-3 text-xs">
                <div>
                  <p className="text-[10px] font-extrabold text-on-surface-variant uppercase">Kode Mesin</p>
                  <p className="font-bold text-on-surface">{unitName} #01</p>
                </div>
                <div>
                  <p className="text-[10px] font-extrabold text-on-surface-variant uppercase">Lokasi / Unit</p>
                  <p className="font-bold text-on-surface">{unitName}</p>
                </div>
                <div>
                  <p className="text-[10px] font-extrabold text-on-surface-variant uppercase">Waktu Pelaksanaan</p>
                  <p className="font-bold text-on-surface">Hari Ini, 08:00 - 11:30 WITA</p>
                </div>
                <div>
                  <p className="text-[10px] font-extrabold text-on-surface-variant uppercase">Teknisi Penanggung Jawab</p>
                  <p className="font-bold text-on-surface">Ahmad / Rahman (Team HAR)</p>
                </div>
              </div>
            )}
          </div>

          {/* Section: Checklist Pemeliharaan */}
          <div className="bg-surface-container-lowest rounded-xl shadow-sm border-l-4 border-secondary border border-outline-variant overflow-hidden">
            <button
              onClick={() => toggleSection('checklist')}
              className="w-full flex items-center justify-between p-4 text-left font-bold text-sm text-on-surface"
            >
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-secondary">fact_check</span>
                <span>Checklist Item Pemeliharaan</span>
              </div>
              <span className="material-symbols-outlined text-on-surface-variant">
                {expandedSections.checklist ? 'expand_less' : 'expand_more'}
              </span>
            </button>
            {expandedSections.checklist && (
              <div className="px-4 pb-4 border-t border-outline-variant/20 pt-3 space-y-2 text-xs">
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-emerald-600 text-base" style={{ fontVariationSettings: "'FILL' 1" }}>
                    check_box
                  </span>
                  <div>
                    <p className="font-bold text-on-surface">Pembersihan Elemen Filter Udara & Saluran Intake</p>
                    <p className="text-[11px] text-on-surface-variant">Kondisi: Bersih, telah disemprot angin kompresor.</p>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-emerald-600 text-base" style={{ fontVariationSettings: "'FILL' 1" }}>
                    check_box
                  </span>
                  <div>
                    <p className="font-bold text-on-surface">Pengecekan Level & Tekanan Oli Pelumas</p>
                    <p className="text-[11px] text-on-surface-variant">Kondisi: Tekanan 4.2 bar (Normal 3.8 - 4.5 bar).</p>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-emerald-600 text-base" style={{ fontVariationSettings: "'FILL' 1" }}>
                    check_box
                  </span>
                  <div>
                    <p className="font-bold text-on-surface">Pemeriksaan Tegangan Output & Frekuensi 50 Hz</p>
                    <p className="text-[11px] text-on-surface-variant">Kondisi: Tegangan 395V, Frekuensi 50.02 Hz stabil.</p>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Section: Temuan & Tindakan */}
          <div className="bg-surface-container-lowest rounded-xl shadow-sm border-l-4 border-error border border-outline-variant overflow-hidden">
            <button
              onClick={() => toggleSection('findings')}
              className="w-full flex items-center justify-between p-4 text-left font-bold text-sm text-on-surface"
            >
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-error">report_problem</span>
                <span>Temuan Teknis & Tindakan Perbaikan</span>
              </div>
              <span className="material-symbols-outlined text-on-surface-variant">
                {expandedSections.findings ? 'expand_less' : 'expand_more'}
              </span>
            </button>
            {expandedSections.findings && (
              <div className="px-4 pb-4 border-t border-outline-variant/20 pt-3 space-y-3 text-xs">
                <div className="bg-error-container/10 p-3 rounded-lg border border-error-container">
                  <h4 className="font-extrabold text-[10px] text-on-error-container uppercase mb-1">TEMUAN AWAL</h4>
                  <p className="text-on-surface">Filter udara sedikit berdebu dan terdapat rembesan oli tipis pada seal valve cover.</p>
                </div>
                <div className="bg-surface-container p-3 rounded-lg border border-outline-variant">
                  <h4 className="font-extrabold text-[10px] text-primary uppercase mb-1">TINDAKAN PERBAIKAN</h4>
                  <p className="text-on-surface">Pembersihan dengan solar, penggantian seal gasket baru, serta pengencangan baut torsi 45 Nm.</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Action Buttons: Supervisor Control */}
        <div className="mt-6 flex flex-col gap-3">
          {!isApproved ? (
            <button
              onClick={handleApprove}
              disabled={isApproving}
              className="w-full h-12 bg-emerald-600 text-white rounded-xl font-extrabold text-sm flex items-center justify-center gap-2 active:scale-95 transition-transform hover:bg-emerald-700 shadow-lg disabled:opacity-50"
            >
              <span className="material-symbols-outlined text-base">check_circle</span>
              <span>{isApproving ? 'Memproses Approval...' : '1-Klik Setujui Tiket HAR (Supervisor)'}</span>
            </button>
          ) : (
            <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-center text-xs font-bold text-emerald-800 flex items-center justify-center gap-2">
              <span className="material-symbols-outlined text-emerald-600">verified</span>
              <span>Tiket ini telah disetujui resmi oleh Supervisor Control Room.</span>
            </div>
          )}

          <button
            onClick={() => triggerToast('Berita Acara HAR & WACB (.PDF) sedang diunduh...')}
            className="w-full h-12 border border-outline text-primary rounded-xl font-bold text-sm flex items-center justify-center gap-2 active:scale-95 transition-transform hover:bg-surface-container-high"
          >
            <span className="material-symbols-outlined text-base">download</span>
            <span>Download Berita Acara HAR (.PDF)</span>
          </button>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};
