<?php
require 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'] ?? null;
    if ($id) {
        $stmt = $pdo->prepare("DELETE FROM cars WHERE id=?");
        $stmt->execute([$id]);
    }
}

header('Location: index.php');
exit;
