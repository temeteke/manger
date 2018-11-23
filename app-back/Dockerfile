FROM python:3
ENV PYTHONUNBUFFERED 1
RUN mkdir /work
WORKDIR /work
ADD requirements.txt /work/
RUN pip install -r requirements.txt
ADD . /work/

RUN pip install uwsgi

CMD python manage.py collectstatic --noinput; uwsgi --socket :8000 --wsgi-file app/wsgi.py
EXPOSE 8000
