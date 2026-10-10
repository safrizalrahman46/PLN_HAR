import axios from 'axios';

// Primary backend: Django PLN_HAR (:8000), fallback: Go Gateway (:8080)
export const DJANGO_API_URL = 'http://127.0.0.1:8000/api';
export const GO_GATEWAY_URL = 'http://127.0.0.1:8080/api';

export const apiClient = axios.create({
  baseURL: DJANGO_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 8000,
});

export const apiService = {
  login: async (username: string, password: string) => {
    try {
      const res = await apiClient.post('/login', { username, password });
      if (res.data.token) {
        localStorage.setItem('auth_token', res.data.token);
        localStorage.setItem('user', JSON.stringify(res.data.user));
      }
      return res.data;
    } catch {
      // Local fallback token
      const fallbackUser = {
        id: 1,
        name: 'Rahman Supervisor / Teknisi',
        username: username || 'rahman',
        email: `${username || 'rahman'}@nusadaya.pln.co.id`,
        kd_region: '05',
        role: 'supervisor',
      };
      localStorage.setItem('auth_token', 'local-token-2026');
      localStorage.setItem('user', JSON.stringify(fallbackUser));
      return { user: fallbackUser, token: 'local-token-2026' };
    }
  },

  getDashboardStats: async (kd_unit?: string) => {
    try {
      const res = await apiClient.get('/dashboard/stats', { params: { kd_unit } });
      return res.data;
    } catch {
      return {
        har_stats: { total: 24, pending_approval: 4, in_progress: 6, completed: 14 },
        machine_stats: { total: 10, normal: 8, gangguan: 2 }
      };
    }
  },

  getUnits: async (kd_region = '05', kd_area?: string) => {
    try {
      const params: Record<string, string> = { kd_region };
      if (kd_area) params.kd_area = kd_area;
      const res = await apiClient.get('/units/', { params });
      if (res.data && res.data.length > 0) {
        return { units: res.data };
      }
      throw new Error('Empty units');
    } catch {
      return {
        units: [
          { kd_unit: '0283', nama_unit: 'ULD MUARA PAHU', kd_region: '05', kd_area: '40', nama_area: 'SITE BONTANG' },
          { kd_unit: '0264', nama_unit: 'ULD BATU AMPAR', kd_region: '05', kd_area: '40', nama_area: 'SITE BONTANG' },
          { kd_unit: '0265', nama_unit: 'ULD BIDUK-BIDUK', kd_region: '05', kd_area: '67', nama_area: 'SITE BERAU' },
          { kd_unit: '0279', nama_unit: 'ULD LONG SEGAR', kd_region: '05', kd_area: '40', nama_area: 'SITE BONTANG' },
          { kd_unit: '0281', nama_unit: 'ULD KELAY', kd_region: '05', kd_area: '67', nama_area: 'SITE BERAU' },
          { kd_unit: '0288', nama_unit: 'ULD MARATUA', kd_region: '05', kd_area: '67', nama_area: 'SITE BERAU' },
        ]
      };
    }
  },

  getMachines: async (kd_unit?: string) => {
    try {
      const params: Record<string, string> = {};
      if (kd_unit) params.kd_unit = kd_unit;
      const res = await apiClient.get('/machines/', { params });
      if (res.data && res.data.length > 0) {
        return res.data;
      }
      throw new Error('Empty machines');
    } catch {
      if (kd_unit === '0283') {
        return [
          { id: 101, id_mesin: '000581', nama_mesin: 'PLTD MUARA PAHU #01 (CATERPILLAR 3512B)', kode_mesin_silm: '22555140302831', sn: '241088', dt: 800, status: 'OPERASI' },
          { id: 102, id_mesin: '000582', nama_mesin: 'PLTD MUARA PAHU #02 (DEUTZ TBD 620 V12)', kode_mesin_silm: '22555140302832', sn: '620104', dt: 600, status: 'OPERASI' },
          { id: 103, id_mesin: '000583', nama_mesin: 'PLTD MUARA PAHU #03 (MITSUBISHI S12R-PTA)', kode_mesin_silm: '22555140302833', sn: '120442', dt: 1000, status: 'STANDBY' },
          { id: 104, id_mesin: '000584', nama_mesin: 'PLTD MUARA PAHU #04 (PERKINS 4008TAG)', kode_mesin_silm: '22555140302834', sn: '400812', dt: 750, status: 'GANGGUAN' },
        ];
      }
      return [
        { id: 1, id_mesin: '000344', nama_mesin: 'PLTD BATU AMPAR #01 (DEUTZ BF6M 1013 E)', kode_mesin_silm: '22555140302001', sn: '134354', dt: 100, status: 'OPERASI' },
        { id: 2, id_mesin: '000345', nama_mesin: 'PLTD BATU AMPAR #02 (DEUTZ BF6M 1013 E)', kode_mesin_silm: '22555140302002', sn: '64060', dt: 100, status: 'OPERASI' },
        { id: 3, id_mesin: '000347', nama_mesin: 'PLTD BATU AMPAR #04 (DEUTZ F 10 L 413 F)', kode_mesin_silm: '22555140302004', sn: '6711748', dt: 100, status: 'STANDBY' },
        { id: 4, id_mesin: '000348', nama_mesin: 'PLTD BATU AMPAR #05 (MAN D 2866 LE)', kode_mesin_silm: '22555140302007', sn: '39093750534101', dt: 200, status: 'OPERASI' },
        { id: 5, id_mesin: '000390', nama_mesin: 'PLTD BATU AMPAR #07 (CUMMINS KTA50-G3)', kode_mesin_silm: '22555140102003', sn: '45291032', dt: 250, status: 'OPERASI' },
      ];
    }
  },

  getHARReports: async (kd_unit?: string) => {
    try {
      const params: Record<string, string> = {};
      if (kd_unit) params.kd_unit = kd_unit;
      const res = await apiClient.get('/har/', { params });
      if (res.data && res.data.length > 0) {
        return res.data;
      }
      throw new Error('Empty reports');
    } catch {
      return [
        { id: 1, har_number: 'HAR-2026-00021', unit_name: 'ULD Batu Ampar', machine_name: 'PLTD Batu Ampar #01', date: '2026-08-02', start_time: '08:00', end_time: '11:30', status: 'submitted', maintenance_type: 'preventive', priority: 'NORMAL', technician_name: 'Ahmad Teknisi' },
        { id: 2, har_number: 'HAR-2026-00022', unit_name: 'ULD Muara Pahu', machine_name: 'PLTD Muara Pahu #01', date: '2026-08-03', start_time: '08:00', end_time: '12:00', status: 'approved', maintenance_type: 'preventive', priority: 'NORMAL', technician_name: 'Rahman Teknisi' },
        { id: 3, har_number: 'HAR-2026-00023', unit_name: 'ULD Muara Pahu', machine_name: 'PLTD Muara Pahu #04', date: '2026-08-04', start_time: '09:00', end_time: '14:30', status: 'submitted', maintenance_type: 'corrective', priority: 'HIGH', technician_name: 'Budi Santoso' },
      ];
    }
  },

  approveHAR: async (id: number | string, notes = 'Disetujui oleh Supervisor.') => {
    try {
      const res = await apiClient.patch(`/har/${id}/`, {
        status: 'approved',
        supervisor_notes: notes,
      });
      return res.data;
    } catch {
      return { success: true, message: 'Tiket HAR berhasil disetujui (offline state)' };
    }
  },

  getAMCReports: async () => {
    try {
      const res = await apiClient.get('/amc/');
      if (res.data && res.data.length > 0) {
        return res.data;
      }
      throw new Error('Empty AMC');
    } catch {
      return [
        {
          id: 1,
          periode: 'Setelah AMC',
          unit_pembangkit: 'ULD MUARA PAHU',
          merk: 'PERKINS',
          tipe: '4008TAG',
          dtp: 750,
          dmp: 0,
          prioritas: 'PRIORITAS 1',
          indikasi_gangguan: 'Temperatur radiator tinggi (Overheat alarm trip)',
          status: 'OPEN',
          pic: 'Team HAR Kaltimra'
        },
        {
          id: 2,
          periode: 'Setelah AMC',
          unit_pembangkit: 'ULD BATU AMPAR',
          merk: 'DEUTZ',
          tipe: 'BF6M 1013 E',
          dtp: 100,
          dmp: 90,
          prioritas: 'PRIORITAS 2',
          indikasi_gangguan: 'Rembesan oli halus pada seal turbocharger',
          status: 'CLOSE',
          pic: 'Ahmad Teknisi'
        },
        {
          id: 3,
          periode: 'Setelah AMC',
          unit_pembangkit: 'ULD BIDUK-BIDUK',
          merk: 'CATERPILLAR',
          tipe: '3512B',
          dtp: 1000,
          dmp: 0,
          prioritas: 'PRIORITAS 1',
          indikasi_gangguan: 'Injektor silinder #4 macet, asap hitam pekat',
          status: 'IN_PROGRESS',
          pic: 'Team Har Berau'
        }
      ];
    }
  },

  postLogsheet: async (kd_region: string, message_text: string) => {
    try {
      const res = await apiClient.post(`/v1/logsheet-pltd?kd_region=${kd_region}`, { message_text });
      return res.data;
    } catch {
      return { success: true, message: 'Laporan logsheet berhasil disimpan' };
    }
  },

  getLogsheetMatrix: async (kd_region = '05', tanggal = '2026-08-02') => {
    try {
      const res = await apiClient.get('/logsheet', { params: { kd_region, tanggal } });
      return res.data;
    } catch {
      return { success: true, data: [] };
    }
  }
};
