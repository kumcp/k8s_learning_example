# For building the image with Dockerfile.helloworld, we can use the command

docker build -f ./Dockerfile.helloworld -t myimage:mytag .

# This command will build:
# Inside folder .
# Image with the name tag myimage:mytag
# -f <filename> if we want to build by a different file name than Dockerfile

# Result will be image myimage:mytag
# See the images with:
docker images

# After the image has been built, we can run (create container and run) by:
docker run myimage:mytag

# If running in background mode, using
docker run -d myimage:mytag

#In this mode, we will not see the log (by echo command), but the log still hold the result.
# We can check the log of this container by:
docker logs container_name
# With container_name is the name or id of the container has been created.

# Lab 3

docker build -f ./Dockerfile.helloworld -t mynginx:mytag .

# We can access inside container environment by:

docker exec -it <container_name> /bin/bash
# <container_name> can be seen by using
docker ps

# For example
docker exec -it hello_world /bin/bash