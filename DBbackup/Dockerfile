FROM quay.io/opsmxpublic/helm-bash:v4-yq-jq

RUN mkdir -p /home/opsmx/scripts
RUN git clone https://github.com/opsmx/enterprise-spinnaker /home/opsmx/scripts/
COPY *.sh /home/opsmx/scripts/
RUN chmod +x /home/opsmx/scripts/*
