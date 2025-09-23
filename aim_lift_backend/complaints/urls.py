from django.urls import path
from .views import complaint_dashboard

urlpatterns = [
    path("", complaint_dashboard, name="complaints"),
    path("create/", complaint_dashboard, name="complaints_create"),
]
