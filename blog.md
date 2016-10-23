# Let's become friends with Docker by practice

## Contains
- Setup Dockerfile
- Images
  - Build
  - Tags
  - Push
- Containers
  - Run
  - Start, Stop & Remove
  - Exec
  - Volumes
  - Links & Networks
  - Logs
  - Environment variables
  - External commands
- Docker compose
  - Build
  - Start, Stop & Remove
  - Bundle

## Brief overview / Introduction
Docker is an open-source tool designed to create, build, deploy and run applications as easy as possible using containers. You are able to create system with all necessary things you need and wrap you application with it. This way the environment is always the same. Unlike virtual machines, Docker shares OS kernel across containers, where every container is running as a process on this hosted OS.

## Let’s practice already
Before we can start using Docker, we need to install it. Following link contains all needed information. Just select type of your OS, download and install.
https://www.docker.com/products/overview

## Dockerfile
Now that you have Docker installed, you are ready to start ruling. Docker needs to have some sort of configuration to be able to build applications. Entry point file with this configuration is called `Dockerfile`. Yes its just Dockerfile, no extension, nothing. It should be placed in the root directory of given application.
However structure of content of this file may vary, in most cases there is some operations order. Below is example how can Dockerfile looks like.

**TODO LINK**

```
# 1 Environment
FROM mhart/alpine-node:6.5

# 2 Attach files to container
COPY public /node-app/public
COPY index.js /node-app/index.js
COPY package.json /node-app/package.json
COPY README.md /node-app/README.md

# 3  Working directory
WORKDIR /node-app/

# 4 Install all dependencies
RUN npm install

# 5 Volume example
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting.txt
VOLUME /myvol

# 6 Environment variable example
ENV PORT 4444

# 7 Expose ports
EXPOSE ${PORT}

# 8 Start app
CMD ["npm", "start"]

```

`# 1` describes what environment you want to use. In this scenario we have NodeJS application, so we want to use NodeJS environment. Most of the time all you need is just search in google for your desired environment (Java, Python, Ruby, etc.) and add docker word to it. There are plenty of containers for almost everything you can imagine. Here using NodeJS we will be able to use NodeJS commands (respective to chosen NodeJS version).

`# 2` specifies what files should be attached to container. Path to these files are based on position of Dockerfile, so be aware of that. You can also use `ADD` instead of `COPY`, but `COPY` looks more transparent.

`# 3` says what working directory you want to use. It's not required, but good to use so your application is stored on place you can easily find(inside container).

`# 4` just runs `npm install` to install all dependencies as you would do locally not using docker.

`# 5` show example how volumes work. Basically you will create new empty directory, create file there with text `hello world` and mount this folder. This is just simple example, mostly you will use this for databases etc.

`# 6` sets environment variable for port. If not specified app will run on port 5000, but using this we will overwrite it.

`# 7` says that application will be available on port 4444 set by environment variable. Which means you have to add this port to url when running containerized application.

Finally `# 8` tell docker what should be executed when everything is done. In this case how to start the application.

**TODO HEALTHCHECKS**

**CLONE, CREATE DOCKERFILE**

## Images
### Build

Next step is to build image using our `Dockerfile`. In terminal type:
`docker build –t=my_app .`

**Don’t forget about dot at the end.** After few seconds/minutes, image is ready to run in container. Make sure that image exists using command: `docker images`

### Tags

Once image exists you are able to tag your image. This option is mostly used for versioning your images. For example version image for production, develop, testing etc. Command would look like this:
`docker tag my_app my_app:production`

List images again and you should see now two versions of your app.

### Push

**PUSH**

## Containers
### Run

Image is ready to run inside container, so let's go for it:
`docker run --name my_app_node my_app`
Name of your container can be absolutely different from image name, but it's good to keep it at least similar for easier searching later.

Using this command we have running application locally inside docker. Let’s check it's true with command:
`docker ps`
Running container should be listed there.

You can also list containers that exists, but are not running:
`docker ps -a`

Container is running and we are finally able to test if app works. Navigate to `localhost:4444` and see if app is working. App should print `Hello world` in browser.

### Stop, Start

Container can be stopped by:
`docker stop my_app_node`
And started up again:
`docker start my_app_node`

### Exec

Once container is running you are able to get into it via bash command line(or other variants) and do actions. For example run some shell scripts that are inside container.

`docker exec –it my_app_node ash`

Now you are inside container and by typing `ls` you should see app structure. If you go one level up by `cd ..` and again `ls` you should also see here our mounted folder `myvol` and inside it `example.txt` file.

### Inspect

You can access detailed container or image information such as networks, volumes etc. by command:
`docker inspect my_app_node`

### Volumes

If you need to mount your docker container data to disk to not loss them when container is destroyed you are able to use volumes. Easiest example of using it is database. Image you run database and there are already some data, but when you remove container data are lost. Volumes will mount data from the container to disk and once you remove container and start it again database will load those data from disk.

Example: docker run -- name your_desired_name - v disk_dir_location:container_dir_location image_name

Docker run -- name my_db - v /data/my_db:/container/folder db

You may question how to know what to place instead of /container/folder. One of the possibilities is to go inside container using “docker exec” command and find the folder where data are stored. Another possibility might be to just use google and ask him where database (or something else you are using) is storing data.

In our example we can do something like this:
`docker run --name my_app_node -v $(pwd)/blog-volume:/myvol -d my_app`

This means that everything inside `myvol` folder inside container will be mapped to disk at our current place and put inside `blog-volume`. Stop and remove container and by using command above you should have `blog-volume` folder at your current place and `example.txt` file there.

### Remove

If you don’t need any image or container anymore you can remove them simply by:  
`docker rm my_app_node`  
`docker rmi my_app`

### Links & Networks

In most cases your application is built out of multiple pieces. There is a big chance that some of them are dependent on other ones. To accomplish connection between them you can choose two ways how to do that.

#### Link

Using link flag you can specify on which containers is your current dependent or needs to be aware of them. It’s pretty straightforward.

`docker run --name image_name -- link db:db image_name`

Link flag is very similar to port. First parameter is name of dependency your container expects and second one name of existing container. By doing this container is aware of “db” and can communicate with it. However this approach is very common in these days is obsolete and you should use second approach.

#### Network

As name says you will create networks. It’s pretty self-explanatory. They behave, as you would expect, everything that is on the same network is visible and everything that is on other networks is not. In other words if you have container A on network 1 and container B on network 2. They are not aware about themselves. But what you can do is specify multiple networks for single container and build some kind of network structure.

First you have to create network:
`docker network create my_network`

And then place container on it.
`docker run --name image_name -- network my_network image_name`

### Logs

Often you want to trace you running app inside container. For example when app goes down for some reason you want to know what happened. Be aware that these logs are just as good as your app is outputting to terminal when you run it locally. Docker will not enhance with anything.

Given command will give you live logs for chosen container. If don’t want live capability just omit “f” flag before container name/id.
`docker logs –f my_app_node`

### Environment variables

You might have places in your app when you don’t want to expose things like API keys etc. and use environment variables. You are free to go and specify them on container run command.

`docker run --name my_app_node -e PORT=”4444” my_app`

Quotes around value of environment variables shouldn’t be necessary, but when you assign multiple values to variable as it is shown below it’s easier to read it.

`docker run -- name my_app - e API_KEY=”123456,4567,09876” image_name`

### External commands

**TODO**

### Docker compose

As your app starts to grow up you may find starting every container one by one exhausting. For this purpose exists Docker compose. Docker compose file allows you to specify all containers you want to start with same properties as you are able to use by standard docker run command. Currently are available two versions and I will use the second one.

EXAMPLE docker-compose file & explanation

Once you have docker-compose file you are able to start app. Just by using command:
`docker-compose up –d`
If you want to see logs from all containers inside (similar to docker logs command) just omit “-d” flag. In case you want multiple docker-compose files (e.g. for development, production, etc.) you are able to specify it using flag “-f name_of_docker_compose_file”.  
`docker-compose –f different_docker_compose_file.yaml up -d`

In same fashion as start you can use stop, rm and kill commands. Which means they will be applied to all containers inside docker compose, so you don’t have to do that one by one (but still can).  
`docker-compose stop`  
`docker-compose rm`  
`docker-compose kill`

When you run `docker ps` you will see that docker-compose started all containers, as you normally would do manually.

**BUNDLE**

**Incoming: Part 2 - Docker swarm & orchestrating.**
