import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresensiGpsScreen extends StatefulWidget {
  const PresensiGpsScreen({super.key});

  @override
  State<PresensiGpsScreen> createState() => _PresensiGpsScreenState();
}

class _PresensiGpsScreenState extends State<PresensiGpsScreen> with SingleTickerProviderStateMixin {
  static const String _keyPresensiLogs = 'pln_har_presensi_logs';

  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  late AnimationController _pulseController;

  String _selectedShift = 'Shift 1 (Pagi: 07:00 - 15:00)';
  final String _unitLocationName = 'PLTD Sentral / Gardu Induk Unit 1-4';
  final double _currentLatitude = -2.214210;
  final double _currentLongitude = 113.921345;
  final double _distanceMeter = 28.5; // Within 100m geofence radius
  final double _geofenceRadiusMax = 100.0;

  bool _isCheckedInToday = false;
  String? _todayCheckInTime;
  String? _todayCheckOutTime;

  List<Map<String, dynamic>> _attendanceLogs = [];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _loadAttendanceLogs();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyPresensiLogs);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _attendanceLogs = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        _attendanceLogs = _getDefaultAttendanceLogs();
      }
    } else {
      _attendanceLogs = _getDefaultAttendanceLogs();
      await _saveAttendanceLogs();
    }

    // Check if user already checked in today
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (final log in _attendanceLogs) {
      if (log['dateKey'] == todayStr) {
        _isCheckedInToday = true;
        _todayCheckInTime = log['checkIn'];
        _todayCheckOutTime = log['checkOut'];
        break;
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveAttendanceLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPresensiLogs, jsonEncode(_attendanceLogs));
  }

  List<Map<String, dynamic>> _getDefaultAttendanceLogs() {
    final now = DateTime.now();
    final dfDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    return [
      {
        'dateKey': DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
        'tanggal': dfDate.format(now.subtract(const Duration(days: 1))),
        'shift': 'Shift 1 (Pagi)',
        'checkIn': '06:52 WITA',
        'checkOut': '15:08 WITA',
        'status': 'Tepat Waktu',
        'distance': '18 m dari Sentral',
        'geotag': 'Lat: -2.2142, Lon: 113.9213',
      },
      {
        'dateKey': DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
        'tanggal': dfDate.format(now.subtract(const Duration(days: 2))),
        'shift': 'Shift 1 (Pagi)',
        'checkIn': '06:55 WITA',
        'checkOut': '15:12 WITA',
        'status': 'Tepat Waktu',
        'distance': '22 m dari Sentral',
        'geotag': 'Lat: -2.2142, Lon: 113.9213',
      },
      {
        'dateKey': DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 3))),
        'tanggal': dfDate.format(now.subtract(const Duration(days: 3))),
        'shift': 'Shift 2 (Siang)',
        'checkIn': '14:48 WITA',
        'checkOut': '23:05 WITA',
        'status': 'Tepat Waktu',
        'distance': '35 m dari Sentral',
        'geotag': 'Lat: -2.2141, Lon: 113.9214',
      },
    ];
  }

  void _handleCheckIn() async {
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateStr = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(_currentTime);
    final dateKey = DateFormat('yyyy-MM-dd').format(_currentTime);

    final newLog = {
      'dateKey': dateKey,
      'tanggal': dateStr,
      'shift': '${_selectedShift.split(' ')[0]} ${_selectedShift.split(' ')[1]}',
      'checkIn': '$timeStr WITA',
      'checkOut': '-',
      'status': 'Hadir (Check-In)',
      'distance': '${_distanceMeter.toStringAsFixed(1)} m dari Sentral',
      'geotag': 'Lat: ${_currentLatitude.toStringAsFixed(4)}, Lon: ${_currentLongitude.toStringAsFixed(4)}',
    };

    setState(() {
      _isCheckedInToday = true;
      _todayCheckInTime = '$timeStr WITA';
      _attendanceLogs.insert(0, newLog);
    });

    await _saveAttendanceLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Check-In berhasil dicatat pada $timeStr WITA.'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleCheckOut() async {
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateKey = DateFormat('yyyy-MM-dd').format(_currentTime);

    setState(() {
      _todayCheckOutTime = '$timeStr WITA';
      for (final log in _attendanceLogs) {
        if (log['dateKey'] == dateKey) {
          log['checkOut'] = '$timeStr WITA';
          log['status'] = 'Shift Selesai';
          break;
        }
      }
    });

    await _saveAttendanceLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Check-Out berhasil pada $timeStr WITA. Terima kasih atas kerja keras Anda!'),
            ],
          ),
          backgroundColor: const Color(0xFF0072B2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('HH:mm:ss').format(_currentTime);
    final dateFormatted = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_currentTime);
    final isInsideGeofence = _distanceMeter <= _geofenceRadiusMax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002F55),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presensi Mandiri GPS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Geofence Lokasi Pembangkit & Absensi Shift',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Dark Hero with Live Clock & Geofence Radar Card
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF002F55), Color(0xFF00437A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Digital Live Clock
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          timeFormatted,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            fontFeatures: [],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 6),
                            Text(
                              dateFormatted,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE0F2FE)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interactive Visual Geofence Radar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Radar visual graphic
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00A2E8).withValues(alpha: 0.06),
                                border: Border.all(color: const Color(0xFF00A2E8).withValues(alpha: 0.2), width: 1.5),
                              ),
                            ),
                            // Middle circle
                            Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00A2E8).withValues(alpha: 0.10),
                                border: Border.all(color: const Color(0xFF00A2E8).withValues(alpha: 0.35), width: 1.5),
                              ),
                            ),
                            // Inner pulse circle
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 50 + (_pulseController.value * 14),
                                  height: 50 + (_pulseController.value * 14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isInsideGeofence ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.25),
                                  ),
                                );
                              },
                            ),
                            // Center Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isInsideGeofence ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isInsideGeofence ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.pin_drop_rounded, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Geofence Validation Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isInsideGeofence ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isInsideGeofence ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isInsideGeofence ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 16,
                                color: isInsideGeofence ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isInsideGeofence ? 'TERVERIFIKASI DI DALAM GEOFENCE' : 'DI LUAR RADIUS UNIT KERJA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isInsideGeofence ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          _unitLocationName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jarak saat ini: ${_distanceMeter.toStringAsFixed(1)} meter (Batas Maksimal: ${_geofenceRadiusMax.toInt()} meter)',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Koordinat: ${_currentLatitude.toStringAsFixed(6)}, ${_currentLongitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Shift Selector & Check-in / Check-out Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Shift Kerja Hari Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedShift,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFF0072B2)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Shift 1 (Pagi: 07:00 - 15:00)', child: Text('Shift 1 (Pagi: 07:00 - 15:00)', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Shift 2 (Siang: 15:00 - 23:00)', child: Text('Shift 2 (Siang: 15:00 - 23:00)', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Shift 3 (Malam: 23:00 - 07:00)', child: Text('Shift 3 (Malam: 23:00 - 07:00)', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'Non-Shift (Piket Pemeliharaan)', child: Text('Non-Shift (Piket Pemeliharaan)', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (v) => setState(() => _selectedShift = v!),
                  ),
                  const SizedBox(height: 18),

                  // Today's Check-in & Check-out Status Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.login_rounded, size: 16, color: Color(0xFF10B981)),
                                  SizedBox(width: 6),
                                  Text('Masuk (In)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _todayCheckInTime ?? '-- : --',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: _todayCheckInTime != null ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.logout_rounded, size: 16, color: Color(0xFF0072B2)),
                                  SizedBox(width: 6),
                                  Text('Pulang (Out)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _todayCheckOutTime ?? '-- : --',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: _todayCheckOutTime != null ? const Color(0xFF0072B2) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Big Action Button
                  if (!_isCheckedInToday)
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isInsideGeofence ? _handleCheckIn : null,
                        icon: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 24),
                        label: const Text('Presensi Check-In Sekarang', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    )
                  else if (_todayCheckOutTime == null)
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0072B2), Color(0xFF00A2E8)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0072B2).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isInsideGeofence ? _handleCheckOut : null,
                        icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 22),
                        label: const Text('Presensi Check-Out Selesai Shift', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 22),
                          SizedBox(width: 8),
                          Text('Presensi Shift Hari Ini Lengkap & Tuntas', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669), fontSize: 13)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),

                  // Recent Attendance History
                  const Text('Riwayat Presensi Mandiri GPS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _attendanceLogs[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['tanggal'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['status'] ?? 'Hadir',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(item['shift'] ?? '', style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text('In: ${item['checkIn']} | Out: ${item['checkOut']}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0072B2))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.my_location_rounded, size: 13, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(item['distance'] ?? '', style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
