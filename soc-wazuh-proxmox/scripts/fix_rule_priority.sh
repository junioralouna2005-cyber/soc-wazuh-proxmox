#!/bin/bash
# =====================================================================
# fix_rule_priority.sh — Corrige le rattachement (if_sid) d'une règle
# personnalisée à une règle native Wazuh, pour résoudre les conflits
# de priorité du moteur de corrélation (une seule règle gagnante
# par événement).
#
# Usage : ./fix_rule_priority.sh <rule_id> <old_parent_sid> <new_parent_sid>
# Exemple : ./fix_rule_priority.sh 100230 31108 31106
# =====================================================================

set -e

RULE_ID="$1"
OLD_SID="$2"
NEW_SID="$3"
RULES_FILE="/var/ossec/etc/rules/local_rules.xml"

if [ -z "$RULE_ID" ] || [ -z "$OLD_SID" ] || [ -z "$NEW_SID" ]; then
  echo "Usage : $0 <rule_id> <old_parent_sid> <new_parent_sid>"
  exit 1
fi

# 1. Sauvegarde avant modification
./backup_rules.sh

# 2. Correction ciblée par expression régulière (évite une réécriture manuelle risquée)
sudo sed -i "/id=\"${RULE_ID}\"/,/<\/rule>/ s|<if_sid>${OLD_SID}<\/if_sid>|<if_sid>${NEW_SID}<\/if_sid>|" "$RULES_FILE"

# 3. Rechargement du moteur de règles
sudo systemctl restart wazuh-manager

echo "Règle ${RULE_ID} rattachée à ${NEW_SID} (était ${OLD_SID}). Manager redémarré."
echo "Valider avec : sudo /var/ossec/bin/wazuh-logtest"
