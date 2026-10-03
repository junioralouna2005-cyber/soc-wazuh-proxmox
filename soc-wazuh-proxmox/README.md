# SOC — Projet de certification CPI

**Auteur :** Alouna Valentin Junior Emmanuel — Spécialisation SR / Cybersécurité (B4) — Ingétis

## 🎯 Objectif

Déploiement et validation offensive d'un SOC (Security Operations Center) complet, mené en autonomie : infrastructure Proxmox/pfSense, SIEM Wazuh, 15 règles de détection personnalisées, 5 playbooks de réponse à incident, et 10 scénarios Red Team validant chaque règle en conditions réelles.

## 📂 Structure du dépôt

| Dossier | Contenu |
|---|---|
| `/wazuh_rules/` | Fichier XML des 15 règles de détection personnalisées |
| `/scripts/` | Scripts shell d'automatisation (sauvegarde, correction de règles, déploiement de l'application de test) |
| `/configs/` | Configuration réseau pfSense et plan d'adressage |
| `/red_team/` | Commandes des 10 scénarios d'attaque de la campagne Red Team |

## 🏗️ Architecture

Réseau isolé `10.10.10.0/24`, hébergé sur un hyperviseur Proxmox VE, derrière un pare-feu pfSense. Six machines virtuelles : pfSense, siem-web (Wazuh), app-linux (cible), kali-attack (attaque), win10-target, winserver-target.

Schéma complet disponible dans le mémoire professionnel (Partie 3.1).

## ✅ Résultats

- **3/3** agents Wazuh actifs
- **15/15** règles de détection validées (méthode `wazuh-logtest` + attaque réelle)
- **10/10** scénarios Red Team validés
- **31** incidents techniques résolus et documentés en cours de projet

## 📄 Documents complémentaires

Ce dépôt accompagne les livrables suivants (non inclus ici, remis séparément) :
- Mémoire professionnel CPI (contient l'architecture détaillée, la méthodologie et l'analyse critique)
- 5 Playbooks de réponse à incident
- Rapport Red Team (captures de validation, matrice MITRE ATT&CK, analyse MTTD/MTTR)

## ⚠️ Avertissement

Tous les scripts et commandes de ce dépôt sont destinés exclusivement à un environnement de laboratoire isolé (réseau `10.10.10.0/24`). Ne jamais les exécuter en dehors de ce cadre sans autorisation explicite.
