from django.urls import path
from .views import DashboardView, get_incidents, iot_alert, resolve_incident, register_interest, attend_incident
from .views import team_view
from . import views

urlpatterns = [
    path("", DashboardView.as_view(), name="dashboard"),
    path("main/", DashboardView.as_view(), name="dashboard"),
    path("api/iot/alert/", iot_alert, name="iot_alert"),
    path("api/incidents/", get_incidents, name="get_incidents"),
    path("api/incidents/<int:incident_id>/attend/", views.attend_incident, name="attend_incident"),
    path("api/incidents/<int:incident_id>/resolve/", views.resolve_incident, name="resolve_incident"),
    path("register-interest/", register_interest, name="register_interest"),
    path("team/", team_view, name="team"),
]
