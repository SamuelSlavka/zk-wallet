FROM python:3.8

ENV PYTHONUNBUFFERED 1

ADD . /src

WORKDIR /src

COPY ./requirements.txt /tmp/requirements.txt

# zokrates setup
RUN ./prepareZokrates.sh
ENV PATH="$PATH:/root/.zokrates/bin"
ENV ZOKRATES_HOME="/root/.zokrates/stdlib"

# python setup
RUN pip install -r /tmp/requirements.txt

CMD gunicorn wsgi:app -w 1 --reload -b 0.0.0.0:5000
