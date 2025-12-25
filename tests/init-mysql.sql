-- Initialize multiple test databases
CREATE DATABASE IF NOT EXISTS test_db1;
CREATE DATABASE IF NOT EXISTS test_db2;
CREATE DATABASE IF NOT EXISTS test_db3;

-- Add test data to test_db1
USE test_db1;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Johnson', 'bob@example.com');

-- Add test data to test_db2
USE test_db2;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0
);

INSERT INTO products (product_name, price, stock) VALUES
    ('Laptop', 999.99, 10),
    ('Mouse', 29.99, 50),
    ('Keyboard', 79.99, 30);

-- Add test data to test_db3
USE test_db3;
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending'
);

INSERT INTO orders (order_number, total, status) VALUES
    ('ORD-001', 1109.97, 'completed'),
    ('ORD-002', 29.99, 'pending'),
    ('ORD-003', 79.99, 'shipped');
