FROM ubuntu:latest
RUN apt update && apt install python3 -y
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
EXPOSE 8000
CMD python3 -m http.server 8000