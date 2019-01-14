#!/bin/env python3
import requests
import argparse
import re
from pathlib import Path
import shutil
import dotenv
import os

dotenv.load_dotenv(Path(__file__).parent / '../.env')

def add_book(authors, title, volume=None):
    data = {'authors': [{'name': author} for author in authors], 'title': title}
    if volume:
        data['volume'] = volume
    print(data)

    r = requests.post("http://" + os.environ.get('HOST') + "/viewer/books/", json=data)
    if r.status_code != requests.codes.created:
        raise Exception(r.text)

def get_info(name):
    m = re.match(r'.*\[(.+)\]\s*(.+)\s*.*(?:(?:第)(\d+))?.*', directory.name)
    if m:
        authors = m.group(1).strip()
        authors = input(f"authors (default:{authors}): ") or authors
        authors = authors.split(',')
        print(f"authors: {authors}")

        title = m.group(2).strip()
        title = input(f"title (default:{title}): ") or title
        print(f"title: {title}")

        if m.group(3):
            volume = int(m.group(3).strip())
            volume = input(f"volume (default:{volume}): ") or volume
            print(f"volume: {volume}")
        else:
            volume = None

    else:
        authors = input(f"authors: ")
        if not authors:
            return
        authors = authors.split(',')
        print(f"authors: {authors}")

        title = input(f"title: ")
        if not title:
            return
        print(f"title: {title}")

        volume = int(input(f"volume: "))
        print(f"volume: {volume}")

    return authors, title, volume

def move(src_dir, authors, title, volume=None):
    dst_dir = Path(os.environ.get('MEDIA_ROOT')) / Path('_'.join(authors)) / Path(title)
    if volume:
        dst_dir /= Path(str(volume))
    print(f"{src_dir} -> {dst_dir}")
    shutil.move(src_dir, dst_dir)

parser = argparse.ArgumentParser()
parser.add_argument("directories", metavar="DIRECTORY", nargs="+")
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
        move(directory, authors, title, volume)
        add_book(authors, title, volume)
