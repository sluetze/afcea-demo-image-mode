export LIBVIRT_STORAGE_DIR=/var/lib/libvirt/images/summit-storage/
export LIBVIRT_QCOW_VM_NAME=qcow
export LIBVIRT_DEFAULT_URI="qemu:///system"
export LIBVIRT_NETWORK=summit-network
export CONTAINERFILE=Containerfile.containered
export CONTAINER=quay.io/sluetzen/bootc-imagerecognition:latest

## Create Container image
podman build --file "${CONTAINERFILE}" --tag "${CONTAINER}" \
        --build-arg SSHPUBKEY="$(shell cat ~/.ssh/id_rsa.pub)" 

## Push Container Image to registry
podman push "${CONTAINER}"

## Create bootable image (qcow)
sudo podman run --rm -it --privileged \
        --pull missing \
        --authfile "/run/user/1000/containers/auth.json" \
        -v .:/output \
        -v /home/steffen/github/afcea-demo-image-mode/config/config-qcow2.json:/config.json \
        "registry.redhat.io/rhel9/bootc-image-builder:latest" \
        --type qcow2 \
        --config /config.json \
        --tls-verify=false \
        "${CONTAINER}"

## Create bootable image (iso)
sudo podman run --rm -it --privileged \
        --pull missing \
        --authfile "/run/user/1000/containers/auth.json" \
        -v .:/output \
        -v /home/steffen/github/afcea-demo-image-mode/config/config-qcow2.json:/config.json \
        "registry.redhat.io/rhel9/bootc-image-builder:latest" \
        --type anaconda-iso \
        --config /config.json \
        --tls-verify=false \
        quay.io/sluetzen/bootc-imagerecognition:latest

sudo cp qcow2/disk.qcow2 ${LIBVIRT_STORAGE_DIR}/.

sudo qemu-img resize "${LIBVIRT_STORAGE_DIR}/disk.qcow2" 30G

virt-install --connect "${LIBVIRT_DEFAULT_URI}" \
--name "${LIBVIRT_QCOW_VM_NAME}" \
--disk "${LIBVIRT_STORAGE_DIR}/disk.qcow2" \
--import \
--network "network=${LIBVIRT_NETWORK},mac=de:ad:be:ef:01:03" \
--memory 4096 \
--graphics none \
--osinfo rhel9-unknown \
--noautoconsole \
--noreboot

virsh --connect "${LIBVIRT_DEFAULT_URI}" start "${LIBVIRT_QCOW_VM_NAME}"