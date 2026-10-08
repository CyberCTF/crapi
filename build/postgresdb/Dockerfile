# The postgresdb service of upstream's deploy/docker/docker-compose.yml: postgres:14 with its
# environment and command baked in.
FROM postgres:14
ENV POSTGRES_USER=admin \
    POSTGRES_PASSWORD=crapisecretpassword \
    POSTGRES_DB=crapi
CMD ["postgres", "-c", "max_connections=500"]
