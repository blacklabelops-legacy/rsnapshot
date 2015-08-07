Rsnapshot is a wrapper around rsync and rsnapshot is strong when it comes to manage The
rotation of daily, weekly and monthly snapshots.

This container offers rsnapshot functionality dockerized, parameterized and demonized. It is a side-car container for creating and managing container backups using rsnapshot. This container can backup
any arbitrary amount of containers and directories. Just hook up some containers and define your
backup volumes.

# Make It Short

In short, this container can backup volumes and manage incremental backups of running containers.

Example container:

~~~~
docker run -d -p 8090:8080 --name jenkins_jenkins_1 blacklabelops/jenkins
~~~~

> The Jenkins container has a default docker volume under /jenkins

Creating a local backup of the running Jenkins container. This is only recommended For
linux system as you can loose file permissions and loose the ability to restore:

~~~~
$ docker run -d \
  --volumes-from jenkins_jenkins_1 \
	-v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_jenkins_1/" \
	blacklabelops/rsnapshotd
~~~~

> Mounts all volumes from the running container and snapshots the volume /jenkins inside the local
snapshot directory under `jenkins_jenkins_1/`. Note: If you use Windows then you will have to replace $(pwd)
with an abolute path.

Browse the backup:

~~~~
$ ls snapshots/hourly.0/jenkins_jenkins_1/jenkins
Download metadata.log		plugins
config.xml					queue.xml.bak
hudson.model.UpdateCenter.xml	secret.key
identity.key.enc				secret.key.not-so-secret
init.groovy.d					secrets
jobs							updates
nodeMonitors.xml				userContent
nodes							war
~~~~

> Multiple invocations of the container will rotate backups. The default configuration sets up to 6 hourly backups.

# Setting Cron Schedule

The demon runs the following cron schedule for rsnapshot by default:

* Hourly backups: @hourly
* Daily backups: @daily
* Weekly backups: @weekly
* Monthly backups: @monthly

The number of managed backups can be found here: [rsnapshot.conf](../configuration/rsnapshot.conf)

You can override the schedule by using the following environment variables. Remember that they
have to contain valid cron syntax. ([Wikipedia Documentation](https://en.wikipedia.org/wiki/Cron))

* CRON_HOURLY
* CRON_DAILY
* CRON_WEEKLY
* CRON_MONTHLY

Example:

~~~~
$ docker run -d \
  --volumes-from jenkins_jenkins_1 \
  --name backupdemon \
  -v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_jenkins_1/" \
  -e "CRON_HOURLY=20 1 * * *" \
  -e "CRON_DAILY=0 2 1 * *" \
  -e "CRON_WEEKLY=0 1 * * Mon" \
  -e "CRON_MONTHLY=0 3 20 * *" \
	blacklabelops/rsnapshotd
~~~~

> Will create backups on the local disk by the defined cron schedule.

# Restoring a Backup

Described in [blacklabelops/rsnapshot](../README.md)

# Setting Backup Directories

Described in [blacklabelops/rsnapshot](../README.md)

## Vagrant

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ docker-compose up
~~~~

> Jenkins will be available on localhost:9200 on the host machine. Backups run
in background.

Vagrant does not leave any docker artifacts on your beloved desktop and the vagrant image can simply be destroyed and repulled if anything goes wrong. Test my project to your heart's content!

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

## References

* [rnsapshot Homepage](http://rsnapshot.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
