-- =========================================
-- Innovatech App - Script de Inicialización
-- =========================================
-- Este script se ejecuta automáticamente al crear el contenedor de MySQL
-- por primera vez gracias al bind mount en docker-compose.yml

-- Seleccionar base de datos
USE innovatech;

-- =========================================
-- Tabla: users
-- =========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- Tabla: products
-- =========================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- Tabla: orders
-- =========================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- Tabla: order_items
-- =========================================
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================
-- DATOS DE PRUEBA (Seeding)
-- =========================================

-- Insertar usuarios de ejemplo
INSERT INTO users (name, email, password) VALUES
    ('Juan Pérez', 'juan@innovatech.com', '$2b$10$dummy.hash.for.testing'),
    ('María García', 'maria@innovatech.com', '$2b$10$dummy.hash.for.testing'),
    ('Carlos López', 'carlos@innovatech.com', '$2b$10$dummy.hash.for.testing'),
    ('Ana Martínez', 'ana@innovatech.com', '$2b$10$dummy.hash.for.testing'),
    ('Luis Rodríguez', 'luis@innovatech.com', '$2b$10$dummy.hash.for.testing')
ON DUPLICATE KEY UPDATE name=name;

-- Insertar productos de ejemplo
INSERT INTO products (name, description, price, stock, category) VALUES
    ('Laptop Dell XPS 13', 'Ultrabook premium con procesador Intel i7', 1299.99, 15, 'Laptops'),
    ('Mouse Logitech MX Master 3', 'Mouse inalámbrico ergonómico para productividad', 99.99, 50, 'Accesorios'),
    ('Teclado Mecánico Keychron K2', 'Teclado mecánico inalámbrico con switches Gateron', 79.99, 30, 'Accesorios'),
    ('Monitor LG UltraWide 34"', 'Monitor curvo 21:9 para multitarea', 599.99, 10, 'Monitores'),
    ('Webcam Logitech C920', 'Cámara HD 1080p para videoconferencias', 79.99, 25, 'Accesorios'),
    ('MacBook Pro 14"', 'Laptop profesional con chip M3 Pro', 1999.99, 8, 'Laptops'),
    ('Auriculares Sony WH-1000XM5', 'Auriculares con cancelación de ruido', 349.99, 20, 'Audio'),
    ('SSD Samsung 1TB', 'Unidad de estado sólido NVMe Gen4', 119.99, 40, 'Almacenamiento'),
    ('Mochila para Laptop', 'Mochila resistente al agua con compartimento acolchado', 49.99, 60, 'Accesorios'),
    ('Hub USB-C Anker', 'Hub 7 en 1 con HDMI, USB-A y lector SD', 59.99, 35, 'Accesorios')
ON DUPLICATE KEY UPDATE name=name;

-- Insertar órdenes de ejemplo
INSERT INTO orders (user_id, total, status) VALUES
    (1, 1299.99, 'completed'),
    (2, 179.98, 'processing'),
    (3, 599.99, 'pending'),
    (1, 429.98, 'completed'),
    (4, 1999.99, 'processing')
ON DUPLICATE KEY UPDATE status=status;

-- Insertar items de órdenes
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
    -- Orden 1
    (1, 1, 1, 1299.99),
    -- Orden 2
    (2, 2, 1, 99.99),
    (2, 3, 1, 79.99),
    -- Orden 3
    (3, 4, 1, 599.99),
    -- Orden 4
    (4, 7, 1, 349.99),
    (4, 3, 1, 79.99),
    -- Orden 5
    (5, 6, 1, 1999.99)
ON DUPLICATE KEY UPDATE quantity=quantity;

-- =========================================
-- Verificación de datos insertados
-- =========================================

-- Mostrar resumen de datos
SELECT 
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items;

-- =========================================
-- Script completado exitosamente
-- =========================================
SELECT '✅ Base de datos inicializada correctamente' AS status;
