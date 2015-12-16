# Docker Logstash Forwarder

A Docker image with logstash forwarder and default configurations:

| Config | Default value |
|--------|---------------|
| Logstash host:port | elk:5000  |
| SSL domain         | elk       |


## SSL

Logstash use SSL certificates to secure data transfer. Default certificates are included in the built image.
The default certificate is available in the `ssl` directory.

The embedded certificate `./ssl/logstash-forwarder.crt` works with `elk` as domain name.

If it does not fit to your needs, feel free to create a new one
and add a volume pointing to `/etc/ssl/logstash-forwarder.crt`

```shell
sudo openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout logstash-forwarder.key -out logstash-forwarder.crt
```

Be careful, the certificate must match the certificate used by your logstash server/container.

## Link with ELK

By default the ELK service can be reached with the `elk` domain on port **5000**:

```yaml
{
    "network": {
        "servers": [ "elk:5000" ],
        "ssl ca": "/etc/ssl/logstash-forwarder.crt"
    },
    ...
}
```

Add a link option when starting your logstash forwarder container:

* Docker

```shell
docker run --link dockerelk_elk_1:elk ypereirareis/logstash-forwarder
```

* Docker Compose

```yaml
forwarder:
  ...
  external_links:
    - dockerelk_elk_1:elk
```

## Log files forwarding

* Docker

```shell
docker run \
    -v PATH_TO_HOST_ERROR_ACCESS_APACHE_DIR/:/var/log/forwarder/apache \
    -v PATH_TO_HOST_ERROR_ACCESS_NGINX_DIR:/var/log/forwarder/nginx \
    -v PATH_TO_HOST_SYMFONY_DEV_PROD_DIR/:/var/log/forwarder/symfony \
    --link dockerelk_elk_1:elk \
    ypereirareis/logstash-forwarder
```

* Docker Compose

```yaml
forwarder:
  build: .
  volumes:
    - PATH_TO_HOST_ERROR_ACCESS_APACHE_DIR/:/var/log/forwarder/apache
    - PATH_TO_HOST_SYMFONY_DEV_PROD_DIR/:/var/log/forwarder/nginx
    - PATH_TO_HOST_ERROR_ACCESS_NGINX_DIR/:/var/log/forwarder/symfony
  external_links:
    - dockerelk_elk_1:elk
```

## Log files configurations

A [default config file](./conf/config.json) is embedded in the docker image:

```yaml
{
    "network": {
        "servers": [ "elk:5000" ],
        "ssl ca": "/etc/ssl/logstash-forwarder.crt"
    },
    "files": [
        {
            "paths":  [ "/var/log/forwarder/nginx/access.log" ],
            "fields": { "type": "nginx-access" }
        },
        {
            "paths":  [ "/var/log/forwarder/nginx/error.log" ],
            "fields": { "type": "nginx-error" }
        },
        {
            "paths":  [ "/var/log/forwarder/apache/access.log" ],
            "fields": { "type": "apache-access" }
        },
        {
            "paths":  [ "/var/log/forwarder/apache/error.log" ],
            "fields": { "type": "apache-error" }
        },
        {
            "paths":  [ "/var/log/forwarder/symfony/logs/dev.log" ],
            "fields": { "type": "symfony_dev" }
        },
        {
            "paths":  [ "/var/log/forwarder/symfony/logs/prod.log" ],
            "fields": { "type": "symfony_prod" }
        }
    ]
}
```

If it does not fit to your needs, feel free to create a new one
and add a volume pointing to `/etc/logstash-forwarder/config.json`
