FROM gliderlabs/alpine:3.1

RUN apk add --update python \
  && rm -rf /var/cache/apk/*

COPY ./requirements.txt /tmp/requirements.txt

RUN apk --update add --virtual build-dependencies \
    python-dev \
    py-pip \
    build-base \
    openssl \
    ca-certificates \
  && pip install virtualenv \
  && virtualenv /env \
  && /env/bin/pip install -r /tmp/requirements.txt \
  && wget -O /tmp/sdk.tar.gz 'https://owncloud.mobile-cloud-networking.eu/owncloud/public.php?service=files&t=01ad0519e7e4ad9bc8fdbf5f959f183e&download' \
  && /env/bin/pip install /tmp/sdk.tar.gz \
  && wget -O /tmp/sm.tar.gz 'https://owncloud.mobile-cloud-networking.eu/owncloud/public.php?service=files&t=3ec7178ae3587866a0d94e27af95024b&download' \
  && /env/bin/pip install /tmp/sm.tar.gz \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* /root/.cache/* /tmp/*

WORKDIR /app

ONBUILD COPY . /app
ONBUILD RUN apk --update add --virtual build-dependencies \ 
    python-dev \
    py-pip \
    build-base \
    openssl \
    ca-certificates \
  && virtualenv /env \
  && /env/bin/pip install -r /app/requirements.txt \
  && /env/bin/python setup.py install \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* /root/.cache/*

EXPOSE 8080
CMD ["/env/bin/python", "app.py"]
