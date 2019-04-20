from random import shuffle

from django.shortcuts import render
from rest_framework import viewsets, filters
from rest_framework.pagination import PageNumberPagination
from rest_framework.settings import api_settings
from django_filters.rest_framework import DjangoFilterBackend

from .models import Author, Book
from .serializers import AuthorSerializer, BookSerializer

class MyOrderingFilter(filters.OrderingFilter):
    def filter_queryset(self, request, queryset, view):
        params = request.query_params.get(self.ordering_param)
        if params and not request.query_params.get(api_settings.SEARCH_PARAM): #searchが指定されているとき、order_by('?')がおかしくなるので、除外する
            fields = [param.strip() for param in params.split(',')]
            if 'random' in fields:
                return queryset.order_by('?')
        return super().filter_queryset(request, queryset, view)

class MyPagination(PageNumberPagination):
    page_size = 24
    page_size_query_param = 'page_size'
    max_page_size = 96

    def paginate_queryset(self, queryset, request, view=None):
        queryset = super().paginate_queryset(queryset, request, view)
        if request.query_params.get(api_settings.SEARCH_PARAM): #searchが指定されているとき、order_by('?')していないので、ページ内でシャッフルする
            shuffle(queryset)
        return queryset

class AuthorViewSet(viewsets.ModelViewSet):
    queryset = Author.objects.all()
    serializer_class = AuthorSerializer
    pagination_class = MyPagination
    filter_backends = (DjangoFilterBackend, filters.SearchFilter, MyOrderingFilter)
    filter_fields = ('name',)
    search_fields = ('name',)

class BookViewSet(viewsets.ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    pagination_class = MyPagination
    filter_backends = (DjangoFilterBackend, filters.SearchFilter, MyOrderingFilter)
    filter_fields = ('authors__name', 'title')
    search_fields = ('title', 'authors__name')
    ordering_fields = ('authors__name', 'title', 'volume', 'pub_date')
    ordering = ('authors__name', 'title', 'volume')
