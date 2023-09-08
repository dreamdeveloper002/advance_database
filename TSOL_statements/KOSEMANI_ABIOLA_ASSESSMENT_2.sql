
------------- Create a database with database name PrescriptionsDB ----------

CREATE DATABASE PrescriptionsDB


---------- USE the just created PrescriptionsDB ----------
USE PrescriptionsDB;


------------- alter the Prescriptions table and make PRESCRIPTION_CODE column the primary key column -----------
-----FIRST ALTER STATEMENT---
ALTER TABLE dbo.Prescriptions
ADD PRIMARY KEY (PRESCRIPTION_CODE)


-------------- alter the Drugs table and make BNF_CODE column the primary key ---------------
----SECOND ALTER STATEMENT----
ALTER TABLE dbo.Drugs
ADD PRIMARY KEY (BNF_CODE)


------------------- alter the Medical_Practice table and make PRACTICE_CODE column the primary key column ------------
---THIRD ALTER STATEMENT---
ALTER TABLE dbo.Medical_Practice
ADD PRIMARY KEY (PRACTICE_CODE)


---------------------- alter Prescriptions table and make BNF_CODE the foreign key column which refrences drugs table-----------
----FOURTH ALTER STATEMENT---
ALTER TABLE dbo.Prescriptions
ADD CONSTRAINT fk_bnf_code
FOREIGN KEY (BNF_CODE) REFERENCES dbo.Drugs (BNF_CODE)


------------------------ alter Prescriptions table and make PRACTICE_CODE the foreign key column which refrences medical_practice table-------------
----FIFTH ALTER STATEMENT---
ALTER TABLE dbo.Prescriptions
ADD CONSTRAINT fk_pratice_code
FOREIGN KEY (PRACTICE_CODE) REFERENCES dbo.Medical_Practice(PRACTICE_CODE)



--------------------- QUESTION NO 2 ---------------------

---------------search the drugs table, where bnf_description column contains capsu or tab characters in them----------------

select * from dbo.Drugs where bnf_description like '%capsu%' or bnf_description like '%tab%'




----------------------- QUESTION NO 3 -----------------------
---------------------- select prescription_code, and multiply quantity by item then tittle the outcome of the result 'total quantity prescriptions'  

select prescription_code, (floor(quantity) * items) as 'total quantity prescriptions' FROM dbo.Prescriptions




-------------------------- QUESTION NO 4 --------------------------------

------------- select only distinct(different) values form chemical_substance_bnf_descr column in drugs table -------------------

select distinct(chemical_substance_bnf_descr) from dbo.Drugs




------------------- QUESTION NO 5 -------------

-----------------calculates the minimum, maximum, and average actual cost for each distinct value of bnf_chapter_plus_code --
----- in the drugs table, and also counts the total number of prescriptions for each bnf_chapter_plus_code value ---

select
    max(p.actual_cost) as 'minimum cost',
    avg(p.actual_cost) as 'average cost',
    min(p.actual_cost) as 'maxiximum cost',
    d.bnf_chapter_plus_code,
    count(*) as 'total number of prescriptions'
from
    dbo.drugs AS d
    join dbo.prescriptions  AS p on d.bnf_code = p.bnf_code
group by
d.bnf_chapter_plus_code



---------------- QUESTION NO 6 -----------------
---- this query returns the most expensive prescription prescribed(max(p.actual_cost) as 'maximum cost') by each practice name ----
---- sorted in descending order('maximum cost' desc) by prescription cost('maximum cost') ----------
--- this also returns the rows where the most expensive prescriprions is more than 4000(having max(p.actual_cost) > 4000) -------

select
    d.bnf_description,
    max(p.actual_cost) as 'maximum cost',
    m.practice_name
from
    dbo.medical_practice m
    join dbo.prescriptions p on m.practice_code = p.practice_code
    join dbo.drugs d on p.bnf_code = d.bnf_code
group by
 d.bnf_description,
 m.practice_name
having
   max(p.actual_cost) > 4000
order by
   'maximum cost' desc






-------------------QUESTION NO 7A--------------------
--Find the drugs that were prescribed by more than one medical practice

SELECT Drugs.BNF_DESCRIPTION
FROM Drugs
JOIN Prescriptions ON Drugs.BNF_CODE = Prescriptions.BNF_CODE
GROUP BY Drugs.BNF_DESCRIPTION
HAVING COUNT(DISTINCT Prescriptions.PRACTICE_CODE) > 1


-------------------QUESTION NO 7B------------------
---returns the sum of total cost of each prescription prescribe by kildonan house----

SELECT d.BNF_DESCRIPTION, SUM(p.ACTUAL_COST) AS 'sum total cost of prescriptions'
FROM Prescriptions AS p
JOIN Medical_Practice  AS mp ON p.PRACTICE_CODE = mp.PRACTICE_CODE
JOIN Drugs AS d ON p.BNF_CODE = d.BNF_CODE
WHERE mp.PRACTICE_NAME = 'KILDONAN HOUSE'
GROUP BY d.BNF_DESCRIPTION;




---------------QUESTION NO 7C------------------------
--- this returns practice name with total numbers of prescriptions greater than 500 with the sum of total numbers of items ---
--- and average prescriptions cost orderby total numbers of items, the average cost, the number of prescriptions in desc order---
SELECT
    Medical_Practice.PRACTICE_NAME,
    SUM(Prescriptions.ITEMS) AS 'total numbers of items',
    AVG(Prescriptions.ACTUAL_COST) AS 'the average cost',
    COUNT(*) AS 'the number of prescriptions'
FROM Prescriptions
JOIN Medical_Practice ON Prescriptions.PRACTICE_CODE = Medical_Practice.PRACTICE_CODE
GROUP BY Medical_Practice.PRACTICE_NAME
HAVING COUNT(*) > 500
ORDER BY 'total numbers of items', 'the average cost', 'the number of prescriptions' DESC;




------------------------QUESTION NO 7D-------------------------
--select practice code, and count the total number of prescriptions from prescriptions table where quantity is greater than 500 ---
---- and the practice have prescribe more than once, group by practice code ---

SELECT PRACTICE_CODE, COUNT(*) AS 'Total number of prescriptions'
FROM Prescriptions
WHERE FLOOR(QUANTITY) > 500
GROUP BY PRACTICE_CODE
HAVING COUNT(*) > 1
ORDER BY 'Total number of prescriptions' DESC;



-------------------------QUESTION NO 7E--------------------------------

select count(*) as 'total number of practice centers in address_2', address_2
from dbo.medical_practice
group by address_2;

select count(*) as 'total number of practice centers in address_3', address_3
from dbo.medical_practice
group by address_3;

select count(*) as 'total number of practice centers in address_4', address_4
from dbo.medical_practice
group by address_4;
