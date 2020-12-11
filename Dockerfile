FROM fedora:33

# Binder arguments
ARG NB_USER="conda-user"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV UID="${NB_UID}"

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN dnf update -y
RUN dnf install -y conda

RUN adduser --comment "Default user"\
    --uid "${UID}"\
    "${USER}"

RUN mkdir "${ENV_DIR}"
RUN chown -R "${USER}" "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

USER "${USER}"

COPY environment.yml .
RUN conda env create

USER root

# /root/run.sh
RUN printf "#!/bin/bash\n\
chown -R \"${USER}\" \"${ENV_DIR}\"\n\
sudo -u \"${USER}\" \"/home/${USER}/conda-run.sh\" \"\$@\"\n"\
> /root/run.sh\
&& chmod +x /root/run.sh

# /home/${USER}/conda.run.sh
RUN printf "#!/bin/bash\n\
cd \"${ENV_DIR}\"\n\
source /etc/profile.d/conda.sh\n\
conda activate default\n\
exec \"\$@\"\n"\
> "/home/${USER}/conda-run.sh"\
&& chown "${USER}" "/home/${USER}/conda-run.sh"\
&& chmod +x "/home/${USER}/conda-run.sh"

ENTRYPOINT ["/root/run.sh"]
CMD jupyter lab --ip 0.0.0.0 --port 8888
