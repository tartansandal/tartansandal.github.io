---
title: Docker on a Fedora Desktop (Part 1)
layout: post
categories: fedora docker
---

Part 1 of some notes I made while exploring using Docker for software
development on a Fedora Desktop.

## The official "Get Started" guide

Many people new to Docker will start out, as I did, with the official [Get
Started](https://docs.docker.com/get-started/) guide referenced by the main
[Docker](https://www.docker.com/) website.  This guide was written with Windows
and MacOS users in mind and is not strictly the best place for Fedora Desktop
users to start.  Completeness fanatics like myself will push ahead though.

The first step was to install *Docker Community Edition* from Docker’s
own repository.

> :point_up:
> While Fedora 31 offers both of [Moby Engine](https://mobyproject.org/) and
> [Podman](https://podman.io/) for containerization, these are too
> 'bleading-edge' to work with this tutorial.  In addition, many projects have
> **Docker CE** as a requirement, so its good to know how to set this up.

### Installing Docker CE on Fedora

First, clear out any of our Fedora versions of the tools (so we don’t get any
conflicts):

``` bash
sudo dnf remove 'docker*'
```

Fedora 31 users will have to revert to using the older cgroups v1:

``` bash
sudo dnf install -y grubby
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
sudo reboot
```

To install from Docker directly we need to set up an additional repository:

``` bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf makecache
```

Then install the `engine` and the `cli` with

``` bash
sudo dnf install docker-ce docker-ce-cli
```

Then ensure the `docker` container services are enabled and running:

``` bash
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service
```

In order to run `docker` client commands without `sudo`, add yourself to
the `docker` group:

``` bash
sudo useradd -aG docker $USER
newgrp
```

## Installing Extra Tools

Users of *Docker Desktop* for *MacOS* or *Windows* have some additional tools
bundled in with its installation, namely, `docker-credential-helpers`,
`docker-compose`, and `docker-machine`.  These tools are useful for exploring
"multi-container orchestration" on your desktop.  If want to complete the [Get
Started](https://docs.docker.com/get-started/) guide, you will have to install
(and trust) the binaries offered by Docker.

Since these tools do not have any package management, I’m going to install them
locally under `~/bin` rather than `~/.local/bin`.  The later is is a more
appropriate target for package managers like `pip`, and `npm`, and I don’t want
to get those mixed up.

### Native storage of Docker credentials

To allow the `docker login` command to use the GNOME Keyring, we need to
install the latest version of `docker-credential-secretservice`.

First check for the latest version at
<https://github.com/docker/docker-credential-helpers/releases>, adjust the
version number below if needed, then run:

``` bash
version=v0.6.3
base=https://github.com/docker/docker-credential-helpers/releases/download/
target=/tmp/docker-credential-secretservice-$version-amd64.tar.gz
curl -L $base/$version/docker-credential-secretservice-$version-amd64.tar.gz -o $target
tar -C ~/bin -zxf $target
chmod +x ~/bin/docker-credential-secretservice
rm -f $target
```

Next edit `~/.docker/config.json` and ensure it contains the following
key:

``` json
{
  "credsStore": "secretservice"
}
```

### Docker Compose

[Docker Compose](https://docs.docker.com/compose/) is a tool for defining and
running multi-container Docker applications.

To install `docker-compose`, check for the latest release at
<https://github.com/docker/compose/releases>, adjust the
version number below if needed, then run:

``` bash
version=1.24.1
base=https://github.com/docker/compose/releases/download/$version
curl -L "$base/docker-compose-$(uname -s)-$(uname -m)" -o ~/bin/docker-compose
chmod +x ~/bin/docker-compose
```

To install bash completion for `docker-compose`, run

``` bash
version=1.24.1
base=https://raw.githubusercontent.com/docker/compose/$version
target=~/.local/share/bash-completion/completions
curl -L $base/contrib/completion/bash/docker-compose -o $target/docker-compose
```

### Docker Machine

[Docker Machine](https://docs.docker.com/machine/) lets you create Docker hosts
on your computer, in our case, using [VirtualBox](https://www.virtualbox.org/).

To install `docker-machine`, first check for the latest release at
<https://github.com/docker/machine/releases>, adjust the
version number below if needed, then run:

``` bash
version=v0.16.2
base=https://github.com/docker/machine/releases/download/$version
curl -L $base/docker-machine-$(uname -s)-$(uname -m) -o ~/bin/docker-machine
chmod +x ~/bin/docker-machine
```

To install bash completion for `docker-machine`, run

``` bash
version=v0.16.2
base=https://raw.githubusercontent.com/docker/machine/$version
target=~/.local/share/bash-completion/completions
for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
do
    curl -L "$base/contrib/completion/bash/${i}" -o $target/$i
done
```

> :anchor:
> While `docker-machine` is being actively **supported**---it is useful for
> learning and local development---it is no longer being actively
> **developed**---being superseded by platform specific orchestration tools like
> K8s.  Both `docker-machine` and its dependency `boot2docker`, are part of
> Docker Desktop and Docker Toolbox.

## Next steps

The above allowed me to run the official *Get Started* guide which
introduced some basic and more advanced concepts, but left me a little
confused about using Docker as part of my development work flow.  Some
other guides like [Docker for Beginners](https://docker-curriculum.com/)
gave a much better introduction.

> :bell: If you have problems with login or connection timeouts to
> [docker.io](https://docker.io) try running
>
> `docker network prune`

For an excellent curated list of Docker resources and projects, check
out [Awesome Docker](https://awesome-docker.netlify.com/).

For example, [Portainer](portainer.io) is a simple tool for tracking and
maintaining all the images and containers that will soon begin to invest my
system.  You can even install it "as a container" itself.

That's all for now.

Future posts will explore actually doing development with Docker [Kubernetes
(K8s)](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) and
[Podman](https://podman.io/).
