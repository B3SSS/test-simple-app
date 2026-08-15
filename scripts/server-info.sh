#!/bin/bash

diagnostics() {
    echo "=== Server Diagnostics ==="
    echo "Date    : $(date +"%F %T")"
    echo "Hostname: $(hostname -s)"
    echo "OS      : $(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)"
    echo "Kernel  : $(uname -r)"
    echo "Uptime  : " 
    echo ""
}

resources() {
    echo "=== Resources ==="
    echo "CPU   : $(nproc) cores, load average: $(awk '{print $1, $2, $3}' /proc/loadavg)"
    echo "RAM   : $(free -h | awk 'NR==2{printf "%s / %s (%.1f%%)\n", $3, $2, $3/$2*100}')"
    echo "Disk /: $(df -h / | awk 'NR==2{printf "%s / %s (%.1f%%)\n", $3, $2, $3/$2*100}')"
    echo ""
}

docker_containers() {
    echo "=== Docker ==="
    if [[ $(docker ps -q | wc -l) -eq 0 ]]; then
        echo "0 running containers"
    else
        docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
    fi
    echo ""
}

service_health_checks() {
    echo "=== Service Health Checks ==="

    echo "Result: m/n services healthy"   
}

show_help() {
    echo "Usage: $(basename "$0") [Options]"
    echo ""
    echo "Script for A lightweight script for quick system resource and Docker container monitoring."
    echo ""
    echo "Options:"
    echo "  --help      Show this help message and exit"
    exit 0
}

show_server_info() {
    for arg in "$@"; do
        if [[ "$arg" == "--help" ]]; then
            show_help
        fi
    done

    diagnostics
    resources
    docker_containers

    if [[ $# -ne 0 ]]; then
        service_health_checks
    fi
}

show_server_info "$@"
