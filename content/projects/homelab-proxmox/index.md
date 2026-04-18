---
title: "Homelab com Proxmox, TrueNAS e serviços auto-hospedados"
date: 2026-04-05T10:00:00-03:00
draft: true
description: "Como montei meu homelab com um servidor Proxmox VE, NAS com TrueNAS Scale, rede segmentada por VLANs e mais de 20 containers Docker gerenciados pelo Portainer."
tags: ["homelab", "proxmox", "docker", "self-hosted", "linux"]
categories: ["projects"]
tech_stack: ["Proxmox VE", "TrueNAS Scale", "Docker", "Portainer", "Traefik", "Cloudflare Tunnels", "Ansible"]
github: "https://github.com/nolram/homelab"
status: "in-progress"
cover:
  image: "homelab-rack.jpg"
  alt: "Mini rack com servidor Proxmox e switch gerenciável"
---

## Motivação

Depois de anos dependendo de serviços em nuvem para tudo — fotos no Google Photos, arquivos no Dropbox, senha no LastPass — decidi retomar o controle dos meus dados. O homelab começou com um velho PC reciclado e hoje é um mini rack com hardware dedicado.

## Hardware atual

| Componente | Especificação |
|---|---|
| Servidor | Dell OptiPlex 7060 Micro (i7-8700T, 64GB DDR4) |
| NAS | Raspberry Pi 4 + 2x 8TB WD Red via USB 3.0 |
| Switch | MikroTik CRS326-24G-2S+RM |
| UPS | SMS Sinus 1500VA |

## Stack de software

O Proxmox hospeda VMs e LXC containers. Os serviços são todos containerizados e expostos via Traefik com certificado TLS automático pelo Let's Encrypt. O acesso externo é feito exclusivamente via **Cloudflare Tunnels**, sem portas abertas no roteador.

```bash
# Script de provisionamento do servidor base via Ansible
ansible-playbook -i inventory/homelab.yml \
  playbooks/proxmox-bootstrap.yml \
  --tags "network,storage,security" \
  --ask-vault-pass
```

O inventário do Ansible fica no repositório `nolram/homelab` junto com os roles para cada serviço. Cada serviço tem seu próprio `docker-compose.yml` com variáveis de ambiente injetadas pelo Ansible Vault — nenhum secret fica em texto plano no repositório.

```yaml
# Exemplo: docker-compose.yml do Immich (substituindo Google Photos)
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

## Próximos passos

- Migrar o NAS do Raspberry Pi para uma máquina x86 com TrueNAS Scale nativo
- Implementar monitoramento com Grafana + Prometheus + Alertmanager
- Adicionar backup off-site automático para Backblaze B2
