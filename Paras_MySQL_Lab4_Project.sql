CREATE DATABASE IF NOT EXISTS E_Commerce_orders_db;
USE E_Commerce_orders_db;

-- PS (1)To create tables for supplier,customer,category,product,productDetails,order,rating to store the data for the E-commerce 
CREATE TABLE IF NOT EXISTS Supplier (
    SUPP_ID INT PRIMARY KEY AUTO_INCREMENT,
    SUPP_NAME VARCHAR(50),
    SUPP_CITY VARCHAR(30),
    SUPP_PHONE BIGINT
);

CREATE TABLE IF NOT EXISTS Customer (
    CUS_ID INT PRIMARY KEY AUTO_INCREMENT,
    CUS_NAME VARCHAR(50),
    CUS_PHONE BIGINT,
    CUS_CITY VARCHAR(30),
    CUS_GENDER VARCHAR(1)
);

CREATE TABLE IF NOT EXISTS Category (
    CAT_ID INT PRIMARY KEY,
    CAT_NAME VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS Product (
    PRO_ID INT PRIMARY KEY,
    PRO_NAME VARCHAR(30),
    PRO_DESC VARCHAR(50),
    CAT_ID INT NOT NULL,
    CONSTRAINT FK_Product_Category_ID FOREIGN KEY (CAT_ID)
        REFERENCES Category (CAT_ID)
);

CREATE TABLE IF NOT EXISTS ProductDetails (
    PROD_ID INT PRIMARY KEY,
    PRO_ID INT NOT NULL,
    SUPP_ID INT NOT NULL,
    PRICE INT,
    CONSTRAINT FK_ProductDetails_Product_ID FOREIGN KEY (PRO_ID)
        REFERENCES Product (PRO_ID),
    CONSTRAINT FK_ProductDetails_Supplier_ID FOREIGN KEY (SUPP_ID)
        REFERENCES Supplier (SUPP_ID)
);

CREATE TABLE IF NOT EXISTS `Order` (
    ORD_ID INT PRIMARY KEY,
    ORD_AMOUNT INT,
    ORD_DATE DATE,
    CUS_ID INT NOT NULL,
    PROD_ID INT NOT NULL,
    CONSTRAINT FK_Order_Customer_ID FOREIGN KEY (CUS_ID)
        REFERENCES Customer (CUS_ID),
    CONSTRAINT FK_Order_ProductDetails_ID FOREIGN KEY (PROD_ID)
        REFERENCES ProductDetails (PROD_ID)
);

CREATE TABLE IF NOT EXISTS Rating (
    RAT_ID INT PRIMARY KEY,
    CUS_ID INT NOT NULL,
    SUPP_ID INT NOT NULL,
    RAT_RATSTARS INT,
    CONSTRAINT FK_Rating_Customer_ID FOREIGN KEY (CUS_ID)
        REFERENCES Customer (CUS_ID),
    CONSTRAINT FK_Rating_Supplier_ID FOREIGN KEY (SUPP_ID)
        REFERENCES Supplier (SUPP_ID)
);

-- PS (2)To Insert the following data in the table created above
INSERT INTO supplier VALUES (1,"Rajesh Retails","Delhi",1234567890);
INSERT INTO supplier VALUES (2,"Appario Ltd.","Mumbai",2589631470);
INSERT INTO supplier VALUES (3,"Knome products","Banglore",9785462315);
INSERT INTO supplier VALUES (4,"Bansal Retails","Kochi",8975463285);
INSERT INTO supplier VALUES (5,"Mittal Ltd.","Lucknow",7898456532);

INSERT INTO customer VALUES (1,"AAKASH",'9999999999',"DELHI","M");
INSERT INTO customer VALUES (2,"AMAN",'9785463215',"NOIDA","M");
INSERT INTO customer VALUES (3,"NEHA",'9999999999',"MUMBAI","F");
INSERT INTO customer VALUES (4,"MEGHA",'9994562399',"KOLKATA","F");
INSERT INTO customer VALUES (5,"PULKIT",'7895999999',"LUCKNOW","M");

INSERT INTO category VALUES (1,"BOOKS");
INSERT INTO category VALUES (2,"GAMES");
INSERT INTO category VALUES (3,"GROCERIES");
INSERT INTO category VALUES (4,"ELECTRONICS");
INSERT INTO category VALUES (5,"CLOTHES");

INSERT INTO product VALUES (1,"GTA V","DFJDJFDJFDJFDJFJF",2);
INSERT INTO product VALUES (2,"TSHIRT","DFDFJDFJDKFD",5);
INSERT INTO product VALUES (3,"ROG LAPTOP","DFNTTNTNTERND",4);
INSERT INTO product VALUES (4,"OATS","REURENTBTOTH",3);
INSERT INTO product VALUES (5,"HARRY POTTER","NBEMCTHTJTH",1);

INSERT INTO productdetails VALUES (1,1,2,1500);
INSERT INTO productdetails VALUES (2,3,5,30000);
INSERT INTO productdetails VALUES (3,5,1,3000);
INSERT INTO productdetails VALUES (4,2,3,2500);
INSERT INTO productdetails VALUES (5,4,1,1000);

INSERT INTO `order` VALUES (50,2000,"2021-10-06",2,1);
INSERT INTO `order` VALUES (20,1500,"2021-10-12",3,5);
INSERT INTO `order` VALUES (25,30500,"2021-09-16",5,2);
INSERT INTO `order` VALUES (26,2000,"2021-10-05",1,1);
INSERT INTO `order` VALUES (30,3500,"2021-08-16",4,3);

INSERT INTO rating VALUES (1,2,2,4);
INSERT INTO rating VALUES (2,3,4,3);
INSERT INTO rating VALUES (3,5,1,5);
INSERT INTO rating VALUES (4,1,3,2);
INSERT INTO rating VALUES (5,4,5,4);

-- PS (3)To display the number of the customer group by their genders who have placed any order of amount greater than or equal to Rs.3000
SELECT 
    customer.CUS_GENDER AS 'Gender', COUNT(*) AS 'Count'
FROM
    customer
        INNER JOIN
    `order` USING (CUS_ID)
WHERE
    `order`.ORD_AMOUNT >= 3000
GROUP BY CUS_GENDER;

-- PS (4)To display all the orders along with the product name ordered by a customer having Customer_Id=2
SELECT 
    O.*, P.PRO_NAME
FROM
    `order` O,
    productdetails PD,
    product P
WHERE
    O.CUS_ID = 2 AND O.PROD_ID = PD.PROD_ID
        AND PD.PRO_ID = P.PRO_ID;

-- PS (5)To display the Supplier details who can supply more than one product
SELECT 
    *
FROM
    supplier
WHERE
    SUPP_ID IN ( SELECT SUPP_ID FROM productdetails GROUP BY SUPP_ID HAVING COUNT(SUPP_ID) > 1);


-- PS (6)to find the category of the product whose order amount is minimum
SELECT 
    category.*
FROM
    `order`
        INNER JOIN
    productdetails USING (PROD_ID)
        INNER JOIN
    product USING (PRO_ID)
        INNER JOIN
    category USING (CAT_ID)
HAVING MIN(`order`.ORD_AMOUNT);


-- PS (7)To display the Id and Name of the Product ordered after “2021-10-05”
SELECT 
    P.PRO_ID AS "Id",
    P.PRO_NAME AS "Product"
FROM
    `order` O
        INNER JOIN
    productdetails USING(PROD_ID)
        INNER JOIN
    product P USING(PRO_ID)
WHERE
    O.ORD_DATE > '2021-10-05';


-- PS (8) To display customer name and gender whose names start or end with character 'A'
SELECT 
    CUS_NAME AS "Customer Name", CUS_GENDER AS "Gender"
FROM
    customer
WHERE
    CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';


-- PS (9) To create a stored procedure to display the Rating for a Supplier if any along with the Verdict on that rating if any like 
--      if rating >4 then “Genuine Supplier” 
--      if rating >2 “Average Supplier” 
--      else “Supplier should not be considered”
DELIMITER $$
USE E_Commerce $$
CREATE PROCEDURE spSupplierRating()
BEGIN
SELECT 
    supplier.SUPP_ID AS "ID",
    supplier.SUPP_NAME AS "Supplier's Name",
    rating.RAT_RATSTARS AS "Ratings",
    CASE
        WHEN rating.RAT_RATSTARS > 4 THEN 'Genuine Supplier'
        WHEN rating.RAT_RATSTARS > 2 THEN 'Average Supplier'
        ELSE 'Supplier should not be considered'
    END AS Verdict
FROM
    rating
        INNER JOIN
    supplier ON supplier.SUPP_ID = rating.SUPP_ID;
END $$
DELIMITER ;

CALL spSupplierRating()
