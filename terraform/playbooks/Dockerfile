# Version: 0.0.1
FROM debian:8.5
LABEL maintainer_name "not@now.net"
RUN apt-get update
RUN apt-get install -y nginx
RUN echo 'Hello world from container. ' \
>/usr/share/nginx/html/index.html
EXPOSE 8080