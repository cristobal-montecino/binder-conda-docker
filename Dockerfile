FROM fedora:33

RUN dnf update -y\
 && dnf install -y conda

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN mkdir "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

RUN groupadd conda-app\
 && usermod -a -G conda-app root\
 && chgrp conda-app "${ENV_DIR}"\
 && chmod g+s "${ENV_DIR}"\
 && mkdir /app\
 && chgrp conda-app /app

# Binder arguments
ARG NB_USER="jovyan"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV NB_UID="${NB_UID}"

RUN adduser --comment "Default user" --uid "${NB_UID}" "${NB_USER}"\
 && usermod -a -G conda-app "${NB_USER}"\
 && chown "${NB_UID}" "${ENV_DIR}"

USER "${NB_USER}"

COPY environment.yml .
RUN conda env create

USER root

RUN printf '#!/bin/bash\n\
cd "%s"\n\
source /etc/profile.d/conda.sh\n\
conda activate %s\n\
exec "${@}"\n'\
 "${ENV_DIR}"\
 "$(su "${NB_USER}" -c 'conda env list' | grep '/home' | head -n 1 | cut -d ' ' -f1)"\
> /app/conda-run\
 && chgrp conda-app /app/conda-run\
 && chmod 500 /app/conda-run\
 && chown "${NB_UID}" /app/conda-run

ENTRYPOINT ["/app/conda-run"]
CMD jupyter-lab --ip 0.0.0.0 --port 8888

COPY . .
RUN chown -R "${NB_UID}" "${ENV_DIR}" && chgrp -R conda-app "${ENV_DIR}"

USER "${NB_USER}"
RUN if [ -f postBuild ]; then\
 chmod ug+x ./postBuild\
 && echo 'postBuild found, executing'\
 && /app/conda-run ./postBuild;\
 else\
 echo 'no postBuild, omitting';\
 fi
