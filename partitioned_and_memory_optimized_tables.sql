-- =============================================
-- LibraryMS: Partitioned and Memory-Optimized Tables
-- =============================================

USE LibraryManagementSystem;
GO

-- Enable snapshot access for memory-optimized tables
ALTER DATABASE LibraryManagementSystem SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO

-- Create memory-optimized table for Notifications
CREATE TABLE NotificationsMemory (
    NotificationID INT NOT NULL PRIMARY KEY NONCLUSTERED,
    MemberID INT NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Message NVARCHAR(255),
    DateSent DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

-- Create partition function for Loans table based on date ranges
CREATE PARTITION FUNCTION LoanDateRangePF (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2023-01-01', 
    '2024-01-01', 
    '2025-01-01',
    '2026-01-01'
);
GO

-- Create partition scheme that maps function to filegroups
CREATE PARTITION SCHEME LoanDateRangePS
AS PARTITION LoanDateRangePF
TO (
    LibraryMS_Archive, -- Before 2023
    LibraryMS_Archive, -- 2023
    LibraryMS_Data,    -- 2024
    LibraryMS_Data,    -- 2025
    LibraryMS_Data     -- 2026 and beyond
);
GO

-- Create a partitioned Loans table using partition scheme
CREATE TABLE LoansPartitioned (
    LoanID INT PRIMARY KEY IDENTITY,
    BookID INT,
    MemberID INT,
    IssueDate DATE,
    IssueYear AS YEAR(IssueDate) PERSISTED,
    DueDate DATE,
    ReturnDate DATE,
    FineAmount DECIMAL(10,2),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
) ON LoanDateRangePS(IssueDate);
GO
sS