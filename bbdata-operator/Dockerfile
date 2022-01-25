FROM flant/shell-operator:latest
RUN apk add --no-cache git && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.22.5/bin/linux/amd64/kubectl -O /bin/kubectl && \
    chmod +x /bin/kubectl
ADD hooks /hooks
ADD scripts /scripts
ADD templates /templates
