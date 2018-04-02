[![Build Status](https://travis-ci.org/JimTouz/counter-strike-docker.svg?branch=master)](https://travis-ci.org/JimTouz/counter-strike-docker)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/JimTouz/counter-strike-docker/blob/master/LICENSE)




# Docker image for Counter Strike 1.6 Dedicated Server

### Build an image:

```
 $ make build
```

### Create and start new Counter-Strike 1.6 server:

```
 $ docker run -d -p 27020:27015/udp -e START_MAP=de_inferno -e ADMIN_STEAM=0:1:1234566 -e SERVER_NAME="My Server" --name cs cs16ds:alpha
```

### Stop the server:

```
 docker stop cs
```

### Start existing (stopped) server:

```
 docker start cs
```

### Remove the server:

```
 docker rm cs
```

## Attributions

This project is based on [counter-strike-docker](https://github.com/artem-panchenko/counter-strike-docker), developed by [Artem Panchenko](https://github.com/artem-panchenko).

## Changes from original project

* Changed the name of the build
