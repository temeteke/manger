from django.shortcuts import render

from rest_framework import viewsets, filters
from .models import Author, Book
from .serializers import AuthorSerializer, BookSerializer

from django_filters.rest_framework import DjangoFilterBackend

class AuthorViewSet(viewsets.ModelViewSet):
    queryset = Author.objects.all()
    serializer_class = AuthorSerializer

class BookViewSet(viewsets.ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    filter_backends = (DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter )
    filter_fields = ('authors__name', 'title')
    search_fields = ('title', 'authors__name')
    ordering_fields = ('authors__name', 'title', 'volume', 'pub_date')
    ordering = ('authors__name', 'title', 'volume')
