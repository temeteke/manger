from django.db import models
from pathlib import Path
from django.conf import settings

class Author(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Title(models.Model):
    name = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author, related_name='titles')

    def __str__(self):
        return self.name

    @property
    def package(self):
        return self.volumes.order_by('number')[0].pages[0]

class Volume(models.Model):
    title = models.ForeignKey(Title, related_name='volumes', on_delete=models.CASCADE)
    number = models.IntegerField(default=1)
    pub_date = models.DateField()

    def __str__(self):
        return self.title.name + ' ' + str(self.number)

    @property
    def directory(self):
        return Path('_'.join([ author.name for author in self.title.authors.all()])) / Path(self.title.name) / Path(str(self.number))

    @property
    def pages(self):
        directory = Path(settings.MEDIA_ROOT) / self.directory
        return [ str(Path(settings.MEDIA_URL) / p.relative_to(settings.MEDIA_ROOT)) for p in sorted(directory.glob('*'))]
