from django.urls import path
from django.contrib.auth.views import LogoutView

from .views import (
    HybridLoginView,
    ProfileView,
    UserPasswordResetView,
    UserPasswordResetDoneView,
    UserPasswordResetConfirmView,
    UserPasswordResetCompleteView,
    PasswordResetAPI,
    PasswordResetConfirmAPI,
    profile_update,
)

urlpatterns = [
    # Web login/logout
    path("login/", HybridLoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(next_page="landing"), name="logout"),

    # Profile
    path("profile/", ProfileView.as_view(), name="profile"),
    path("profile/update/", profile_update, name="profile_update"),

    # Web password reset flow
    path("password_reset/", UserPasswordResetView.as_view(), name="password_reset"),
    path("password_reset/done/", UserPasswordResetDoneView.as_view(), name="password_reset_done"),
    path("reset/<uidb64>/<token>/", UserPasswordResetConfirmView.as_view(), name="password_reset_confirm"),
    path("reset/done/", UserPasswordResetCompleteView.as_view(), name="password_reset_complete"),

    # API password reset
    path("api/password_reset/", PasswordResetAPI.as_view(), name="api_password_reset"),
    path("api/password_reset/confirm/<uidb64>/<token>/", PasswordResetConfirmAPI.as_view(), name="api_password_reset_confirm"),
]
