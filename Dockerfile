FROM fedora:33

RUN dnf update -y\
&&  dnf install -y conda

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN mkdir "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

# Binder arguments
ARG NB_USER="conda-user"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV UID="${NB_UID}"

RUN adduser --comment "Default user"\
    --uid "${UID}"\
    "${USER}"\
&&  chown -R "${USER}" "${ENV_DIR}"

USER "${USER}"

COPY environment.yml .
RUN conda env create
COPY . .

USER root

RUN printf "#!/bin/bash\n\
chown -R \"${USER}\" \"${ENV_DIR}\"\n\
sudo -u \"${USER}\" \"/home/${USER}/conda-run.sh\" \"\$@\"\n"\
> /root/run.sh\
&& chmod +x /root/run.sh\
&& printf "#!/bin/bash\n\
cd \"${ENV_DIR}\"\n\
source /etc/profile.d/conda.sh\n\
conda activate default\n\
exec \"\$@\"\n"\
> "/home/${USER}/conda-run.sh"\
&& chown "${USER}" "/home/${USER}/conda-run.sh"\
&& chmod +x "/home/${USER}/conda-run.sh"

USER "${USER}"

ENTRYPOINT ["conda", "run", "-n", "default"]
#CMD jupyter-lab --ip 0.0.0.0 --port 8888
