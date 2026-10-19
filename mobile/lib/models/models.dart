class User {
  final String username;
  final String name;
  final String role;
  final String token;
  final String kdRegion;

  User({
    required this.username,
    required this.name,
    required this.role,
    required this.token,
    this.kdRegion = '05',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? 'kal3',
      name: json['name'] ?? 'Super Admin K3',
      role: json['role'] ?? 'superadmin',
      token: json['token'] ?? 'superadmin-token',
      kdRegion: json['kd_region'] ?? '05',
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'name': name,
    'role': role,
    'token': token,
    'kd_region': kdRegion,
  };
}

class UnitModel {
  final String kdUnit;
  final String namaUnit;
  final String kdArea;
  final String namaArea;
  final String kdRegion;

  UnitModel({
    required this.kdUnit,
    required this.namaUnit,
    required this.kdArea,
    required this.namaArea,
    this.kdRegion = '05',
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      kdUnit: json['kd_unit']?.toString() ?? '',
      namaUnit: json['nama_unit']?.toString() ?? '',
      kdArea: json['kd_area']?.toString() ?? '',
      namaArea: json['nama_area']?.toString() ?? 'SITE BONTANG',
      kdRegion: json['kd_region']?.toString() ?? '05',
    );
  }

  Map<String, dynamic> toJson() => {
    'kd_unit': kdUnit,
    'nama_unit': namaUnit,
    'kd_area': kdArea,
    'nama_area': namaArea,
    'kd_region': kdRegion,
  };
}

class MachineModel {
  final int id;
  final String idMesin;
  final String namaMesin;
  final String kodeMesinSilm;
  final String sn;
  final double dt;
  final String status;
  final String kdUnit;
  final String tipeMesin;

  MachineModel({
    this.id = 0,
    required this.idMesin,
    required this.namaMesin,
    required this.kodeMesinSilm,
    required this.sn,
    required this.dt,
    required this.status,
    this.kdUnit = '0264',
    this.tipeMesin = 'DIESEL',
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idMesin: json['id_mesin']?.toString() ?? '',
      namaMesin: json['nama_mesin']?.toString() ?? '',
      kodeMesinSilm: json['kode_mesin_silm']?.toString() ?? '',
      sn: json['sn']?.toString() ?? '',
      dt: json['dt'] is num ? (json['dt'] as num).toDouble() : double.tryParse(json['dt']?.toString() ?? '0.0') ?? 0.0,
      status: json['status']?.toString() ?? 'OPERASI',
      kdUnit: json['kd_unit']?.toString() ?? (json['unit'] is Map ? json['unit']['kd_unit']?.toString() ?? '0264' : '0264'),
      tipeMesin: json['tipe_mesin']?.toString() ?? 'DIESEL',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_mesin': idMesin,
    'nama_mesin': namaMesin,
    'kode_mesin_silm': kodeMesinSilm,
    'sn': sn,
    'dt': dt,
    'status': status,
    'kd_unit': kdUnit,
    'tipe_mesin': tipeMesin,
  };
}

class HARChecklistItem {
  final String title;
  final String category;
  String condition; // 'baik', 'perbaikan', 'rusak', 'skip'
  String notes;

  HARChecklistItem({
    required this.title,
    required this.category,
    this.condition = 'baik',
    this.notes = '',
  });

  factory HARChecklistItem.fromJson(Map<String, dynamic> json) {
    return HARChecklistItem(
      title: json['title'] ?? '',
      category: json['category'] ?? 'Pemeriksaan Umum',
      condition: json['condition'] ?? 'baik',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'condition': condition,
    'notes': notes,
  };
}

class HARModel {
  final String id;
  final String harNumber;
  final String kdUnit;
  final String unitName;
  final String idMesin;
  final String machineName;
  final String date;
  final String timeSlot;
  String status; // 'draft', 'submitted', 'approved', 'revision'
  final String priority; // 'LOW', 'NORMAL', 'HIGH', 'CRITICAL'
  final String maintenanceType; // 'preventive', 'corrective'
  final String technicianName;
  final String findingDescription;
  final String actionTaken;
  final String finalResult;
  final double dayaMampu;
  final double beban;
  final double standKwh;
  final double standBbm;
  final double jamKerjaMesin;
  final double tekananOli;
  final List<HARChecklistItem> checklists;
  final List<String> photos;

  HARModel({
    required this.id,
    required this.harNumber,
    required this.kdUnit,
    required this.unitName,
    required this.idMesin,
    required this.machineName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.priority,
    this.maintenanceType = 'preventive',
    this.technicianName = 'Ahmad Teknisi',
    this.findingDescription = '',
    this.actionTaken = '',
    this.finalResult = 'Normal Andal',
    this.dayaMampu = 450.0,
    this.beban = 380.0,
    this.standKwh = 12450.5,
    this.standBbm = 2800.0,
    this.jamKerjaMesin = 1420.0,
    this.tekananOli = 4.2,
    this.checklists = const [],
    this.photos = const [],
  });

  factory HARModel.fromJson(Map<String, dynamic> json) {
    List<HARChecklistItem> checks = [];
    if (json['checklists'] is List) {
      checks = (json['checklists'] as List)
          .map((c) => HARChecklistItem.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    List<String> photoList = [];
    if (json['photos'] is List) {
      photoList = (json['photos'] as List).map((p) => p.toString()).toList();
    }

    return HARModel(
      id: json['id']?.toString() ?? '',
      harNumber: json['har_number'] ?? json['harNumber'] ?? 'HAR-2026-00000',
      kdUnit: json['kd_unit'] ?? json['kdUnit'] ?? '0264',
      unitName: json['unit_name'] ?? json['unitName'] ?? 'ULD BATU AMPAR',
      idMesin: json['id_mesin'] ?? json['idMesin'] ?? '000344',
      machineName: json['machine_name'] ?? json['machineName'] ?? 'PLTD BATU AMPAR #01',
      date: json['date'] ?? '2026-08-01',
      timeSlot: json['time_slot'] ?? json['timeSlot'] ?? '08:00',
      status: json['status'] ?? 'submitted',
      priority: json['priority'] ?? 'NORMAL',
      maintenanceType: json['maintenance_type'] ?? json['maintenanceType'] ?? 'preventive',
      technicianName: json['technician_name'] ?? json['technicianName'] ?? 'Ahmad Teknisi',
      findingDescription: json['finding_description'] ?? json['findingDescription'] ?? '',
      actionTaken: json['action_taken'] ?? json['actionTaken'] ?? '',
      finalResult: json['final_result'] ?? json['finalResult'] ?? 'Normal Andal',
      dayaMampu: (json['daya_mampu'] ?? json['dayaMampu'] ?? 450.0).toDouble(),
      beban: (json['beban'] ?? 380.0).toDouble(),
      standKwh: (json['stand_kwh'] ?? json['standKwh'] ?? 12450.5).toDouble(),
      standBbm: (json['stand_bbm'] ?? json['standBbm'] ?? 2800.0).toDouble(),
      jamKerjaMesin: (json['jam_kerja_mesin'] ?? json['jamKerjaMesin'] ?? 1420.0).toDouble(),
      tekananOli: (json['tekanan_oli'] ?? json['tekananOli'] ?? 4.2).toDouble(),
      checklists: checks,
      photos: photoList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'har_number': harNumber,
    'kd_unit': kdUnit,
    'unit_name': unitName,
    'id_mesin': idMesin,
    'machine_name': machineName,
    'date': date,
    'time_slot': timeSlot,
    'status': status,
    'priority': priority,
    'maintenance_type': maintenanceType,
    'technician_name': technicianName,
    'finding_description': findingDescription,
    'action_taken': actionTaken,
    'final_result': finalResult,
    'daya_mampu': dayaMampu,
    'beban': beban,
    'stand_kwh': standKwh,
    'stand_bbm': standBbm,
    'jam_kerja_mesin': jamKerjaMesin,
    'tekanan_oli': tekananOli,
    'checklists': checklists.map((c) => c.toJson()).toList(),
    'photos': photos,
  };
}
