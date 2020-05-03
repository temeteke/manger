from django.shortcuts import render
from rest_framework.viewsets import ModelViewSet
from rest_framework.pagination import PageNumberPagination
from rest_framework.settings import api_settings
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend

from .models import Author, Book
from .serializers import AuthorSerializer, BookSerializer


class RandomOrderingFilter(OrderingFilter):
    def filter_queryset(self, request, queryset, view):
        ordering_params = request.query_params.get(self.ordering_param)
        if ordering_params and 'random' in [param.strip() for param in ordering_params.split(',')]:
            return super().filter_queryset(request, queryset, view).order_by('?').distinct()
        else:
            return super().filter_queryset(request, queryset, view)


class MyPagination(PageNumberPagination):
    page_size = 24
    page_size_query_param = 'page_size'
    max_page_size = 96


class AuthorViewSet(ModelViewSet):
    queryset = Author.objects.all()
    serializer_class = AuthorSerializer
    pagination_class = MyPagination
    filter_backends = (DjangoFilterBackend, SearchFilter, RandomOrderingFilter)
    filter_fields = ('name',)
    search_fields = ('name',)


class BookViewSet(ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    pagination_class = MyPagination
    filter_backends = (DjangoFilterBackend, SearchFilter, RandomOrderingFilter)
    filter_fields = ('type', 'authors__name', 'title')
    search_fields = ('title', 'authors__name')
    ordering_fields = ('id', 'type', 'authors__name', 'title', 'volume', 'pub_date')
    ordering = ('type', 'authors__name', 'title', 'volume')


@api_view()
def update_book(request, book_id):
    book = Book.objects.get(id=book_id)
    book.update()
    return Response(BookSerializer(book, context={'request': request}).data)
