# dashboard/views.py
import json
from datetime import timedelta
from django.views.generic import TemplateView
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.utils import timezone
from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from .models import Incident, Premise, ContactPerson
from django.db.models import Count, Q
from django.db.models import F


# ------------------------
# Landing + Simple Pages
# ------------------------
class LandingView(TemplateView):
    template_name = "dashboard/landing.html"


def register_interest(request):
    return HttpResponse("<h1>Register Interest Page</h1><p>Form coming soon...</p>")


# ------------------------
# Dashboard View
# ------------------------
class DashboardView(TemplateView):
    template_name = "dashboard/dashboard.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        # Active = incidents still "Detected" and not yet attended
        active_incidents = Incident.objects.filter(status="Detected", attended_at__isnull=True)

        # Unresolved = incidents attended but not resolved
        unresolved_incidents = Incident.objects.filter(
            status="Detected", attended_at__isnull=False, resolved_at__isnull=True
        )

        # SLA calculations
        attended = Incident.objects.filter(attended_at__isnull=False)
        resolved = Incident.objects.filter(resolved_at__isnull=False)

        # Response SLA → on-time attendance
        if attended.exists():
            on_time_attended = attended.filter(attended_at__lte=F("created_at") + timedelta(minutes=30))
            response_sla = round(on_time_attended.count() / attended.count() * 100, 1)
        else:
            response_sla = 0

        # Resolution SLA → resolved within 14 days
        if resolved.exists():
            on_time_resolved = resolved.filter(resolved_at__lte=F("created_at") + timedelta(days=14))
            resolution_sla = round(on_time_resolved.count() / resolved.count() * 100, 1)
        else:
            resolution_sla = 0

        # Pass to template
        context["active_count"] = active_incidents.count()
        context["unresolved_count"] = unresolved_incidents.count()
        context["response_sla"] = response_sla
        context["resolution_sla"] = resolution_sla

        # Premises for map
        context["premises"] = [
            {"name": p.name, "lat": p.lat, "lng": p.lng, "status": p.status}
            for p in Premise.objects.all()
        ]

        return context


# ------------------------
# IoT Alert (from ESP32)
# ------------------------
@csrf_exempt
def iot_alert(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body.decode("utf-8"))
            premise_name = data.get("premise", "Unknown Premise")
            incident_type = data.get("incident_type", "Unknown")
            incoming_status = data.get("status", "Detected")

            # Always create new incident as Detected
            incident = Incident.objects.create(
                premise=premise_name,
                incident_type=incident_type,
                status="Detected",
                reported_by=None,
            )

            # If ESP32 reports resolved
            if incoming_status == "Resolved":
                incident.resolved = True
                incident.status = "Resolved"
                incident.resolved_at = timezone.now()
                incident.save()

            # Update premise status
            try:
                premise_obj = Premise.objects.get(name=premise_name)
                premise_obj.status = "Alert" if incident.status == "Detected" else "Normal"
                premise_obj.save()
            except Premise.DoesNotExist:
                pass

            return JsonResponse({"success": True, "id": incident.id, "status": incident.status})
        except Exception as e:
            return JsonResponse({"success": False, "error": str(e)}, status=400)

    return JsonResponse({"error": "Only POST allowed"}, status=405)


# ------------------------
# API: Get Incidents
# ------------------------
def get_incidents(request):
    incidents = Incident.objects.order_by("-created_at")[:20]
    data = {
        "incidents": [
            {
                "id": i.id,
                "incident_type": i.incident_type,
                "premise": i.premise,
                "status": i.status,
                "created_at": i.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                "attended_at": i.attended_at.strftime("%Y-%m-%d %H:%M:%S") if i.attended_at else None,
                "resolved_at": i.resolved_at.strftime("%Y-%m-%d %H:%M:%S") if i.resolved_at else None,
            }
            for i in incidents
        ]
    }
    return JsonResponse(data)


# ------------------------
# API: Attend Incident
# ------------------------
@require_POST
@login_required
def attend_incident(request, incident_id):
    try:
        incident = Incident.objects.get(id=incident_id)

        # Only JKR or Contractors can attend
        if not (
            request.user.groups.filter(name="JKR").exists()
            or request.user.groups.filter(name="Contractors").exists()
        ):
            return JsonResponse({"success": False, "error": "Not authorized"}, status=403)

        now_time = timezone.now()
        incident.attended_at = now_time

        # SLA check: 30 min
        deadline = incident.created_at + timedelta(minutes=30)
        sla_status = "On-Time" if now_time <= deadline else "Late"

        incident.save()

        return JsonResponse({
            "success": True,
            "attended_at": incident.attended_at.strftime("%Y-%m-%d %H:%M:%S"),
            "sla_status": sla_status,
        })
    except Incident.DoesNotExist:
        return JsonResponse({"success": False, "error": "Incident not found"}, status=404)


# ------------------------
# API: Resolve Incident
# ------------------------
@require_POST
@login_required
def resolve_incident(request, incident_id):
    try:
        incident = Incident.objects.get(id=incident_id)

        # Only JKR can resolve
        if not request.user.groups.filter(name="JKR").exists():
            return JsonResponse({"success": False, "error": "Not authorized"}, status=403)

        now_time = timezone.now()
        incident.resolved_at = now_time
        incident.status = "Resolved"
        incident.save()

        # SLA check: must resolve within 14 days
        deadline = incident.created_at + timedelta(days=14)
        sla_status = "On-Time" if now_time <= deadline else "Late"

        # Update premise back to Normal
        try:
            premise_obj = Premise.objects.get(name=incident.premise)
            premise_obj.status = "Normal"
            premise_obj.save()
        except Premise.DoesNotExist:
            pass

        return JsonResponse({
            "success": True,
            "resolved_at": incident.resolved_at.strftime("%Y-%m-%d %H:%M:%S"),
            "sla_status": sla_status,
        })

    except Incident.DoesNotExist:
        return JsonResponse({"success": False, "error": "Incident not found"}, status=404)

# ------------------------
# Team View
# ------------------------
def team_view(request):
    contacts = ContactPerson.objects.select_related("premise").all().order_by("premise__name")
    return render(request, "team.html", {"contacts": contacts})
