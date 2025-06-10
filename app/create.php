<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "
        INSERT INTO cars
            (make, model, year, color, country, price)
        VALUES
            (?, ?, ?, ?, ?, ?)
    ";
    $stmt = $pdo->prepare($sql);

    try {
        $stmt->execute([
            $_POST['make'],
            $_POST['model'],
            $_POST['year'],
            $_POST['color'],
            $_POST['country'],
            $_POST['price']
        ]);

        header('Location: index.php');
        exit;
    } catch (PDOException $e) {
        echo "<h2>Database Insertion Error</h2>";
        echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
        exit;
    }
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
    <form class="form" method="post">
        <label>
            Marca:
            <input name="make" type="text" required>
        </label>
        <br>

        <label>
            Modelo:
            <input name="model" type="text" required>
        </label>
        <br>

        <label>
            Ano:
            <input name="year" type="number" required>
        </label>
        <br>

        <label>
            Cor:
            <input name="color" type="text" required>
        </label>
        <br>

        <label>
            País:
            <input name="country" type="text" required>
        </label>
        <br>

        <label>
            Preço:
            <input name="price" type="number" step="0.01" required>
        </label>
        <br><br>

        <div class="form-buttons">
            <button type="submit">Salvar</button>
            <a class="secondary-button" href="index.php">Voltar</a>
        </div>
    </form>
</body>

</html>