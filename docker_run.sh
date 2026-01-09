#!/bin/sh

docker network create back-tier
docker network create front-tier

docker volume create db-data

docker run -d --name db \
    --env POSTGRES_USER="postgres" \
    --env POSTGRES_PASSWORD="postgres" \
    --volume db-data:/var/lib/postgresql/data \
    --volume ./healthchecks:/healthchecks \
    --network back-tier \
    --health-cmd="./healthchecks/postgres.sh" \
    --health-interval=5s \
    postgres:15-alpine

docker run -d --name redis \
    --volume ./healthchecks:/healthchecks \
    --network back-tier \
    --health-cmd="./healthchecks/redis.sh" \
    --health-interval=5s \
    redis:alpine

docker run -d --name worker \
    --network back-tier \
    dockersamples/examplevotingapp_worker

docker run -d -p 8081:80 --name result \
    --network back-tier \
    --network front-tier \
    dockersamples/examplevotingapp_result

docker run -d -p 8080:80 --name vote \
    --network back-tier \
    --network front-tier \
    dockersamples/examplevotingapp_vote

