-- Set the database to use
USE LibraryManagementSystem;
GO



-- 3. CREATING TABLES WITH RELATIONSHIPS
-- =============================================

-- Create Authors table
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Bio NVARCHAR(MAX)
) ON LibraryMS_Data;
GO

-- Create Publishers table
CREATE TABLE Publishers (
    PublisherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    ContactInfo NVARCHAR(500)
) ON LibraryMS_Data;
GO

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500)
) ON LibraryMS_Data;
GO

-- Create Books table
CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ISBN NVARCHAR(20) UNIQUE,
    AuthorID INT NOT NULL,
    PublisherID INT NOT NULL,
    CategoryID INT NOT NULL,
    CopiesAvailable INT NOT NULL DEFAULT 0,
    Condition NVARCHAR(20) CHECK (Condition IN ('New', 'Good', 'Fair', 'Poor')),
    Location NVARCHAR(50),
    CONSTRAINT FK_Books_Authors FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    CONSTRAINT FK_Books_Publishers FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    CONSTRAINT FK_Books_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
) ON LibraryMS_Data;
GO

-- Create index on Books
CREATE NONCLUSTERED INDEX IX_Books_ISBN ON Books(ISBN) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Books_Title ON Books(Title) ON LibraryMS_Index;
GO

-- Create Members table
CREATE TABLE Members (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Address NVARCHAR(250),
    Phone NVARCHAR(20),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('active', 'suspended', 'expired')),
    JoinDate DATE NOT NULL DEFAULT GETDATE(),
    PasswordHash NVARCHAR(128) NOT NULL
) ON LibraryMS_Data;
GO

-- Create index on Members
CREATE NONCLUSTERED INDEX IX_Members_Email ON Members(Email) ON LibraryMS_Index;
GO

-- Create Staff table
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('admin', 'librarian')),
    PasswordHash NVARCHAR(128) NOT NULL,
    JoinDate DATE NOT NULL DEFAULT GETDATE(),
    Phone NVARCHAR(20)
) ON LibraryMS_Data;
GO

-- CORRECTED: Create partitioned Loans table
-- The issue is that we're trying to partition on a column that's not part of the primary key
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
) ON LibraryMS_Data;
GO


-- Create other indexes for the Loans table
CREATE NONCLUSTERED INDEX IX_Loans_BookID ON Loans(BookID) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Loans_MemberID ON Loans(MemberID) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Loans_DueDate ON Loans(DueDate) ON LibraryMS_Index;
GO

-- Create Reservations table
CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    ReservationDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('pending', 'notified', 'cancelled')),
    CONSTRAINT FK_Reservations_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_Reservations_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
) ON LibraryMS_Data;
GO

-- Create index on Reservations
CREATE NONCLUSTERED INDEX IX_Reservations_BookID ON Reservations(BookID) ON LibraryMS_Index;
CREATE NONCLUSTERED INDEX IX_Reservations_MemberID ON Reservations(MemberID) ON LibraryMS_Index;
GO

-- Create Notifications table
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    Type NVARCHAR(30) NOT NULL CHECK (Type IN ('due_reminder', 'fine', 'reservation')),
    Message NVARCHAR(500) NOT NULL,
    DateSent DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Notifications_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
) ON LibraryMS_Data;
GO

-- Create index on Notifications
CREATE NONCLUSTERED INDEX IX_Notifications_MemberID ON Notifications(MemberID) ON LibraryMS_Index;
GO

-- 4. MEMORY-OPTIMIZED TABLE FOR REAL-TIME OPERATIONS
-- =============================================

-- Create a memory-optimized table for BookInventoryLogs
-- Corrected version
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