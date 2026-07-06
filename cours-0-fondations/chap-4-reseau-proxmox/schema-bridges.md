# Schémas du chapitre 4 — à reproduire à l'écran

## Un bridge = un switch virtuel

```
              INTERNET
                 │
            ┌────┴────┐
            │ ta box  │
            └────┬────┘
                 │  câble (ou NAT VirtualBox)
   ══════════════╪══════════════════════════════════
   PROXMOX  ┌────┴────┐          ┌─────────┐
            │  vmbr0  │          │  vmbr1  │   ← 2 "switchs" virtuels
            │ (relié  │          │ (isolé, │
            │ au monde│          │  aucun  │
            │ réel)   │          │  câble) │
            └─┬─────┬─┘          └─┬─────┬─┘
              │     │              │     │
           ┌──┴──┐ ┌┴────┐      ┌──┴──┐ ┌┴────┐
           │ VM  │ │ VM  │      │ VM  │ │ VM  │
           │9001 │ │9002 │      │9101 │ │9102 │
           └─────┘ └─────┘      └─────┘ └─────┘
            a Internet           PAS d'Internet
                                 (et c'est voulu)
```

## Le nœud comme routeur entre segments

```
   vmbr1 (10.10.99.0/24)          vmbr2 (10.10.98.0/24)
        │                              │
   .254 └────────── PROXMOX ──────────┘ .254
                (ip_forward=1)
   Les VMs de vmbr1 joignent celles de vmbr2 en passant
   par le nœud — qui devient leur routeur.
```
