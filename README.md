# Ollama behind caddy authentications
**Goal**

The goal of this repository is to provide a simple and secure solution for handling incoming requests to an Ollama API by using Caddy as a reverse proxy.

## Installation

* clone the repo with ```git clone https://github.com/kcvanderlinden/ollama-caddy-authentication.git```
* The image installs necessary dependencies using `apt-get`.
* It downloads the latest version of Caddy from GitHub and extracts it to `/usr/bin`.

**Configuration**

* Copies a `Caddyfile` file into the container.
* Sets environment variables for Ollama API key and endpoint.

**Caddyfile Configuration**

The following Caddyfile configuration is used:
```
:8081 {
    # Define a matcher for authorized API access
    @apiAuth {
        header Authorization "Bearer {env.OLLAMA_API_KEY}"
    }

    # Proxy authorized requests
    reverse_proxy @apiAuth {env.OLLAMA_ENDPOINT} {
        header_up Host {http.reverse_proxy.upstream.hostport}
    }

    # Define a matcher for unauthorized access
    @unauthorized {
        not {
            header Authorization "Bearer {env.OLLAMA_API_KEY}"
        }
    }

    # Respond to unauthorized access
    respond @unauthorized "Unauthorized" 401 {
        close
    }
}
```
This Caddyfile configuration:

* Listens on port 8081 (or any available port)
* Checks for an `Authorization` header with a value in the format `Bearer <api-key>`
* If authorized, proxies requests to the Ollama API endpoint using the provided API key and endpoint
* If unauthorized, returns a 401 Unauthorized response

**Startup**

* Loads environment variables from the `.env.local` file at runtime.
* Exposes port 80 for Caddy to listen on.
* Copies a script (`start_services.sh`) to start both Ollama and Caddy services.
* Sets the entrypoint of the container to run `caddy` with the configuration file.

**Prerequisites**

* You must have a running ollama instance
* You must generate your own Ollama API key and provide it in the Dockerfile.
* The `Caddyfile` is required for configuring Caddy's behavior.

## Generating a secure API Key

To generate a secure API key, you can use a cryptographic random method. This ensures the key is both unique and secure. Make sure you have `openssl` installed on your machine. You can generate the key with the following one-liner, adjust the `sk-ollama-` prefix to whatever you want:

```bash
echo "sk-ollama-$(openssl rand -hex 16)"
```

This should generate something like this:

```bash
sk-ollama-78834bcb4c76d97d35a0c1acd0d938c6
```

## Credits

This repo is based on [ollama-bearer-auth](https://github.com/bartolli/ollama-bearer-auth/) by bartolli. With that repo, also ollama is installed. As I already have such an instance, I changed the code such that it works with an existing ollama instance.
