# Binder

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/cristobal-montecino/binder-conda-docker/master?urlpath=lab%2Ftree%2Fmain.ipynb)

# Local installation

This install a development container

## Building

Build the image:

```
$ git clone https://github.com/cristobal-montecino/binder-conda-docker.git
$ sudo docker build -t binder-conda-docker binder-conda-docker
```

Explanation:

```
-t binder-conda-docker-test: builds an image called 'binder-conda-docker' (you can named as whatever you want, but need to make changes)
```

## Running

Execute the container:

```
$ cd binder-conda-docker
$ sudo docker run --mount type=bind,source="$(pwd)",target=/env --rm -p 8888:8888 -it binder-conda-docker
```

Explanation:

```
--mount type=bind,source="$(pwd)",target=/env : Binds the local 'binder-conda-docker' directory to the container '/env' directory
                  --rm : the container will be removed at server shutdown
          -p 8888:8888 : forwards the container 8888 tcp port to the machine 8888 tcp port
                   -it : makes interactive
   binder-conda-docker : the image name
```
