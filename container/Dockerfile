FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED True

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

RUN apt-get update && apt-get install -y calibre python3-pip
    
RUN pip install --no-cache-dir -r requirements.txt

CMD exec gunicorn --bind :$PORT --workers 1 --threads 1 --timeout 0 main:app
