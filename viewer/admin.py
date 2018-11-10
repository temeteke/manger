from django.contrib import admin

from .models import Author, Title, Volume

admin.site.register(Author)
admin.site.register(Title)
admin.site.register(Volume)
