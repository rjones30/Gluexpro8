#
# Dockerfile - docker build script for a standard GlueX sim-recon 
#              container image based on RHEL8.
#
# author: richard.t.jones at uconn.edu
# version: september 7, 2021
#
# usage: [as root] $ docker build -t rjones30/gluexpro8 .
#

#FROM registry.access.redhat.com/ubi8/ubi:8.1
FROM centos:8

# install a few utility rpms
RUN dnf -y install bind-utils util-linux which wget tar procps less file dump gcc gcc-c++ gcc-gfortran gdb gdb-gdbserver strace openssh-server
RUN dnf -y install vim-common vim-filesystem vim-minimal vim-enhanced vim-X11
RUN dnf config-manager --set-enabled powertools
RUN dnf -y install qt5-devel
RUN dnf -y install motif-devel libXpm-devel libXmu-devel libXp-devel
RUN dnf -y install java-1.8.0-openjdk
RUN dnf -y install blas lapack
RUN dnf -y install python3 python3-devel python3-pip
RUN dnf -y install postgresql-devel
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/libtbb.tgz
RUN tar xf libtbb.tgz -C /
RUN rm libtbb.tgz

# install the osg worker node client packages
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# work-around for problems using the EPEL mirrors (repomd.xml does not match metalink for epel)
RUN rpm -Uvh https://repo.opensciencegrid.org/osg/3.6/osg-3.6-el8-release-latest.rpm
RUN dnf -y install osg-wn-client
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/dcache-srmclient-3.0.11-1.noarch.rpm
RUN rpm -Uvh dcache-srmclient-3.0.11-1.noarch.rpm
RUN rm dcache-srmclient-3.0.11-1.noarch.rpm

# install some additional packages that might be useful
RUN dnf -y install apr apr-util atlas autoconf automake bc cmake cmake3 git python3-scons bzip2-devel boost-python3
RUN dnf -y install gsl gsl-devel lyx-fonts m4 neon pakchois mariadb-devel
RUN dnf -y install perl-File-Slurp perl-Test-Harness perl-Thread-Queue perl-XML-NamespaceSupport perl-XML-Parser perl-XML-SAX perl-XML-SAX-Base perl-XML-Simple perl-XML-Writer
RUN dnf -y install subversion subversion-libs
RUN dnf -y install python2-pip python2-devel python3-pip python3-devel
RUN dnf -y install hdf5 hdf5-devel
RUN dnf -y install valgrind
RUN pip2 install future numpy==1.16.6
RUN pip3 install psycopg2
RUN pip3 install --upgrade pip
RUN python3 -m pip install numpy==1.19.5

# install the intel compilers
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/Intel_oneAPI.repo
RUN mv Intel_oneAPI.repo /etc/yum.repos.d/
RUN dnf -y install intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
RUN dnf -y install intel-oneapi-compiler-fortran
# some bits from intel-basekit,intel-hpckit that look useful
#RUN dnf -y install intel-basekit intel-hpckit
RUN dnf -y install intel-oneapi-mkl-devel intel-oneapi-mpi-devel

# create mount point for sim-recon, simlinks in /usr/local
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/local.tar.gz
RUN mv /usr/sbin/sshd /usr/sbin/sshd_orig
RUN tar xf local.tar.gz -C /
RUN rm local.tar.gz
RUN rm -rf /hdpm

# add the molpro and octopus applications, these must be bind-mounted under the build dir
ADD opt/octopus /opt/octopus
ADD opt/molpro /opt/molpro
RUN wget --no-check-certificate https://zeus.phys.uconn.edu/halld/gridwork/libgfortran.tar
RUN tar xf libgfortran.tar -C / usr/lib64/libgfortran.so.3 usr/lib64/libgfortran.so.3.0.0 usr/lib64/libgfortran.so.4 usr/lib64/libgfortran.so.4.0.0

# make the cvmfs filesystem visible inside the container
VOLUME /cvmfs/oasis.opensciencegrid.org

# add the README
COPY README.md /
