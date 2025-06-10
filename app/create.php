<?php
require 'config.php';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "INSERT INTO cars (make, model, year, color, price) VALUES (?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$_POST['make'], $_POST['model'], $_POST['year'], $_POST['color'], $_POST['price']]);
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Adicionar Carro</title>
    <link rel="stylesheet" href="./styles/styles.css">
</head>

<body>
    <h1>Adicionar Carro</h1>
    <form method="post">
        <label>Marca: <input name="make" required></label><br>
        <label>Modelo: <input name="model" required></label><br>
        <label>Ano: <input name="year" type="number" required></label><br>
        <label>Cor: <input name="color" required></label><br>
        <label>Preço: <input name="price" type="number" step="0.01" required></label><br>
        <button type="submit">Salvar</button>
    </form>
    <p><a href="index.php">Voltar</a></p>
</body>

</html>