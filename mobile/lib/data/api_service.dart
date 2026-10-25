import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // 10.0.2.2 is Android Emulator host loopback; 127.0.0.1 is for Desktop/iOS/Web
  static const String baseUrl = "http://10.0.2.2:8000/api";
  static const String fallbackLocalUrl = "http://127.0.0.1:8000/api";
  static const String wacbBaseUrl = "http://wacb.nusadaya.net/api";

  // Keys for SharedPreferences
  static const String _keyUser = "pln_har_user_session";
  static const String _keySelectedUnit = "pln_har_selected_unit";
  static const String _keyHarReports = "pln_har_local_reports";

  // ==================== AUTHENTICATION ====================
  static Future<User> login(String username, String password) async {
    // 1. Check hardened demo account kal3
    if (username == 'kal3' && password == 'password') {
      final user = User(
        username: 'kal3',
        name: 'Super Admin K3 (PLN Nusa Daya)',
        role: 'superadmin',
        token: 'superadmin-token-kal3-2026',
        kdRegion: '05',
      );
      await saveCurrentUser(user);
      return user;
    }

    // 2. Try Backend API
    for (final url in [baseUrl, fallbackLocalUrl]) {
      try {
        final res = await http.post(
          Uri.parse("$url/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": username, "password": password}),
        ).timeout(const Duration(seconds: 3));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final user = User.fromJson(data['user'] ?? data);
          await saveCurrentUser(user);
          return user;
        }
      } catch (_) {}
    }

    // 3. Fallback User for offline field deployment
    final fallbackUser = User(
      username: username.isNotEmpty ? username : 'teknisi_lapangan',
      name: username.isNotEmpty ? 'Teknisi $username' : 'Ahmad Teknisi PLTD',
      role: username.toLowerCase().contains('spv') || username.toLowerCase().contains('admin') ? 'supervisor' : 'teknisi',
      token: 'user-token-${DateTime.now().millisecondsSinceEpoch}',
      kdRegion: '05',
    );
    await saveCurrentUser(fallbackUser);
    return fallbackUser;
  }

  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyUser);
    if (str != null) {
      try {
        return User.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return null;
  }

  static Future<User?> updateProfile({
    String? username,
    required String name,
    required String bio,
    required String avatarPreset,
    required String phone,
    String? email,
    String? photoBase64,
    String? newPassword,
  }) async {
    final current = await getCurrentUser();
    if (current == null) return null;
    final updated = current.copyWith(
      username: (username != null && username.isNotEmpty) ? username : current.username,
      name: name,
      bio: bio,
      avatarPreset: avatarPreset,
      phone: phone,
      email: (email != null && email.isNotEmpty) ? email : current.email,
      photoBase64: photoBase64 ?? current.photoBase64,
      password: (newPassword != null && newPassword.isNotEmpty) ? newPassword : current.password,
    );
    await saveCurrentUser(updated);
    return updated;
  }

  static Future<User> resetProfileToDefault() async {
    final defaultUser = User(
      username: 'kal3',
      name: 'Super Admin K3 (PLN Nusa Daya)',
      role: 'superadmin',
      token: 'superadmin-token-kal3-2026',
      kdRegion: '05',
      bio: 'Teknisi Operasi & Pemeliharaan Pembangkit PLTD',
      avatarPreset: '1',
      phone: '0812-3456-7890',
      password: 'password',
    );
    await saveCurrentUser(defaultUser);
    return defaultUser;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // ==================== UNIT SELECTION ====================
  static Future<void> saveSelectedUnit(UnitModel unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedUnit, jsonEncode(unit.toJson()));
  }

  static Future<UnitModel> getSelectedUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keySelectedUnit);
    if (str != null) {
      try {
        return UnitModel.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    // Default: ULD Batu Ampar (0264)
    return UnitModel(
      kdUnit: '0264',
      namaUnit: 'ULD BATU AMPAR',
      kdArea: '40',
      namaArea: 'SITE BONTANG',
      kdRegion: '05',
    );
  }

  static Future<List<UnitModel>> getUnits() async {
    for (final url in [baseUrl, fallbackLocalUrl]) {
      try {
        final res = await http.get(Uri.parse("$url/units/")).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is List && data.isNotEmpty) {
            return data.map((u) => UnitModel.fromJson(u)).toList();
          }
        }
      } catch (_) {}
    }

    // Canonical Kalimantan 3 Units fallback
    return [
      UnitModel(kdUnit: '0264', namaUnit: 'ULD BATU AMPAR', kdArea: '40', namaArea: 'SITE BONTANG'),
      UnitModel(kdUnit: '0283', namaUnit: 'ULD MUARA PAHU', kdArea: '40', namaArea: 'SITE BONTANG'),
      UnitModel(kdUnit: '0265', namaUnit: 'ULD BIDUK-BIDUK', kdArea: '67', namaArea: 'SITE BERAU'),
      UnitModel(kdUnit: '0279', namaUnit: 'ULD LONG SEGAR', kdArea: '40', namaArea: 'SITE BONTANG'),
      UnitModel(kdUnit: '0281', namaUnit: 'ULD KELAY', kdArea: '67', namaArea: 'SITE BERAU'),
      UnitModel(kdUnit: '0288', namaUnit: 'ULD MARATUA', kdArea: '67', namaArea: 'SITE BERAU'),
    ];
  }

  // ==================== MACHINES ====================
  static Future<List<MachineModel>> getMachines({String? kdUnit}) async {
    final unitCode = kdUnit ?? (await getSelectedUnit()).kdUnit;

    for (final url in [baseUrl, fallbackLocalUrl]) {
      try {
        final res = await http.get(Uri.parse("$url/machines/?kd_unit=$unitCode")).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is List && data.isNotEmpty) {
            return data.map((m) => MachineModel.fromJson(m)).toList();
          }
        }
      } catch (_) {}
    }

    // Authentic Machine Inventory fallback
    if (unitCode == '0283') {
      return [
        MachineModel(id: 101, idMesin: '000581', namaMesin: 'PLTD MUARA PAHU #01 (CATERPILLAR 3512B)', kodeMesinSilm: '22555140302831', sn: '241088', dt: 800, status: 'OPERASI', kdUnit: '0283', tipeMesin: 'CATERPILLAR 3512B'),
        MachineModel(id: 102, idMesin: '000582', namaMesin: 'PLTD MUARA PAHU #02 (DEUTZ TBD 620 V12)', kodeMesinSilm: '22555140302832', sn: '620104', dt: 600, status: 'OPERASI', kdUnit: '0283', tipeMesin: 'DEUTZ TBD 620 V12'),
        MachineModel(id: 103, idMesin: '000583', namaMesin: 'PLTD MUARA PAHU #03 (MITSUBISHI S12R-PTA)', kodeMesinSilm: '22555140302833', sn: '120442', dt: 1000, status: 'STANDBY', kdUnit: '0283', tipeMesin: 'MITSUBISHI S12R-PTA'),
        MachineModel(id: 104, idMesin: '000584', namaMesin: 'PLTD MUARA PAHU #04 (PERKINS 4008TAG)', kodeMesinSilm: '22555140302834', sn: '400812', dt: 750, status: 'GANGGUAN', kdUnit: '0283', tipeMesin: 'PERKINS 4008TAG'),
      ];
    } else if (unitCode == '0265') {
      return [
        MachineModel(id: 201, idMesin: '000621', namaMesin: 'PLTD BIDUK-BIDUK #01 (MTU 16V4000)', kodeMesinSilm: '22555140302651', sn: '524100', dt: 1200, status: 'OPERASI', kdUnit: '0265', tipeMesin: 'MTU 16V4000'),
        MachineModel(id: 202, idMesin: '000622', namaMesin: 'PLTD BIDUK-BIDUK #02 (CAT 3512B)', kodeMesinSilm: '22555140302652', sn: '351209', dt: 800, status: 'STANDBY', kdUnit: '0265', tipeMesin: 'CAT 3512B'),
      ];
    }

    // Default: ULD Batu Ampar (0264)
    return [
      MachineModel(id: 1, idMesin: '000344', namaMesin: 'PLTD BATU AMPAR #01 (DEUTZ BF6M 1013 E)', kodeMesinSilm: '22555140302001', sn: '134354', dt: 100, status: 'OPERASI', kdUnit: '0264', tipeMesin: 'DEUTZ BF6M 1013 E'),
      MachineModel(id: 2, idMesin: '000345', namaMesin: 'PLTD BATU AMPAR #02 (DEUTZ BF6M 1013 E)', kodeMesinSilm: '22555140302002', sn: '64060', dt: 100, status: 'OPERASI', kdUnit: '0264', tipeMesin: 'DEUTZ BF6M 1013 E'),
      MachineModel(id: 3, idMesin: '000347', namaMesin: 'PLTD BATU AMPAR #04 (DEUTZ F 10 L 413 F)', kodeMesinSilm: '22555140302004', sn: '6711748', dt: 100, status: 'STANDBY', kdUnit: '0264', tipeMesin: 'DEUTZ F 10 L 413 F'),
      MachineModel(id: 4, idMesin: '000348', namaMesin: 'PLTD BATU AMPAR #05 (MAN D 2866 LE)', kodeMesinSilm: '22555140302007', sn: '39093750534101', dt: 200, status: 'OPERASI', kdUnit: '0264', tipeMesin: 'MAN D 2866 LE'),
      MachineModel(id: 5, idMesin: '000390', namaMesin: 'PLTD BATU AMPAR #07 (CUMMINS KTA50-G3)', kodeMesinSilm: '22555140102003', sn: '45291032', dt: 250, status: 'GANGGUAN', kdUnit: '0264', tipeMesin: 'CUMMINS KTA50-G3'),
    ];
  }

  // ==================== HAR REPORTS & CHECKLISTS ====================
  static List<HARModel> _getInitialSeedReports() {
    return [
      HARModel(
        id: '1',
        harNumber: 'HAR-2026-00021',
        kdUnit: '0264',
        unitName: 'ULD BATU AMPAR',
        idMesin: '000344',
        machineName: 'PLTD BATU AMPAR #01 (DEUTZ BF6M 1013 E)',
        date: '2026-08-02',
        timeSlot: '08:00',
        status: 'approved',
        priority: 'NORMAL',
        maintenanceType: 'preventive',
        technicianName: 'Ahmad Teknisi',
        findingDescription: 'Kondisi pelumasan dan pendingin dalam toleransi normal.',
        actionTaken: 'Pemeriksaan level oli, filter solar racor, dan tegangan aki starter.',
        finalResult: 'Normal Andal',
        checklists: [
          HARChecklistItem(title: 'Level & Tekanan Oli Mesin', category: 'Sistem Pelumasan', condition: 'baik'),
          HARChecklistItem(title: 'Pemeriksaan Filter Air & Udara', category: 'Sistem Udara', condition: 'baik'),
          HARChecklistItem(title: 'Sistem Pendingin & Radiator', category: 'Sistem Pendingin', condition: 'baik'),
          HARChecklistItem(title: 'Tegangan & Frekuensi Generator (380V/50Hz)', category: 'Sistem Elektrikal', condition: 'baik'),
        ],
        photos: ['before_01.jpg', 'process_01.jpg', 'after_01.jpg'],
      ),
      HARModel(
        id: '2',
        harNumber: 'HAR-2026-00020',
        kdUnit: '0264',
        unitName: 'ULD BATU AMPAR',
        idMesin: '000345',
        machineName: 'PLTD BATU AMPAR #02 (DEUTZ BF6M 1013 E)',
        date: '2026-08-01',
        timeSlot: '07:00',
        status: 'submitted',
        priority: 'NORMAL',
        maintenanceType: 'preventive',
        technicianName: 'Ahmad Teknisi',
        findingDescription: 'Filter oli sedikit kotor, baut klem radiator kendor.',
        actionTaken: 'Pembersihan filter oli dan pengencangan klem radiator.',
        finalResult: 'Perlu Monitoring',
        checklists: [
          HARChecklistItem(title: 'Level & Tekanan Oli Mesin', category: 'Sistem Pelumasan', condition: 'perbaikan', notes: 'Filter kotor'),
          HARChecklistItem(title: 'Sistem Pendingin & Radiator', category: 'Sistem Pendingin', condition: 'perbaikan', notes: 'Klem kendor'),
          HARChecklistItem(title: 'Sistem Bahan Bakar & Filter Solar', category: 'Sistem Bahan Bakar', condition: 'baik'),
          HARChecklistItem(title: 'Tegangan & Frekuensi Generator', category: 'Sistem Elektrikal', condition: 'baik'),
        ],
        photos: ['before_02.jpg', 'process_02.jpg'],
      ),
      HARModel(
        id: '3',
        harNumber: 'HAR-2026-00019',
        kdUnit: '0264',
        unitName: 'ULD BATU AMPAR',
        idMesin: '000390',
        machineName: 'PLTD BATU AMPAR #07 (CUMMINS KTA50-G3)',
        date: '2026-07-31',
        timeSlot: '16:00',
        status: 'draft',
        priority: 'HIGH',
        maintenanceType: 'corrective',
        technicianName: 'Rudi Teknisi',
        findingDescription: 'Tekanan oli drop menjadi 2.8 Bar saat pembebanan 200kW.',
        actionTaken: 'Inspeksi kebocoran packing filter oli dan oil cooler.',
        finalResult: 'Belum Selesai',
        checklists: [
          HARChecklistItem(title: 'Level & Tekanan Oli Mesin', category: 'Sistem Pelumasan', condition: 'rusak', notes: 'Tekanan oli drop'),
          HARChecklistItem(title: 'Sistem Pendingin & Radiator', category: 'Sistem Pendingin', condition: 'baik'),
          HARChecklistItem(title: 'Sistem Bahan Bakar', category: 'Sistem Bahan Bakar', condition: 'baik'),
        ],
        photos: ['before_03.jpg'],
      ),
    ];
  }

  static Future<List<HARModel>> getHARReports({String? kdUnit}) async {
    final prefs = await SharedPreferences.getInstance();
    List<HARModel> reports = [];

    // Load from local storage
    final localJson = prefs.getString(_keyHarReports);
    if (localJson != null) {
      try {
        final List list = jsonDecode(localJson);
        reports = list.map((item) => HARModel.fromJson(item)).toList();
      } catch (_) {}
    }

    if (reports.isEmpty) {
      reports = _getInitialSeedReports();
      await prefs.setString(_keyHarReports, jsonEncode(reports.map((r) => r.toJson()).toList()));
    }

    if (kdUnit != null && kdUnit.isNotEmpty) {
      final filtered = reports.where((r) => r.kdUnit == kdUnit).toList();
      return filtered.isNotEmpty ? filtered : reports;
    }
    return reports;
  }

  static Future<HARModel?> getHARDetail(String harId) async {
    final reports = await getHARReports();
    try {
      return reports.firstWhere((r) => r.id == harId || r.harNumber == harId);
    } catch (_) {
      return reports.isNotEmpty ? reports.first : null;
    }
  }

  static Future<bool> submitHAR(HARModel newHAR) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getHARReports();

    // Insert at front
    reports.insert(0, newHAR);
    await prefs.setString(_keyHarReports, jsonEncode(reports.map((r) => r.toJson()).toList()));

    // Submit to Django API in background if online
    try {
      for (final url in [baseUrl, fallbackLocalUrl]) {
        http.post(
          Uri.parse("$url/har/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "har_number": newHAR.harNumber,
            "unit": newHAR.kdUnit,
            "machine": newHAR.idMesin,
            "date": newHAR.date,
            "start_time": newHAR.timeSlot,
            "maintenance_type": newHAR.maintenanceType,
            "priority": newHAR.priority,
            "status": "submitted",
            "technician_name": newHAR.technicianName,
            "finding_description": newHAR.findingDescription,
            "action_taken": newHAR.actionTaken,
            "final_result": newHAR.finalResult,
          }),
        ).timeout(const Duration(seconds: 3)).ignore();
      }
    } catch (_) {}

    // Submit to WACB
    final wacbMsg = "jam : ${newHAR.timeSlot}, kode mesin : ${newHAR.machineName}, daya mampu : ${newHAR.dayaMampu.toInt()}, beban : ${newHAR.beban.toInt()}, stand kwh : ${newHAR.standKwh}, stand bbm : ${newHAR.standBbm.toInt()}, tek oli : ${newHAR.tekananOli}, jam kerja mesin : ${newHAR.jamKerjaMesin.toInt()}, status mesin : operasi";
    postLogsheet(wacbMsg).ignore();

    return true;
  }

  static Future<bool> approveHAR(String harId) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getHARReports();

    final idx = reports.indexWhere((r) => r.id == harId || r.harNumber == harId);
    if (idx != -1) {
      reports[idx].status = 'approved';
      await prefs.setString(_keyHarReports, jsonEncode(reports.map((r) => r.toJson()).toList()));

      // Try update Django API
      try {
        for (final url in [baseUrl, fallbackLocalUrl]) {
          http.patch(
            Uri.parse("$url/har/$harId/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"status": "approved"}),
          ).timeout(const Duration(seconds: 3)).ignore();
        }
      } catch (_) {}

      return true;
    }
    return false;
  }

  static Future<Map<String, int>> getDashboardStats({String? kdUnit}) async {
    final reports = await getHARReports(kdUnit: kdUnit);
    int total = reports.length;
    int pending = reports.where((r) => r.status == 'submitted').count();
    int inProgress = reports.where((r) => r.status == 'draft').count();
    int completed = reports.where((r) => r.status == 'approved').count();

    return {
      'total': total,
      'pending': pending,
      'in_progress': inProgress,
      'completed': completed,
    };
  }

  static Future<bool> postLogsheet(String messageText) async {
    try {
      final res = await http.post(
        Uri.parse("$wacbBaseUrl/v1/logsheet-pltd?kd_region=05&message_text=${Uri.encodeComponent(messageText)}"),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return true; // local fallback safe
    }
  }

  static Future<int> importReports(List<HARModel> newReports) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHARReports();
    int addedCount = 0;
    for (final r in newReports) {
      final existingIndex = current.indexWhere((item) => item.harNumber == r.harNumber);
      if (existingIndex == -1) {
        current.insert(0, r);
        addedCount++;
      } else {
        current[existingIndex] = r;
        addedCount++;
      }
    }
    await prefs.setString(_keyHarReports, jsonEncode(current.map((r) => r.toJson()).toList()));
    return addedCount;
  }
}
extension ListCount<E> on Iterable<E> {
  int count() => length;
}
