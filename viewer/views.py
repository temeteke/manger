from django.shortcuts import render

from rest_framework import viewsets
from .models import Volume
from .serializers import VolumeSerializer

class VolumeViewSet(viewsets.ModelViewSet):
    queryset = Volume.objects.all()
    serializer_class = VolumeSerializer
