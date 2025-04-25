FROM alpine:latest

RUN apk add --no-cache openssl

COPY generate-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-ssl.sh

CMD ["/usr/local/bin/generate-ssl.sh"] 