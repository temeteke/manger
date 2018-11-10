from django.shortcuts import render

from rest_framework import viewsets, filters
from .models import Author, Title, Volume
from .serializers import AuthorSerializer, TitleSerializer, VolumeSerializer

from django_filters.rest_framework import DjangoFilterBackend

class AuthorViewSet(viewsets.ModelViewSet):
    queryset = Author.objects.all()
    serializer_class = AuthorSerializer

class TitleViewSet(viewsets.ModelViewSet):
    queryset = Title.objects.all()
    serializer_class = TitleSerializer
    filter_backends = (filters.SearchFilter, )
    search_fields = ( 'name', 'authors__name' )

class VolumeViewSet(viewsets.ModelViewSet):
    queryset = Volume.objects.all()
    serializer_class = VolumeSerializer
    filter_backends = (DjangoFilterBackend, )
    filter_fields = ('title', )
