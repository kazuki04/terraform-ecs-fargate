FROM amazon/aws-for-fluent-bit:2.28.3

COPY ./myparsers.conf /fluent-bit/etc/myparsers.conf

COPY ./backend/ /fluent-bit/etc/backend/
COPY ./frontend/ /fluent-bit/etc/frontend/
