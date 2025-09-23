from django.views.generic import TemplateView
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.shortcuts import get_object_or_404
from django.contrib.auth.decorators import login_required
from dashboard.models import Incident
import json


class LandingView(TemplateView):
    template_name = "dashboard/landing.html"


class DashboardView(TemplateView):
    template_name = "dashboard/dashboard.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["incidents"] = Incident.objects.order_by("-created_at")[:5]

        # 🔹 Pass user role into template/JS
        if self.request.user.is_authenticated:
            context["user_role"] = getattr(self.request.user, "role", "CLIENT")
        else:
            context["user_role"] = "ANON"

        return context

# 🔹 IoT Alert API (ESP32)
@csrf_exempt
def iot_alert(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body.decode("utf-8"))

            incident = Incident.objects.create(
                premise=data.get("premise", "Unknown Premise"),
                incident_type=data.get("incident_type", "Unknown"),
                status=data.get("status", "Detected"),
                reported_by=None,
            )

            return JsonResponse({"success": True, "id": incident.id})
        except Exception as e:
            return JsonResponse({"success": False, "error": str(e)}, status=400)

    return JsonResponse({"error": "Only POST allowed"}, status=405)


# 🔹 Get latest incidents
def get_incidents(request):
    incidents = Incident.objects.order_by("-created_at")[:10]
    data = {
        "incidents": [
            {
                "id": i.id,
                "incident_type": i.incident_type,
                "premise": i.premise,
                "status": i.status,
                "created_at": i.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            }
            for i in incidents
        ]
    }
    return JsonResponse(data)


# 🔹 Resolve Incident (JKR & Contractor ONLY)
@csrf_exempt
@require_POST
@login_required
def resolve_incident(request, incident_id):
    user = request.user

    # ✅ Only allow JKR + Contractor
    if user.role not in ["JKR", "CONTRACTOR"]:
        return JsonResponse({"success": False, "error": "Permission denied"}, status=403)

    try:
        incident = get_object_or_404(Incident, id=incident_id)
        incident.status = "Resolved"
        incident.save()
        return JsonResponse({"success": True, "message": "Incident resolved."})
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=400)
