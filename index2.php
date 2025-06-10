<?php
require 'config.php';
$stmt = $pdo->query("SELECT * FROM cars ORDER BY id");
$cars = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Lista de Carros</title>
    <link rel="stylesheet" href="./styles/styles.css">
</head>

<body>
    <h1>Carros</h1>
    <a href="./app/create.php">Adicionar Novo Carro</a>
    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th>
            <th>Marca</th>
            <th>Modelo</th>
            <th>Ano</th>
            <th>Cor</th>
            <th>Preço</th>
            <th>Ações</th>
        </tr>
        <?php foreach ($cars as $car): ?>
            <tr>
                <td><?= htmlspecialchars($car['id']) ?></td>
                <td><?= htmlspecialchars($car['make']) ?></td>
                <td><?= htmlspecialchars($car['model']) ?></td>
                <td><?= htmlspecialchars($car['year']) ?></td>
                <td><?= htmlspecialchars($car['color']) ?></td>
                <td><?= htmlspecialchars($car['price']) ?></td>
                <td>
                    <a href="./app/edit.php?id=<?= $car['id'] ?>">Editar</a> |
                    <a href="./app/delete.php?id=<?= $car['id'] ?>" onclick="return confirm('Tem certeza?');">Eliminar</a>
                </td>
            </tr>
        <?php endforeach; ?>
    </table>
</body>

</html>