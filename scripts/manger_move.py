#!/bin/env python3
import requests
import argparse
import re
from pathlib import Path
import shutil
import dotenv
import os
import unicodedata

dotenv.load_dotenv(Path(__file__).parent / '../.env')

def add_book(book_type, authors, title, volume=None):
    directory = Path(book_type) / Path('_'.join(authors)) / Path(title)
    if volume:
        directory /= Path(str(volume))
    directory = str(directory).replace(' ', '_')

    data = {'directory': directory, 'type': book_type, 'authors': [{'name': author} for author in authors], 'title': title}
    if volume:
        data['volume'] = volume
    print(data)

    r = requests.post("http://" + os.environ.get('HOST') + ':' + os.environ.get('PORT') + "/viewer/books/", json=data)
    if r.status_code != requests.codes.created:
        raise Exception(r.text)

def get_info(name):
    m = re.search(r'\[(.+)\]\s*([^\[第v]+)', directory.name)
    if m:
        authors = m.group(1).replace('_', ' ').strip()
        authors = input(f"authors (default:{authors}): ") or authors
        authors = re.split(r'[,×]', authors)
        authors = [unicodedata.normalize('NFKC', x) for x in authors]
        print(f"authors: {authors}")

        title = m.group(2).replace('_', ' ').strip()
        title = input(f"title (default:{title}): ") or title
        title = unicodedata.normalize('NFKC', title)
        print(f"title: {title}")
    else:
        authors = input(f"authors: ")
        if not authors:
            return
        authors = re.split(r'[,×]', authors)
        authors = [unicodedata.normalize('NFKC', x) for x in authors]
        print(f"authors: {authors}")

        title = input(f"title: ")
        if not title:
            return
        title = unicodedata.normalize('NFKC', title)
        print(f"title: {title}")

    m = re.search(r'[第v](\d+)', directory.name)
    if m:
        volume = int(m.group(1).strip())
        volume = input(f"volume (default:{volume}): ") or volume
        print(f"volume: {volume}")
    else:
        try:
            volume = int(input(f"volume: "))
        except ValueError:
            volume = None
        print(f"volume: {volume}")

    authors = [unicodedata.normalize('NFKC', x) for x in authors]
    title = unicodedata.normalize('NFKC', title)

    return authors, title, volume

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--type', dest='type', default='manga')
parser.add_argument('directories', metavar='DIRECTORY', nargs='+')
args = parser.parse_args()

for directory in args.directories:
    directory = Path(directory)
    if not directory.is_dir():
        continue
    print(directory.name)

    try:
        authors, title, volume = get_info(directory.name)
    except TypeError:
        continue

    if authors and title:
        dst_dir = Path(os.environ.get('MEDIA_ROOT')) / Path(args.type) / Path('_'.join(authors).replace(' ', '_')) / Path(title.replace(' ', '_'))
        if volume:
            dst_dir /= Path(str(volume))

        if dst_dir.exists():
            print(f"{dst_dir} already exists.")
        else:
            print(f"{directory} -> {dst_dir}")
            shutil.move(str(directory), str(dst_dir))
            add_book(args.type, authors, title, volume)
