# Blacklabelops Rsnapshot

[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/rsnapshot.svg)](https://hub.docker.com/r/blacklabelops/rsnapshot/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/rsnapshot.svg)](https://hub.docker.com/r/blacklabelops/rsnapshot/)

This is a side-car container for creating and managing container backups using rsnapshot. This container can backup
any arbitrary amount of containers and directories. Just hook up some containers and define your
backup volumes.

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

Rsnapshot is a wrapper around rsync and rsnapshot is strong when it comes to manage The
rotation of daily, weekly and monthly snapshots. This image is a the base container with
rsnapshot functionality dockerized and parameterized.

The cron scheduled backup container can be found here: [blacklabelops/rsnapshotd](./rsnapshot-cron/README.md)

# Make It Short

In short, this container can backup volumes and manage incremental backups of running containers.

Example container:

~~~~
docker run -d -p 8090:8080 --name jenkins blacklabelops/jenkins
~~~~

> The Jenkins container has a default docker volume under /jenkins

Creating a local backup of the running Jenkins container. This is only recommended For
linux system as you can loose file permissions and loose the ability to restore:

~~~~
$ docker run -d \
  --volumes-from jenkins \
	-v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins/" \
	blacklabelops/rsnapshot
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

# Restoring a Backup

You can restore any backup immediately. Choose the directory of your requested backup and formulate the following command.

Example:

* Restore daily backup daily.4 of container `jenkins_jenkins_1`

> Defined by container parameter `-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_jenkins_1/"`

* The container blacklabelops/jenkins uses Volume /jenkins
* The backup container blacklabelops/rsnapshot stores backups inside volume /snapshots

Restore a local stored backup by first running a dry-run, so that you can check the execution of The
restore. This command will perform a test restore without copying or deleting any files:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
	-v $(pwd)/snapshots/:/snapshots \
	blacklabelops/rsnapshot \
  rsync -avr --delete --dry-run /snapshots/daily.4/jenkins_jenkins_1/jenkins/ /jenkins/
~~~~

> Note you can always leave the `-v` option. Afterwards the backups will always be performed on the
container volume.

Now execute the restore:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
	-v $(pwd)/snapshots/:/snapshots \
	blacklabelops/rsnapshot \
  rsync -avr --delete /snapshots/daily.4/jenkins_jenkins_1/jenkins/ /jenkins/
~~~~

# Setting the Backup Interval

The default backup mode is `hourly`. This can be overriden. The rsnapshot intervals are:

* `hourly`
* `monthly`
* `weekly`
* `monthly`

This can be set by using the environment variable `BACKUP_INTERVAL`. Here is an
example on how to execute a monthly backup.

~~~~
$ docker run -d \
  --volumes-from jenkins_jenkins_1 \
	-v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_jenkins_1/" \
  -e "BACKUP_INTERVAL=monthly" \
	blacklabelops/rsnapshot
~~~~

> The correct semantics for intervals and how they work can be found in the [rnsapshot manual](http://rsnapshot.org/)

# Setting Backup Directories

This container can backup and arbitrary amount of containers and directories. All containers
must be connected by using the `--volumes-from` directive. Afterwards you can define all
backup directories by using the Environment variable `BACKUP_DIRECTORIES`.

Each backup directory is a touple of an absolute path of the backup directory and a relative path
for the identifier inside the snapshots directory (target directory). All directories require trailing `/`.

Examples:

* `/jenkins/ jenkins_1/`

> Backups volume /jenkins/ under /snapshots/[interval_id]/jenkins_1/

* `/opt/atlassian-home/ jira_1/`

> Backups volume /opt/atlassian-home/ under /snapshots/[interval_id]/jira_1

All directory touples must be seperated by `;` in order to fit the environment variable:

~~~~
BACKUP_DIRECTORIES="/jenkins/ jenkins_1/;/opt/atlassian-home/ jira_1/"
~~~~

Example using Jenkins and Jira. Fire up both containers:

~~~~
$ docker run -d -p 8090:8080 --name jenkins_jenkins_1 blacklabelops/jenkins
$ docker run -d -p 8100:8080 --name="jira_jira_1" blacklabelops/jira
~~~~

Backup both containers by mounting their volumes and defining the backup directories:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
  --volumes-from jira_jira_1 \
  --rm \
	-v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_1/;/opt/atlassian-home/ jira_1/" \
	blacklabelops/rsnapshot
~~~~

## How many backups do you want?

The following environment variables define the number of backups for each category:

* hourly: RSNAPSHOT_HOURLY_TIMES
* daily: RSNAPSHOT_DAILY_TIMES
* weekly: RSNAPSHOT_WEEKLY_TIMES
* monthly: RSNAPSHOT_MONTHLY_TIMES

Example:

~~~~
$ docker run \
  --volumes-from jenkins_jenkins_1 \
  --volumes-from jira_jira_1 \
  --rm \
	-v $(pwd)/snapshots/:/snapshots \
	-e "BACKUP_DIRECTORIES=/jenkins/ jenkins_1/;/opt/atlassian-home/ jira_1/" \
  -e "RSNAPSHOT_HOURLY_TIMES=4" \
  -e "RSNAPSHOT_DAILY_TIMES=7" \
  -e "RSNAPSHOT_WEEKLY_TIMES=4" \
  -e "RSNAPSHOT_MONTHLY_TIMES=12" \
	blacklabelops/rsnapshot
~~~~

> Represents the default setup: hourly=4, daily=7, weekly=4, monthly=12.

# Vagrant

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ ./scripts/build.sh
~~~~

> Builds the image.

Vagrant does not leave any docker artifacts on your beloved desktop and the vagrant image can simply be destroyed and repulled if anything goes wrong. Test my project to your heart's content!

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

# References

* [rnsapshot Homepage](http://rsnapshot.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
