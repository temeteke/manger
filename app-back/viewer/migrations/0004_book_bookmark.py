# Generated by Django 2.1 on 2018-11-24 08:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('viewer', '0003_auto_20181124_1148'),
    ]

    operations = [
        migrations.AddField(
            model_name='book',
            name='bookmark',
            field=models.IntegerField(blank=True, null=True),
        ),
    ]
