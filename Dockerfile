FROM debian:jessie
MAINTAINER Jeff Turner <jeff.t@coastec.net.au>
ENV DEBIAN_FRONTEND noninteractive

# Download & install required applications: curl, sudo.
RUN apt-get -qqy update
RUN apt-get -qqy install inotify-tools rsync ssh

# Create service account and set permissions.

# Perform image clean up.
RUN apt-get -qqy autoclean

COPY sync_dropbox_to_s3.sh /
RUN chmod +x /sync_dropbox_to_s3.sh

CMD ["/sync_dropbox_to_s3.sh"]
