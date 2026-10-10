from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    login_view, format_logsheet_view, post_logsheet_view,
    logsheet_report_matrix_view, dashboard_stats_view,
    UnitViewSet, MachineViewSet, HARReportViewSet, AMCReportViewSet
)

router = DefaultRouter()
router.register(r'units', UnitViewSet)
router.register(r'machines', MachineViewSet)
router.register(r'har', HARReportViewSet)
router.register(r'amc', AMCReportViewSet)

urlpatterns = [
    path('login', login_view),
    path('v1/format-logsheet-pltd', format_logsheet_view),
    path('v1/logsheet-pltd', post_logsheet_view),
    path('logsheet', logsheet_report_matrix_view),
    path('dashboard/stats', dashboard_stats_view),
    path('', include(router.urls)),
]
