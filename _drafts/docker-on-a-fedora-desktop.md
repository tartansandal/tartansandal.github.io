---
title: Docker on Fedora Desktop
layout: post
categories: fedora docker
---

The following are some notes made while exploring using Docker as part
of a software development pipeline on a Fedora Desktop in 2019.

I’d been wanting to explore Docker for a long time, years in fact, but
life and work seemed to have conspired against that ambition for a long.
This month I finally got some spare time and the freedom to explore, so
I headed off to the main website [Docker](https://www.docker.com/) and
the associated [Getting Started](https://docs.docker.com/get-started/)
tutorial.

It turns out that this was not 100% the best place for me to start and
did cause some confusion. Some of this is due to tutorials that needed
to work for Linux, Mac, and Windows users at the same time. Some of this
is due to the rapid development of containerization and orchestration
technologies.

> **Note**
>
> [Docker for Beginners](https://docker-curriculum.com/) is a
> particularly good first time tutorial.
>
> For an excellent curated list of Docker resources and projects, check
> out [Awesome Docker](https://awesome-docker.netlify.com/).

## Installing Docker CE

The first step was to install *Docker Community Edition* from Docker’s
own repository. This was a bit odd since the official Fedora
repositories provide a version of Docker.

> What’s the deal here?

It turns out that the open source home of Docker is the [Moby
Project](https://mobyproject.org/) which is the ultimate upstream for
*Docker CE (Community Edition)* and the commercially supported *Docker
EE (Enterprise Edition)*. The following advice is given:

> Moby is NOT recommended for application developers looking for an easy
> way to run their applications in containers. We recommend Docker CE
> instead.
>
> —  Moby Project

Fedora’s version of Docker is provided via
[ProjectAtomic](http://www.projectatomic.io/) which forks and patches
work from the *Moby Project*. The focus of *ProjectAtomic* is on
developing minimal operating systems for hosting containers like Docker.
The Docker tools provided are actively maintained but the versions are a
bit older and probably err on the side of stability. This is
interesting, but probably not what we want.

The upshot is we want to install Docker CE and clear out any of our
Fedora versions of the tools (so we don’t get any conflicts).

The following is a quick break down of this process.

First ensure we have a clean slate and any exiting packages have been
removed:

``` bash
sudo dnf remove 'docker*'
```

To install from Docker directly we need to set up an additional
repository:

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

Users of *Docker Desktop* for *MacOS* or *Windows* have some additional
tools bundled in with its installation, namely, `docker-compose`,
`docker-credential-helpers` and `docker-machine`. These tools are useful
for exploring "multi-container orchestration" on your desktop. If want
to complete the "Getting Started" guide, you will have to install (and
trust) the binaries offered by Docker.

> **Note**
>
> One of these tools, `docker-machine`, is in an unusual situation of
> being actively *supported* (since it is useful for learning and local
> development) and is part of Docker Desktop and Docker ToolBox, but it
> is no longer being actively **developed**. This may cause some
> confusion if you visit the project on GitHub . The reason is that it
> has been superseded by platform specific orchestration tools, e.g.,
> for production we might use, say, K8s for a Google deployment of our
> Docker images.
>
> Note that `docker-machine` relies on another development-only
> component `boot2docker` which is part of Docker Desktop and Docker
> ToolBox.

> **Note**
>
> There *is* a version of `docker-compose` provided by the Fedora
> repositories but it is more than a year old.

The following is a quick break down of this process.

Since these tools do not have any package management, I’m going to
install them locally under `~/bin`. I don’t install under `~/.local/bin`
since that is a more appropriate target for package managers like `pip`,
`gem`, and `npm`, and I don’t want to get those mixed up. I use the
`~/bin` directory for **manual** installations only.

To allow the `docker login` command to use the GNOME Keyring, we need to
install the latest version of `docker-credential-secretservice`.

First check for the latest version at
`https://github.com/docker/docker-credential-helpers/releases`, then run
(adjusting the version number if needed):

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

To install `docker-compose`, first check for the latest release at
`https://github.com/docker/compose/releases`, then run the following
(adjusting the version number if needed):

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

To install `docker-machine`, first check for the latest release at
`https://github.com/docker/machine/releases`, then run the following
(adjusting the version number if needed):

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

## Troubleshooting

If you have problems with login or connection timeouts to docker.io try:

    docker network prune


## What next?

The above allowed me to run the official *Getting Started* guide which
introduced some basic and more advanced concepts, but left me a little
confused about using Docker as part of my development work flow. Some
other guides like [Docker for Beginners](https://docker-curriculum.com/)
gave a much better introduction.

Given the most likely deployment scenarios, I think I should be
exploring orchestration that fits with AWS and GCP. Probably K8s.

Running `portainer.io` made it much easier to track all the images and
containers that had begun to invest my system. Very easy to install "as
a container" itself.

We should be able to avoid needing *VirtualBox* on Fedora, say using
*Boxes* or `virt-manager` for the machines? The problem is getting
access to images.

Even *MiniKube* is a bit clunky on Fedora with VirtualBox.

What about `rancher`? <https://rancher.com/>
