# Set the base image ubuntu with mamba
FROM condaforge/mambaforge

# Sets which branch to fetch requirements from
ARG BRANCH

# Make RUN commands use `bash --login`:
SHELL ["/bin/bash", "--login", "-c"]

MAINTAINER Reimar Bauer <rb.proj@gmail.com>

# install packages for qt X
RUN  export DEBIAN_FRONTEND=noninteractive \
  && apt-get -yqq update --fix-missing \
  && apt-get -yqq upgrade \
  && apt-get -yqq install \
      apt \
      apt-utils \
      libgl1-mesa-glx \
      libx11-xcb1 \
      libxi6 \
      xfonts-scalable \
      x11-apps \
      netbase \
      git \
      xvfb \
  && apt-get -yqq clean all \
  && apt list --installed


# Install requirements, fetched from the specified branch
RUN wget -O /meta.yaml -q https://raw.githubusercontent.com/Open-MSS/fs_filepicker/${BRANCH}/localbuild/meta.yaml \
  && wget -O /development.txt -q https://raw.githubusercontent.com/Open-MSS/fs_filepicker/${BRANCH}/requirements.d/development.txt \
  && cat /meta.yaml \
   | sed -n '/^requirements:/,/^test:/p' \
   | sed -e "s/.*- //" \
   | sed -e "s/menuinst.*//" \
   | sed -e "s/.*://" > reqs.txt \
  && cat development.txt >> reqs.txt \
  && echo pyvirtualdisplay >> reqs.txt \
  && mamba create -y -n fsfp-${BRANCH}-env --file reqs.txt \
  && conda clean --all \
  && rm reqs.txt \
  && cp /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh 

# execute /etc/profile also in non-interactive use
ENV BASH_ENV /etc/profile.d/conda.sh
# default command to start when run
CMD [ "/bin/bash", "--login" ]
