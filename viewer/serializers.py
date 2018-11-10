from rest_framework import serializers
from .models import Author, Book

class AuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Author
        fields = ('name', )

class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = ('id', 'title', 'authors', 'volume', 'pub_date', 'directory', 'pages')

    authors = serializers.StringRelatedField(many=True)
    directory = serializers.CharField()
    pages = serializers.ListField()
