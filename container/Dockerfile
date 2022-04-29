FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED True

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

RUN apt-get update && apt-get install --no-install-recommends -y calibre python3-pip && rm -rf /var/lib/apt/lists/*
    
RUN pip install --no-cache-dir -r requirements.txt

RUN useradd nonpriv
USER nonpriv

CMD exec gunicorn --bind :$PORT --workers 1 --threads 1 --timeout 0 main:app
