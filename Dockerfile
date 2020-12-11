FROM fedora:33

RUN dnf update -y\
&&  dnf install -y conda

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN mkdir "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

RUN printf "#!/bin/bash\n\
cd \"${ENV_DIR}\"\n\
source /etc/profile.d/conda.sh\n\
conda activate default\n\
exec \"\${@}\"\n"\
> "/usr/local/conda-run.sh"

# Binder arguments
ARG NB_USER="conda-user"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV UID="${NB_UID}"

RUN adduser --comment "Default user"\
    --uid "${UID}"\
    "${USER}"\
&&  chown -R "${UID}" "${ENV_DIR}"\
&&  chown "${UID}" "/usr/local/conda-run.sh"\
&&  chmod +x "/usr/local/conda-run.sh"

USER "${USER}"

COPY environment.yml .
RUN conda env create
COPY . .

ENTRYPOINT ["/usr/local/conda-run.sh"]
CMD jupyter-lab --ip 0.0.0.0 --port 8888
