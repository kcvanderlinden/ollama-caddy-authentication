FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y wget jq curl

# Download and install the latest Caddy
RUN LATEST_CADDY_URL=$(wget -qO- "https://api.github.com/repos/caddyserver/caddy/releases/latest" | jq -r 'assets[] | select(.name | endswith("_linux_amd64.tar.gz")).browser_download_url') \    
    && wget --no-check-certificate "$LATEST_CADDY_URL" -O caddy.tar.gz \
    && tar -xvf caddy.tar.gz -C /usr/bin caddy \
    && chown root:root /usr/bin/caddy \
    && chmod 755 /usr/bin/caddy

# Copy the Caddyfile and .env.local to the container
COPY Caddyfile /etc/caddy/Caddyfile

# Set the environment variable for the API-key
ENV OLLAMA_API_KEY=<your api key>
ENV OLLAMA_ENDPOINT=<endpoint to you ollama (including :11434)>

# Load environment variables from the .env.local file
RUN echo "source /etc/caddy/.env.local" >> /root/.bashrc

# Expose the port that Caddy will listen on
EXPOSE 80

# Copy a script to start both Ollama and Caddy
COPY start_services.sh /start_services.sh

# Set the entrypoint to the script
ENTRYPOINT [caddy run --config /etc/caddy/Caddyfile]