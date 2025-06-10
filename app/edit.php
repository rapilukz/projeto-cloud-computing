<?php
require 'config.php';
$id = $_GET['id'] ?? null;
if (!$id) header('Location: index.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "UPDATE cars SET make=?, model=?, year=?, color=?, price=? WHERE id=?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$_POST['make'], $_POST['model'], $_POST['year'], $_POST['color'], $_POST['price'], $id]);
    header('Location: index.php');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM cars WHERE id=?");
$stmt->execute([$id]);
$car = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$car) die('Carro não encontrado');
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Editar Carro</title>
</head>

<body>
    <h1>Editar Carro #<?= htmlspecialchars($car['id']) ?></h1>
    <form method="post">
        <label>Marca: <input name="make" value="<?= htmlspecialchars($car['make']) ?>" required></label><br>
        <label>Modelo: <input name="model" value="<?= htmlspecialchars($car['model']) ?>" required></label><br>
        <label>Ano: <input name="year" type="number" value="<?= htmlspecialchars($car['year']) ?>" required></label><br>
        <label>Cor: <input name="color" value="<?= htmlspecialchars($car['color']) ?>" required></label><br>
        <label>Preço: <input name="price" type="number" step="0.01" value="<?= htmlspecialchars($car['price']) ?>" required></label><br>
        <button type="submit">Atualizar</button>
    </form>
    <p><a href="index.php">Voltar</a></p>
</body>

</html>