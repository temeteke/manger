#!/bin/env python3
import requests
import json
import glob
import os
import dotenv
import re
from pathlib import Path

TYPES = ['manga', 'novel']

dotenv.load_dotenv(Path(__file__).parent / '../.env')

def add_book(book_type, authors, title, volume=None, volume_title=''):
    directory = Path(book_type) / Path('_'.join(authors)) / Path(title)
    if volume:
        volume_str = str(volume)
        if volume_title:
            volume_str += '_' + volume_title
        directory /= Path(volume_str)
    directory = str(directory).replace(' ', '_')

    data = {'directory': directory, 'type': book_type, 'authors': [{'name': author} for author in authors], 'title': title}
    if volume:
        data['volume'] = volume
    if volume_title:
        data['volume_title'] = volume_title
    print(data)

    r = requests.post("http://" + os.environ.get('HOST') + ':' + os.environ.get('PORT') + "/viewer/books/", json=data)
    if r.status_code != requests.codes.created:
        print(r.text)

for book_type in TYPES:
    directory = Path(os.environ.get('MEDIA_ROOT')) / Path(book_type)
    for author_path in directory.glob('*'):
        for title_path in author_path.glob('*'):
            volume_paths = [volume_path for volume_path in title_path.glob('*') if volume_path.is_dir()]
            if volume_paths:
                for volume_path in volume_paths:
                    if volume_path.name.isdecimal():
                        add_book(book_type, author_path.name.split('_'), title_path.name.replace('_', ' '), volume_path.name)
                    else:
                        try:
                            x = re.findall(r'^(\d+)_(.+)$', volume_path.name)[0]
                            add_book(book_type, author_path.name.split('_'), title_path.name.replace('_', ' '), x[0], x[1].replace('_', ' '))
                        except IndexError:
                            pass
            else:
                add_book(book_type, author_path.name.split('_'), title_path.name.replace('_', ' '))
