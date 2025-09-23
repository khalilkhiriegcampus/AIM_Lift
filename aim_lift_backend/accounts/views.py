from django.shortcuts import render, redirect
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .serializers import UserSerializer
from django.contrib.auth.views import LoginView
from django.contrib.auth.decorators import login_required
from .forms import ProfileUpdateForm

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class UserLoginView(LoginView):
    template_name = "accounts/login.html"

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