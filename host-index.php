<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $hostname = trim($_POST['hostname']);
    $port = trim($_POST['port']);
    $apikey = trim($_POST['apikey']);

    if($apikey != "s3cr3t") {
        die("Ungültiker API Key");
    }

    // Hostname validieren (nur Buchstaben, Zahlen und Bindestrich erlaubt)
    if (!preg_match('/^[a-zA-Z0-9\-]{1,30}$/', $hostname)) {
        die("Ungültiger Hostname.");
    }

    // Escapen, um Kommandoinjektion zu vermeiden
    $escapedHostname = escapeshellarg($hostname);

    // Aufruf des Shell-Skripts (dieses muss als root ausgeführt werden können)
    $output = shell_exec("sudo /home/manuel/docker-webhost/mkwebspace.sh $escapedHostname $port 2>&1");

    echo "<h2>Container-Erstellung abgeschlossen</h2>";
    echo "<pre>" . htmlspecialchars($output) . "</pre>";
} else {
    ?>

<center>

<h1>Kostenloses Webhosting</h1>
<p>Alpha Phase gestartet... API Key ben&ouml;tigt.</p>

    <form method="post">
        <label for="hostname">Hostname eingeben:</label>
        <input type="text" name="hostname" id="hostname" placeholder="hostname" required>
        <input type="text" name="port" id="port" placeholder="2201" required>
        <input type="password" name="apikey" id="apikey" required>
        <input type="submit" value="Container erstellen">
    </form>
    <?php
}
?>
