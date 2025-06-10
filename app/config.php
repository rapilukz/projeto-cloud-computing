<?php
$connectionString = getenv('SQLAZURECONNSTR_DefaultConnection');

// Converte "Server=...;Database=...;User ID=...;Password=...;..." em array
$connParts = explode(';', $connectionString);
foreach ($connParts as $part) {
    if (strpos($part, '=') !== false) {
        list($key, $val) = explode('=', $part, 2);
        $conn[trim($key)] = trim($val);
    }
}

$server   = $conn['Server'];
$database = $conn['Database'];
$user     = $conn['User ID'];
$pass     = $conn['Password'];

try {
    $dsn = "sqlsrv:Server=$server;Database=$database";
    $pdo = new PDO($dsn, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Falha na conexão: " . $e->getMessage());
}
