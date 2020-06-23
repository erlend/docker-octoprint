FROM python:3.8-alpine

# Install build dependencies and any extra apks specified in EXTRA_BUILD_APKS
# and EXTRA_RUNTIME_APKS.
ARG EXTRA_BUILD_APKS
ARG EXTRA_RUNTIME_APKS
RUN apk add --no-cache \
      build-base \
      linux-headers \
      $EXTRA_BUILD_APKS \
      $EXTRA_RUNTIME_APKS

# Install OctoPrint and any other Python packages specified in EXTRA_PKGS
ARG EXTRA_PKGS
RUN pip install OctoPrint $EXTRA_PKGS

# Add octoprint user and group with values from the `OCTOPRINT_UID` and
# `OCTOPRINT_GID` arguments. Should the user or group already exist it will be
# removed first.
#
# The is also added to the tty and dialout groups to make sure it can access the
# serial ports.
ARG OCTOPRINT_UID=1000
ARG OCTOPRINT_GID=1000
RUN sed -i "/:$OCTOPRINT_GID:[^:]*/d" /etc/group && \
    addgroup -g $OCTOPRINT_GID octoprint && \
    sed -i "/\([^:]\+:\)\{2\}$OCTOPRINT_UID:/d" /etc/passwd && \
    adduser -D -G octoprint -u $OCTOPRINT_UID octoprint && \
    adduser octoprint tty && \
    adduser octoprint dialout

USER octoprint
ENTRYPOINT ["/usr/local/bin/octoprint"]
CMD ["serve"]
