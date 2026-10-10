from rest_framework import serializers
from .models import (
    Region, Area, Unit, Machine, HARReport, HARChecklist, HARDocumentation,
    LogsheetReport, AMCReport
)

class RegionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Region
        fields = '__all__'

class AreaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Area
        fields = '__all__'

class UnitSerializer(serializers.ModelSerializer):
    area_name = serializers.CharField(source='area.nama_area', read_only=True)
    region_name = serializers.CharField(source='region.nama_region', read_only=True)

    class Meta:
        model = Unit
        fields = '__all__'

class MachineSerializer(serializers.ModelSerializer):
    unit_name = serializers.CharField(source='unit.nama_unit', read_only=True)

    class Meta:
        model = Machine
        fields = '__all__'

class HARChecklistSerializer(serializers.ModelSerializer):
    class Meta:
        model = HARChecklist
        fields = '__all__'

class HARDocumentationSerializer(serializers.ModelSerializer):
    class Meta:
        model = HARDocumentation
        fields = '__all__'

class HARReportSerializer(serializers.ModelSerializer):
    unit_name = serializers.CharField(source='unit.nama_unit', read_only=True)
    machine_name = serializers.CharField(source='machine.nama_mesin', read_only=True)
    checklists = HARChecklistSerializer(many=True, read_only=True)
    documentations = HARDocumentationSerializer(many=True, read_only=True)

    class Meta:
        model = HARReport
        fields = '__all__'

class LogsheetReportSerializer(serializers.ModelSerializer):
    unit_name = serializers.CharField(source='unit.nama_unit', read_only=True)
    machine_name = serializers.CharField(source='machine.nama_mesin', read_only=True)

    class Meta:
        model = LogsheetReport
        fields = '__all__'

class AMCReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = AMCReport
        fields = '__all__'
