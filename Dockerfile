# docker build -t firmadyne .
FROM ubuntu:14.04

# Update packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo
RUN apt-get install -y busybox-static fakeroot git dmsetup kpartx netcat-openbsd nmap python-psycopg2 python3-psycopg2 snmp uml-utilities util-linux vlan postgresql wget qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils vim unzip

# Copy current dir into the container
ADD . /firmadyne

# Create firmadyne user
RUN useradd -m firmadyne
RUN echo "firmadyne:firmadyne" | chpasswd && adduser firmadyne sudo

# Run setup script
WORKDIR /firmadyne
RUN /firmadyne/setup.sh

USER firmadyne
ENTRYPOINT ["/firmadyne/startup.sh"]
CMD ["/firmadyne/analysis.sh"]
