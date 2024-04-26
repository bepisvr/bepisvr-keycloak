# modified from https://community.render.com/t/how-to-setup-keycloak-with-render-db/21175/3, was given permission to share as MIT-License

FROM quay.io/phasetwo/keycloak-crdb:latest as builder

# necessary to let us use cockroach
ENV OPERATOR_KEYCLOAK_IMAGE=quay.io/phasetwo/keycloak-crdb:latest

# set these env variables
ARG ADMIN
ARG ADMIN_PASSWORD

# something like mykeycloaksite.onrender.com
ARG DOMAIN_NAME

# set these env variables, from db website
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_URL
ARG DB_DATABASE
ARG DB_PORT
ARG DB_SCHEMA
ARG CERT_PATH

# set port 8443 to PORT environment variable in render
ENV KC_HTTP_RELATIVE_PATH=/auth
ENV PROXY_ADDRESS_FORWARDING=true
ENV KC_DB_USERNAME=$DB_USERNAME
ENV KC_DB_PASSWORD=$DB_PASSWORD
ENV KC_DB_URL_PROPERTIES='?'
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME=$DOMAIN_NAME
ENV KC_HOSTNAME_ADMIN=$DOMAIN_NAME
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8443
ENV KC_HTTPS_PORT=8444
ENV KC_LOG_LEVEL=INFO
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=passthrough
ENV KC_PROXY_HEADERS=xforwarded
ENV KEYCLOAK_ADMIN=$ADMIN
ENV KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV KB_DB=cockroach
ENV KC_TRANSACTION_XA_ENABLED=false
ENV KC_TRANSACTION_JTA_ENABLED=false
ENV KC_DB_URL=jdbc:postgresql://${DB_URL}:${DB_PORT}/${DB_DATABASE}

# db may seem redundant but it is not
RUN /opt/keycloak/bin/kc.sh build --db=cockroach
FROM quay.io/phasetwo/keycloak-crdb:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# necessary to let us use cockroach db
ENV OPERATOR_KEYCLOAK_IMAGE=quay.io/phasetwo/keycloak-crdb:latest

# set these env variables
ARG ADMIN
ARG ADMIN_PASSWORD

# set these env variables, from db website
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_URL
ARG DB_DATABASE
ARG DB_PORT
ARG DB_SCHEMA
ARG CERT_PATH

# set port 8443 to PORT environment variable in render
ENV KC_HTTP_RELATIVE_PATH=/auth
ENV PROXY_ADDRESS_FORWARDING=true
ENV KC_DB_USERNAME=$DB_USERNAME
ENV KC_DB_PASSWORD=$DB_PASSWORD
ENV KC_DB_URL_PROPERTIES='?'
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME=$DOMAIN_NAME
ENV KC_HOSTNAME_ADMIN=$DOMAIN_NAME
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8443
ENV KC_HTTPS_PORT=8444
ENV KC_LOG_LEVEL=INFO
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=passthrough
ENV KC_PROXY_HEADERS=xforwarded
ENV KEYCLOAK_ADMIN=$ADMIN
ENV KEYCLOAK_ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV KB_DB=cockroach
ENV KC_TRANSACTION_XA_ENABLED=false
ENV KC_TRANSACTION_JTA_ENABLED=false
ENV KC_DB_URL=jdbc:postgresql://${DB_URL}:${DB_PORT}/${DB_DATABASE}

RUN mkdir -p $HOME/.postgresql
ADD ${CERT_PATH} $HOME/.postgresql/root.crt

EXPOSE 8443
EXPOSE 8444

# does not match own cookie warnigns are normal idk how to fix them but they don't seem to matter

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
# even though we build, using --optimized disallows postgresql databases so we need this workaround https://github.com/keycloak/keycloak/issues/15898
# in other words don't add optimzied here
CMD ["start", "--db=cockroach"]
