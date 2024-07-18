FROM registry.redhat.io/rhel9/rhel-bootc:9.4

COPY certs/004-summit.conf /etc/containers/registries.conf.d/004-summit.conf

ADD etc/ /etc

RUN dnf install -y httpd

RUN <<EOF
    mv /var/www /usr/share/www
    sed -i 's-/var/www-/usr/share/www-' /etc/httpd/conf/httpd.conf
EOF

RUN echo "Hello Red Hat Summit Connect 2024!!" > /usr/share/www/html/index.html

RUN systemctl enable httpd.service
