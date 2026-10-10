class User {
  final String username;
  final String name;
  final String role;
  final String token;

  User({
    required this.username,
    required this.name,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? 'kal3',
      name: json['name'] ?? 'Super Admin K3',
      role: json['role'] ?? 'superadmin',
      token: json['token'] ?? 'superadmin-token',
    );
  }
}

class MachineModel {
  final String idMesin;
  final String namaMesin;
  final String kodeMesinSilm;
  final String sn;
  final double dt;
  final String status;

  MachineModel({
    required this.idMesin,
    required this.namaMesin,
    required this.kodeMesinSilm,
    required this.sn,
    required this.dt,
    required this.status,
  });
}

class HARModel {
  final String id;
  final String harNumber;
  final String unitName;
  final String machineName;
  final String date;
  final String timeSlot;
  final String status;
  final String priority;

  HARModel({
    required this.id,
    required this.harNumber,
    required this.unitName,
    required this.machineName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.priority,
  });
}
