#!/bin/bash

# Get the current directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Read the configuration file from the script's directory
source "${SCRIPT_DIR}/config.conf"

# Create necessary folders
create_folders() {
  mkdir -p "${SCRIPT_DIR}/options" "${SCRIPT_DIR}/records" "${SCRIPT_DIR}/cache"
  echo "Created necessary folders: options, records, and cache."
}

# Generate the Docker Compose YAML content
generate_docker_compose_content() {
  cat <<EOF
version: '3.3'

services:
  bind9:
    container_name: dnsbind
    image: ubuntu/bind9:latest
    environment:
      - BIND9_USER=${BIND_USER}
      - TZ=${TZ}
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ${SCRIPT_DIR}/options/named.conf:/etc/bind/named.conf
      - ${SCRIPT_DIR}/options/zone-records:/var/lib/bind/zone-records
      - ${SCRIPT_DIR}/cache:/var/cache/bind
    restart: unless-stopped
EOF
}

# Generate the named.conf file content
generate_named_conf_content() {
  cat <<EOF
acl internal {
    ${PRIMARY_DNS_IP};
};

options {
    forwarders {
        ${DNS_RESOLVERS[0]}; // Use your preferred external DNS resolvers here
        ${DNS_RESOLVERS[1]};
    };
    allow-query { internal; };
};

zone "${DOMAIN_NAME}" IN {
    type master;
    file "/var/lib/bind/zone-records";  // Point to the zone-records file for zone data
};

\$TTL ${TTL}
@       IN SOA  ns1.${DOMAIN_NAME}. admin.${DOMAIN_NAME}. (
                    $(date +%Y%m%d01)  ; Serial
                    ${REFRESH}        ; Refresh
                    ${RETRY}          ; Retry
                    ${EXPIRE}         ; Expire
                    ${MINIMUM_TTL}    ; Minimum TTL
            )
;
@       IN NS   ns1.${DOMAIN_NAME}.
@       IN NS   ns2.${DOMAIN_NAME}.
ns1     IN A    ${PRIMARY_DNS_IP}
ns2     IN A    ${SECONDARY_DNS_IP}
EOF
}

# Generate the Docker Compose YAML file
generate_docker_compose_file() {
  generate_docker_compose_content > "${SCRIPT_DIR}/docker-compose.yml"
  echo "Generated docker-compose.yml file."
}

# Generate the named.conf file
generate_named_conf_file() {
  generate_named_conf_content > "${SCRIPT_DIR}/options/named.conf"
  echo "Generated named.conf file."
}

# Generate the zone-records file
generate_zone_records_file() {
  cat <<EOF > "${SCRIPT_DIR}/options/zone-records"
\$TTL ${TTL}
@       IN SOA  ns1.${DOMAIN_NAME}. admin.${DOMAIN_NAME}. (
                    $(date +%Y%m%d01)  ; Serial
                    ${REFRESH}        ; Refresh
                    ${RETRY}          ; Retry
                    ${EXPIRE}         ; Expire
                    ${MINIMUM_TTL}    ; Minimum TTL
            )
;
@       IN NS   ns1.${DOMAIN_NAME}.
@       IN NS   ns2.${DOMAIN_NAME}.
ns1     IN A    ${PRIMARY_DNS_IP}
ns2     IN A    ${SECONDARY_DNS_IP}
EOF
  echo "Generated zone-records file."
}

# Main function
main() {
  create_folders
  generate_docker_compose_file
  generate_named_conf_file
  generate_zone_records_file
}

# Run the main function
main
