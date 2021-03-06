from rest_framework import serializers
from .models import Author, Book

class AuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Author
        fields = ('id', 'name')

class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = ('id', 'type', 'title', 'authors', 'volume', 'volume_title', 'isbn', 'publisher', 'pub_date', 'description', 'directory', 'pages', 'bookmark')

    authors = AuthorSerializer(many=True)
    pages = serializers.ListField(read_only=True)

    def create(self, validated_data):
        authors_data = validated_data.pop('authors')

        book, created = Book.objects.get_or_create(**validated_data)

        for author_data in authors_data:
            author, created = Author.objects.get_or_create(**author_data)
            book.authors.add(author)

        return book
