# Generated by Django 2.1 on 2018-11-24 08:14

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('viewer', '0004_book_bookmark'),
    ]

    operations = [
        migrations.AlterField(
            model_name='book',
            name='bookmark',
            field=models.IntegerField(default=0),
        ),
    ]
