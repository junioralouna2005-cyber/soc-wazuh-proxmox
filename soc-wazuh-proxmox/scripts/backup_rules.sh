#!/bin/bash
# =====================================================================
# backup_rules.sh — Sauvegarde horodatée du fichier de règles Wazuh
# avant toute modification, pour permettre une restauration rapide
# en cas d'erreur.
# =====================================================================

RULES_FILE="/var/ossec/etc/rules/local_rules.xml"
BACKUP_FILE="${RULES_FILE}.before_$(date +%Y%m%d_%H%M%S)"

if [ ! -f "$RULES_FILE" ]; then
  echo "Erreur : fichier de règles introuvable ($RULES_FILE)"
  exit 1
fi

sudo cp "$RULES_FILE" "$BACKUP_FILE"
echo "Sauvegarde créée : $BACKUP_FILE"
