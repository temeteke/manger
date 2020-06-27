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
        raise Exception(r.text)

parser = argparse.ArgumentParser()
parser.add_argument('--type', dest='type', default='manga')
parser.add_argument('--authors', dest='authors')
parser.add_argument('--title', dest='title')
parser.add_argument('-a', '--auto', dest='auto', action='store_true')
parser.add_argument('directories', metavar='DIRECTORY', nargs='+')
args = parser.parse_args()

print(f"type: {args.type}")

for directory in args.directories:
    directory = Path(directory)
    print(f"directory: {directory.name}")
    if not directory.is_dir():
        print("Not found")
        continue

    authors = ''
    title = ''
    volume = ''
    volume_title = ''

    if args.authors:
        authors = args.authors
    if args.title:
        title = args.title

    m = re.search(r'\[(.+)\]\s*([^\[第v]+)', directory.name)
    if m:
        if not authors:
            authors = m.group(1).replace('_', ' ').strip()

        if not title:
            title = m.group(2).replace('_', ' ').strip()

    if not args.auto:
        authors = input(f"authors(default:{authors}): ") or authors
    authors = re.split(r'[,×]', authors)
    authors = [x.strip() for x in authors]
    authors = [unicodedata.normalize('NFKC', x) for x in authors if x]
    if not authors:
        continue
    print(f"authors: {authors}")

    if not args.auto:
        title = input(f"title(default:{title}): ") or title
    title = title.strip()
    title = unicodedata.normalize('NFKC', title)
    if not title:
        continue
    print(f"title: {title}")

    m = re.search(r'[第v](\d+)', directory.name)
    if m:
        volume = m.group(1).strip()
    if not args.auto:
        volume = input(f"volume(default:{volume}): ") or volume
    if volume:
        try:
            volume = int(volume)
        except ValueError:
            print("Not Integer")
            continue
    print(f"volume: {volume}")

    if volume and not args.auto:
        volume_title = input(f"volume_title: ")
        volume_title = unicodedata.normalize('NFKC', volume_title)
        print(f"volume_title: {volume_title}")

    dst_dir = Path(os.environ.get('MEDIA_ROOT')) / Path(args.type) / Path('_'.join(authors).replace(' ', '_')) / Path(title.replace(' ', '_'))
    if volume:
        volume_str = str(volume)
        if volume_title:
            volume_str += '_' + volume_title
        dst_dir /= Path(volume_str)

    if dst_dir.exists():
        print(f"{dst_dir} already exists.")
    else:
        print(f"Moving directory: {directory} -> {dst_dir}")
        shutil.move(str(directory), str(dst_dir))
        add_book(args.type, authors, title, volume, volume_title)
