<?php
require 'config.php';

$id = $_GET['id'] ?? null;
if (!$id) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "UPDATE cars SET make=?, model=?, year=?, color=?, country=?, price=? WHERE id=?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        $_POST['make'],
        $_POST['model'],
        $_POST['year'],
        $_POST['color'],
        $_POST['country'],
        $_POST['price'],
        $id
    ]);
    header('Location: index.php');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM cars WHERE id=?");
$stmt->execute([$id]);
$car = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$car) {
    die('Carro não encontrado');
}
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Editar Carro</title>
    <link rel="stylesheet" href="./styles/styles.css">
</head>

<body>
    <h1>Editar Carro #<?= htmlspecialchars($car['id']) ?></h1>
    <form class="form" method="post">
        <label>
            Marca:
            <input name="make" type="text" value="<?= htmlspecialchars($car['make']) ?>" required>
        </label>
        <br>

        <label>
            Modelo:
            <input name="model" type="text" value="<?= htmlspecialchars($car['model']) ?>" required>
        </label>
        <br>

        <label>
            Ano:
            <input name="year" type="number" value="<?= htmlspecialchars($car['year']) ?>" required>
        </label>
        <br>

        <label>
            Cor:
            <input name="color" type="text" value="<?= htmlspecialchars($car['color']) ?>" required>
        </label>
        <br>

        <label>
            País:
            <input name="country" type="text" value="<?= htmlspecialchars($car['country']) ?>" required>
        </label>
        <br>

        <label>
            Preço:
            <input name="price" type="number" step="0.01" value="<?= htmlspecialchars($car['price']) ?>" required>
        </label>
        <br><br>

        <div class="form-buttons">
            <button type="submit">Atualizar</button>
            <a class="secondary-button" href="index.php">Voltar</a>
        </div>
    </form>
</body>

</html>
