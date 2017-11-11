# pos-docker-compose
   
 A aplicação desenvolvida é um crud javaweb com tomcat e o postgres.   
 Ela é o suficiente para trabalharmos com três conceitos junto ao docker que serão 
 `docker-composer`, `volumes` e `network`.  
 
 
Concebido para resolução de atividade da disciplina de POS   
Curso **Análise e Desenvolvimento de Sistemas**   
IFPB Campus Cajazerias   
Professor da disciplina Ricardo Job   

## Getting Started   

Antes de tudo obtenha o `Docker`    ![alt text](img/Whale.png "Docker")


[Docker Download](https://www.docker.com/community-edition)  
 
## Prerequisitos
* Java instalado
* Maven instalado
* Docker instalado
* IDE de sua preferência  

Mas como estamos usando o Docker para a implantação pode usar
apenas um Editor de texto como o [Sublime](https://www.sublimetext.com/3) ou [Notepad++](https://notepad-plus-plus.org/download/v7.5.1.html ) ...

![alt text](img/java.png "Java") 
![alt text](img/Maven.png "Maven") 
![alt text](img/Elephant.png "Posgtres") 
![alt text](img/sublime.png "Sublime") 
![alt text](img/notepad++.png "Notepad++") 




Se você gosta mais do estilo de deixar a IDE ajudar voce a completar o código pode
usar o [Netbeans](https://netbeans.org/downloads/) ou o [Eclipse](http://www.eclipse.org/downloads/).   
![alt text](img/eclipse.png "Ecplise") 
![alt text](img/netbeans.png "Netbeans") 

 ## O que é o docker-compose?
 O Docker Compose facilita a criação e execução de uma penca(muitos) de 
containers de uma aplicação. Com o Docker-Compose.
Você pode fazer isso através de um arquivo do tipo yaml, nele podemos
 definir como será o nosso ambiente da aplicação.
Sua escrita é bem simples e intuitiva.
Assim usando um único comando criaremor e iniciarermos todos os serviços definidos.

## O que é o volume?  
Um volume é um mecanismo ideal para a persistência de dados gerados e usados pelos container Docker. Os volumes são completamente gerenciados pelo Docker.Uma vez que os volumes são devidamente configurados seus dados serão persistidos mesmo que voce reconstrua a sua aplicação, ou seja todas as modificações relaizadas anteriormente ainda permanecerão como  antes.

## O que é network?
O Docker permite voce trablahar com containers em rede através do uso de drivers de rede. Quando você não cria nenhum ele usa o padrão dele nomeado de `bridge`. As redes são formas naturais de isolar contêineres de outros contêineres ou mesmo de outras redes. Então, à medida que você ler esse documento,vai ganhar mais experiência com o Docker e criar sua própria rede.


## Criando o arquivo `Dockerfile` do banco de dados

Dentro do seu projeto crie uma diretório com o nome `postgres`, e dentro crie um
arquivo nomeado `Dockerfile`, juntamente com mais dois arquivos create.sql e insert.sql,falaremos deles
do seu conteúdo logo mais.   
   
O arquivo Dockerfile teve ter o seguinte conteúdo:     

FROM postgres   
ENV POSTGRES_USER postgres   
ENV POSTGRES_PASSWORD 12345   
ENV POSTGRES_DB pos-cliente   
COPY create.sql /docker-entrypoint-initdb.d/    
COPY insert.sql /docker-entrypoint-initdb.d/   

Como percebemos no arquivo acima, estamos configurando o postgres   
indicando o user ,o passaword e o nome do banco que sera criado para receber os dados   
da aplicação.   
Nas últimas duas linha estamos informando ao docker que ,após ele criar o banco de dados    
ele deve ler o conteúdo dos dois arquivos `create.sql` que vai criar a tabela e `insert.sql`    
que vai inserir no nossso banco pos-cliente.   

Sensacional não?   

## Conteúdo do arquivo create.sql

CREATE TABLE pessoa(    
  id  serial,   
  nome character varying(80) NOT NULL,    
  cpf character varying(14) NOT NULL,    
  PRIMARY KEY (id)    
); 


## Conteúdo do arquivo insert.sql 

INSERT INTO pessoa(nome, cpf) VALUES ('Kiko','123.132.121-31');    
INSERT INTO pessoa(nome, cpf) VALUES ('Chaves','123.132.121-31');    
INSERT INTO pessoa(nome, cpf) VALUES ('Chiquinha', '123.132.121-31');    
INSERT INTO pessoa(nome, cpf) VALUES ('Madruga', '123.132.121-31');    
INSERT INTO pessoa(nome, cpf) VALUES ('Florinda', '123.132.121-31');     


## Criar a imagem do banco

`docker build -t elefante/banco ./postgres`    
*`-t`: qual a tag que vamos atribuir a essa imagem*  
*`./postgres`: caminho  para o arquivo Dockerfile do postgres que esta dentro da pasta postgres*   
*`elefante/banco`*: nome da imagem  que atribuimos   
Depois que você executar o comando acima , caso você não tenha a imagem    
do postgres, o docker vai providenciar  para você automaticamente, claro    
isso acontece porque descrevemos isso no Dockerfile.
        



## Criando o arquivo `Dockerfile` da aplicação web

```
FROM tomcat
COPY target/Aplicacao.war ${CATALINA_HOME}/webapps  
```   
`FROM` :  diz qual a imagem que precisamos   
`COPY` :  diz o caminho de onde copiar os arquivos .war para a implantação   
`${CATALINA_HOME}/webapps` :  lugar  onde vamos armazenar os gloriosos arquivos   

Este arquivo `Dockerfile`, deve obrigatoriamente estar dentro do diretório raiz do seu projeto.


Vale ressaltar que o nome `Aplicacao` foi o finalName que eu demos para a aplicação       
dentro do pom.xml.  
É por esse nome que vamos chamar o sistema no browser.   

```
<build>    
        <finalName>Aplicacao</finalName>    
</build>   
```

E claro dentro da pasta `WEB-INF` temos que ter uma outro diretório chamado `lib`   
que deve conter as bibliotecas `jstl.jar` e `standart.jar`, camos contrario teremos   
problemas ao carreagar o nosso sistema no browser.

## Criar a imagem da aplicação web 

`docker build -t minhaapp .`    
*`-t`: qual a tag que vamos atribuir a essa imagem*  
*`.`: caminho relativo (ou absoluto) para o arquivo Dockerfile*  

Depois que você executar o comando acima , caso você não tenha a imagem    
do tomcat, o docker vai providenciar  para você automaticamente, claro    
isso acontece porque descrevemos isso  no Dockerfile do projeto em questão.
        
   
FROM  **tomcat**   
COPY target/Aplicacao.war ${CATALINA_HOME}/webapps   
    
## Criando o docker-composer.yml 

Crie um arquivo no diretorio de sua aplicação chamado `docker-compose.yml`, dentro dele coloque o conteudo abaixo:   

Você deve respeitar a identação desse arquivo.
```
version: '2'
networks:
  antenas-de-vinil:
    external:
      name: antenas-de-vinil
services:
 postgres:
  build: ./postgres
  image: ricardojob/banco
  container_name: banco
  ports: 
    - "5433:5432"
  volumes:
    - ./postgres/data:/var/lib/postgresql/data
  networks: 
    - antenas-de-vinil
 web:
  build: .
  image: ricardojob/app
  container_name: app
  ports: 
    - "8082:8080" 
  links: 
    - "postgres:host-banco"
  networks:
    - antenas-de-vinil  
```
####  Entendendo o arquivo 

Vamos por parte:   
Primeiro vamos criar a nossa rede:  
*`version: '2'`* :  indica a versão do compose    
*`networks:`* : diz que estamos trabalhando com uma rede.   
  *`antenas-de-vinil:`*   Configuramos a  nossa rede exitente aqui.   
    *`external:`*   
       *`name: antenas-de-vinil `* :  nome da rede


Agora vamos configurar os serviços:   
Serão dois o serviço chamado postgres (para o nosso banco de dados)   
e o serviço chamado web (para o sistema java web)   
*`postgres:`* diz o nome do serviço       
  *`build: ./postgres`*  referesse ao ponto de montagem  
  *`image: ricardojob/banco`* indica a imagem      
  *`container_name: banco`*   nome do container   
  *`ports:`*   diz quais portas serão usadas   
     *`  - "5433:5432"`*  as portas  em si (nossa_maquina:container)   
  *`volumes: `*  diz qual o volume usado  
     *` - ./postgres/data:/var/lib/postgresql/data`*    lugar onde o volume vai estar     
  *`networks:`* indica a rede usada pelo serviço       
      *`- antenas-de-vinil `* nome da rede   

	
Se você observar atentamente o arquivo docker-composer.yml criado acima, você verá que ele esta identado e tambem que a seguinte estrutura se repete:   
```
nome-do-serviço:    
  build: 
  image:
  container_name: 
  ports: 
  links: 
  networks:
  ```
  Pois bem nele esta configurado o que teriamos de digitar todas as vezes que quisessemos executar a nossa aplicação.
  
  Na segunda linha
  
  
  
  
Agora va até o browser a abra o seu projeto: [http://localhost:8082/Aplicacao](http://localhost:8081/Aplicacao.war/ )   

Acima nós configuramos a porta do tomcat para 8082 lembra?   
     
No meu caso como ainda estou usando o Docker Toolbox no windows abro a aplicação em [http://192.168.99.100:8082/Aplicacao.war/](http://192.168.99.100:8082/Aplicacao.war/ )

  
## Implantação usando  arquivo .sh

Para agilizar o processo de desenvolvimento vamos criar dois arquivos .sh: 
 
**run.sh**   

O arquivo **run.sh** deve conter o seguinte conteúdo:

-------------------------------------------------------------    
#docker network create antenas-de-vinil   
#docker build -t ricardojob/banco ./postgres    
#docker run -p 5433:5432 -d --name banco -v $(pwd)/data:/var/lib/postgresql/data ricardojob/banco
#mvn clean package
#docker build -t ricardojob/app .
#docker run -p 8082:8080 -d --name app --link banco:host-banco ricardojob/app

 docker network create antenas-de-vinil
 mvn clean package
 docker-compose up -d

-------------------------------------------------------------    
**nonrun.sh**  

O arquivo **nonrun.sh** deve conter o seguinte conteúdo:    
-------------------------------------------------------------    
#docker stop app
#docker kill app
#docker rm app
#docker rmi -f ricardojob/app

#docker stop banco
#docker kill banco
#docker rm banco
#docker rmi -f ricardojob/banco
#docker network rm antenas-de-vinil

docker-compose down
docker network rm antenas-de-vinil
mvn clean 
-------------------------------------------------------------   


Assim uma vez que você já tenha as imagens e os containers criados você   
não precsia digitar todas as vezes os comandos de criar a imagem do banco de dados,      
criar o conteiner desse banco, e depois criar a imagem da aplicação web criar o   
o container apos cada atualização de seu projeto.   
Simplesmente abra digite no docker: 
  
### Para iniciar:  

**sh run.sh**     

 Vai fazer tudo de uma só vez :    
* O docker vai criar a imagem do banco   
* O dockar vai criar o container desse banco e iniciar o mesmo    
* O maven vai criar o arquivo .war do projeto   
* Vai criar a imagem da aplicação   
* Por ultimo criar e iniciar o container da aplicação  

### Para encerrar digite:  

**sh nonrun.sh**   

  Vai fazer tudo de uma só vez :  
* O docker vai parar o container da Aplicacao    
* O docker vai matar o container    
* Remover o container da aplicação
* Vai remover a imagem da aplicação do Docker  

* O docker vai parar o container do banco elefante    
* O docker vai matar o container   
* Remover o container do banco
* Remover a imagem do banco
 
* O maven vai limpar o projeto   


![alt text](img/sue.png "Java") 

## Listar os containers

`docker container ls`


## Listar os containers de ativos e inativos

`docker ps -a`


## Parar o container

`docker stop <container_id | container_name>`


## Documentação Docker
[Docker referências](https://docs.docker.com/reference/ )

## Construido com 

* [Java](http://www.dropwizard.io/1.0.2/docs/) - Lingugem de programação
* [Postgres](https://www.postgresql.org) - Banco de dados 
* [Maven](https://maven.apache.org/) - Gerenciador de dependencias
* [Tomcat](https://tomcat.apache.org/) - Servidor Web usado para a implantação do projeto
* [Docker](https://www.docker.com) - Gerenciador de containers onde podemos usar o container do Tomcat... 
* [NetBeans](https://netbeans.org/downloads/) - Usado para escrever o codigo fonte do projeto

## Controle de versão

Nós usamos o [Git](https://git-scm.com/) . 

## Autor

* Wellington Lins


## Agradecimentos

* Ao pai eterno

## Here I can listen you call my name: 

wellingtonlins2013@gmail.com

#### Tell me your problems and doubts...