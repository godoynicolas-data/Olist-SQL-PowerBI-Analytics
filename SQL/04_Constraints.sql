/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: 04_Constraints.sql

    DESCRIPCIÓN:
    Creación de restricciones adicionales para garantizar
    la integridad y calidad de los datos.

    IMPORTANTE:
    Las PRIMARY KEY y FOREIGN KEY principales ya fueron
    creadas en 02_Creacion_Tablas.sql.

    MOTOR:
    Microsoft SQL Server
============================================================*/


USE OlistDB;
GO


/*============================================================
    1. CUSTOMERS
============================================================

    Un customer_unique_id representa al cliente real dentro
    de la plataforma.

    El mismo cliente puede tener diferentes customer_id
    debido a que un customer_id representa una relación
    específica con un pedido.
    
    Por este motivo NO se agrega UNIQUE sobre
    customer_unique_id.
============================================================*/


/*============================================================
    2. PRODUCTS
============================================================

    Validación de características físicas del producto.
============================================================*/

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Weight
CHECK (product_weight_g >= 0);
GO

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Length
CHECK (product_length_cm >= 0);
GO

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Height
CHECK (product_height_cm >= 0);
GO

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Width
CHECK (product_width_cm >= 0);
GO

ALTER TABLE Products
ADD CONSTRAINT CK_Products_Photos
CHECK (product_photos_qty >= 0);
GO


/*============================================================
    3. ORDERS
============================================================

    Validación del estado del pedido.
============================================================*/

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_Status
CHECK
(
    order_status IN
    (
        'delivered',
        'shipped',
        'canceled',
        'invoiced',
        'processing',
        'approved',
        'created',
        'unavailable'
    )
);
GO


/*============================================================
    4. ORDER ITEMS
============================================================

    El precio y el valor del flete no pueden ser negativos.
============================================================*/

ALTER TABLE Order_Items
ADD CONSTRAINT CK_OrderItems_Price
CHECK (price >= 0);
GO

ALTER TABLE Order_Items
ADD CONSTRAINT CK_OrderItems_Freight
CHECK (freight_value >= 0);
GO

ALTER TABLE Order_Items
ADD CONSTRAINT CK_OrderItems_ItemID
CHECK (order_item_id >= 1);
GO


/*============================================================
    5. ORDER PAYMENTS
============================================================

    Validación de valores relacionados con los pagos.
============================================================*/

ALTER TABLE Order_Payments
ADD CONSTRAINT CK_OrderPayments_Value
CHECK (payment_value >= 0);
GO

ALTER TABLE Order_Payments
ADD CONSTRAINT CK_OrderPayments_Installments
CHECK (payment_installments >= 1);
GO

ALTER TABLE Order_Payments
ADD CONSTRAINT CK_OrderPayments_Sequential
CHECK (payment_sequential >= 1);
GO


/*============================================================
    6. ORDER REVIEWS
============================================================

    El puntaje de una reseña debe estar entre 1 y 5.
============================================================*/

ALTER TABLE Order_reviews
ADD CONSTRAINT CK_OrderReviews_Score
CHECK (review_score BETWEEN 1 AND 5);
GO


/*============================================================
    7. GEOLOCATION
============================================================

    Validación básica de coordenadas geográficas.

    Latitud:
        -90 a 90

    Longitud:
        -180 a 180
============================================================*/

ALTER TABLE Geolocation
ADD CONSTRAINT CK_Geolocation_Latitude
CHECK (geolocation_lat BETWEEN -90 AND 90);
GO

ALTER TABLE Geolocation
ADD CONSTRAINT CK_Geolocation_Longitude
CHECK (geolocation_lng BETWEEN -180 AND 180);
GO


/*============================================================
    8. SELLERS
============================================================

    Validación del código postal.
============================================================*/

ALTER TABLE Sellers
ADD CONSTRAINT CK_Sellers_ZipCode
CHECK
(
    LEN(seller_zip_code_prefix) BETWEEN 1 AND 5
);
GO


/*============================================================
    9. CUSTOMERS
============================================================

    Validación del código postal.
============================================================*/

ALTER TABLE Customers
ADD CONSTRAINT CK_Customers_ZipCode
CHECK
(
    LEN(customer_zip_code_prefix) BETWEEN 1 AND 5
);
GO


/*============================================================
    10. VALIDACIÓN DE CONSTRAINTS
============================================================

    Consulta para comprobar las restricciones creadas
    en la base de datos.
============================================================*/

SELECT
    name AS ConstraintName,
    type_desc AS ConstraintType,
    OBJECT_NAME(parent_object_id) AS TableName
FROM sys.objects
WHERE type = 'C'
ORDER BY TableName, ConstraintName;
GO