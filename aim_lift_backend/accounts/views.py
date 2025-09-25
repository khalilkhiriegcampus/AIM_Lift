from django.contrib.auth.views import (
    LoginView,
    PasswordResetView,
    PasswordResetConfirmView,
    PasswordResetDoneView,
    PasswordResetCompleteView,
)
from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.urls import reverse_lazy

from .serializers import UserSerializer
from .forms import ProfileUpdateForm

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class UserLoginView(LoginView):
    template_name = "accounts/login.html"

# 🔹 Forgot Password
class UserPasswordResetView(PasswordResetView):
    template_name = "accounts/forgot_password.html"
    email_template_name = "accounts/password_reset_email.html"
    success_url = reverse_lazy("password_reset_done")  # ✅ redirect to done page

class UserPasswordResetDoneView(PasswordResetDoneView):
    template_name = "accounts/password_reset_done.html"

class UserPasswordResetConfirmView(PasswordResetConfirmView):
    template_name = "accounts/reset_password.html"
    success_url = reverse_lazy("password_reset_complete")

class UserPasswordResetCompleteView(PasswordResetCompleteView):
    template_name = "accounts/password_reset_complete.html"

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
