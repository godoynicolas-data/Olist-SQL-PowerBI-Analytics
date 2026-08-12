/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: 05_Views.sql

    DESCRIPCIÓN:
    Creación de la vista utilizada para analizar el intervalo
    de tiempo entre la primera y segunda compra de cada cliente.

    Esta vista fue utilizada posteriormente en Power BI para
    analizar el comportamiento de los clientes recurrentes.

    BASE DE DATOS:
    OlistDB

    MOTOR:
    Microsoft SQL Server
============================================================*/


USE OlistDB;
GO


/*============================================================
    VISTA: vw_CustomerPurchaseIntervals

    OBJETIVO:
    Identificar para cada cliente:

        - Primera compra
        - Segunda compra
        - Días transcurridos entre ambas compras

    La vista considera únicamente clientes que realizaron
    al menos dos compras.
============================================================*/

CREATE OR ALTER VIEW dbo.vw_CustomerPurchaseIntervals
AS

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

    customer_unique_id,

    PrimeraCompra,

    SegundaCompra,

    DATEDIFF
    (
        DAY,
        PrimeraCompra,
        SegundaCompra
    ) AS DiasEntreCompras

FROM PrimeraSegundaCompra

WHERE SegundaCompra IS NOT NULL;
GO


/*============================================================
    VALIDACIÓN DE LA VISTA
============================================================*/

SELECT TOP 20
    customer_unique_id,
    PrimeraCompra,
    SegundaCompra,
    DiasEntreCompras

FROM dbo.vw_CustomerPurchaseIntervals

ORDER BY DiasEntreCompras;
GO