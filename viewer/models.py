from django.db import models

class Author(models.Model):
    name = models.CharField(max_length=100)

class Title(models.Model):
    name = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author, related_name='titles')

class Volume(models.Model):
    title = models.ForeignKey(Title, related_name='volumes', on_delete=models.CASCADE)
    number = models.IntegerField(default=1)
    pub_date = models.DateField()
