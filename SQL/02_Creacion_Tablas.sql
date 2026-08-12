/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: 02_Creacion_Tablas.sql

    DESCRIPCIÓN:
    Creación de las tablas principales utilizadas para el
    análisis del dataset Olist Brazilian E-Commerce.

    MOTOR:
    Microsoft SQL Server
============================================================*/


USE OlistDB;
GO


/*============================================================
    1. CUSTOMERS
    Información de los clientes.
============================================================*/

CREATE TABLE Customers
(
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(5) NULL,
    customer_city VARCHAR(100) NULL,
    customer_state CHAR(2) NULL
);
GO


/*============================================================
    2. PRODUCTS
    Información de los productos comercializados.
============================================================*/

CREATE TABLE Products
(
    product_id VARCHAR(50) NOT NULL,
    product_category_name VARCHAR(100) NULL,
    product_name_lenght INT NOT NULL,
    product_description_lenght INT NOT NULL,
    product_photos_qty INT NOT NULL,
    product_weight_g INT NOT NULL,
    product_length_cm INT NOT NULL,
    product_height_cm INT NOT NULL,
    product_width_cm INT NOT NULL,

    CONSTRAINT PK_Products
        PRIMARY KEY (product_id)
);
GO


/*============================================================
    3. SELLERS
    Información de los vendedores.
============================================================*/

CREATE TABLE Sellers
(
    seller_id VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(5) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL,

    CONSTRAINT PK_Sellers
        PRIMARY KEY (seller_id)
);
GO


/*============================================================
    4. GEOLOCATION
    Información geográfica asociada a códigos postales.
============================================================*/

CREATE TABLE Geolocation
(
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_lat DECIMAL(20,18) NOT NULL,
    geolocation_lng DECIMAL(20,18) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL
);
GO


/*============================================================
    5. PRODUCT CATEGORY TRANSLATION
    Traducción de categorías de productos del portugués
    al inglés.
============================================================*/

CREATE TABLE Product_Category_Translation
(
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Product_Category_Translation
        PRIMARY KEY (product_category_name)
);
GO


/*============================================================
    6. ORDERS
    Información principal de los pedidos.
============================================================*/

CREATE TABLE Orders
(
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NOT NULL,

    CONSTRAINT PK_Orders
        PRIMARY KEY (order_id),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
);
GO


/*============================================================
    7. ORDER ITEMS
    Productos incluidos en cada pedido.
============================================================*/

CREATE TABLE Order_Items
(
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Order_Items
        PRIMARY KEY (order_id, order_item_id),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    CONSTRAINT FK_OrderItems_Sellers
        FOREIGN KEY (seller_id)
        REFERENCES Sellers(seller_id)
);
GO


/*============================================================
    8. ORDER PAYMENTS
    Información de los métodos de pago utilizados
    en cada pedido.
============================================================*/

CREATE TABLE Order_Payments
(
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Order_Payments
        PRIMARY KEY (order_id, payment_sequential),

    CONSTRAINT FK_OrderPayments_Orders
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);
GO


/*============================================================
    9. ORDER REVIEWS
    Reseñas y puntuaciones realizadas por los clientes.

    NOTA:
    La clave primaria es compuesta por review_id + order_id
    debido a que el dataset contiene review_id repetidos.
============================================================*/

CREATE TABLE Order_reviews
(
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(500) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,

    CONSTRAINT PK_OrderReviews
        PRIMARY KEY (review_id, order_id),

    CONSTRAINT FK_OrderReviews_Orders
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);
GO