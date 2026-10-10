from django.db import models

class Region(models.Model):
    kd_region = models.CharField(max_length=10, unique=True, default='05')
    nama_region = models.CharField(max_length=100, default='Kalimantan 3')

    def __str__(self):
        return f"{self.kd_region} - {self.nama_region}"

class Area(models.Model):
    kd_area = models.CharField(max_length=10, unique=True)
    nama_area = models.CharField(max_length=100)
    region = models.ForeignKey(Region, on_delete=models.CASCADE, related_name='areas')

    def __str__(self):
        return f"{self.kd_area} - {self.nama_area}"

class Unit(models.Model):
    kd_unit = models.CharField(max_length=10, unique=True)
    nama_unit = models.CharField(max_length=150)
    area = models.ForeignKey(Area, on_delete=models.CASCADE, related_name='units')
    region = models.ForeignKey(Region, on_delete=models.CASCADE, related_name='units')
    latitude = models.FloatField(default=0.0)
    longitude = models.FloatField(default=0.0)

    def __str__(self):
        return f"{self.kd_unit} - {self.nama_unit}"

class Machine(models.Model):
    STATUS_CHOICES = [
        ('OPERASI', 'OPERASI / Normal'),
        ('STANDBY', 'STANDBY / Siaga'),
        ('GANGGUAN', 'GANGGUAN / Rusak'),
        ('MAINTENANCE', 'Perlu Pemeliharaan'),
    ]

    id_mesin = models.CharField(max_length=20, unique=True)
    nama_mesin = models.CharField(max_length=200)
    kode_mesin_silm = models.CharField(max_length=50, blank=True, null=True)
    sn = models.CharField(max_length=100, blank=True, null=True)
    dt = models.FloatField(default=0.0, help_text="Daya Terpasang kW")
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, related_name='machines')
    kd_jenis_bahan_bakar = models.CharField(max_length=20, default='B35')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='OPERASI')

    def __str__(self):
        return f"{self.id_mesin} - {self.nama_mesin}"

class HARReport(models.Model):
    MAINTENANCE_TYPES = [
        ('preventive', 'Preventive Maintenance (PM)'),
        ('corrective', 'Corrective Maintenance (CM)'),
        ('predictive', 'Predictive Maintenance (PdM)'),
    ]
    PRIORITY_CHOICES = [
        ('LOW', 'LOW'),
        ('NORMAL', 'NORMAL'),
        ('HIGH', 'HIGH'),
        ('CRITICAL', 'CRITICAL'),
    ]
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Menunggu Approval'),
        ('revision', 'Perlu Revisi'),
        ('approved', 'Selesai / Approved'),
    ]

    har_number = models.CharField(max_length=50, unique=True)
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, related_name='har_reports')
    machine = models.ForeignKey(Machine, on_delete=models.CASCADE, related_name='har_reports')
    date = models.DateField()
    start_time = models.CharField(max_length=10, default='08:00')
    end_time = models.CharField(max_length=10, default='11:30')
    duration_minutes = models.IntegerField(default=210)
    maintenance_type = models.CharField(max_length=20, choices=MAINTENANCE_TYPES, default='preventive')
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='NORMAL')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted')
    technician_name = models.CharField(max_length=100, default='Ahmad Teknisi')
    finding_description = models.TextField(blank=True, default='')
    action_taken = models.TextField(blank=True, default='')
    final_result = models.CharField(max_length=50, default='Normal')
    supervisor_notes = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.har_number} - {self.machine.nama_mesin}"

class HARChecklist(models.Model):
    CONDITION_CHOICES = [
        ('baik', 'Baik'),
        ('perbaikan', 'Perlu Perbaikan'),
        ('rusak', 'Rusak'),
        ('skip', 'Tidak Diperiksa'),
    ]
    har_report = models.ForeignKey(HARReport, on_delete=models.CASCADE, related_name='checklists')
    title = models.CharField(max_length=150)
    category = models.CharField(max_length=100, default='Pemeriksaan Umum')
    condition = models.CharField(max_length=20, choices=CONDITION_CHOICES, default='baik')
    notes = models.TextField(blank=True, default='')

class HARDocumentation(models.Model):
    PHOTO_TYPES = [
        ('before', 'Sebelum'),
        ('process', 'Saat Pekerjaan'),
        ('after', 'Setelah'),
    ]
    har_report = models.ForeignKey(HARReport, on_delete=models.CASCADE, related_name='documentations')
    photo_type = models.CharField(max_length=10, choices=PHOTO_TYPES)
    image_url = models.CharField(max_length=500, blank=True, default='')
    caption = models.CharField(max_length=255, blank=True, default='')
    taken_at = models.DateTimeField(auto_now_add=True)

class LogsheetReport(models.Model):
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, related_name='logsheets')
    machine = models.ForeignKey(Machine, on_delete=models.CASCADE, related_name='logsheets')
    submitted_at = models.DateTimeField()
    time_slot = models.CharField(max_length=10, default='08:00')
    operator_name = models.CharField(max_length=100)
    beban_mesin = models.FloatField(default=0.0)
    stand_kwh = models.FloatField(default=0.0)
    stand_bbm = models.FloatField(default=0.0)
    tekanan_oli = models.FloatField(default=0.0)
    temperatur_air = models.FloatField(default=0.0)
    phasa_r = models.FloatField(default=0.0)
    phasa_s = models.FloatField(default=0.0)
    phasa_t = models.FloatField(default=0.0)
    tegangan = models.FloatField(default=0.0)
    cos_phi = models.FloatField(default=1.0)
    frequency = models.FloatField(default=50.0)
    jam_kerja_mesin = models.FloatField(default=0.0)
    daya_mampu = models.FloatField(default=0.0)
    machine_status = models.CharField(max_length=20, default='OPERASI')
    notes = models.TextField(blank=True, default='')
    wacb_verified = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Logsheet {self.unit.nama_unit} {self.machine.nama_mesin} {self.time_slot}"

class AMCReport(models.Model):
    PRIORITY_CHOICES = [
        ('PRIORITAS 1', 'PRIORITAS 1'),
        ('PRIORITAS 2', 'PRIORITAS 2'),
        ('PRIORITAS 3', 'PRIORITAS 3'),
    ]
    STATUS_CHOICES = [
        ('OPEN', 'OPEN'),
        ('IN_PROGRESS', 'IN PROGRESS'),
        ('CLOSE', 'CLOSE'),
    ]

    periode = models.CharField(max_length=50, default='Setelah AMC')
    up3 = models.CharField(max_length=100, default='UP3 KALTIMRA')
    sentral = models.CharField(max_length=100, default='ULPLTD BONTANG')
    unit_pembangkit = models.CharField(max_length=150, default='ULD MUARA PAHU')
    merk = models.CharField(max_length=100, blank=True, default='')
    tipe = models.CharField(max_length=100, blank=True, default='')
    serial_number = models.CharField(max_length=100, blank=True, default='')
    dtp = models.FloatField(default=0.0, help_text="Daya Terpasang kW")
    dmp = models.FloatField(default=0.0, help_text="Daya Mampu Pasok kW")
    prioritas = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='PRIORITAS 1')
    indikasi_gangguan = models.TextField(blank=True, default='')
    dampak_mesin = models.TextField(blank=True, default='')
    waktu_kejadian = models.DateTimeField(null=True, blank=True)
    rencana_tindak_lanjut = models.TextField(blank=True, default='')
    list_material = models.TextField(blank=True, default='')
    progres = models.TextField(blank=True, default='')
    pic = models.CharField(max_length=100, default='Team HAR Kaltimra')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='OPEN')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"AMC {self.unit_pembangkit} - {self.indikasi_gangguan[:30]}"
