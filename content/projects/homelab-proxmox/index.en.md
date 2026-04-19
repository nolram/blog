---
title: "Homelab with Proxmox, TrueNAS and self-hosted services"
date: 2026-04-05T10:00:00-03:00
draft: true
description: "How I built my homelab with a Proxmox VE server, TrueNAS Scale NAS, VLAN-segmented network and over 20 Docker containers managed by Portainer."
tags: ["homelab", "proxmox", "docker", "self-hosted", "linux"]
categories: ["projects"]
tech_stack: ["Proxmox VE", "TrueNAS Scale", "Docker", "Portainer", "Traefik", "Cloudflare Tunnels", "Ansible"]
github: "https://github.com/nolram/homelab"
status: "in-progress"
cover:
  image: "homelab-rack.jpg"
  alt: "Mini rack with Proxmox server and managed switch"
---

## Motivation

After years of relying on cloud services for everything — photos on Google Photos, files on Dropbox, passwords in LastPass — I decided to take back control of my data. The homelab started with an old recycled PC and today it's a mini rack with dedicated hardware.

## Current hardware

| Component | Spec |
|---|---|
| Server | Dell OptiPlex 7060 Micro (i7-8700T, 64GB DDR4) |
| NAS | Raspberry Pi 4 + 2x 8TB WD Red via USB 3.0 |
| Switch | MikroTik CRS326-24G-2S+RM |
| UPS | SMS Sinus 1500VA |

## Software stack

Proxmox hosts VMs and LXC containers. All services are containerized and exposed via Traefik with automatic TLS certificates from Let's Encrypt. External access is handled exclusively through **Cloudflare Tunnels** — no open ports on the router.

```bash
# Base server provisioning script via Ansible
ansible-playbook -i inventory/homelab.yml \
  playbooks/proxmox-bootstrap.yml \
  --tags "network,storage,security" \
  --ask-vault-pass
```

The Ansible inventory lives in the `nolram/homelab` repository alongside the roles for each service. Each service has its own `docker-compose.yml` with environment variables injected by Ansible Vault — no secret ever sits in plaintext in the repository.

```yaml
# Example: docker-compose.yml for Immich (replacing Google Photos)
services:
  immich-server:
    image: ghcr.io/immich-app/immich-server:release
    volumes:
      - /mnt/storage/photos:/usr/src/app/upload
    env_file: .env
    depends_on:
      - redis
      - database
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.immich.rule=Host(`photos.nolram.dev`)"
      - "traefik.http.routers.immich.tls.certresolver=cloudflare"
```

## Next steps

- Migrate the NAS from Raspberry Pi to an x86 machine running native TrueNAS Scale
- Implement monitoring with Grafana + Prometheus + Alertmanager
- Add automated off-site backup to Backblaze B2
