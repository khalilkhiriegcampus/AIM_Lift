from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from dashboard.models import Incident

@api_view(["POST"])
def iot_alert(request):
    data = request.data
    incident = Incident.objects.create(
        device_id=data.get("device_id"),
        incident_type=data.get("incident_type"),
        premise=data.get("premise"),
        status=data.get("status")
    )
    return Response({"message": "Incident stored", "id": incident.id}, status=status.HTTP_201_CREATED)
