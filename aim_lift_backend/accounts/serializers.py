from django.contrib.auth.models import Group
from rest_framework import serializers
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "username", "email", "role"]  # include role

    def get_role(self, obj):
        if obj.is_superuser:
            return "JKR"
        elif obj.groups.filter(name="Contractor").exists():
            return "Contractor"
        elif obj.groups.filter(name="Client").exists():
            return "Client"
        return "User"
