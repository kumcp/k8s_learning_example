# For installing Docker, we use this command

sudo apt-get install docker-ce-cli docker-ce -y
# Start docker permission
sudo chmod 666 /var/run/docker.sock
sudo chmod 666 /run/containerd/containerd.sock


# Lab 1
# Step 1
# Try using this command for starting a container

docker run -p 80:80 docker/getting-started

# This command will open port 80 from VM/host to port 80 inside container
# For running in background mode, we can use parameter -d

docker run -p 80:80 -d docker/getting-started

# Common Command to use

docker ps               # List container
docker images           # List images

docker stop strange_sanderson       # Stop container name strange_sanderson
docker rm strange_sanderson         # Remove container name strange_sanderson

# We can list all running container ids by using parameter -q
docker ps -q

# Or all running or stopped container ids by
docker ps -aq

# We can combine the command with:
docker stop $(docker ps -q)     # Stop all running containers
docker rm $(docker ps -aq)      # Remove all containers


# Delete images with
docker rmi docker/getting-started:latest        # Delete image docker/getting-started:latest

# Delete all images with
docker rmi $(docker images -q)

