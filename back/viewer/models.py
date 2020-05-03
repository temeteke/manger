from django.db import models
from pathlib import Path
from django.conf import settings
import urllib
import re
import requests
import datetime

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

    def update(self):
        if self.isbn:
            info = requests.get('https://www.googleapis.com/books/v1/volumes', params={'q': 'isbn:' + self.isbn}).json()
            try:
                info = requests.get(info['items'][0]['selfLink']).json()
            except KeyError:
                return self
        else:
            queries = []
            for author in self.authors.all():
                queries.append(author.name)
            queries.append(self.title)
            if self.volume:
                queries.append(self.volume)

            info = requests.get('https://www.googleapis.com/books/v1/volumes', params={'q': ' '.join(queries)}).json()

            for x in info['items']:
                if self.title in x['volumeInfo']['title']:
                    if self.volume:
                        if self.volume not in x['volumeInfo']['title']:
                            continue
                    info = requests.get(x['selfLink']).json()
                    break
            else:
                return self

        try:
            self.title = info['volumeInfo']['title']
        except KeyError:
            pass
        for x in info['volumeInfo']['authors']:
            author, created = Author.objects.get_or_create(name=x)
            self.authors.add(author)
        try:
            self.isbn = info['volumeInfo']['industryIdentifiers'][-1]['identifier']
        except KeyError:
            pass
        try:
            self.publisher = info['volumeInfo']['publisher']
        except KeyError:
            pass
        try:
            try:
                self.pub_date = datetime.date.fromisoformat(info['volumeInfo']['publishedDate']).date()
            except ValueError:
                self.pub_date = datetime.datetime.strptime(info['volumeInfo']['publishedDate'], '%Y-%m').date()
        except KeyError:
            pass
        try:
            self.description = info['volumeInfo']['description']
        except KeyError:
            pass

        self.save()

        return self
