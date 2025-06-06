BEGIN
    CREATE TABLE cars (
        id INT IDENTITY(1,1) PRIMARY KEY,
        make VARCHAR(50) NOT NULL,
        model VARCHAR(50) NOT NULL,
        year INT NOT NULL,
        color VARCHAR(30) NOT NULL,
        mileage INT NOT NULL,
        price DECIMAL(10,2) NOT NULL
    );
END;
