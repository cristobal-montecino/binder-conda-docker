FROM fedora:33

RUN dnf update -y\
 && dnf install -y conda gcc

ARG ENV_DIR=/env
ENV ENV_DIR="${ENV_DIR}"

RUN mkdir "${ENV_DIR}"
WORKDIR "${ENV_DIR}"

RUN groupadd conda-app\
 && usermod -a -G conda-app root\
 && chgrp -R conda-app "${ENV_DIR}"\
 && chmod -R g+s "${ENV_DIR}"\
 && mkdir /app\
 && printf "#!/bin/bash\n\
cd \"${ENV_DIR}\"\n\
source /etc/profile.d/conda.sh\n\
/app/set-owner && chgrp -R conda-app \"${ENV_DIR}\"\n\
conda activate default\n\
exec \"\${@}\"\n"\
> /app/conda-run\
 && chgrp -R conda-app /app\
 && chmod 500 /app/conda-run

ENTRYPOINT ["/app/conda-run"]
CMD jupyter-lab --ip 0.0.0.0 --port 8888

# Binder arguments
ARG NB_USER="conda-user"
ARG NB_UID=1000

ENV USER="${NB_USER}"
ENV NB_UID="${NB_UID}"

RUN adduser --comment "Default user" --uid "${NB_UID}" "${USER}"\
 && usermod -a -G conda-app "${USER}"\
 && chown -R "${NB_UID}" "${ENV_DIR}"\
 && chown "${USER}" /app/conda-run\
 && printf "#include <stdlib.h>\n#include <unistd.h>\n#include <sys/types.h>\n\
int main() {\n\
setuid(geteuid());\n\
system(\"chown -R \\\\\"${NB_UID}\\\\\" \\\\\"${ENV_DIR}\\\\\"\");\n\
return 0;\n\
}"\
> /app/set-owner.c && gcc -O2 -o /app/set-owner /app/set-owner.c && rm /app/set-owner.c\
 && chown root /app/set-owner\
 && chgrp conda-app /app/set-owner\
 && chmod u=s,g=x,o= /app/set-owner

USER "${USER}"

COPY environment.yml .
RUN conda env create

USER root
COPY . .
RUN chown -R "${NB_UID}" "${ENV_DIR}" && chgrp -R conda-app "${ENV_DIR}"
USER "${USER}"
