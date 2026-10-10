export interface User {
  id: number;
  name: string;
  username: string;
  email: string;
  kd_region: string;
  role: string;
}

export interface Region {
  id: number;
  kd_region: string;
  nama_region: string;
}

export interface Area {
  id: number;
  kd_area: string;
  nama_area: string;
  region: number;
}

export interface Unit {
  id: number;
  kd_unit: string;
  nama_unit: string;
  area: number;
  region: number;
  area_name?: string;
  region_name?: string;
  latitude: number;
  longitude: number;
}

export interface Machine {
  id: number;
  id_mesin: string;
  nama_mesin: string;
  kode_mesin_silm: string;
  sn: string;
  dt: number;
  unit: number;
  unit_name?: string;
  kd_jenis_bahan_bakar: string;
  status: 'OPERASI' | 'STANDBY' | 'GANGGUAN' | 'MAINTENANCE';
}

export interface HARReport {
  id: number;
  har_number: string;
  unit: number;
  machine: number;
  unit_name?: string;
  machine_name?: string;
  date: string;
  start_time: string;
  end_time: string;
  duration_minutes: number;
  maintenance_type: 'preventive' | 'corrective' | 'predictive';
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'CRITICAL';
  status: 'draft' | 'submitted' | 'revision' | 'approved';
  technician_name: string;
  finding_description: string;
  action_taken: string;
  final_result: string;
  supervisor_notes: string;
  created_at: string;
}
