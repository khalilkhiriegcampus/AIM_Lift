from django.contrib import admin
from .models import Incident

@admin.register(Incident)
class IncidentAdmin(admin.ModelAdmin):
    list_display = ("premise", "incident_type", "status", "created_at", "reported_by")
    list_filter = ("incident_type", "status")
    search_fields = ("premise", "incident_type")
