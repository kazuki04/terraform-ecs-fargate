FROM nginx:latest

RUN rm -f /etc/nginx/conf.d/*
RUN apt-get update && apt-get install -y curl 

COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
