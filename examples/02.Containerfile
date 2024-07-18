FROM registry.redhat.io/rhel9/rhel-bootc:9.4

COPY certs/004-summit.conf /etc/containers/registries.conf.d/004-summit.conf

RUN dnf install -y httpd
RUN echo "Hello Red Hat" > /var/www/html/index.html

RUN systemctl enable httpd.service

