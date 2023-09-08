
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT [name]
FROM sys.databases
WHERE [name] = N'LibaryManagementSystem'
)
CREATE DATABASE LibaryManagementSystem
GO



------ USE the LibaryManagementSystem DATABASE---------

USE LibaryManagementSystem;




------ script to drop all tables if they exist---------


IF OBJECT_ID('member_auth', 'U') IS NOT NULL
    DROP TABLE member_auth;

IF OBJECT_ID('member_address', 'U') IS NOT NULL
    DROP TABLE member_address;

IF OBJECT_ID('gender', 'U') IS NOT NULL
    DROP TABLE gender;

IF OBJECT_ID('membership_status', 'U') IS NOT NULL
    DROP TABLE membership_status;

IF OBJECT_ID('member_fine', 'U') IS NOT NULL
    DROP TABLE member_fine;

IF OBJECT_ID('item_status', 'U') IS NOT NULL
    DROP TABLE item_status;

IF OBJECT_ID('item_type', 'U') IS NOT NULL
    DROP TABLE item_type;


IF OBJECT_ID('payment_method', 'U') IS NOT NULL
    DROP TABLE payment_method;


IF OBJECT_ID('fine_payment', 'U') IS NOT NULL
    DROP TABLE fine_payment;

IF OBJECT_ID('author_address', 'U') IS NOT NULL
    DROP TABLE author_address;

IF OBJECT_ID('authors', 'U') IS NOT NULL
    DROP TABLE authors;

IF OBJECT_ID('item_author', 'U') IS NOT NULL
    DROP TABLE item_author;


IF OBJECT_ID('reservations', 'U') IS NOT NULL
    DROP TABLE reservations;

IF OBJECT_ID('reservation_status', 'U') IS NOT NULL
    DROP TABLE reservation_status;

IF OBJECT_ID('item_reviews', 'U') IS NOT NULL
    DROP TABLE item_reviews;

IF OBJECT_ID('author_reviews', 'U') IS NOT NULL
    DROP TABLE author_reviews;

IF OBJECT_ID('loans', 'U') IS NOT NULL
    DROP TABLE loans;

IF OBJECT_ID('members', 'U') IS NOT NULL 
    DROP TABLE members;

IF OBJECT_ID('catalog', 'U') IS NOT NULL
    DROP TABLE catalog;

IF OBJECT_ID('pulisher_address', 'U') IS NOT NULL
    DROP TABLE pulisher_address;

IF OBJECT_ID('publishers', 'U') IS NOT NULL
    DROP TABLE publishers;







---------- MEMBER'S TABLE ------------

CREATE TABLE members
(
    id INT IDENTITY(1, 1) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    email_address VARCHAR(255) UNIQUE NULL,
    telephone_number VARCHAR(20) UNIQUE NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_date_of_birth CHECK (date_of_birth <= GETDATE()),
    CONSTRAINT chk_email_member CHECK (email_address LIKE '%_@__%.%')
);

-------MEMBER'S ADDRESS TABLE---------

create Table member_address
(
    id INT IDENTITY(1, 1) NOT NULL,
    street_number INT NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    member_id INT NOT NULL,
    postcode VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);

--------- MEMBER'S AUTH TABLE -----------

CREATE TABLE member_auth
(
    id INT IDENTITY(1, 1) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password BINARY(64) NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id),
    PRIMARY KEY (id)
);


--------- MEMBER'S GENDER STATUS TABLE ----------


CREATE TABLE gender
(
    id INT IDENTITY(1, 1) NOT NULL,
    gender VARCHAR(50) NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id),
    PRIMARY KEY (id)
);


---------- MEMBER'S MEMBERSHIP STATUS TABLE ---------


CREATE TABLE membership_status
(
    id INT IDENTITY(1, 1) NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE NULL,
    membership_suspended_date DATE NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id),
    PRIMARY KEY (id)
);


---------- MEMBER'S FINE TABLE ------------


CREATE TABLE member_fine
(
    id INT IDENTITY(1, 1) NOT NULL,
    member_id INT NOT NULL,
    total_fines DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    outstanding_balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);


---------------- PUBLISHER'S TABLE ----------------

CREATE TABLE publishers
(
    id INT IDENTITY(1, 1) NOT NULL,
    publisher_name VARCHAR(50) NOT NULL,
    number_of_publications INT DEFAULT 0,
    telephone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT publisher_name_unique UNIQUE (publisher_name),
    CONSTRAINT chk_email_publisher CHECK (email LIKE '%_@__%.%')
);

---------------- PUBLISHER'S ADDRESS TABLE ----------------

CREATE TABLE pulisher_address
(
    id INT IDENTITY(1, 1) NOT NULL,
    street_number INT NOT NULL,
    publisher_id INT NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postcode VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (publisher_id) REFERENCES publishers (id)
);

---------- CATALOG TABLE ------------

CREATE TABLE catalog
(
    item_id INT IDENTITY(1, 1) NOT NULL,
    item_title VARCHAR(255) NOT NULL,
    year_of_publication DATE NOT NULL,
    date_added DATE NOT NULL,
    publisher_id INT NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    PRIMARY KEY (item_id)
);

-------- CATALOG ITEM'S STATUS TABLE  ------------

CREATE TABLE item_status
(
    id INT IDENTITY(1, 1) NOT NULL,
    item_id INT NOT NULL,
    item_status_value VARCHAR(50) NOT NULL,
    item_status_date DATE NOT NULL,
    FOREIGN KEY (item_id) REFERENCES catalog(item_id),
    PRIMARY KEY (id)
);

---------- CATALOG ITEM TYPE TABLE -----------

--ISBN CONSTRAINT CHECK : -- ISBN CAN EITHER BE 10(ISBN-10) OR 13(ISBN-13) DIGITS NO
-- item_type_constraint : When item type is a book, item_isbn shouldn't be null and the same implies for dvd

CREATE TABLE item_type
(
    id INT IDENTITY(1, 1) NOT NULL,
    item_id INT NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    item_isbn VARCHAR(50) NULL,
    item_issn VARCHAR(50) NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (item_id) REFERENCES catalog(item_id),
    CONSTRAINT item_type_constraint  CHECK ( (item_type = 'book' AND item_isbn IS NOT NULL AND item_issn IS NULL)
        OR (item_type = 'dvd' AND item_issn IS NOT NULL AND item_isbn IS NULL))
);


--------- MEMBER'S LOAN TABLE ------------

CREATE TABLE loans
(
    id INT IDENTITY(1, 1) NOT NULL,
    member_id INT NOT NULL,
    item_id INT NOT NULL,
    total_fines DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    date_taken_out DATE NOT NULL,
    date_due_back DATE NOT NULL,
    date_returned DATE NULL,
    status VARCHAR(20) CHECK (status IN('Returned', 'Not-Returned')) DEFAULT 'Not-Returned' NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (item_id) REFERENCES catalog(item_id)
);


--------- MEMBER'S FINE PAYMENT TABLE ------------

CREATE TABLE fine_payment
(
    id INT IDENTITY(1, 1) NOT NULL,
    member_id INT NOT NULL,
    time TIME NOT NULL,
    loan_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);


---------- MEMBER'S FINE PAYMENT METHOD TABLE -----------

CREATE TABLE payment_method
(
    id INT IDENTITY(1, 1) NOT NULL,
    fine_payment_id INT NOT NULL,
    fine_payment_method VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (fine_payment_id) REFERENCES fine_payment(id)
);


--------- AUTHOR'S TABLE ------------

CREATE TABLE authors
(
    id INT IDENTITY(1, 1) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    no_of_books_written INT DEFAULT 0,
    date_of_birth DATE NOT NULL,
    email_address VARCHAR(255) UNIQUE NULL,
    telephone_number VARCHAR(20) UNIQUE NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_date_of_birth_author CHECK ( date_of_birth <= GETDATE()),
    CONSTRAINT chk_email_author CHECK (email_address LIKE '%_@__%.%')
);


-------AUTHOR'S ADDRESS TABLE---------

create Table author_address
(
    id INT IDENTITY(1, 1) NOT NULL,
    street_number INT NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    author_id INT NOT NULL,
    postcode VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);


---------- ITEM-AUTHOR'S TABLE -----------

CREATE TABLE item_author
(
    id INT IDENTITY(1, 1) NOT NULL,
    item_id INT NOT NULL,
    author_id INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES authors(id),
    FOREIGN KEY (item_id) REFERENCES catalog(item_id),
    PRIMARY KEY (id)
);




-----------------------ADDED TABLES -----------------------------

----------------- ITEM RESERVATION'S TABLE -------------------

CREATE TABLE reservations
(
    id INT IDENTITY(1, 1) NOT NULL,
    item_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (item_id) REFERENCES catalog(item_id),
    PRIMARY KEY (id)
);


------------------ ITEM RESERVATION'S STATUS ------------------

CREATE TABLE reservation_status
(
    id INT IDENTITY(1, 1) NOT NULL,
    reservation_id INT NOT NULL,
    status VARCHAR(100) NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    PRIMARY KEY (id)
);


------------------ ITEM REVIEW'S TABLE ----------------- 
--item_rating_check constrainst make sure the review's rating falls between the range 0f 1-5

CREATE TABLE item_reviews
(
    id INT IDENTITY(1, 1) NOT NULL,
    item_id INT NOT NULL,
    rating INT NOT NULL,
    review_comment VARCHAR(1000),
    FOREIGN KEY (item_id) REFERENCES catalog(item_id),
    PRIMARY KEY (id),
    CONSTRAINT item_rating_check CHECK (rating >= 1 AND rating <= 5),
);




------------------ AUTHOR'S REVIEW TABLE ----------------

CREATE TABLE author_reviews
(
    id INT IDENTITY(1, 1) NOT NULL,
    author_id INT NOT NULL,
    rating INT NOT NULL,
    review_comment VARCHAR(1000),
    FOREIGN KEY (author_id) REFERENCES authors(id),
    PRIMARY KEY (id),
    CONSTRAINT author_rating_check CHECK (rating >= 1 AND rating <= 5),
);



---------------------  STORE PROCEDURE TO INSERT A NEW MEMBER INTO THE MEMBER'S TABLE ------------------------------------

GO
CREATE PROCEDURE addNewMember
    @full_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255) = NULL,
    @telephone_number VARCHAR(20) = NULL,
    @id INT OUTPUT
AS
BEGIN
    INSERT INTO members
        (full_name, date_of_birth, email_address, telephone_number)
    OUTPUT
    inserted.id
    VALUES
        (@full_name, @date_of_birth, @email_address, @telephone_number)

    SET @id = SCOPE_IDENTITY();
END
GO


---------------------  STORE PROCEDURE TO INSERT A NEW ADDRESS INTO THE ADDRESS'S TABLE ------------------------------------

GO
CREATE PROCEDURE addNewAddress
    @street_number INT,
    @member_id INT,
    @street_address VARCHAR(200),
    @city VARCHAR(100),
    @state VARCHAR(100),
    @postcode VARCHAR(50)
AS
BEGIN
    INSERT INTO member_address
        (street_number, member_id, street_address, city, state, postcode)
    VALUES
        (@street_number, @member_id, @street_address, @city, @state, @postcode)
END
GO



-----------------------  STORE PROCEDURE TO INSERT A MEMBER'S GENDER STATUS INTO THE MEMBER'S GENDER STATUS TABLE ------------------------------------

GO
CREATE PROCEDURE addMemberGender
    @gender VARCHAR(50),
    @member_id INT
AS
BEGIN
    INSERT INTO gender
        (gender, member_id)
    VALUES
        (@gender, @member_id)
END
GO


---------------------  STORE PROCEDURE TO MEMBER'S AUTH TO MEMBER'S AUTH TABLE ------------------------------------

GO
CREATE PROCEDURE addNewMemberAuth
    @username VARCHAR(50),
    @password BINARY(255),
    @member_id INT
AS
BEGIN
    INSERT INTO member_auth
        (username, password, member_id)
    VALUES
        (@username, @password, @member_id)
END
GO





-----------------------  STORE PROCEDURE TO INSERT A MEMBERSHIP STATUS INTO THE MEMBERSHIP STATUS TABLE ------------------------------------

GO
CREATE PROCEDURE addMemberShipStatus
    @membership_start_date DATE,
    @membership_end_date DATE = NULL,
    @membership_suspended_date DATE = NULL,
    @member_id INT
AS
BEGIN
    INSERT INTO membership_status
        (membership_start_date, membership_end_date, membership_suspended_date, member_id)
    VALUES
        (@membership_start_date, @membership_end_date, @membership_suspended_date, @member_id)
END
GO





-------------------------- STORE PROCEDURE TO UDATE MEMBER'S DETAIL -----------------------------

GO
CREATE PROCEDURE updateMemberDetails
    @member_id INT,
    @full_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255),
    @telephone_number VARCHAR(20)
AS
BEGIN
    UPDATE members
    SET full_name = @full_name, @telephone_number = @telephone_number, 
    email_address = @email_address
    WHERE id = @member_id
END
GO


-------------------------- STORE PROCEDURE TO UDATE MEMBER'S DETAIL -----------------------------

GO
CREATE PROCEDURE updateMemberStatus
    @member_id INT,
    @membership_start_date DATE,
    @membership_end_date DATE,
    @membership_suspended_date DATE
AS
BEGIN
    UPDATE membership_status 
    SET membership_start_date = @membership_start_date, 
    membership_end_date = @membership_end_date, 
    membership_suspended_date = @membership_suspended_date
    WHERE member_id = @member_id
END
GO


-------------------------- STORE PROCEDURE TO UDATE MEMBER'S DETAIL -----------------------------

GO
CREATE PROCEDURE updateMemberAddress
    @street_number INT,
    @street_address VARCHAR(200),
    @city VARCHAR(100),
    @state VARCHAR(100),
    @member_id INT,
    @postcode VARCHAR(50)
AS
BEGIN
    UPDATE member_address 
    SET 
    street_number = @street_number, 
    street_address = @street_address, 
    city = @city,
    state = @state,
    postcode = @postcode
    WHERE member_id = @member_id
END
GO

---------- single update procedure ------------------
CREATE PROCEDURE updateMemberInformation
    @member_id INT,
    @full_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255),
    @telephone_number VARCHAR(20),
    @membership_start_date DATE,
    @membership_end_date DATE,
    @membership_suspended_date DATE,
    @street_number INT,
    @street_address VARCHAR(200),
    @city VARCHAR(100),
    @state VARCHAR(100),
    @postcode VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
    -- Update the full name, telephone number, email address in members table ---
    ---By calling the UPDATE members status procedure-------
    UPDATE members
    SET full_name = @full_name, telephone_number = @telephone_number, 
    email_address = @email_address
    WHERE id = @member_id

    -- Update the memebership start date, membership end date and membership suspended date in membership_status table --
    ---By calling the UPDATE membership status procedure-------
    UPDATE membership_status 
    SET membership_start_date = @membership_start_date, 
    membership_end_date = @membership_end_date, 
    membership_suspended_date = @membership_suspended_date
    WHERE member_id = @member_id

    -- Update member_address table by updating the street number, street address, city and state----
    ---- by calling the member_address procedure---
    UPDATE member_address 
    SET 
    street_number = @street_number, 
    street_address = @street_address, 
    city = @city,
    state = @state,
    postcode = @postcode
    WHERE member_id = @member_id

    -- Roll back all the changes in case of an error -----
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION
        RETURN
    END
    -- If the operation was successful, commit all changes-----
    COMMIT TRANSACTION
END









-- -----------------------  STORE PROCEDURE TO INSERT A NEW ITEM INTO A CATALOG'S TABLE ------------------------------------

GO
CREATE PROCEDURE insertItemIntoCatalog
    @item_title VARCHAR(255),
    @year_of_publication DATE,
    @date_added DATE,
    @publisher_id INT,
    @item_id INT OUTPUT
AS
BEGIN
    DECLARE @InsertedRows TABLE (item_id INT);

    INSERT INTO catalog
        (item_title, year_of_publication, date_added, publisher_id)
    OUTPUT inserted.item_id INTO @InsertedRows
    VALUES
        (@item_title, @year_of_publication, @date_added, @publisher_id);

    SELECT @item_id = item_id
    FROM @InsertedRows;
END
GO


-----------------------  STORE PROCEDURE TO INSERT A ITEM TYPE IN ITEM TYPE TABLE ------------------------------------


GO
CREATE PROCEDURE insertIntoItemType
    @item_id INT,
    @item_type VARCHAR(50),
    @item_isbn VARCHAR(50) = NULL,
    @item_issn VARCHAR(50) = NULL
AS
BEGIN
    INSERT INTO item_type
        (item_id, item_type, item_isbn, item_issn)
    VALUES
        (@item_id, @item_type, @item_isbn, @item_issn)
END
GO



-----------------------  STORE PROCEDURE TO INSERT A ITEM STATUS INTO A ITEM STATUS TABLE -------------------------------


GO
CREATE PROCEDURE insertIntoItemStatus
    @item_id INT,
    @item_status_value VARCHAR(50),
    @item_status_date DATE
AS
BEGIN
    INSERT INTO item_status
        (item_id, item_status_value, item_status_date)
    VALUES
        (@item_id, @item_status_value, @item_status_date)
END
GO



-----------------------  STORE PROCEDURE TO INSERT A LOAN INTO A LOAN TABLE -------------------------------

GO
CREATE PROCEDURE insertIntoLoans
    @item_id INT,
    @member_id INT,
    @date_taken_out DATE,
    @date_due_back DATE,
    @date_returned DATE = NULL,
    @status VARCHAR(20) = 'Not-Returned'
AS
BEGIN
    INSERT INTO loans
        (item_id, member_id, date_taken_out, date_due_back, date_returned, status)
    VALUES
        (@item_id, @member_id, @date_taken_out, @date_due_back, @date_returned, @status)
END
GO



------------ create procedure for inserting payment fine into fine_payment table -------------

GO
CREATE PROCEDURE insertFine_payment
    @amount_paid DECIMAL(10,2) = 0.00,
    @member_id INT,
    @loan_id INT,
    @time TIME
AS
BEGIN
    INSERT INTO fine_payment
        (amount_paid, member_id, loan_id, time)
    VALUES
        (@amount_paid, @member_id, @loan_id, @time)
END
GO



------------ create procedure for inserting payment method into payment method table ----------------

GO
CREATE PROCEDURE insertpayment_method
    @fine_payment_id INT,
    @fine_payment_method VARCHAR(50)
AS
BEGIN
    INSERT INTO payment_method
        (fine_payment_id, fine_payment_method)
    VALUES
        (@fine_payment_id, @fine_payment_method)
END
GO


-------------------------- STORE PROCEDURE TO UDATE LOAN TABLE -----------------------------

GO
CREATE PROCEDURE loanItemStatus
    @loan_id INT,
    @date_taken_out DATE,
    @date_due_back DATE,
    @date_returned DATE = NULL,
    @status VARCHAR(20)
AS
BEGIN
    UPDATE loans 
    SET date_taken_out = @date_taken_out, date_due_back = @date_due_back, date_returned = @date_returned, status = @status
    WHERE id = @loan_id
END
GO


-- 
----------------------  STORE PROCEDURE TO INSERT A NEW AUTHOR INTO THE AUTHOR'S TABLE ------------------------------------

GO
CREATE PROCEDURE addNewAuthor
    @first_name VARCHAR(100),
    @last_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255),
    @telephone_number VARCHAR(20),
    @author_id INT OUTPUT
AS
BEGIN
    INSERT INTO authors
        (first_name, last_name, date_of_birth, email_address, telephone_number)
    OUTPUT
    inserted.id
    VALUES
        (@first_name, @last_name, @date_of_birth, @email_address, @telephone_number)
    SET @author_id = SCOPE_IDENTITY();
END
GO


-----------------------  STORE PROCEDURE TO INSERT AUTHOR ADDRESS INTO THE AUTHOR'S ADDRESS TABLE ------------------------------------

GO
CREATE PROCEDURE addAuthorAddress
    @street_number INT,
    @author_id INT,
    @street_address VARCHAR(200),
    @city VARCHAR(100),
    @state VARCHAR(100),
    @postcode VARCHAR(50)
AS
BEGIN
    INSERT INTO author_address
        (street_number, author_id, street_address, city, state, postcode)
    VALUES
        (@street_number, @author_id, @street_address, @city, @state, @postcode)
END
GO



-------------------------- STORE PROCEDURE TO UDATE AUTHOR'S DETAIL -----------------------------

GO
CREATE PROCEDURE updateAuthorDetails
    @author_id INT,
    @first_name VARCHAR(100),
    @last_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255),
    @telephone_number VARCHAR(20)
AS
BEGIN
    UPDATE authors
    SET first_name = @first_name, last_name = @last_name, @telephone_number = @telephone_number, email_address = @email_address
    WHERE id = @author_id
END
GO



-----------------------  STORE PROCEDURE TO INSERT AN ITEM AND AUTHOR INTO THE ITEM-AUTHOR'S TABLE ------------------------------------

GO
CREATE PROCEDURE addNewItemAuthor
    @item_id INT,
    @author_id INT
AS
BEGIN
    INSERT INTO item_author
        (item_id, author_id)
    VALUES
        (@item_id, @author_id)
END
GO



------------------------- ADDED TABLES POCEDURE --------------------------

----------- MAKE RESERVATION PROCEDURE ----------

GO
CREATE PROCEDURE makeReservation
    @item_id INT,
    @reservation_date DATE,
    @member_id INT
AS
BEGIN
    INSERT INTO reservations
        (item_id, reservation_date, member_id)
    VALUES
        (@item_id, @reservation_date, @member_id)
END
GO


------------- SET RESERVATION STATUS ROCEDURE ---------

GO
CREATE PROCEDURE insertItemReservationStatus
    @reservation_id INT,
    @status VARCHAR(100)
AS
BEGIN
    INSERT INTO reservation_status
        (reservation_id, status)
    VALUES
        (@reservation_id, @status)
END
GO


-------------- UPDATE RESERVATION STATUS --------------

GO
CREATE PROCEDURE updateReservationStatus
    @reservation_id INT,
    @status VARCHAR(100)
AS
BEGIN
    UPDATE reservation_status
    SET status = @status  
    WHERE reservation_id = @reservation_id
END
GO



--------- INSERT ITEM REVIEW PROCEDURE ----------------

GO
CREATE PROCEDURE insertItemReview
    @item_id INT,
    @rating INT,
    @review_comment VARCHAR(1000)
AS
BEGIN
    INSERT INTO item_reviews
        (item_id, rating, review_comment)
    VALUES
        (@item_id, @rating, @review_comment)
END
GO



------------ INSERT AUTHOR REVIEW PROCEDURE -----------

GO
CREATE PROCEDURE insertAuthorReview
    @item_id INT,
    @rating INT,
    @review_comment VARCHAR(1000)
AS
BEGIN
    INSERT INTO author_reviews
        (author_id, rating, review_comment)
    VALUES
        (@item_id, @rating, @review_comment)
END
GO


------------ INSERT PUBLISHER PROCEDURE -----------

GO
CREATE PROCEDURE insertPublishers
    @publisher_name VARCHAR(50),
    @telephone_number VARCHAR(20),
    @email VARCHAR(50),
    @publisher_id INT OUTPUT
AS
BEGIN
    INSERT INTO publishers
        (publisher_name, telephone_number, email)
    OUTPUT
    inserted.id
    VALUES
        (@publisher_name, @telephone_number, @email)
    SET @publisher_id = SCOPE_IDENTITY();
END
GO


-------CREATE MEMBER_FINE TABLE------------


GO
CREATE PROCEDURE insertMembersFine
    @member_id INT
AS
BEGIN
    INSERT INTO member_fine(member_id )
    VALUES
        (@member_id)
END
GO


------------ INSERT PUBLISHER ADDRESS PROCEDURE -----------

GO
CREATE PROCEDURE addNewPublisherAddress
    @street_number INT,
    @street_address VARCHAR(200),
    @publisher_id INT,
    @city VARCHAR(100),
    @state VARCHAR(100),
    @postcode VARCHAR(50)
AS
BEGIN
    INSERT INTO pulisher_address
        (street_number, street_address, publisher_id, city, state, postcode)
    VALUES
        (@street_number, @street_address, @publisher_id, @city, @state, @postcode)
END
GO




-------------------------FUNTIONS, VIEWS, AND TRIGGERS ---------------------------------

-------- FUNCTION TO: search the catalog by title and sorts the results by publication date, while also joining the item_type and item_status tables ---------
CREATE FUNCTION search_catalog_for_item_by_title(@title VARCHAR(255))
RETURNS TABLE
AS
RETURN (
    SELECT TOP 100 PERCENT
    c.item_id, c.item_title, t.item_isbn, t.item_issn, s.item_status_value, s.item_status_date, c.year_of_publication, t.item_type
FROM catalog c
    JOIN item_status s ON c.item_id = s.item_id
    JOIN item_type t ON c.item_id = t.item_id
WHERE c.item_title LIKE '%' + @title + '%'
ORDER BY c.year_of_publication DESC
);
GO


SELECT * FROM search_catalog_for_item_by_title('The Lord of the Rings');


-- ----- Return a full list of all items currently on loan which have a due date of less than or equals five days from the current date -----------

GO
CREATE PROCEDURE itemsOnLoanWhichDueIn5DaysOrLess
AS
BEGIN

    DECLARE @Today DATE
    SET @Today = GETDATE()

    SELECT c.item_title, c.year_of_publication, t.item_type,
           s.item_status_value, l.date_taken_out, l.date_due_back
    FROM loans AS l
        INNER JOIN catalog AS c ON l.item_id = c.item_id
        INNER JOIN item_type AS t ON t.item_id = c.item_id
        INNER JOIN item_status AS s ON s.item_id = c.item_id
    WHERE l.status = 'Not-Returned'
        AND l.date_due_back BETWEEN @Today AND DATEADD(DAY, 5, @Today)
    ORDER BY l.date_due_back ASC;
END
GO


EXEC itemsOnLoanWhichDueIn5DaysOrLess;


--  ---- the loan history, showing all previous and currentloans, and including details of the item borrowed, borrowed date ---,
--- due date and any associated fines for each loan ------

GO
CREATE VIEW loan_history
AS
    SELECT c.item_title, it.item_type, it.item_isbn, it.item_issn, ist.item_status_value,
        l.date_taken_out, l.date_due_back, l.date_returned,
        l.status, l.total_fines, COALESCE(SUM(f.amount_paid), 0.00) AS total_amount_paid_fine_on_item_loan
    FROM catalog c
        INNER JOIN item_type it ON c.item_id = it.item_id
        INNER JOIN item_status ist ON c.item_id = ist.item_id
        INNER JOIN loans l ON c.item_id = l.item_id
        LEFT JOIN fine_payment f ON l.id = f.loan_id
    GROUP BY c.item_title, it.item_type, it.item_isbn, it.item_issn, ist.item_status_value,
        l.date_taken_out, l.date_due_back, l.date_returned, l.status, l.total_fines;
GO

--SELECT * FROM loan_history;

-- ------ select query which allows the library toidentify the total number of loans made on a specified date ---------------

SELECT COUNT(*) as total_loans
FROM loans
WHERE date_taken_out = '2023-04-22'



----- trigger that update the current status of an item automatically to Available when the book is returned ---------

GO
CREATE TRIGGER update_item_status
ON loans
AFTER UPDATE
AS
BEGIN
    IF UPDATE (date_returned)
    BEGIN
        UPDATE item_status
  SET item_status_value = 'Available'
  FROM item_status
            INNER JOIN inserted ON item_status.item_id = inserted.item_id
  WHERE inserted.date_returned IS NOT NULL;
    END
END;
GO



----------------------------ADDED TRIGGERS------------------------------------

-----trigger that calculate numbers of book written by an author------

GO
CREATE TRIGGER no_of_books_written
ON item_author
AFTER INSERT
AS
BEGIN
    UPDATE authors
  SET no_of_books_written = no_of_books_written + 1
  WHERE id = (SELECT author_id
    FROM inserted)
END
GO


-----trigger that calculate publisher numbers of publication------

GO
CREATE TRIGGER update_number_of_publications
ON catalog
AFTER INSERT
AS
BEGIN
    UPDATE publishers
  SET number_of_publications =  number_of_publications + 1
  WHERE id = (SELECT publisher_id
    FROM inserted)
END
GO



----- trigger that add total fines to the loan, every number of days after due when an item is still yet to be returned ----
-- ---- SET @date_due_back = @new_due_date -----
-- --- THIS PREVENT THE TRIGGER FROM RUNNING MULTIPLE TIMES THERE BY GIVING INVALID CALCULATION OF FINE, OR BECOMES AN INVINITE LOOP---

GO
CREATE TRIGGER add_overdue_fee
ON loans
AFTER UPDATE
AS
BEGIN
    DECLARE @member_id INT
    DECLARE @total_fines DECIMAL(10,2)
    DECLARE @outstanding_balance DECIMAL(10,2)
    DECLARE @date_due_back DATE
    DECLARE @status VARCHAR(20)

    SELECT @member_id = member_id, @total_fines = total_fines
    FROM inserted

    IF (DATEDIFF(day, @date_due_back, GETDATE()) > 0 AND @status = 'Not-Returned')
  BEGIN
        DECLARE @new_due_date DATE
        SET @new_due_date = GETDATE()
        SET @total_fines = @total_fines + 10.00
        SET @date_due_back = @new_due_date

        UPDATE member_fine SET total_fines = total_fines + 10.00, 
        outstanding_balance = outstanding_balance + 10.00 WHERE member_id = @member_id
    END
END
GO




-- ----------- Trigger that substract the total fine from loan table and set the status as returned 
-----  and inturns update total member's fine table when fine payment is made -------
GO
CREATE TRIGGER update_fine_payment
ON fine_payment
AFTER INSERT
AS
BEGIN
    DECLARE @member_id INT, @loan_id INT, @amount_paid DECIMAL(10,2);
    SELECT @member_id = member_id, @loan_id = loan_id, @amount_paid = amount_paid
    FROM inserted;

    UPDATE loans
  SET total_fines = total_fines - @amount_paid,
      date_returned = GETDATE(),
      status = 'Returned'
  WHERE id = @loan_id;

    UPDATE member_fine
  SET amount_paid = amount_paid + @amount_paid,
      outstanding_balance = total_fines - @amount_paid
  WHERE member_id = @member_id;
END
GO



--- a function that search through the author, return their books, along with the average ratings(both author and book ratinngs) sorted by year of publication
GO
CREATE PROCEDURE search_books_by_author
    @first_name VARCHAR(100),
    @last_name VARCHAR(100)
AS
BEGIN
    SELECT c.item_title, c.year_of_publication, ia.author_id, ir.review_comment AS item_reviews, ar.review_comment AS author_reviews,
           (SELECT AVG(rating) FROM item_reviews WHERE item_id = c.item_id) AS item_rating,
           (SELECT AVG(rating) FROM author_reviews WHERE author_id = ia.author_id) AS author_rating
    FROM catalog c
        INNER JOIN item_author ia ON c.item_id = ia.item_id
        INNER JOIN authors a ON a.id = ia.author_id
        LEFT JOIN item_reviews ir ON c.item_id = ir.item_id
        LEFT JOIN author_reviews ar ON a.id= ar.author_id
        INNER JOIN item_type it ON c.item_id = it.item_id
        INNER JOIN item_status ist ON c.item_id = ist.item_id
    WHERE a.first_name LIKE '%' + @first_name + '%'
        AND a.last_name LIKE '%' + @last_name + '%'
    ORDER BY c.year_of_publication ASC
END
GO

-- EXEC search_books_by_author 'Peter', 'harrison';




-----------------------Populating the tables with the create procedures----------------------

--------------------------ALL TRANSACTIONS PROCEDURES------------------------------------------

------------------------------ JOINING ALL THE MEMBER'S PROCEDURES USING TRANSACTIONS -------------------

GO
CREATE PROCEDURE addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
    @full_name VARCHAR(100),
    @date_of_birth DATE,
    @email_address VARCHAR(255) = NULL,
    @telephone_number VARCHAR(20) = NULL,
    @street_number INT,
    @street_address VARCHAR(200),
    @city VARCHAR(100),
    @state VARCHAR(100),
    @postcode VARCHAR(50),
    @gender VARCHAR(50),
    @username VARCHAR(50),
    @password BINARY(255),
    @membership_start_date DATE,
    @membership_end_date DATE = NULL,
    @membership_suspended_date DATE = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @id INT;

    EXEC addNewMember 
        @full_name = @full_name,
        @date_of_birth = @date_of_birth,
        @email_address = @email_address,
        @telephone_number = @telephone_number,
        @id = @id OUTPUT;

    SET @id = @id

    EXEC addNewAddress 
        @street_number = @street_number,
        @member_id = @id,
        @street_address = @street_address,
        @city = @city,
        @state = @state,
        @postcode = @postcode;

    EXEC addMemberGender 
        @gender = @gender,
        @member_id = @id;

    EXEC addNewMemberAuth 
        @username = @username,
        @password = @password,
        @member_id = @id;

    EXEC addMemberShipStatus
        @member_id = @id,
        @membership_start_date = @membership_start_date,
        @membership_end_date = @membership_end_date,
        @membership_suspended_date = @membership_suspended_date;

    EXEC insertMembersFine
          @member_id = @id

    COMMIT TRANSACTION;
END
GO


-------- JOINING ALL CATALOGUE RELATED PROCEDURES --------------
-- Publisher, publisher's address, catalog,  
--item status, item type, author, author's address, item_author

GO
CREATE PROCEDURE insertAllCatalogueAssociatedTables
    -------publisher-----------
    @publisher_name VARCHAR(50),
    @publisher_telephone_number VARCHAR(20),
    @publisher_email VARCHAR(50),

    ------publisher's address-----
    @pulisher_street_number INT,
    @pulisher_street_address VARCHAR(200),
    @pulisher_city VARCHAR(100),
    @pulisher_state VARCHAR(100),
    @pulisher_postcode VARCHAR(50),

    --------author--------
    @author_first_name VARCHAR(100),
    @author_last_name VARCHAR(100),
    @author_date_of_birth DATE,
    @author_email_address VARCHAR(255),
    @author_telephone_number VARCHAR(20),

    -------author's address------
    @author_street_number INT,
    @author_street_address VARCHAR(200),
    @author_city VARCHAR(100),
    @author_state VARCHAR(100),
    @author_postcode VARCHAR(50),

    -------catalogue--------
    @item_title VARCHAR(255),
    @year_of_publication DATE,
    @date_added DATE,

    -------item type--------
    @item_type VARCHAR(50),
    @item_isbn VARCHAR(50) = NULL,
    @item_issn VARCHAR(50) = NULL,

    ------item status-------
    @item_status_value VARCHAR(50),
    @item_status_date DATE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @publisher_id INT;
    DECLARE @author_id INT;
    DECLARE @item_id INT;

    EXEC insertPublishers
        @publisher_name = @publisher_name,
        @telephone_number = @publisher_telephone_number,
        @email = @publisher_email,
        @publisher_id = @publisher_id OUTPUT;

    SET @publisher_id = @publisher_id

    EXEC addNewPublisherAddress
        @street_number = @pulisher_street_number,
        @street_address = @pulisher_street_address,
        @city = @pulisher_city,
        @state = @pulisher_state,
        @postcode = @pulisher_postcode,
        @publisher_id = @publisher_id
    EXEC insertItemIntoCatalog
        @item_title =  @item_title,
        @year_of_publication = @year_of_publication,
        @date_added = @date_added,
        @publisher_id = @publisher_id,
        @item_id = @item_id OUTPUT;

    SET @item_id = @item_id

    EXEC insertIntoItemType
        @item_id = @item_id,
        @item_type = @item_type,
        @item_isbn  = @item_isbn,
        @item_issn  = @item_issn
    EXEC insertIntoItemStatus
        @item_id = @item_id,
        @item_status_value = @item_status_value,
        @item_status_date = @item_status_date
    EXEC addNewAuthor
        @first_name = @author_first_name,
        @last_name = @author_last_name,
        @date_of_birth  = @author_date_of_birth,
        @email_address = @author_email_address,
        @telephone_number = @author_telephone_number,
        @author_id = @author_id OUTPUT;

    SET @author_id = @author_id

    EXEC addAuthorAddress
        @street_number = @author_street_number,
        @street_address = @author_street_address,
        @city = @author_city,
        @state = @author_state,
        @postcode = @author_postcode,
        @author_id = @author_id
    EXEC addNewItemAuthor
        @item_id = @item_id,
        @author_id = @author_id


    COMMIT TRANSACTION;
END
GO







----- join query for all member's information ------



--- loan items query ----------

SELECT full_name, total_fines, date_taken_out,
    status, item_title, date_due_back, date_returned
FROM
    loans l
    JOIN members m ON l.member_id = m.id
    JOIN catalog ca ON l.item_id = ca.item_id;





--- join query from all catalogue items with related tables using join-----


SELECT
    pub.id, pub.publisher_name, pub.number_of_publications,
    pub.telephone_number, pub.email, pub_address.street_number,
    pub_address.publisher_id, pub_address.street_address, pub_address.city,
    pub_address.state, pub_address.postcode, cat.item_id,
    cat.item_title, cat.year_of_publication, cat.date_added,
    cat.publisher_id, item_stat.item_id, item_stat.item_status_value,
    item_stat.item_status_date, item_typ.item_id, item_typ.item_type,
    item_typ.item_isbn, item_typ.item_issn, aut.id,
    aut.first_name, aut.last_name, aut.no_of_books_written,
    aut.date_of_birth, aut.email_address, aut.telephone_number,
    aut_address.street_number, aut_address.street_address,
    aut_address.city, aut_address.state, aut_address.postcode, item_aut.id
FROM
    publishers AS pub
    JOIN pulisher_address AS pub_address ON pub.id = pub_address.publisher_id
    JOIN catalog AS cat ON pub.id = cat.publisher_id
    JOIN item_status AS item_stat ON cat.item_id = item_stat.item_id
    JOIN item_type AS item_typ ON cat.item_id = item_typ.item_id
    JOIN item_author AS item_aut ON cat.item_id = item_aut.item_id
    JOIN authors AS aut ON item_aut.author_id = aut.id
    JOIN author_address AS aut_address ON aut.id = aut_address.author_id;




-----query to return all reservations-----


SELECT
    reservation_date,
    full_name,
    [status],
    item_title,
    item_type
FROM reservations r
    JOIN members m ON r.member_id = m.id
    JOIN [catalog] c ON c.item_id = c.item_id
    JOIN reservation_status rs ON r.id = rs.reservation_id
    JOIN item_type it ON it.item_id = c.item_id




-----------------INSERTING DATA-----------------------------


-- EXEC insertAllCatalogueAssociatedTables
--     @publisher_name = 'ABC Publisher',
--     @publisher_telephone_number = '555-1234',
--     @publisher_email = 'info@abcpublisher.com',
--     @pulisher_street_number = 123,
--     @pulisher_street_address = '123 Main St',
--     @pulisher_city = 'Vegas',
--     @pulisher_state = 'CA',
--     @pulisher_postcode = '12345',
--     @item_title = 'The Great Gatsby',
--     @year_of_publication = '2022-01-01',
--     @date_added = '2022-01-15',
--     @item_type = 'book',
--     @item_isbn = '978-1-2345-6789-0',
--     @item_status_value = 'Available',
--     @item_status_date = '2022-01-15',
--     @author_first_name = 'John',
--     @author_last_name = 'Doe',
--     @author_date_of_birth = '1980-01-01',
--     @author_email_address = 'john@example.com',
--     @author_telephone_number = '898-567',
--     @author_street_number = 456,
--     @author_street_address = '456 Main St',
--     @author_city = 'Luton',
--     @author_state = 'CA',
--     @author_postcode = '12345';


-- EXEC insertAllCatalogueAssociatedTables
--     @publisher_name = 'IJK Publisher',
--     @publisher_telephone_number = '555-1299',
--     @publisher_email = 'ijk@abcpublisher.com',
--     @pulisher_street_number = 123,
--     @pulisher_street_address = '123 Main St',
--     @pulisher_city = 'Seatle',
--     @pulisher_state = 'CA',
--     @pulisher_postcode = '12345',
--     @item_title = 'The Maze Runner',
--     @year_of_publication = '2022-01-01',
--     @date_added = '2022-01-15',
--     @item_type = 'book',
--     @item_isbn = '978-1-2345-6789-0',
--     @item_status_value = 'Available',
--     @item_status_date = '2022-01-15',
--     @author_first_name = 'Peter',
--     @author_last_name = 'harrison',
--     @author_date_of_birth = '1980-01-01',
--     @author_email_address = 'peter@example.com',
--     @author_telephone_number = '909-567',
--     @author_street_number = 456,
--     @author_street_address = '456 Main St',
--     @author_city = 'Lacanshire',
--     @author_state = 'CA',
--     @author_postcode = '12345';



-- EXEC insertAllCatalogueAssociatedTables
--     @publisher_name = 'XYZ Publishing',
--     @publisher_telephone_number = '555-5678',
--     @publisher_email = 'unique@xyzpublishing.com',
--     @pulisher_street_number = 456,
--     @pulisher_street_address = '456 Main St',
--     @pulisher_city = 'bolton',
--     @pulisher_state = 'CA',
--     @pulisher_postcode = '12345',
--     @item_title = 'The Book Thief',
--     @year_of_publication = '2022-02-01',
--     @date_added = '2022-02-15',
--     @item_type = 'dvd',
--     @item_issn = '1234-5678',
--     @item_status_value = 'Available',
--     @item_status_date = '2022-02-15',
--     @author_first_name = 'peter',
--     @author_last_name = 'pan',
--     @author_date_of_birth = '1985-01-01',
--     @author_email_address = 'pan@example.com',
--     @author_telephone_number = '456-678',
--     @author_street_number = 456,
--     @author_street_address = '456 Main St',
--     @author_city = 'Alabama',
--     @author_state = 'CA',
--     @author_postcode = '12345';



-- EXEC insertAllCatalogueAssociatedTables
--     @publisher_name = 'UTC Publishing',
--     @publisher_telephone_number = '585-5678',
--     @publisher_email = 'utce@xyzpublishing.com',
--     @pulisher_street_number = 470,
--     @pulisher_street_address = '456 Peter St',
--     @pulisher_city = 'liverpool',
--     @pulisher_state = 'TX',
--     @pulisher_postcode = '9876',
--     @item_title = 'The Fault in Our Stars',
--     @year_of_publication = '2023-02-11',
--     @date_added = '2022-04-16',
--     @item_type = 'dvd',
--     @item_issn = '1234-5678',
--     @item_status_value = 'Available',
--     @item_status_date = '2022-02-15',
--     @author_first_name = 'samson',
--     @author_last_name = 'sunday',
--     @author_date_of_birth = '1985-01-01',
--     @author_email_address = 'sun@example.com',
--     @author_telephone_number = '1274-678',
--     @author_street_number = 456,
--     @author_street_address = '459 Main St',
--     @author_city = 'shicago',
--     @author_state = 'SH',
--     @author_postcode = '12387';


-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'DBOOK Publishing',
-- @publisher_telephone_number = '444-5678',
-- @publisher_email = 'dbooke@xyzpublishing.com',
-- @pulisher_street_number = 560,
-- @pulisher_street_address = '458 Johnson St',
-- @pulisher_city = 'Newcastle',
-- @pulisher_state = 'NW',
-- @pulisher_postcode = '9876',
-- @item_title = 'Gone Girl',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'abiola',
-- @author_last_name = 'moshood',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'abiola@example.com',
-- @author_telephone_number = '555-678',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';



-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'LABEL Publishing',
-- @publisher_telephone_number = '005-5678',
-- @publisher_email = 'myemail@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Buton',
-- @pulisher_state = 'BT',
-- @pulisher_postcode = '9876',
-- @item_title = 'Angels and Demons',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'paul',
-- @author_last_name = 'jack',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'jack@example.com',
-- @author_telephone_number = '456-699',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';






-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'WINNERS Publishing',
-- @publisher_telephone_number = '885-5678',
-- @publisher_email = 'jobmail@xyzpublishing.com',
-- @pulisher_street_number = 589,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Buton',
-- @pulisher_state = 'BT',
-- @pulisher_postcode = '9876',
-- @item_title = 'Game of thrones',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'john',
-- @author_last_name = 'snow',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'snow@example.com',
-- @author_telephone_number = '000-699',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';






-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'Movie Publishing',
-- @publisher_telephone_number = '266-5678',
-- @publisher_email = 'mymovie@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Buton',
-- @pulisher_state = 'BT',
-- @pulisher_postcode = '9876',
-- @item_title = 'The Lord of the Rings',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'saka',
-- @author_last_name = 'bukayo',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'saka@example.com',
-- @author_telephone_number = '299-699',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';





-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'Pride Publishing',
-- @publisher_telephone_number = '0985-5678',
-- @publisher_email = 'pridel@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Buton',
-- @pulisher_state = 'BT',
-- @pulisher_postcode = '9876',
-- @item_title = 'Pride and Prejudice',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'not available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'camila',
-- @author_last_name = 'camilo',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'camilo@example.com',
-- @author_telephone_number = '088-699',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';




-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'ALL Publishing',
-- @publisher_telephone_number = '111-5678',
-- @publisher_email = 'myallemail@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Newcastle',
-- @pulisher_state = 'NW',
-- @pulisher_postcode = '9876',
-- @item_title = 'All or nothing',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'documentry',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'arsenal',
-- @author_last_name = 'pride of london',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'arsenal@example.com',
-- @author_telephone_number = '111-699',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';


-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'QDOT Publishing',
-- @publisher_telephone_number = '500-5678',
-- @publisher_email = 'qdot@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Newcastle',
-- @pulisher_state = 'NW',
-- @pulisher_postcode = '9876',
-- @item_title = 'The Catcher in the Rye 2',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'Available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'catcher',
-- @author_last_name = 'rey',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'rey@example.com',
-- @author_telephone_number = '533-600',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'London',
-- @author_state = 'LD',
-- @author_postcode = '1299';



-- EXEC insertAllCatalogueAssociatedTables
-- @publisher_name = 'ikigai Publishing',
-- @publisher_telephone_number = '777-5678',
-- @publisher_email = 'ikigai@xyzpublishing.com',
-- @pulisher_street_number = 561,
-- @pulisher_street_address = '430 morrison St',
-- @pulisher_city = 'Tokyo',
-- @pulisher_state = 'TK',
-- @pulisher_postcode = '9876',
-- @item_title = 'Ikigai',
-- @year_of_publication = '2022-02-22',
-- @date_added = '2023-04-18',
-- @item_type = 'book',
-- @item_isbn = '1234-5678',
-- @item_status_value = 'not available',
-- @item_status_date = '2022-02-15',
-- @author_first_name = 'mimi',
-- @author_last_name = 'aiko',
-- @author_date_of_birth = '1985-01-01',
-- @author_email_address = 'aiko@example.com',
-- @author_telephone_number = '444-600',
-- @author_street_number = 456,
-- @author_street_address = '450 Jones St',
-- @author_city = 'Tokyo',
-- @author_state = 'TK',
-- @author_postcode = '1299';



-- -----adding members to the table--------

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Jonathan davids',
--     @date_of_birth = '1990-05-12',
--     @email_address = 'jonathan.smith@example.com',
--     @telephone_number = '000-456-7890',
--     @street_number = 123,
--     @street_address = 'Main St',
--     @city = 'Anytown',
--     @state = 'NY',
--     @postcode = '12345',
--     @gender = 'Male',
--     @username = 'jonathanDavis',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2020-01-01',
--     @membership_end_date = NULL,
--     @membership_suspended_date = NULL;

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Sarah Johnson',
--     @date_of_birth = '1985-11-02',
--     @email_address = 'sarah.johnson@example.com',
--     @telephone_number = '555-555-5555',
--     @street_number = 456,
--     @street_address = 'Broadway',
--     @city = 'Anytown',
--     @state = 'CA',
--     @postcode = '54321',
--     @gender = 'Female',
--     @username = 'sjohnson',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2019-05-01',
--     @membership_end_date = NULL,
--     @membership_suspended_date = '2022-03-15';

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Michael Lee',
--     @date_of_birth = '1987-09-20',
--     @email_address = 'michael.lee@example.com',
--     @telephone_number = '777-777-7777',
--     @street_number = 789,
--     @street_address = 'Park Ave',
--     @city = 'Anytown',
--     @state = 'FL',
--     @postcode = '98765',
--     @gender = 'Male',
--     @username = 'mlee',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2021-01-01',
--     @membership_end_date = '2022-12-31',
--     @membership_suspended_date = NULL;

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Emily Wilson',
--     @date_of_birth = '1995-02-14',
--     @email_address = 'emily.wilson@example.com',
--     @telephone_number = NULL,
--     @street_number = 456,
--     @street_address = 'Main St',
--     @city = 'Anytown',
--     @state = 'TX',
--     @postcode = '67890',
--     @gender = 'Female',
--     @username = 'ewilson',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2018-06-01',
--     @membership_end_date = NULL,
--     @membership_suspended_date = NULL;


-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'David Brown',
--     @date_of_birth = '1993-11-22',
--     @email_address = 'david.brown@example.com',
--     @telephone_number = '555-9876',
--     @street_number = 789,
--     @street_address = 'Park Ave',
--     @city = 'Chicago',
--     @state = 'IL',
--     @postcode = '60601',
--     @gender = 'Male',
--     @username = 'davidbrown',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2022-03-01',
--     @membership_end_date = '2023-02-28',
--     @membership_suspended_date = NULL;

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Karen Taylor',
--     @date_of_birth = '1978-06-05',
--     @email_address = 'karen.taylor@example.com',
--     @telephone_number = '555-6789',
--     @street_number = 321,
--     @street_address = 'State St',
--     @city = 'Boston',
--     @state = 'MA',
--     @postcode = '02101',
--     @gender = 'Female',
--     @username = 'karentaylor',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2021-10-01',
--     @membership_end_date = '2022-09-30',
--     @membership_suspended_date = NULL;


--     EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Mila Kunis',
--     @date_of_birth = '1983-08-14',
--     @email_address = 'mila.kunis@example.com',
--     @telephone_number = '555-555-1234',
--     @street_number = 123,
--     @street_address = 'Main St.',
--     @city = 'Los Angeles',
--     @state = 'California',
--     @postcode = '90001',
--     @gender = 'Female',
--     @username = 'milak',
--     @password = 0x7C5A2A474053F20BB0CCED39A96A5D01610C9E1A,
--     @membership_start_date = '2022-03-01',
--     @membership_end_date = '2023-03-01'

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Saoirse Ronan',
--     @date_of_birth = '1994-04-12',
--     @email_address = 'saoirse.ronan@example.com',
--     @telephone_number = '555-555-5678',
--     @street_number = 456,
--     @street_address = 'Oak St.',
--     @city = 'New York',
--     @state = 'New York',
--     @postcode = '10001',
--     @gender = 'Female',
--     @username = 'saoirser',
--     @password = 0xD29EAE99FCFDB6371EE0EBF88E864DD77EBFD5F5,
--     @membership_start_date = '2022-02-01',
--     @membership_end_date = '2023-02-01'

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Tom Hardy',
--     @date_of_birth = '1977-09-15',
--     @email_address = 'tom.hardy@example.com',
--     @telephone_number = '555-555-9101',
--     @street_number = 789,
--     @street_address = 'Park Ave.',
--     @city = 'London',
--     @state = '',
--     @postcode = 'EC1Y 8SY',
--     @gender = 'Male',
--     @username = 'tomh',
--     @password = 0x67B7B2F78BB9E9D0B8C0399020D3EB5393F05D7E,
--     @membership_start_date = '2022-01-01',
--     @membership_end_date = '2023-01-01'

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus
--     @full_name = 'Emma Stone',
--     @date_of_birth = '1988-11-06',
--     @email_address = 'emma.stone@example.com',
--     @telephone_number = '555-555-1212',
--     @street_number = 101,
--     @street_address = '1st St.',
--     @city = 'Los Angeles',
--     @state = 'California',
--     @postcode = '90001',
--     @gender = 'Female',
--     @username = 'emmast',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2022-04-01',
--     @membership_end_date = '2023-04-01'


-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus 
--     @full_name = 'Robert Davis',
--     @date_of_birth = '1980-12-05',
--     @email_address = 'robert.davis@gmail.com',
--     @telephone_number = '666-9876',
--     @street_number = 789,
--     @street_address = 'Elm St',
--     @city = 'New York',
--     @state = 'NY',
--     @postcode = '10001',
--     @gender = 'Male',
--     @username = 'robert.davis',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2022-03-01',
--     @membership_end_date = '2022-12-31',
--     @membership_suspended_date = NULL;

-- EXEC addNewMemberWithAddressAndAuthAndGenderAndMemberShipStatus 
--     @full_name = 'Emily Chen',
--     @date_of_birth = '1995-08-11',
--     @email_address = 'emily.chen@gmail.com',
--     @telephone_number = '555-4321',
--     @street_number = 246,
--     @street_address = 'Cedar St',
--     @city = 'Boston',
--     @state = 'MA',
--     @postcode = '02108',
--     @gender = 'Female',
--     @username = 'emily.chen',
--     @password = 0x1E8C5F20D86431ED4D4C7A522436B3830D9F189A,
--     @membership_start_date = '2022-04-01',
--     @membership_end_date = '2022-12-31',
--     @membership_suspended_date = NULL;



-----INSERTING LOAN-----

-- EXEC insertIntoLoans
--     @item_id = 1,
--     @member_id = 1,
--     @date_taken_out = '2023-04-10',
--     @date_due_back = '2023-04-24',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 2,
--     @member_id = 2,
--     @date_taken_out = '2023-04-12',
--     @date_due_back = '2023-04-25',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 3,
--      @member_id = 1,
--     @date_taken_out = '2023-04-15',
--     @date_due_back = '2023-04-23',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 4,
--      @member_id = 3,
--     @date_taken_out = '2023-04-17',
--     @date_due_back = '2023-04-26',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 11,
--     @member_id = 1,
--     @date_taken_out = '2023-04-20',
--     @date_due_back = '2023-04-24',
--     @date_returned = NULL,
--     @status = 'Not-Returned'



-- EXEC insertIntoLoans
--     @item_id = 6,
--      @member_id = 1,
--     @date_taken_out = '2023-04-22',
--     @date_due_back = '2023-04-26',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 7,
--      @member_id = 6,
--     @date_taken_out = '2023-04-25',
--     @date_due_back = '2023-04-22',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 8,
--      @member_id = 1,
--     @date_taken_out = '2023-04-27',
--     @date_due_back = '2023-04-24',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 9,
--      @member_id = 5,
--     @date_taken_out = '2023-04-30',
--     @date_due_back = '2023-05-25',
--     @date_returned = NULL,
--     @status = 'Not-Returned'

-- EXEC insertIntoLoans
--     @item_id = 13,
--     @member_id = 4,
--     @date_taken_out = '2023-05-01',
--     @date_due_back = '2023-05-08',
--     @date_returned = NULL,
--     @status = 'Not-Returned'


----payment----

-- EXEC insertFine_payment @amount_paid = 20.00, @member_id = 1, @loan_id = 1, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 50.00, @member_id = 2, @loan_id = 2, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 30.00, @member_id = 3, @loan_id = 3, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 40.00, @member_id = 4, @loan_id = 4, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 60.00, @member_id = 5, @loan_id = 5, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 300.00, @member_id = 6, @loan_id = 17, @time = '12:30:00'
-- EXEC insertFine_payment @amount_paid = 35.00, @member_id = 7, @loan_id = 7, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 45.00, @member_id = 8, @loan_id = 8, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 55.00, @member_id = 9, @loan_id = 9, @time = '12:30:00';
-- EXEC insertFine_payment @amount_paid = 15.00, @member_id = 10, @loan_id = 10, @time = '12:30:00';


--payment method--

-- EXEC insertpayment_method @fine_payment_id = 2, @fine_payment_method = 'Credit Card';
-- EXEC insertpayment_method @fine_payment_id = 2, @fine_payment_method = 'Debit Card';
-- EXEC insertpayment_method @fine_payment_id = 3, @fine_payment_method = 'PayPal';
-- EXEC insertpayment_method @fine_payment_id = 4, @fine_payment_method = 'Apple Pay';
-- EXEC insertpayment_method @fine_payment_id = 5, @fine_payment_method = 'Google Wallet';
-- EXEC insertpayment_method @fine_payment_id = 6, @fine_payment_method = 'Venmo';
-- EXEC insertpayment_method @fine_payment_id = 7, @fine_payment_method = 'Cash';
-- EXEC insertpayment_method @fine_payment_id = 8, @fine_payment_method = 'Check';
-- EXEC insertpayment_method @fine_payment_id = 9, @fine_payment_method = 'Money Order';
-- EXEC insertpayment_method @fine_payment_id = 10, @fine_payment_method = 'Bank Transfer';


---insert item review---

-- EXEC insertItemReview  6, 4, 'Great book!'
-- EXEC insertItemReview  7, 5, 'Excellent read!'
-- EXEC insertItemReview  8, 3, 'Average book'
-- EXEC insertItemReview 9, 2, 'Not impressed with the plot'
-- EXEC insertItemReview  10, 4, 'Good characters and pacing'
-- EXEC insertItemReview  11, 4, 'Satisfied with the story'
-- EXEC insertItemReview  12, 1, 'Terrible book'
-- EXEC insertItemReview 3, 5, 'Impressed with the writing style'
-- EXEC insertItemReview  4, 2, 'Disappointing ending'
-- EXEC insertItemReview 5, 3, 'Could be better'


--author's review-----

-- EXEC insertAuthorReview 1, 4, 'Great author!'
-- EXEC insertAuthorReview 2, 5, 'Excellent writing skills!'
-- EXEC insertAuthorReview 1, 3, 'Average author'
-- EXEC insertAuthorReview 3, 2, 'Not impressed with the storytelling'
-- EXEC insertAuthorReview 4, 4, 'Good style and approach'
-- EXEC insertAuthorReview 2, 4, 'Satisfied with the book'
-- EXEC insertAuthorReview 5, 1, 'Terrible author'
-- EXEC insertAuthorReview 3, 5, 'Impressed with the creativity'
-- EXEC insertAuthorReview 4, 2, 'Disappointing works'
-- EXEC insertAuthorReview 5, 3, 'Could be better'


-- ---item reservation----
-- EXEC makeReservation 1, '2023-04-22', 1
-- EXEC makeReservation 2, '2023-04-23', 2
-- EXEC makeReservation 1, '2023-04-24', 3
-- EXEC makeReservation 3, '2023-04-25', 4
-- EXEC makeReservation 4, '2023-04-26', 5
-- EXEC makeReservation 2, '2023-04-27', 6
-- EXEC makeReservation 5, '2023-04-28', 7
-- EXEC makeReservation 3, '2023-04-29', 8
-- EXEC makeReservation 4, '2023-04-30', 9
-- EXEC makeReservation 5, '2023-05-01', 10


-- ----item reservation status---
-- EXEC insertItemReservationStatus 1, 'Pending'
-- EXEC insertItemReservationStatus 2, 'Approved'
-- EXEC insertItemReservationStatus 3, 'Canceled'
-- EXEC insertItemReservationStatus 4, 'Pending'
-- EXEC insertItemReservationStatus 5, 'Approved'
-- EXEC insertItemReservationStatus 6, 'Canceled'
-- EXEC insertItemReservationStatus 7, 'Pending'
-- EXEC insertItemReservationStatus 8, 'Approved'
-- EXEC insertItemReservationStatus 9, 'Canceled'
-- EXEC insertItemReservationStatus 10, 'Pending'


------------------------UPDATE MEMBER'S DETAILS-----------

-- EXEC updateMemberInformation
--     @member_id = 12,
--     @full_name = 'Mrs Emily chen',
--     @date_of_birth = '1992-06-30',
--     @email_address = 'Alan@Salford.co.uk',
--     @telephone_number = '555-4321',
--     @membership_start_date = '2022-04-01',
--     @membership_end_date = '2022-12-31',
--     @membership_suspended_date = NULL,
--     @street_number = 246,
--     @street_address = 'Cedar St',
--     @city = 'Boston',
--     @state = 'VA',
--     @postcode = '300'

   
select * from members