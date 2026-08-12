/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: 03_Importacion_Datos.sql

    DESCRIPCIÓN:
    Importación de los archivos CSV del dataset Olist
    Brazilian E-Commerce hacia SQL Server.

    MOTOR:
    Microsoft SQL Server

    NOTAS:
    - Los archivos deben encontrarse en la ruta indicada.
    - Se utiliza CODEPAGE 65001 para archivos UTF-8.
    - Los archivos CSV utilizan coma (,) como separador,
      excepto Order_reviews, cuyo archivo utilizado para
      la carga final utiliza punto y coma (;).
============================================================*/


USE OlistDB;
GO


/*============================================================
    1. CUSTOMERS
============================================================*/

BULK INSERT dbo.Customers
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_customers_dataset.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    2. PRODUCTS
============================================================*/

BULK INSERT dbo.Products
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_products_dataset.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    3. SELLERS
============================================================*/

BULK INSERT dbo.Sellers
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_sellers_dataset.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    4. GEOLOCATION
============================================================*/

BULK INSERT dbo.Geolocation
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_geolocation_dataset.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    5. PRODUCT CATEGORY TRANSLATION
============================================================*/

BULK INSERT dbo.Product_Category_Translation
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\product_category_name_translation.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    6. ORDERS
============================================================*/

BULK INSERT dbo.Orders
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_orders_dataset.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);
GO


/*============================================================
    7. ORDER ITEMS
============================================================*/

BULK INSERT dbo.Order_Items
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_order_items_dataset.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO


/*============================================================
    8. ORDER PAYMENTS
============================================================*/

BULK INSERT dbo.Order_Payments
FROM 'C:\Olist-SQL-PowerBI-Project\dataset\olist_order_payments_dataset.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO


/*============================================================
    9. ORDER REVIEWS
============================================================

    IMPORTANTE:

    El archivo de Order Reviews utilizado durante el proyecto
    utiliza ';' como separador.

    Además, las fechas originales presentan el formato:

        dd/mm/yyyy hh:mm

    Por este motivo, el archivo fue preparado previamente
    para poder realizar la carga hacia las columnas DATETIME.

============================================================*/


BULK INSERT dbo.Order_reviews
FROM 'C:\Olist-SQL-PowerBI-Project\olist_order_reviews_dataset.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO


/*============================================================
    10. VALIDACIÓN DE LA IMPORTACIÓN
============================================================*/

SELECT 'Customers' AS Tabla, COUNT(*) AS Registros
FROM dbo.Customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM dbo.Products

UNION ALL

SELECT 'Sellers', COUNT(*)
FROM dbo.Sellers

UNION ALL

SELECT 'Geolocation', COUNT(*)
FROM dbo.Geolocation

UNION ALL

SELECT 'Product_Category_Translation', COUNT(*)
FROM dbo.Product_Category_Translation

UNION ALL

SELECT 'Orders', COUNT(*)
FROM dbo.Orders

UNION ALL

SELECT 'Order_Items', COUNT(*)
FROM dbo.Order_Items

UNION ALL

SELECT 'Order_Payments', COUNT(*)
FROM dbo.Order_Payments

UNION ALL

SELECT 'Order_reviews', COUNT(*)
FROM dbo.Order_reviews;
GO