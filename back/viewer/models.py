from django.db import models
from pathlib import Path
from django.conf import settings
import urllib
import re

class Author(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Book(models.Model):
    type = models.CharField(max_length=20)
    title = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author, related_name='books')
    volume = models.IntegerField(blank=True, null=True)
    isbn = models.CharField('ISBN', max_length=13, blank=True)
    publisher = models.CharField(max_length=20, blank=True)
    pub_date = models.DateField(blank=True, null=True)
    description = models.TextField(blank=True)
    bookmark = models.IntegerField(default=0)

    def __str__(self):
        name = self.title
        if self.volume:
           name += ' ' + str(self.volume)
        return name

    @property
    def directory(self):
        directory = Path(self.type) / Path('_'.join([author.name for author in self.authors.all()])) / Path(self.title)
        if self.volume:
            directory /= Path(str(self.volume))
        directory = Path(str(directory).replace(' ', '_'))
        return directory

    @property
    def pages(self):
        numbers = re.compile(r'(\d+)')
        def numerical_sort(path):
            parts = numbers.split(path.name)
            parts[1::2] = [ part.zfill(8) for part in parts[1::2] ]
            return ''.join(parts)

        directory = Path(settings.MEDIA_ROOT) / self.directory
        if not directory.is_dir():
            return

        paths = sorted([ path for path in directory.iterdir() if path.is_file() ], key=numerical_sort)
        return [ urllib.parse.quote(str(Path(settings.MEDIA_URL) / p.relative_to(settings.MEDIA_ROOT))) for p in paths]
