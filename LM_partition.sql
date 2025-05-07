-- =============================================
-- Library Management System Database Scripts
-- Partitioning and Memory-Optimized Tables
-- =============================================

USE LibraryManagementSystem;
GO

-- 1. PARTITION FUNCTIONS AND SCHEMES
-- =============================================

-- Create a partition function for loans based on date
CREATE PARTITION FUNCTION LoanDateRangePF (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2023-01-01', 
    '2024-01-01', 
    '2025-01-01',
    '2026-01-01'
);
GO

-- Create a partition scheme that maps the partition function to filegroups
CREATE PARTITION SCHEME LoanDateRangePS
AS PARTITION LoanDateRangePF
TO (
    LibraryMS_Archive, -- Before 2023s
    LibraryMS_Archive, -- 2023
    LibraryMS_Data,    -- 2024
    LibraryMS_Data,    -- 2025
    LibraryMS_Data     -- 2026 and later
);
GO

-- 2. PARTITIONED LOANS TABLE
-- =============================================
-- Create Loans table with partitioning on IssueDate
CREATE TABLE Loans (
    LoanID INT IDENTITY(1,1),
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    StaffID INT NOT NULL,
    IssueDate DATE NOT NULL DEFAULT GETDATE(),
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    FineAmount DECIMAL(10, 2) DEFAULT 0.00,
    -- Include IssueDate in the primary key for partitioning
    CONSTRAINT PK_Loans PRIMARY KEY NONCLUSTERED (LoanID, IssueDate),
    CONSTRAINT FK_Loans_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_Loans_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT FK_Loans_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
) ON LoanDateRangePS(IssueDate);
GO

-- Create other indexes for the Loans table
CREATE NONCLUSTERED INDEX IX_Loans_BookID ON Loans(BookID) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Loans_MemberID ON Loans(MemberID) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Loans_DueDate ON Loans(DueDate) ON LibraryMS_Index;
GO

-- 3. MEMORY-OPTIMIZED TABLES FOR REAL-TIME OPERATIONS
-- =============================================

-- Create a memory-optimized table for BookInventoryLogs
CREATE TABLE BookInventoryLogs (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    BookID INT NOT NULL,
    StaffID INT NOT NULL,
    ActionType NVARCHAR(20) NOT NULL CHECK (ActionType IN ('added', 'removed', 'damaged', 'relocated')),
    ActionDate DATETIME NOT NULL DEFAULT GETDATE(),
    Notes NVARCHAR(500),
    INDEX IX_BookInventoryLogs_BookID NONCLUSTERED (BookID),
    INDEX IX_BookInventoryLogs_ActionDate NONCLUSTERED (ActionDate),
    CONSTRAINT FK_BookInventoryLogs_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_BookInventoryLogs_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
) WITH (
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA
);
GO

-- Create memory-optimized Notifications table for real-time alerts
CREATE TABLE NotificationsMemory (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    MemberID INT NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Message NVARCHAR(255),
    DateSent DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_NotificationsMemory_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO