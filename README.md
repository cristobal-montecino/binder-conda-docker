# Binder

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/cristobal-montecino/binder-docker-test/master?urlpath=lab%2Ftree%2Fmain.ipynb)

# Local installation

This install a development container

## Building

Build the image:

```
$ git clone https://github.com/cristobal-montecino/binder-docker-test.git
$ sudo docker build -t binder-docker-test binder-docker-test
```

Explanation:

```
-t binder-docker-test: builds an image called 'binder-docker-test' (you can named as whatever you want, but need to make changes)
```

## Running

Execute the container:

```
$ cd binder-docker-test
$ sudo docker run --mount type=bind,source="$(pwd)",target=/env --rm -p 8888:8888 binder-docker-test
```

Explanation:

```
--mount type=bind,source="$(pwd)",target=/env : Binds the local 'binder-docker-test' directory to the container '/env' directory
                  --rm : the container will be removed at server shutdown
          -p 8888:8888 : forwards the container 8888 tcp port to the machine 8888 tcp port
    binder-docker-test : the image name
```
