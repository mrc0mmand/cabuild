#
# fedpkg - Fedora Package Management Image
#
# A small fedora-based image to be used with `fedpkg` for package manegement
# purposes.
#
# Arguments:
#
#   * CAB_FROM="docker.io/library/fedora:latest"
#       This controls the host container used as base for the CI image.
#
#   * CAB_DNF_PACKAGES=""
#       Specify the packages to install into the container. Separate packages
#       by comma. By default, no package is pulled in.
#
#   * CAB_DNF_GROUPS=""
#       Specify the package groups to install into the container. Separate
#       groups by comma. By default, no group is pulled in.
#

ARG             CAB_FROM="docker.io/library/fedora:latest"
FROM            "${CAB_FROM}" AS target

#
# Import our build sources and prepare the target environment. When finished,
# we drop the build sources again, to keep the target image small.
#

WORKDIR         /cab
COPY            src src

ARG             CAB_DNF_PACKAGES=""
ARG             CAB_DNF_GROUPS=""
RUN             ./src/image-script/dnf.sh "${CAB_DNF_PACKAGES}" "${CAB_DNF_GROUPS}"

RUN             sed -i 's|default_ccache_name = KEYRING:.*$|default_ccache_name = FILE:/tmp/krb5keyring|' /etc/krb5.conf
RUN             git config --global --add safe.directory '*'

RUN             rm -rf /cab/src

#
# Rebuild from scratch to drop all intermediate layers and keep the final image
# as small as possible. Then setup the entrypoint.
#

FROM            scratch
COPY            --from=target . .

WORKDIR         /cab/workdir
