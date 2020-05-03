from django.urls import path
from rest_framework import routers
from .views import AuthorViewSet, BookViewSet, update_book

router = routers.DefaultRouter()
router.register(r'authors', AuthorViewSet)
router.register(r'books', BookViewSet)

urlpatterns = [
    path('update-book/<int:book_id>', update_book),
]

urlpatterns += router.urls
