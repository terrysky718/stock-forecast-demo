#
# Ubuntu 18.04 Dockerfile for machine learning training
#

FROM continuumio/anaconda3
MAINTAINER Terry Song

USER root

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y apt-utils
RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8

# Install necessary tools
RUN apt-get update && apt-get install -y make && \
    apt-get install -y gcc && \
    apt-get install -y g++ && \
    apt-get install -y vim && \
    apt-get install -y wget && \
    apt-get install -y bzip2 && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV LANG en_GB.utf8
ENV HOME /root

# Define working directory in container
WORKDIR /root

# Install Anaconda and set up Python environment
# current installer:  https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh~
RUN wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
RUN bash Anaconda3-2019.07-Linux-x86_64.sh -b
RUN rm Anaconda3-2019.07-Linux-x86_64.sh

# Set path to conda
ENV PATH /root/anaconda3/bin:$PATH
RUN conda update conda
RUN conda update --all

# Set Python 3.6 as the environment
# RUN conda create -n pyfinance python=3.6

# Activate the Python environment
# RUN echo "source activate pyfinance" > ~/.bashrc
# RUN /bin/bash -c "source activate pyfinance"

# Define path to Python packages
# ENV PATH /opt/conda/envs/pyfinance/bin:$PATH

# RUN /bin/bash -c "conda activate pyfinance"
# RUN conda activate pyfinance

# Install TA-Lib library
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar -xvzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    ./configure --prefix=/usr && \
    make && \
    make install
RUN rm ta-lib-0.4.0-src.tar.gz

# Create the Python environment and install the necessary libraries
ADD docker-environment.yml /root/docker-environment.yml
RUN conda env create -f docker-environment.yml

# Activate the Python environment
RUN echo "source activate pyfinance" > ~/.bashrc

# Jupyter listens port: 8888
EXPOSE 8888

# Configuring access to Jupyter
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

