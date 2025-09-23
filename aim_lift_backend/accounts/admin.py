from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ("Extra Info", {"fields": ("full_name", "designation", "profile_picture")}),
    )

admin.site.register(CustomUser, CustomUserAdmin)
