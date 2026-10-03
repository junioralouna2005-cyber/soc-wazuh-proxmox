#!/bin/bash
# =====================================================================
# deploy_webapp_test.sh — Déploie une mini-application web volontairement
# vulnérable (PHP + MariaDB) sur app-linux, pour valider les règles de
# détection applicatives (SQLi, brute force, path traversal, fichiers
# sensibles exposés).
#
# ⚠️ À exécuter UNIQUEMENT dans le réseau isolé du laboratoire.
# =====================================================================

set -e

echo "[1/5] Installation de PHP et MariaDB..."
sudo apt update
sudo apt install -y php libapache2-mod-php php-mysql mariadb-server

echo "[2/5] Création de la base de données de test..."
sudo mysql -e "
CREATE DATABASE IF NOT EXISTS testapp;
USE testapp;
CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50), password VARCHAR(50));
INSERT INTO users (username, password) VALUES ('admin', 'admin123');
CREATE USER IF NOT EXISTS 'webapp'@'localhost' IDENTIFIED BY 'webapp123';
GRANT ALL PRIVILEGES ON testapp.* TO 'webapp'@'localhost';
FLUSH PRIVILEGES;
"

echo "[3/5] Déploiement du formulaire de connexion vulnérable (SQLi, brute force)..."
sudo tee /var/www/html/login.php > /dev/null << 'PHPEOF'
<?php
$conn = new mysqli("localhost", "webapp", "webapp123", "testapp");
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user = $_POST['user'];
    $pass = $_POST['pass'];
    $sql = "SELECT * FROM users WHERE username='$user' AND password='$pass'";
    $result = $conn->query($sql);
    if ($result && $result->num_rows > 0) {
        echo "Login successful. Welcome $user.";
    } else {
        echo "Invalid credentials.";
    }
} else {
    echo '<form method="post">User: <input name="user"><br>Pass: <input name="pass" type="password"><br><input type="submit"></form>';
}
?>
PHPEOF

echo "[4/5] Déploiement de la page produit vulnérable (SQLi) et du téléchargement (path traversal)..."
sudo tee /var/www/html/item.php > /dev/null << 'PHPEOF'
<?php
$conn = new mysqli("localhost", "webapp", "webapp123", "testapp");
$id = $_GET['id'];
$sql = "SELECT * FROM users WHERE id=$id";
$result = $conn->query($sql);
if ($result) {
    while ($row = $result->fetch_assoc()) {
        echo "ID: " . $row['id'] . " - User: " . $row['username'] . "<br>";
    }
} else {
    echo "Error: " . $conn->error;
}
?>
PHPEOF

sudo tee /var/www/html/download.php > /dev/null << 'PHPEOF'
<?php
$file = $_GET['file'];
$path = "/var/www/html/files/" . $file;
if (file_exists($path)) {
    echo file_get_contents($path);
} else {
    echo "File not found.";
}
?>
PHPEOF

echo "[5/5] Exposition volontaire de fichiers sensibles (pour tester la règle 100240)..."
sudo mkdir -p /var/www/html/files
echo "Fichier de test normal" | sudo tee /var/www/html/files/readme.txt > /dev/null
echo "DB_PASSWORD=SuperSecret123" | sudo tee /var/www/html/.env > /dev/null
echo "<?php \$db_pass='old_secret_password'; ?>" | sudo tee /var/www/html/config.php.bak > /dev/null
sudo mkdir -p /var/www/html/.git
echo "ref: refs/heads/main" | sudo tee /var/www/html/.git/HEAD > /dev/null

sudo chown -R www-data:www-data /var/www/html/
sudo systemctl restart apache2

echo "=== Application web de test déployée avec succès ==="
