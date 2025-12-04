ARG ALPTAG=3.22
FROM alpine:${ALPTAG}
RUN apk add --no-cache tor lyrebird
COPY torrc /etc/tor/torrc
USER tor
EXPOSE 9050/tcp
CMD ["tor", "-f", "/etc/tor/torrc"]
