from rest_framework import serializers
from .models import CustomUser

class UserSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "username",
            "email",
            "full_name",
            "designation",
            "mobile_number",
            "company_name",
            "role",
        ]

    def get_role(self, obj):
        if obj.is_superuser:
            return "JKR"
        elif obj.groups.filter(name="Contractor").exists():
            return "Contractor"
        elif obj.groups.filter(name="Client").exists():
            return "Client"
        return "User"
