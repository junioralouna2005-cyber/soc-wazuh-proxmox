# Configuration pfSense — Réseau isolé du laboratoire

## Interfaces
- **WAN** : accès via Tailscale (tunnel chiffré), pas d'exposition Internet directe
- **LAN** : `10.10.10.1/24` — passerelle du réseau isolé du laboratoire

## Règles de pare-feu (principe de moindre privilège)

| Source | Destination | Port / Protocole | Action |
|---|---|---|---|
| Internet (WAN) | Tout le réseau 10.10.10.0/24 | Tous ports | **Bloquer** (par défaut) |
| Poste admin (via Tailscale) | siem-web, toutes cibles | 22, 443, 3389, 8443 | Autoriser |
| kali-attack | app-linux, win10-target, winserver-target | Tous ports (test) | Autoriser (trafic de test Red Team) |
| Toutes les VM internes | Internet (WAN) | 80, 443 (mises à jour) | Autoriser |

## Plan d'adressage

| Machine | IP | Rôle |
|---|---|---|
| pfSense | 10.10.10.1 | Pare-feu / passerelle |
| siem-web | 10.10.10.100 | Wazuh Manager + Dashboard + Indexer |
| app-linux | 10.10.10.30 | Cible Linux + agent Wazuh + application web de test |
| kali-attack | 10.10.10.40 | Machine d'attaque (Red Team) |
| win10-target | 10.10.10.50 | Endpoint Windows 10 |
| winserver-target | 10.10.10.60 | Endpoint Windows Server 2019 |

## Dépendance critique

⚠️ **pfSense doit systématiquement être démarrée en premier.** Toute VM du laboratoire perd sa connectivité réseau tant que pfSense n'est pas opérationnelle (passerelle + DNS).

Ordre de démarrage recommandé :
```bash
qm start 102   # pfSense (en premier, toujours)
sleep 20
qm start 103   # siem-web
qm start 101   # app-linux
qm start 104   # kali-attack
qm start 105   # win10-target
qm start 106   # winserver-target
```
