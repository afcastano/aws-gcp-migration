# From https://github.com/mesosphere/aws-cli

FROM google/cloud-sdk:alpine

# Add common packages
RUN apk -v --update add \
        curl \
        unzip \
        build-base

# Add aws-cli
RUN apk add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

# Add gettext
RUN apk add \
        gettext \
        libintl

# Add Hashicorp terraform    
RUN apk add terraform

VOLUME /root/.aws
VOLUME /root/.gcp
VOLUME /project
WORKDIR /project
CMD ["sh"]