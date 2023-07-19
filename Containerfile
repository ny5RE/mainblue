ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG BASE_IMAGE="quay.io/fedora-ostree-desktops/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

####ADD build.sh /tmp/build.sh
####ADD post-install.sh /tmp/post-install.sh
####ADD packages.json /tmp/packages.json

####COPY --from=ghcr.io/ublue-os/config:latest /rpms /tmp/rpms
####COPY --from=ghcr.io/ublue-os/akmods:${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms

# Revert to older version of ostree to fix Flatpak installations
####RUN rpm-ostree override replace https://bodhi.fedoraproject.org/updates/FEDORA-2023-cab8a89753

####RUN /tmp/build.sh
####RUN /tmp/post-install.sh
####RUN rm -rf /tmp/* /var/*
####RUN ostree container commit
####RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp

COPY rootfs/ /

RUN rpm-ostree install gnome-tweaks && \
    systemctl enable dconf-update.service && \
    rm -rf /usr/share/gnome-shell/extensions/background-logo@fedorahosted.org && \
    systemctl enable flatpak-add-flathub-repo.service && \
    systemctl enable flatpak-replace-fedora-apps.service && \
    systemctl enable flatpak-cleanup.timer && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=check/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    rpm-ostree cleanup -m && \
    ostree container commit
