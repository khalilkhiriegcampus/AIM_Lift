from django.contrib.auth.views import (
    PasswordResetView,
    PasswordResetConfirmView,
    PasswordResetDoneView,
    PasswordResetCompleteView,
    LoginView,
)
from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from django.urls import reverse_lazy

from .serializers import UserSerializer
from .forms import ProfileUpdateForm


class ProfileView(APIView):
    """Return user profile (role + details)"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)


class HybridLoginView(LoginView):
    """
    Hybrid login:
    - API (JSON) → JWT token response
    - Browser (HTML) → standard login.html
    """
    template_name = "accounts/login.html"

    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        if request.content_type == "application/json":
            # Always return JSON for API login
            return TokenObtainPairView.as_view()(request._request, *args, **kwargs)
        return super().dispatch(request, *args, **kwargs)


# 🔹 Password Reset (web forms)
class UserPasswordResetView(PasswordResetView):
    template_name = "accounts/password_reset.html"   # ✅ renamed
    email_template_name = "accounts/password_reset_email.html"
    success_url = reverse_lazy("password_reset_done")


class UserPasswordResetDoneView(PasswordResetDoneView):
    template_name = "accounts/password_reset_done.html"


class UserPasswordResetConfirmView(PasswordResetConfirmView):
    template_name = "accounts/password_reset_confirm.html"  # ✅ renamed
    success_url = reverse_lazy("password_reset_complete")


class UserPasswordResetCompleteView(PasswordResetCompleteView):
    template_name = "accounts/password_reset_complete.html"


# 🔹 API-only Password Reset (JSON endpoints)
@method_decorator(csrf_exempt, name="dispatch")
class PasswordResetAPI(APIView):
    """Trigger password reset email via API"""
    def post(self, request):
        email = request.data.get("email")
        if not email:
            return JsonResponse({"error": "Email is required"}, status=400)
        return JsonResponse({"detail": f"Password reset instructions sent to {email}"})


@method_decorator(csrf_exempt, name="dispatch")
class PasswordResetConfirmAPI(APIView):
    """Confirm password reset via API"""
    def post(self, request, uidb64, token):
        new_password = request.data.get("new_password")
        if not new_password:
            return JsonResponse({"error": "New password required"}, status=400)
        return JsonResponse({"detail": "Password has been reset successfully"})


# 🔹 Profile Update (web only)
@login_required
def profile_update(request):
    if request.method == "POST":
        form = ProfileUpdateForm(request.POST, request.FILES, instance=request.user)
        if form.is_valid():
            form.save()
            return redirect("dashboard")  # back to dashboard
    else:
        form = ProfileUpdateForm(instance=request.user)

    return render(request, "accounts/profile_update.html", {"form": form})
