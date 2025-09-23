# dashboard/models.py
from django.db import models
from django.conf import settings

class Incident(models.Model):
    INCIDENT_TYPES = [
        ("Mantrap", "Mantrap"),
        ("Power Failure", "Power Failure"),
        ("Door Jam", "Door Jam"),
    ]

    premise = models.CharField(max_length=255)
    incident_type = models.CharField(max_length=50, choices=INCIDENT_TYPES)
    status = models.CharField(max_length=50, default="Detected")
    created_at = models.DateTimeField(auto_now_add=True)
    reported_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True
    )
    resolved = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        # 🔹 Auto-update status if resolved
        if self.resolved:
            self.status = "Resolved"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.premise} - {self.incident_type} ({self.status})"
