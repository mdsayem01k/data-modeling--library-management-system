-- =============================================
-- Library Management System Database Scripts
-- MSSQL Server Implementation
-- =============================================
-- 1. DATABASE CREATION WITH FILEGROUPS
-- =============================================

-- ===================================================================================
/*
    PRIMARY: For system objects
    LibraryMS_Data: For main data tables
    LibraryMS_Index: For indexes to improve performance
    LibraryMS_Archive: For historical/archived data
    LibraryMS_InMemory: For memory-optimized tables
*/
-- ===================================================================================

USE master;
GO

-- Drop database if it exists
-- DROP DATABASE LibraryManagementSystem;

-- Create the database with multiple filegroups
CREATE DATABASE LibraryManagementSystem
ON PRIMARY
(
    NAME = 'LibraryMS_Primary',
    FILENAME = 'D:\SQLData\LibraryMS_Primary.mdf',
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 25MB
),
FILEGROUP LibraryMS_Data
(
    NAME = 'LibraryMS_Data',
    FILENAME = 'D:\SQLData\LibraryMS_Data.ndf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
),
FILEGROUP LibraryMS_Index
(
    NAME = 'LibraryMS_Index',
    FILENAME = 'D:\SQLData\LibraryMS_Index.ndf',
    SIZE = 50MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 25MB
),
FILEGROUP LibraryMS_Archive
(
    NAME = 'LibraryMS_Archive',
    FILENAME = 'D:\SQLData\LibraryMS_Archive.ndf',
    SIZE = 200MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
)
LOG ON
(
    NAME = 'LibraryMS_Log',
    FILENAME = 'D:\SQLData\LibraryMS_Log.ldf',
    SIZE = 50MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 25MB
);
GO

-- Add memory-optimized filegroup
ALTER DATABASE LibraryManagementSystem
    ADD FILEGROUP LibraryMS_InMemory CONTAINS MEMORY_OPTIMIZED_DATA;
GO

ALTER DATABASE LibraryManagementSystem
ADD FILE 
(
    NAME = 'LibraryMS_InMemory',
    FILENAME = 'D:\SQLData\LibraryMS_InMemory'
)
TO FILEGROUP LibraryMS_InMemory;
GO

-- Enable memory-optimized features
ALTER DATABASE LibraryManagementSystem SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO

-- Set the database to use
USE LibraryManagementSystem;
GO