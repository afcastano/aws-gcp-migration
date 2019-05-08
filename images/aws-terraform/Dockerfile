# From https://github.com/mesosphere/aws-cli

FROM alpine:3.9

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

# Add Hashicorp terraform    
RUN apk add terraform

VOLUME /root/.aws
VOLUME /project
WORKDIR /project
CMD ["sh"]