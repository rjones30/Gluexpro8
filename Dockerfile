#
# Dockerfile - docker build script for a standard GlueX sim-recon 
#              container image based on RHEL8.
#
# author: richard.t.jones at uconn.edu
# version: september 7, 2021
#
# usage: [as root] $ docker build Dockerfile .
#

FROM registry.access.redhat.com/ubi8/ubi:8.1

# install a few utility rpms
RUN yum -y install bind-utils util-linux which wget tar procps less file dump gcc gcc-c++ gcc-gfortran gdb gdb-gdbserver strace openssh-server
RUN yum -y install vim-common vim-filesystem docker-io-vim vim-minimal vim-enhanced vim-X11
RUN yum -y install qt qt-x11 qt-devel
RUN yum -y install motif-devel libXpm-devel libXmu-devel libXp-devel
RUN yum -y install java-1.8.0-openjdk
RUN yum -y install blas lapack
RUN yum -y install python3 python3-devel python3-pip
RUN yum -y install postgresql-devel
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/libtbb.tgz
RUN tar xf libtbb.tgz -C /
RUN rm libtbb.tgz

# install the osg worker node client packages
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# work-around for problems using the EPEL mirrors (repomd.xml does not match metalink for epel)
RUN sed -i 's/^#baseurl/baseurl/' /etc/yum.repos.d/epel.repo
RUN sed -i 's/^metalink/#metalink/' /etc/yum.repos.d/epel.repo
# end of work-around
RUN yum -y install yum-plugin-priorities
RUN rpm -Uvh https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el7-release-latest.rpm
RUN yum -y install osg-wn-client
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/dcache-srmclient-3.0.11-1.noarch.rpm
RUN rpm -Uvh dcache-srmclient-3.0.11-1.noarch.rpm
RUN rm dcache-srmclient-3.0.11-1.noarch.rpm

# install some additional packages that might be useful
RUN yum -y install apr apr-util atlas autoconf automake bc cmake cmake3 git scons bzip2-devel boost-python36
RUN yum -y install gsl gsl-devel libgnome-keyring lyx-fonts m4 neon pakchois mariadb mariadb-libs mariadb-devel
RUN yum -y install perl-File-Slurp perl-Test-Harness perl-Thread-Queue perl-XML-NamespaceSupport perl-XML-Parser perl-XML-SAX perl-XML-SAX-Base perl-XML-Simple perl-XML-Writer
RUN yum -y install subversion subversion-libs
RUN yum -y install python2-pip python-devel
RUN yum -y install hdf5 hdf5-devel
RUN yum -y install valgrind
RUN pip2 install future numpy==1.16.6
RUN pip3 install psycopg2
RUN pip3 install --upgrade pip
RUN python3 -m pip install numpy==1.19.5

# create mount point for sim-recon, simlinks in /usr/local
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/local.tar.gz
RUN mv /usr/sbin/sshd /usr/sbin/sshd_orig
RUN tar xf local.tar.gz -C /
RUN rm local.tar.gz
RUN rm -rf /hdpm

# make the cvmfs filesystem visible inside the container
VOLUME /cvmfs/oasis.opensciencegrid.org

# set the default build for sim_recon
RUN ln -s /cvmfs/oasis.opensciencegrid.org/gluex/.hdpm /usr/local/
