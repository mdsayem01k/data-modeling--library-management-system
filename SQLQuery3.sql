-- Set the database to use
USE LibraryManagementSystem;
GO

-- 2. CREATING PARTITION FUNCTION AND SCHEME FOR LOANS TABLE
-- =============================================
-- Create a partition function for loans based on year
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
    LibraryMS_Archive, -- Before 2023
    LibraryMS_Archive, -- 2023
    LibraryMS_Archive,    -- 2024
    LibraryMS_Data,    -- 2025
    LibraryMS_Data     -- 2026 and later
);
GO






-- 4. MEMORY-OPTIMIZED TABLE FOR REAL-TIME OPERATIONS
-- =============================================

-- Create a memory-optimized table for BookInventoryLogs
-- This will provide high-performance logging of inventory changes
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

-- 5. CREATE SOME BASIC VIEWS FOR COMMON QUERIES
-- =============================================

-- View for available books
CREATE VIEW vw_AvailableBooks
AS
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    a.Name AS Author,
    p.Name AS Publisher,
    c.CategoryName,
    b.CopiesAvailable,
    b.Condition,
    b.Location
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
JOIN Publishers p ON b.PublisherID = p.PublisherID
JOIN Categories c ON b.CategoryID = c.CategoryID
WHERE b.CopiesAvailable > 0;
GO

-- View for overdue loans
CREATE VIEW vw_OverdueLoans
AS
SELECT 
    l.LoanID,
    b.Title,
    b.ISBN,
    m.FullName AS MemberName,
    m.Email AS MemberEmail,
    m.Phone AS MemberPhone,
    l.IssueDate,
    l.DueDate,
    DATEDIFF(DAY, l.DueDate, GETDATE()) AS DaysOverdue,
    l.FineAmount
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL AND l.DueDate < GETDATE();
GO

-- View for member loan history
CREATE VIEW vw_MemberLoanHistory
AS
SELECT 
    m.MemberID,
    m.FullName,
    b.Title,
    l.IssueDate,
    l.DueDate,
    l.ReturnDate,
    CASE 
        WHEN l.ReturnDate IS NULL AND l.DueDate < GETDATE() THEN 'Overdue'
        WHEN l.ReturnDate IS NULL THEN 'Active'
        ELSE 'Returned'
    END AS LoanStatus,
    l.FineAmount
FROM Members m
JOIN Loans l ON m.MemberID = l.MemberID
JOIN Books b ON l.BookID = b.BookID;
GO

-- 6. BASIC SECURITY
-- =============================================

-- Create application roles
CREATE ROLE LibraryAdmin;
CREATE ROLE Librarian;
CREATE ROLE MemberUser;
GO

-- Grant permissions to roles
GRANT CONTROL ON DATABASE::LibraryManagementSystem TO LibraryAdmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Librarian;
REVOKE DELETE ON dbo.Members FROM Librarian;
REVOKE DELETE ON dbo.Staff FROM Librarian;

GRANT SELECT ON dbo.vw_AvailableBooks TO MemberUser;
GRANT SELECT ON dbo.Reservations TO MemberUser;
GRANT INSERT ON dbo.Reservations TO MemberUser;
GO

PRINT 'Library Management System database created successfully!';