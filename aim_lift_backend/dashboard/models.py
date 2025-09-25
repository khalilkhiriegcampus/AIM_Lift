# dashboard/models.py
from django.db import models
from django.conf import settings
from django.utils import timezone


class Premise(models.Model):
    STATUS_CHOICES = [
        ("Normal", "Normal"),
        ("Alert", "Alert"),
    ]

    name = models.CharField(max_length=200)
    lat = models.FloatField(null=True, blank=True)
    lng = models.FloatField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="Normal")

    def __str__(self):
        return self.name


class Incident(models.Model):
    INCIDENT_TYPES = [
        ("Mantrap", "Mantrap"),
        ("Power Failure", "Power Failure"),
        ("Door Jam", "Door Jam"),
    ]

    premise = models.CharField(max_length=255)  # Link to Premise by name
    incident_type = models.CharField(max_length=50, choices=INCIDENT_TYPES)
    status = models.CharField(max_length=50, default="Detected")
    created_at = models.DateTimeField(auto_now_add=True)

    # SLA tracking
    attended_at = models.DateTimeField(null=True, blank=True)  # when contractor arrived
    resolved_at = models.DateTimeField(null=True, blank=True)  # when fully resolved

    reported_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    resolved = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        # Auto-update status if resolved
        if self.resolved and not self.resolved_at:
            self.status = "Resolved"
            self.resolved_at = timezone.now()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.premise} - {self.incident_type} ({self.status})"


class ContactPerson(models.Model):
    premise = models.ForeignKey(Premise, on_delete=models.CASCADE, related_name="contacts")
    name = models.CharField(max_length=200)
    role = models.CharField(max_length=100)  # e.g. JKR Engineer, Contractor, Client Rep
    phone = models.CharField(max_length=20)
    email = models.EmailField()

    def __str__(self):
        return f"{self.name} ({self.role})"
