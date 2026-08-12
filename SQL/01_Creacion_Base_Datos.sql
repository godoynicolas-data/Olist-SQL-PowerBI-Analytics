/*============================================================
    PROYECTO: Olist SQL + Power BI Analytics
    ARCHIVO: 01_Creacion_Base_Datos.sql

    DESCRIPCIÓN:
    Creación de la base de datos utilizada para el análisis
    del dataset Olist Brazilian E-Commerce.

    MOTOR:
    Microsoft SQL Server
============================================================*/


/*============================================================
     CREACIÓN DE LA BASE DE DATOS
============================================================*/

IF DB_ID('OlistDB') IS NULL
BEGIN
    CREATE DATABASE OlistDB;
END;
GO

