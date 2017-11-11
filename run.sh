# docker network create antenas-de-vinil
# docker build -t ricardojob/banco ./postgres
# docker run -p 5433:5432 -d --name banco -v $(pwd)/data:/var/lib/postgresql/data ricardojob/banco
# mvn clean package
# docker build -t ricardojob/app .
# docker run -p 8082:8080 -d --name app --link banco:host-banco ricardojob/app
# x-www-browser localhost:8082/app

 docker network create antenas-de-vinil
 mvn clean package
 docker-compose up -d