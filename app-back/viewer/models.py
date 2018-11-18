from django.db import models
from pathlib import Path
from django.conf import settings
import re

class Author(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Book(models.Model):
    title = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author, related_name='books')
    volume = models.IntegerField(blank=True, null=True)
    pub_date = models.DateField()

    def __str__(self):
        name = self.title
        if self.volume:
           name += ' ' + str(self.volume)
        return name

    @property
    def directory(self):
        directory = Path('_'.join([ author.name for author in self.authors.all()])) / Path(self.title)
        if self.volume:
            directory /= Path(str(self.volume))
        directory = Path(str(directory).replace(' ', '_'))
        return directory

    @property
    def pages(self):
        numbers = re.compile(r'(\d+)')
        def numerical_sort(path):
            parts = numbers.split(str(path))
            parts[1::2] = map(int, parts[1::2])
            return parts

        directory = Path(settings.MEDIA_ROOT) / self.directory
        return [ str(Path(settings.MEDIA_URL) / p.relative_to(settings.MEDIA_ROOT)) for p in sorted(directory.glob('*'), key=numerical_sort)]
