// File: delete.php
<?php
require 'config.php';
$id = $_GET['id'] ?? null;
if ($id) {
    $stmt = $pdo->prepare("DELETE FROM cars WHERE id=?");
    $stmt->execute([$id]);
}
header('Location: index.php');
exit;
?>