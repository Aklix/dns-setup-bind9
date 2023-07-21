# DNS Setup with BIND9 using Docker Compose

This repository contains scripts and configurations to set up a DNS server using BIND9 in Docker Compose. The setup includes a primary DNS server with a master zone configuration. The repository aims to simplify the process of configuring a DNS server for your domain.

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/ubuntu/) and Docker Compose installed on your server.
- Basic knowledge of DNS and domain configuration.

## Installation

1. Clone this repository to your server:
```bash
git clone https://github.com/aklix/dns-setup-bind9.git
cd dns-setup-bind9
```

2. Configure your DNS settings in the `config.conf` file:

```bash
# Define your DNS settings here
PRIMARY_DNS_IP="X.X.X.X"  # Replace with your primary DNS server's IP
SECONDARY_DNS_IP="Y.Y.Y.Y"  # Replace with your secondary DNS server's IP (if applicable)
DOMAIN_NAME="example.com"  # Replace with your domain name
DNS_RESOLVERS=("8.8.8.8" "8.8.4.4")  # Use your preferred external DNS resolvers
TTL="2d"  # Replace with your desired TTL (Time to Live) value
MINIMUM_TTL="2h"  # Replace with your desired minimum TTL value
EXPIRE="3w"  # Replace with your desired expiry time
REFRESH="12h"  # Replace with your desired refresh time
RETRY="1h"  # Replace with your desired retry time
TZ="Asia/Istanbul"  # Replace with your desired timezone
BIND_USER="root"  # Replace with the user under which BIND9 runs (optional)
```

3. Run the setup script to generate the necessary configuration files:

```bash
chmod +x generate_dns_files.sh
./generate_dns_files.sh
```
4. Start the BIND9 DNS server using Docker Compose:

```bash
sudo docker-compose up -d
```

# Usage

Once the DNS server is up and running, you can configure your domain registrar or hosting provider to point to your primary DNS server's IP address. The BIND9 DNS server will handle DNS queries for your domain and return the appropriate DNS records based on your zone configuration.
License

This project is licensed under the [MIT License](LICENSE).

# Contributing

Contributions to improve this project are welcome! If you encounter any issues or have suggestions for enhancements, feel free to open an issue or submit a pull request.