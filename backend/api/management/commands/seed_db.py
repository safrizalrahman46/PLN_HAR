from django.core.management.base import BaseCommand
from api.models import Region, Area, Unit, Machine, HARReport, HARChecklist, HARDocumentation, AMCReport
import datetime
from django.utils import timezone

class Command(BaseCommand):
    help = 'Seeds initial database for PLN Nusa Daya HAR, AMC & Logsheet'

    def handle(self, *args, **options):
        self.stdout.write('Seeding initial data for all Kalimantan 3 units...')

        region, _ = Region.objects.get_or_create(kd_region='05', defaults={'nama_region': 'Kalimantan 3'})
        area_bontang, _ = Area.objects.get_or_create(kd_area='40', defaults={'nama_area': 'SITE BONTANG', 'region': region})
        area_berau, _ = Area.objects.get_or_create(kd_area='67', defaults={'nama_area': 'SITE BERAU', 'region': region})

        # Units
        units_data = [
            {'kd': '0264', 'nama': 'ULD BATU AMPAR', 'area': area_bontang, 'lat': 0.54012, 'lng': 116.98541},
            {'kd': '0283', 'nama': 'ULD MUARA PAHU', 'area': area_bontang, 'lat': -0.34210, 'lng': 115.89240},
            {'kd': '0265', 'nama': 'ULD BIDUK-BIDUK', 'area': area_berau, 'lat': 1.23450, 'lng': 118.69230},
            {'kd': '0279', 'nama': 'ULD LONG SEGAR', 'area': area_bontang, 'lat': 0.65120, 'lng': 116.78210},
            {'kd': '0281', 'nama': 'ULD KELAY', 'area': area_berau, 'lat': 1.76540, 'lng': 117.23410},
            {'kd': '0288', 'nama': 'ULD MARATUA', 'area': area_berau, 'lat': 2.21540, 'lng': 118.61230},
        ]

        unit_objs = {}
        for u in units_data:
            obj, _ = Unit.objects.get_or_create(
                kd_unit=u['kd'],
                defaults={
                    'nama_unit': u['nama'],
                    'area': u['area'],
                    'region': region,
                    'latitude': u['lat'],
                    'longitude': u['lng']
                }
            )
            unit_objs[u['kd']] = obj

        # Machines
        machines_data = [
            # 0264 Batu Ampar
            {'id': '000344', 'nama': 'PLTD BATU AMPAR #01 (DEUTZ BF6M 1013 E)', 'silm': '22555140302001', 'sn': '134354', 'dt': 100.0, 'unit': '0264', 'status': 'OPERASI'},
            {'id': '000345', 'nama': 'PLTD BATU AMPAR #02 (DEUTZ BF6M 1013 E)', 'silm': '22555140302002', 'sn': '64060', 'dt': 100.0, 'unit': '0264', 'status': 'OPERASI'},
            {'id': '000347', 'nama': 'PLTD BATU AMPAR #04 (DEUTZ F 10 L 413 F)', 'silm': '22555140302004', 'sn': '6711748', 'dt': 100.0, 'unit': '0264', 'status': 'STANDBY'},
            {'id': '000348', 'nama': 'PLTD BATU AMPAR #05 (MAN D 2866 LE)', 'silm': '22555140302007', 'sn': '39093750534101', 'dt': 200.0, 'unit': '0264', 'status': 'OPERASI'},
            {'id': '000390', 'nama': 'PLTD BATU AMPAR #07 (CUMMINS KTA50-G3)', 'silm': '22555140102003', 'sn': '45291032', 'dt': 250.0, 'unit': '0264', 'status': 'OPERASI'},

            # 0283 Muara Pahu
            {'id': '000581', 'nama': 'PLTD MUARA PAHU #01 (CATERPILLAR 3512B)', 'silm': '22555140302831', 'sn': '241088', 'dt': 800.0, 'unit': '0283', 'status': 'OPERASI'},
            {'id': '000582', 'nama': 'PLTD MUARA PAHU #02 (DEUTZ TBD 620 V12)', 'silm': '22555140302832', 'sn': '620104', 'dt': 600.0, 'unit': '0283', 'status': 'OPERASI'},
            {'id': '000583', 'nama': 'PLTD MUARA PAHU #03 (MITSUBISHI S12R-PTA)', 'silm': '22555140302833', 'sn': '120442', 'dt': 1000.0, 'unit': '0283', 'status': 'STANDBY'},
            {'id': '000584', 'nama': 'PLTD MUARA PAHU #04 (PERKINS 4008TAG)', 'silm': '22555140302834', 'sn': '400812', 'dt': 750.0, 'unit': '0283', 'status': 'GANGGUAN'},

            # 0265 Biduk-Biduk
            {'id': '000411', 'nama': 'PLTD BIDUK-BIDUK #01 (MTU 16V4000)', 'silm': '22555140302651', 'sn': 'MTU-4001', 'dt': 1500.0, 'unit': '0265', 'status': 'OPERASI'},
            {'id': '000412', 'nama': 'PLTD BIDUK-BIDUK #02 (CAT 3512B)', 'silm': '22555140302652', 'sn': 'CAT-3512-02', 'dt': 1000.0, 'unit': '0265', 'status': 'OPERASI'},

            # 0279 Long Segar
            {'id': '000421', 'nama': 'PLTD LONG SEGAR #01 (PERKINS 4008TAG)', 'silm': '22555140302791', 'sn': 'PRK-4008-01', 'dt': 750.0, 'unit': '0279', 'status': 'OPERASI'},

            # 0281 Kelay
            {'id': '000431', 'nama': 'PLTD KELAY #01 (CUMMINS KTA50-G3)', 'silm': '22555140302811', 'sn': 'CUM-5001', 'dt': 1000.0, 'unit': '0281', 'status': 'OPERASI'},

            # 0288 Maratua
            {'id': '000441', 'nama': 'PLTD MARATUA #01 (MITSUBISHI S16R-PTA)', 'silm': '22555140302881', 'sn': 'MIT-1601', 'dt': 1400.0, 'unit': '0288', 'status': 'OPERASI'},
        ]

        machine_objs = {}
        for m in machines_data:
            obj, _ = Machine.objects.get_or_create(
                id_mesin=m['id'],
                defaults={
                    'nama_mesin': m['nama'],
                    'kode_mesin_silm': m['silm'],
                    'sn': m['sn'],
                    'dt': m['dt'],
                    'unit': unit_objs[m['unit']],
                    'status': m['status']
                }
            )
            machine_objs[m['id']] = obj

        # HAR Reports
        har_list = [
            {
                'num': 'HAR-2026-00021',
                'unit': unit_objs['0264'],
                'machine': machine_objs['000344'],
                'date': datetime.date(2026, 8, 2),
                'type': 'preventive',
                'priority': 'NORMAL',
                'status': 'submitted',
                'technician': 'Ahmad Teknisi',
                'finding': 'Filter oli terlihat kotor dan terdapat rembesan halus pada seal penutup klep.',
                'action': 'Pembersihan filter dengan solar, penggantian seal gasket baru.',
                'result': 'Normal'
            },
            {
                'num': 'HAR-2026-00022',
                'unit': unit_objs['0283'],
                'machine': machine_objs['000581'],
                'date': datetime.date(2026, 8, 3),
                'type': 'preventive',
                'priority': 'NORMAL',
                'status': 'approved',
                'technician': 'Rahman Teknisi',
                'finding': 'Pemeriksaan 500 jam operasi rutin. Kualitas oli pelumas dan celah katup dalam batas toleransi.',
                'action': 'Penggantian oli pelumas Meditran SX4 15W-40, pembersihan elemen filter udara.',
                'result': 'Normal Andal'
            },
            {
                'num': 'HAR-2026-00023',
                'unit': unit_objs['0283'],
                'machine': machine_objs['000584'],
                'date': datetime.date(2026, 8, 4),
                'type': 'corrective',
                'priority': 'HIGH',
                'status': 'submitted',
                'technician': 'Budi Santoso',
                'finding': 'Suhu air pendingin radiator melebihi 95°C (Overheat alarm memicu trip).',
                'action': 'Flushing kisi radiator, pemeriksaan kebocoran water pump dan penggantian thermostat.',
                'result': 'Dalam Pemantauan'
            },
        ]

        for h in har_list:
            har_obj, _ = HARReport.objects.get_or_create(
                har_number=h['num'],
                defaults={
                    'unit': h['unit'],
                    'machine': h['machine'],
                    'date': h['date'],
                    'start_time': '08:00',
                    'end_time': '11:30',
                    'duration_minutes': 210,
                    'maintenance_type': h['type'],
                    'priority': h['priority'],
                    'status': h['status'],
                    'technician_name': h['technician'],
                    'finding_description': h['finding'],
                    'action_taken': h['action'],
                    'final_result': h['result'],
                }
            )
            HARChecklist.objects.get_or_create(
                har_report=har_obj,
                title='Pemeriksaan Sistem Pelumasan',
                defaults={'category': 'Sistem Pelumasan', 'condition': 'baik', 'notes': 'Tekanan normal 4.2 bar'}
            )
            HARChecklist.objects.get_or_create(
                har_report=har_obj,
                title='Pemeriksaan Sistem Pendingin',
                defaults={'category': 'Sistem Pendingin', 'condition': 'baik', 'notes': 'Level air normal'}
            )

        # AMC Reports (Laporan Gangguan AMC KIT KALTIMRA 2026)
        amc_list = [
            {
                'periode': 'Setelah AMC',
                'up3': 'UP3 KALTIMRA',
                'sentral': 'ULPLTD BONTANG',
                'unit_pembangkit': 'ULD MUARA PAHU',
                'merk': 'PERKINS',
                'tipe': '4008TAG',
                'sn': '400812',
                'dtp': 750.0,
                'dmp': 0.0,
                'prioritas': 'PRIORITAS 1',
                'indikasi': 'Temperatur radiator tinggi (Overheat alarm trip)',
                'dampak': 'Daya mampu pasok berkurang 750 kW, sistem siaga defisit',
                'rencana': 'Flushing kerak radiator dan penggantian thermostat',
                'material': 'Thermostat 4008TAG, Gasket Radiator, Coolant 50L',
                'progres': 'Menunggu kedatangan coolant dan sparepart seal',
                'pic': 'Team HAR Kaltimra',
                'status': 'OPEN'
            },
            {
                'periode': 'Setelah AMC',
                'up3': 'UP3 KALTIMRA',
                'sentral': 'ULPLTD BONTANG',
                'unit_pembangkit': 'ULD BATU AMPAR',
                'merk': 'DEUTZ',
                'tipe': 'BF6M 1013 E',
                'sn': '64060',
                'dtp': 100.0,
                'dmp': 90.0,
                'prioritas': 'PRIORITAS 2',
                'indikasi': 'Rembesan oli halus pada seal turbocharger',
                'dampak': 'Mesin tetap beroperasi dengan pemantauan tekanan oli intensif',
                'rencana': 'Re-torque baut intake dan penggantian O-ring return oil',
                'material': 'O-ring turbocharger, sealant Loctite 518',
                'progres': 'Selesai perbaikan dan uji pembebanan 85 kW normal',
                'pic': 'Ahmad Teknisi',
                'status': 'CLOSE'
            },
            {
                'periode': 'Setelah AMC',
                'up3': 'UP3 KALTIMRA',
                'sentral': 'ULPLTD BERAU',
                'unit_pembangkit': 'ULD BIDUK-BIDUK',
                'merk': 'CATERPILLAR',
                'tipe': '3512B',
                'sn': 'CAT-3512-02',
                'dtp': 1000.0,
                'dmp': 0.0,
                'prioritas': 'PRIORITAS 1',
                'indikasi': 'Injektor silinder #4 macet, asap hitam pekat',
                'dampak': 'Mesin shutdown darurat untuk mencegah kerusakan piston',
                'rencana': 'Kalibrasi dan penggantian nozzle injektor unit',
                'material': 'Unit Injector CAT 3512B (2 unit)',
                'progres': 'Pemasangan injektor baru dan bleeding solar',
                'pic': 'Team Har Berau',
                'status': 'IN_PROGRESS'
            },
        ]

        for a in amc_list:
            AMCReport.objects.get_or_create(
                unit_pembangkit=a['unit_pembangkit'],
                indikasi_gangguan=a['indikasi'],
                defaults={
                    'periode': a['periode'],
                    'up3': a['up3'],
                    'sentral': a['sentral'],
                    'merk': a['merk'],
                    'tipe': a['tipe'],
                    'serial_number': a['sn'],
                    'dtp': a['dtp'],
                    'dmp': a['dmp'],
                    'prioritas': a['prioritas'],
                    'dampak_mesin': a['dampak'],
                    'rencana_tindak_lanjut': a['rencana'],
                    'list_material': a['material'],
                    'progres': a['progres'],
                    'pic': a['pic'],
                    'status': a['status'],
                    'waktu_kejadian': timezone.now() - datetime.timedelta(days=2)
                }
            )

        self.stdout.write(self.style.SUCCESS('Successfully seeded all units, machines, HAR & AMC reports!'))
