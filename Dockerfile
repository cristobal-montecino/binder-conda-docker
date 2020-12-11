FROM fedora:33

RUN dnf update -y\
 && dnf install -y conda

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN mkdir "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

RUN printf "#!/bin/bash\n\
cd \"${ENV_DIR}\"\n\
source /etc/profile.d/conda.sh\n\
conda activate default\n\
exec \"\${@}\"\n"\
> "/usr/local/bin/conda-run"

ENTRYPOINT ["/usr/local/bin/conda-run"]
CMD jupyter-lab --ip 0.0.0.0 --port 8888

# Binder arguments
ARG NB_USER="conda-user"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV NB_UID="${NB_UID}"

RUN adduser --comment "Default user" --uid "${NB_UID}" "${USER}"\
 && chown -R "${NB_UID}" "${ENV_DIR}"\
 && chown "${NB_UID}" "/usr/local/bin/conda-run"\
 && chmod +x "/usr/local/bin/conda-run"

USER "${USER}"

COPY environment.yml .
RUN conda env create
COPY . .
