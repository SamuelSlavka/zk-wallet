FROM python:3.8

ENV PYTHONUNBUFFERED 1

ADD . /src

WORKDIR /src

COPY ./requirements.txt /tmp/requirements.txt

RUN ./prepareZokrates.sh

RUN pip install -r /tmp/requirements.txt

CMD gunicorn wsgi:app -w 1 --reload -b 0.0.0.0:5000
