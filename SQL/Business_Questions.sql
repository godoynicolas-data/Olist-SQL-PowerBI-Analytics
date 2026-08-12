/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: Business_Questions.sql

    DESCRIPCIÓN:
    Consultas SQL orientadas a responder preguntas de negocio
    utilizando el dataset Brazilian E-Commerce by Olist.

    Las consultas buscan obtener información relevante sobre:

        1. Evolución de ventas
        2. Categorías más importantes por estado
        3. Relación entre entregas y satisfacción
        4. Clientes recurrentes
        5. Métodos de pago

    BASE DE DATOS:
    OlistDB

    MOTOR:
    Microsoft SQL Server
============================================================*/


USE OlistDB;
GO


/*============================================================
    1. EVOLUCIÓN MENSUAL DE VENTAS
============================================================

    Pregunta de negocio:

    ¿Cómo evolucionaron las ventas totales mes a mes y cuál
    fue el porcentaje de crecimiento o decrecimiento respecto
    al mes anterior?

    Objetivo:
    Analizar la evolución temporal de las ventas y detectar
    períodos de crecimiento o disminución.
============================================================*/

WITH MonthlySales AS
(
    SELECT
        CONVERT(
            CHAR(7),
            o.order_purchase_timestamp,
            120
        ) AS Periodo,

        SUM(oi.price) AS VentasTotales

    FROM Orders o

    INNER JOIN Order_Items oi
        ON o.order_id = oi.order_id

    GROUP BY
        CONVERT(
            CHAR(7),
            o.order_purchase_timestamp,
            120
        )
)

SELECT
    Periodo,

    VentasTotales,

    LAG(VentasTotales) OVER
    (
        ORDER BY Periodo
    ) AS VentasMesAnterior,

    ROUND
    (
        (
            VentasTotales
            -
            LAG(VentasTotales) OVER
            (
                ORDER BY Periodo
            )
        )
        * 100.0
        /
        NULLIF
        (
            LAG(VentasTotales) OVER
            (
                ORDER BY Periodo
            ),
            0
        ),
        2
    ) AS PorcentajeCrecimiento

FROM MonthlySales

ORDER BY Periodo;
GO


/*============================================================
    2. TOP 3 CATEGORÍAS POR ESTADO
============================================================

    Pregunta de negocio:

    En cada estado de Brasil (customer_state), ¿cuáles son
    las 3 categorías de productos que generan más ingresos?

    Objetivo:
    Identificar las categorías de mayor facturación en cada
    estado y detectar diferencias en el comportamiento
    comercial entre regiones.
============================================================*/

WITH SalesByState AS
(
    SELECT
        c.customer_state,

        pct.product_category_name_english AS Categoria,

        SUM(oi.price) AS Ingresos

    FROM Customers c

    INNER JOIN Orders o
        ON c.customer_id = o.customer_id

    INNER JOIN Order_Items oi
        ON o.order_id = oi.order_id

    INNER JOIN Products p
        ON oi.product_id = p.product_id

    INNER JOIN Product_Category_Translation pct
        ON p.product_category_name =
           pct.product_category_name

    GROUP BY
        c.customer_state,
        pct.product_category_name_english
),

Ranking AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_state
            ORDER BY Ingresos DESC
        ) AS Ranking

    FROM SalesByState
)

SELECT
    customer_state,
    Categoria,
    Ingresos,
    Ranking

FROM Ranking

WHERE Ranking <= 3

ORDER BY
    customer_state,
    Ranking;
GO


/*============================================================
    3. ENTREGA VS. SATISFACCIÓN DEL CLIENTE
============================================================

    Pregunta de negocio:

    ¿Cuál es la diferencia en el puntaje promedio de las
    reseñas entre los pedidos entregados a tiempo y los
    entregados tarde?

    Objetivo:
    Analizar si el cumplimiento de los tiempos de entrega
    está relacionado con la satisfacción del cliente.
============================================================*/

SELECT

    CASE

        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date

            THEN 'A tiempo'

        ELSE 'Con retraso'

    END AS EstadoEntrega,

    COUNT(*) AS TotalOrders,

    CAST
    (
        AVG
        (
            CAST
            (
                r.review_score
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,2)
    ) AS PuntajePromedioReseñas

FROM Orders o

INNER JOIN Order_reviews r
    ON o.order_id = r.order_id

WHERE
    o.order_delivered_customer_date IS NOT NULL

GROUP BY

    CASE

        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date

            THEN 'A tiempo'

        ELSE 'Con retraso'

    END;
GO


/*============================================================
    4. CLIENTES RECURRENTES
============================================================

    Pregunta de negocio:

    ¿Qué porcentaje de los clientes realizaron más de una
    compra en la plataforma y cuál es el tiempo promedio
    en días entre su primera y segunda compra?

    Objetivo:
    Medir la recurrencia de clientes y conocer cuánto tiempo
    tarda, en promedio, un cliente en volver a comprar.

    customer_unique_id representa al cliente real, mientras
    que customer_id identifica una relación específica
    dentro de la plataforma.
============================================================*/

WITH ComprasOrdenadas AS
(
    SELECT

        c.customer_unique_id,

        o.order_purchase_timestamp,

        ROW_NUMBER() OVER
        (
            PARTITION BY c.customer_unique_id

            ORDER BY o.order_purchase_timestamp

        ) AS NumeroCompra

    FROM Orders o

    INNER JOIN Customers c
        ON o.customer_id = c.customer_id
),

PrimeraSegundaCompra AS
(
    SELECT

        customer_unique_id,

        MAX
        (
            CASE
                WHEN NumeroCompra = 1
                    THEN order_purchase_timestamp
            END
        ) AS PrimeraCompra,

        MAX
        (
            CASE
                WHEN NumeroCompra = 2
                    THEN order_purchase_timestamp
            END
        ) AS SegundaCompra

    FROM ComprasOrdenadas

    GROUP BY
        customer_unique_id
)

SELECT

    COUNT(SegundaCompra) AS ClientesRecurrentes,

    (
        SELECT
            COUNT(DISTINCT customer_unique_id)

        FROM Customers
    ) AS TotalClientes,

    CAST
    (
        COUNT(SegundaCompra) * 100.0
        /
        (
            SELECT
                COUNT(DISTINCT customer_unique_id)

            FROM Customers
        )

        AS DECIMAL(5,2)
    ) AS PorcentajeClientesRecurrentes,

    CAST
    (
        AVG
        (
            DATEDIFF
            (
                DAY,
                PrimeraCompra,
                SegundaCompra
            )
        )

        AS DECIMAL(10,2)
    ) AS PromedioDiasEntreCompras

FROM PrimeraSegundaCompra;
GO


/*============================================================
    5. ANÁLISIS DE MÉTODOS DE PAGO
============================================================

    Pregunta de negocio:

    ¿Cómo se distribuyen las ventas según el método de pago
    utilizado por los clientes?

    Objetivo:
    Comparar los métodos de pago utilizados y analizar:

        - Cantidad de pedidos
        - Facturación total
        - Ticket promedio

    Esta información permite identificar los medios de pago
    más utilizados y su peso económico dentro de la plataforma.
============================================================*/

SELECT

    payment_type AS MetodoPago,

    COUNT(DISTINCT order_id) AS TotalPedidos,

    SUM(payment_value) AS FacturacionTotal,

    CAST
    (
        AVG(payment_value)
        AS DECIMAL(10,2)
    ) AS TicketPromedio

FROM Order_Payments

GROUP BY
    payment_type

ORDER BY
    FacturacionTotal DESC;
GO