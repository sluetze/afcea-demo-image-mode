# text based install
graphical

# generic network config
network --bootproto=dhcp --device=link --activate

# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
reqpart --add-boot
part / --grow --fstype xfs

# Here's where we reference the container image to install - notice the kickstart
# has no `%packages` section!  What's being installed here is a container image.
ostreecontainer --url quay.io/[my_account]/lamp-bootc:latest

firewall --disabled
services --enabled=sshd

# optionally add a user
user --name=lab-user --groups=wheel --plaintext --password=lb1506
sshkey --username lab-user "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJvvCCozfyPpfbRXa5Ky8+J3F9FUEe10Z0xKqpWMDU3 sluetzen@sluetzen-mac"

# if desired, inject a SSH key for root
rootpw lb1506
sshkey --username root "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJvvCCozfyPpfbRXa5Ky8+J3F9FUEe10Z0xKqpWMDU3 sluetzen@sluetzen-mac" #paste your ssh key here
poweroff
