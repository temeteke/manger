from rest_framework import serializers
from .models import Author, Title, Volume

class AuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Author
        fields = ('name', )

class TitleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Title
        fields = ('id', 'name', 'authors', 'package', 'volumes')

    authors = serializers.StringRelatedField(many=True)

class VolumeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Volume
        fields = ('title', 'number', 'pub_date', 'directory', 'pages')

    directory = serializers.CharField()
    pages = serializers.ListField()
