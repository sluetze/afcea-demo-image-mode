## Prepare
depending on what you want to do, you might need some stuff from the makefile
`make setup`
`make templates`
`make vm-setup`

## Setup environment

```bash
export LIBVIRT_STORAGE_DIR=/var/lib/libvirt/images/summit-storage/
export LIBVIRT_QCOW_VM_NAME=qcow
export LIBVIRT_DEFAULT_URI="qemu:///system"
export LIBVIRT_NETWORK=summit-network
export CONTAINERFILE=Containerfile.containered
export CONTAINERFILE=Containerfile.containered-rhel
export CONTAINER=quay.io/sluetzen/bootc-imagerecognition:latest
```



## Create Container image
`podman build --file "${CONTAINERFILE}" --tag "${CONTAINER}"`

## Push Container Image to registry
`podman push "${CONTAINER}"`

`sudo podman pull "${CONTAINER}"`

## Create bootable image (qcow)
```bash
sudo podman run --rm -it --privileged \
        --pull newer \
        --authfile "/run/user/1000/containers/auth.json" \
        -v .:/output \
        -v /home/steffen/github/afcea-demo-image-mode/config/config-qcow2.json:/config.json \
        "registry.redhat.io/rhel9/bootc-image-builder:latest" \
        --type qcow2 \
        --config /config.json \
        --tls-verify=false \
        "${CONTAINER}"


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
```

## Create bootable image (iso)
```bash
sudo podman run --rm -it --privileged \
        --pull newer \
        --authfile "/run/user/1000/containers/auth.json" \
        -v .:/output \
        -v /home/steffen/github/afcea-demo-image-mode/config/config-iso.toml:/config.toml \
        -v "/var/lib/containers/storage:/var/lib/containers/storage" \
        "registry.redhat.io/rhel9/bootc-image-builder:latest" \
        --type anaconda-iso \
        --rootfs xfs \
        --config /config.toml \
        --use-librepo \
        --tls-verify=false \
        "${CONTAINER}"
```
