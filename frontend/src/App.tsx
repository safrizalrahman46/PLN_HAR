import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { PilihUnitPage } from './pages/PilihUnitPage';
import { DashboardPage } from './pages/DashboardPage';
import { DaftarMesinPage } from './pages/DaftarMesinPage';
import { BuatHARPage } from './pages/BuatHARPage';
import { RiwayatHARPage } from './pages/RiwayatHARPage';
import { DetailHARPage } from './pages/DetailHARPage';

export const App: React.FC = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/pilih-unit" element={<PilihUnitPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/daftar-mesin" element={<DaftarMesinPage />} />
        <Route path="/buat-har" element={<BuatHARPage />} />
        <Route path="/riwayat-har" element={<RiwayatHARPage />} />
        <Route path="/detail-har/:id" element={<DetailHARPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
};

export default App;
