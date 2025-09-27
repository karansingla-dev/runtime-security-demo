FROM gitpod/workspace-full

USER root

# Install Docker Compose
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    apt-get install -y docker-compose

# Install additional tools
RUN apt-get update && apt-get install -y \
    jq \
    curl \
    postgresql-client \
    && apt-get clean

USER gitpod