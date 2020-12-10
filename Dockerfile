FROM fedora:33

ARG USER=user
ARG UID=1000
ENV USER=${USER}
ENV DEFAULT_DIR=/home/${USER}/env

RUN dnf update -y
RUN dnf install -y conda
RUN adduser ${USER}\
	--comment "Default user"\
	--uid ${UID}

USER user
RUN mkdir ${DEFAULT_DIR}
WORKDIR ${DEFAULT_DIR}

COPY environment.yml .
RUN conda env create

EXPOSE 8888

ENTRYPOINT ["conda", "run", "-n", "default"]
