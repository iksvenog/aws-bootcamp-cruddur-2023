# Week 1 — App Containerization

# Homework

## Docker and Docker Compose Setup

### Created Frontend and Backend Dockerfiles

Following along with the Week 1 Live Video, I created the frontend and backend dockerfiles in the frontend-react-js and backend-flask folders of the project:


```Frontend Dockerfile
FROM node:16.18
ENV PORT=3000
COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```

```Backend Dockerfile
FROM python:3.10-slim-buster
WORKDIR /backend-flask
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
ENV FLASK_ENV=development
EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

### Building Frontend and Backend Images

Then, continuing to follow along with the livestream, I built the images from the two Dockerfiles:

```sh Frontend
docker build -t frontend-react-js ./frontend-react-js
```

```sh Backend
docker build -t  backend-flask ./backend-flask
```

### Running Frontend and Backend Containers

Then, as part of following along further from the content of the livstream, I ran the two containers:

*Note: Before running the frotnend, I ran `npm install` to set up the package dependencies json files.
```sh Frontend
docker run -p 3000:3000 -d frontend-react-js
```

*Note: In the command below, the `-e` refers to environment variables added when running the Docker container.
```sh Backend
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
```

### Creating Docker Compose File

Culminating the work from the livestream, I created the docker compose file for running both containers at once:

```yaml
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```

### Adding DynamoDB Local and Postgres to Docker Compose

The next part, which was an addendum to the livestream, involved learning how to implement DynamoDB local and Postreges into the Docker Compose file:

``` Adding DynamoDB Local
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
```

```Adding Postgres
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
volumes:
  db:
    driver: local
```

I also learned how to add the option to install Postgres into the task definition of the Gitpod Yaml file for simpler configuration of the code environment:

```sh
  - name: postgres
    init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev
```

# Homework Challenges

## Run the dockerfile CMD as an external script

From the Docker documentation [Docker Run Command Documentation](https://docs.docker.com/engine/reference/commandline/run/) I found that, apart from specifying the CMD within the Dockerfile, it can be overwritten by adding the CMD command to the `docker run` command itself. To meet the requirement of running this command as an external script, I ran it as part of bash scripts from the terminal to test running for each docker container in this alternate method:

``` Frontend Script
#!/bin/bash
# runs the starting frontend task
# Enter the appropriate tag name for running this script
docker run -p 3000:3000 -d frontend-react-js:latest npm start
```

```Backend Script
#!/bin/bash
# runs the starting backend task
# Enter the appropriate tag name for running this script
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask:latest python3 -m flask run --host=0.0.0.0 --port=4567
```

## Push and tag a image to DockerHub

From the Docker documentation, [Docker Push and Tag Documentation](https://docs.docker.com/docker-hub/repos/), I learned tag and push commands for storing Docker images to Dockerhub. To get started, I created a Dockerhub and used a tutorial image to test out this process. After creating a Dockerhub account, it provided the option to download the Docker Desktop application, from which, there was an option for getting started with the docker/getting-started base image.
 
I pulled the tutorial image `docker run -d -p 80:80 docker/getting-started` from Dockerhub, and then tagged the image `docker tag docker/getting-started acgecloud/docker-tutorial-acge:getting-started-v1` and pushed it `docker tag docker/getting-started acgecloud/docker-tutorial-acge:getting-started-v1` to the repository in my Dockerhub account, as follows:

![Tagged and Pushed Docker Image to DockerHub](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week1/Homework-Challenge-Tag-and-Push.PNG)

## Use multi-stage building for a Dockerfile build

From the Docker Documentation [Multi-Stage Building Docs](https://docs.docker.com/build/building/multi-stage/), I learned about how to reduce image size and improve portability of Docker by creaging multi-stage builds for both the frontend and backend containers. The Dockerfiles for both frontend and backend were updated with the multi-stage build feature, which is also recognized as best practice when building images. For building each image, the alpine versions for Python and Node JS were used for portability as their base images that were smaller in size for meeting this criteria.

### Implementing Multi-Stage Frontend
Similarly, in following with the Docker Multi-Stage build implementation, I copied over the node package dependencies to a lighterweight docker build.

```Multi-Stage Frontend
FROM node:16.18 AS builder
COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
FROM node:19-alpine AS final
COPY --from=builder /frontend-react-js /frontend-react-js
WORKDIR /frontend-react-js
ENV PORT=3000
EXPOSE ${PORT}
CMD ["npm", "start"]
```

### Implementing Multi-Stage Backend
For preparing all dependences before moving them to the final build image in the multi-stage implementation this documentation [Python Multi-Stage Building Docker](https://docs.docker.com/build/building/multi-stage/) was useful for understanding how to keep all Python dependencies in one place before porting over to the final build image. The creation of a virtual environment allows for keeping all dependnecies in one place before copying over. 

```Multi-Stage Backend
FROM python:3.10-slim-buster AS builder

WORKDIR /backend-flask
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt requirements.txt

RUN pip3 install -Ur requirements.txt

FROM python:3.10-alpine AS final

WORKDIR /backend-flask
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY . .

ENV FLASK_ENV=development
EXPOSE ${PORT}

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

## Implement a healthcheck in the V3 Docker compose file

From researching the implementation of a health check, the following link [Docker-Compose_Health-Check_Tutorial](https://medium.com/geekculture/how-to-successfully-implement-a-healthcheck-in-docker-compose-efced60bc08e) was useful for refeernce in learning how to apply a Health Check to ensure the docker service is working as intended. From the documentation, the `curl` commmand was added to the health check for pinging to the backend of the application to test if the service works.

```Docker-Compose Health Check
frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    # Added health-check, referencing https://medium.com/geekculture/how-to-successfully-implement-a-healthcheck-in-docker-compose-efced60bc08e
    healthcheck:
      test: curl --fail "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}" || exit 1
      interval: 60s
      retries: 5
      start_period: 20s
      timeout: 10s
    volumes:
      - ./frontend-react-js:/frontend-react-js
```

## Learn how to install Docker on your localmachine and get the same containers running outside of Gitpod / Codespaces

After setting up Docker Desktop locally after creating a DockerHub account, I downloaded the project folder from Github to my local machine to get started with this challenge. For docker compose to work, the gitpod url's will not work on the localmachine; instead  `"http://localhost:4567"` and `"http://localhost:3000"` were used as the locations on the local machine where the services could work on their respective ports. I also performed `npm install` again to ensure the configuration of the frontend and the package.json dependencies were working correctly locally. Afterwards, I ran docker comopse and ensured that Cruddur worked locally.

![Docker on LocalMachine](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week1/Run-Docker-Local-Machine.PNG)

## Launch an EC2 instance that has docker installed, and pull a container to demonstrate you can run your own docker processes

In AWS, I launced a Linux AMI EC2 with Docker installed and performed the same action as I did when I first created my DockerHub account and pulled the tutorial base image that was retagged and pushed to DockerHub. As such, I pulled the docker/getting-started image to the EC2 as part of this homework challenges, as follows:

[Pulled Docker Image to EC2](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week1/Docker-Pull-Container-on-EC2.PNG)
