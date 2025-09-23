from django.urls import path
from .views import DashboardView, get_incidents, iot_alert, resolve_incident

urlpatterns = [
    path("", DashboardView.as_view(), name="dashboard"),
    path("main/", DashboardView.as_view(), name="dashboard"),
    path("api/iot/alert/", iot_alert, name="iot_alert"),
    path("api/incidents/", get_incidents, name="get_incidents"),
    path("api/incidents/<int:incident_id>/resolve/", resolve_incident, name="resolve_incident"),
]
