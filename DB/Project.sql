CREATE schema project;  
#DROP schema project;

#create tables
CREATE TABLE Person
(ID INT NOT NULL auto_increment,
PRIMARY KEY (ID),first_name VARCHAR(20),last_name VARCHAR(20),
birthdate DATE,first_dose_date DATE,neighborhood VARCHAR(20),
HMO_ID INT,age INT,second_dose_date DATE,is_high_risk_group BOOLEAN DEFAULT FALSE,is_vaccinated BOOLEAN DEFAULT FALSE
);

CREATE TABLE HMO
(ID INT NOT NULL auto_increment,PRIMARY KEY (ID),name VARCHAR(20)
);

ALTER TABLE Person
ADD FOREIGN KEY(HMO_ID) REFERENCES HMO(ID) ON DELETE CASCADE;

CREATE TABLE Delivery
(delivery_ID INT NOT NULL auto_increment,PRIMARY KEY(delivery_ID),
delivery_date DATE, HMO_ID INT NOT NULL,amount INT,manufacturer VARCHAR(20) NOT NULL
);

CREATE TABLE National_Inventory
(manufacturer VARCHAR(20) NOT NULL,batch_No INT NOT NULL,PRIMARY KEY(manufacturer,batch_No),
amount INT,delivery_date DATE,delivery_ID INT
);

ALTER TABLE Delivery
ADD FOREIGN KEY(manufacturer) REFERENCES National_Inventory(manufacturer) ON DELETE CASCADE;

CREATE TABLE Vaccine
(manufacturer VARCHAR(20) NOT NULL,batch_No INT NOT NULL,FOREIGN KEY(manufacturer,batch_No)
REFERENCES National_Inventory(manufacturer,batch_No) ON DELETE CASCADE,
expiry_date DATE,manufacturing_date DATE
);

CREATE TABLE COVID19_Positive
(ID INT NOT NULL,FOREIGN KEY (ID) REFERENCES Person(ID) ON DELETE CASCADE,infection_date DATE 
);

CREATE TABLE disease
(ID INT NOT NULL auto_increment,PRIMARY KEY (ID),name VARCHAR(20)
);

CREATE TABLE Person_Medical_History
(Person_ID INT NOT NULL,disease_ID INT,PRIMARY KEY (Person_ID,disease_ID),
HMO_ID INT NOT NULL,FOREIGN KEY(HMO_ID) REFERENCES HMO(ID) ON DELETE CASCADE
);

CREATE TABLE HMO_Inventory
(HMO_ID INT NOT NULL,delivery_ID INT,FOREIGN KEY(HMO_ID) REFERENCES HMO(ID) ON DELETE CASCADE,
FOREIGN KEY(delivery_ID) REFERENCES Delivery(delivery_ID) ON DELETE CASCADE,PRIMARY KEY(HMO_ID,delivery_ID),
manufacturer VARCHAR(20),FOREIGN KEY(manufacturer) REFERENCES National_Inventory(manufacturer) ON DELETE CASCADE,
amount INT
);

CREATE TABLE HMO_Inventory_Delivery
(HMO_ID INT NOT NULL,delivery_ID INT NOT NULL,PRIMARY KEY(HMO_ID,delivery_ID),
FOREIGN KEY(HMO_ID) REFERENCES HMO(ID) ON DELETE CASCADE,FOREIGN KEY(delivery_ID) REFERENCES delivery(delivery_ID) ON DELETE CASCADE
);

#triggers
DELIMITER $$

CREATE TRIGGER new_person_trigger BEFORE INSERT
ON Person FOR EACH ROW
BEGIN
	SET new.age=YEAR(CURDATE()) - YEAR(new.birthdate);
    IF new.age > 60 THEN 
    SET new.is_high_risk_group=true;
    END IF;
END $$

CREATE TRIGGER update_second_dose_date BEFORE UPDATE
ON Person FOR EACH ROW
BEGIN
	IF NOT(new.first_dose_date <=> old.first_dose_date) THEN
    SET new.second_dose_date=DATE_ADD(new.first_dose_date, INTERVAL 21 DAY);
    SET new.is_vaccinated=true;
    UPDATE HMO_Inventory INNER JOIN Person ON(HMO_Inventory.HMO_ID=new.HMO_ID)
	SET HMO_Inventory.amount=HMO_Inventory.amount-1;
    END IF;
END $$
DELIMITER ;

#INSERT DATA
INSERT INTO HMO(name)
VALUES
	('Maccabi'),
    ('Clalit'),
    ('Leumit'),
    ('Meohedet');

INSERT INTO Person(first_name,last_name,birthdate,neighborhood,HMO_ID)
VALUES
	('Yakir','Travish',DATE'1997-08-15','A',4),
    ('Ran','Sasson',DATE'1996-12-15','B',1),
    ('Alex','Cohen',DATE'1940-10-01','A',2),
    ('Gregori','Shaulov',DATE'1956-04-30','C',3),
    ('Limor','Tavor',DATE'1982-05-20','C',2),
    ('Sami','Dami',DATE'2000-09-27','A',1),
    ('Dina','Mina',DATE'1969-07-12','B',1),
    ('Oren','Cohen',DATE'1977-05-27','A',4),
    ('Shimi','Mimi',DATE'1950-02-28','C',3);
INSERT INTO disease (name)
VALUES
	('Asthma'),
    ('Lupus'),
    ('ALS'),
    ('High Cholesterol'),
    ('High Blood Preasure'),
    ('Migranes');
        
INSERT INTO person_medical_history(person_ID,disease_ID,HMO_ID)
VALUES
	(3,4,2),
    (3,2,2),
    (4,5,3),
    (4,6,3),
    (9,1,3);
    
INSERT INTO covid19_positive(ID,infection_date)
VALUES
	(7,DATE'2020-05-20'),
    (5,DATE'2021-01-01'),
    (1,DATE'2020-12-31');
    
INSERT INTO national_inventory(manufacturer,batch_No,amount,delivery_date,delivery_ID)
VALUES
('pfizer',1234,100,DATE'2020-12-25',15849),
('pfizer',4567,500,DATE'2021-01-12',15850),
('moderna',6525,300,DATE'2021-01-16',15851),
('moderna',8848,1000,DATE'2021-01-31',15852),
('astrazeneca',1548,2500,DATE'2021-02-01',15853),
('astrazeneca',7777,10000,DATE'2021-02-06',15854),
('moderna',8888,20000,DATE'2021-02-07',15855),
('pfizer',2626,15000,DATE'2021-02-08',15856);


INSERT INTO vaccine(manufacturer,batch_No,expiry_date,manufacturing_date)
VALUES
('pfizer',1234,DATE'2021-02-02',DATE'2020-12-25'),
('pfizer',4567,DATE'2031-01-12',DATE'2021-01-12'),
('moderna',6525,DATE'2031-01-16',DATE'2021-01-16'),
('moderna',8848,DATE'2031-01-31',DATE'2021-01-31'),
('astrazeneca',1548,DATE'2031-02-01',DATE'2021-02-01'),
('astrazeneca',7777,DATE'2031-02-06',DATE'2021-02-06'),
('moderna',8888,DATE'2031-02-07',DATE'2021-02-07'),
('pfizer',2626,DATE'2031-02-08',DATE'2021-02-08');

INSERT INTO delivery(delivery_ID,delivery_date,HMO_ID,amount,manufacturer)
VALUES
(15849,DATE'2020-12-25',1,100,'pfizer'),
(15850,DATE'2021-01-12',2,500,'pfizer'),
(15851,DATE'2021-01-12',4,300,'moderna'),
(15852,DATE'2021-01-31',1,1000,'moderna'),
(15853,DATE'2021-02-01',3,2500,'astrazeneca'),
(15854,DATE'2021-02-06',2,10000,'astrazeneca');

INSERT INTO HMO_Inventory(HMO_ID,delivery_ID,manufacturer,amount)
VALUES
(1,15849,'pfizer',100),
(2,15850,'pfizer',500),
(4,15851,'moderna',300),
(1,15852,'moderna',1000),
(3,15853,'astrazeneca',2500),
(2,15854,'astrazeneca',10000);

INSERT INTO hmo_inventory_delivery(HMO_ID,delivery_ID)
VALUES
(1,15849),
(2,15850),
(4,15851),
(1,15852),
(3,15853),
(2,15854);

update person
set is_vaccinated=true
where person.id<4;

#select statements
SELECT person.ID,person.first_name,person.last_name FROM person
WHERE person.ID NOT IN (SELECT covid19_positive.ID FROM covid19_positive) AND person.is_high_risk_group=TRUE;

SELECT hmo_inventory.manufacturer, SUM(hmo_inventory.amount) AS total_amount FROM hmo_inventory
GROUP BY hmo_inventory.manufacturer;

SELECT vaccine.batch_No,MIN(vaccine.expiry_date) AS expiry_date FROM vaccine;

SELECT person.ID,person.first_name,person.last_name FROM person
WHERE person.first_dose_date IS NOT NULL;

SELECT person.ID,person.first_name,person.last_name FROM person
WHERE person.is_vaccinated=TRUE;

SELECT person.ID,person.first_name,person.last_name FROM person
WHERE person.first_dose_date IS NULL;

SELECT national_inventory.manufacturer, SUM(national_inventory.amount) AS total_amount FROM national_inventory
GROUP BY national_inventory.manufacturer;

SELECT person.ID,person.first_name,person.last_name FROM person
INNER JOIN covid19_positive ON (person.ID=covid19_positive.ID);

SELECT person.HMO_ID,ROUND((SUM(person.is_vaccinated)/COUNT(person.ID)*100),2) AS percent FROM person
GROUP BY person.HMO_ID;

SELECT ROUND((SUM(person.is_vaccinated)/COUNT(person.ID)*100),2) AS percent FROM person;

SELECT person.neighborhood,ROUND((SUM(person.is_vaccinated)/COUNT(person.ID)*100),2) AS percent FROM person
GROUP BY person.neighborhood;

SELECT person.neighborhood,ROUND((COUNT(covid19_positive.ID)/COUNT(person.ID)*100),2) AS percent FROM person
LEFT JOIN covid19_positive ON(person.ID=covid19_positive.ID)
GROUP BY person.neighborhood;

#delete statements 
DELETE FROM vaccine
WHERE vaccine.expiry_date<CURDATE();

#insert statements
DELIMITER $$
INSERT INTO delivery(delivery_ID,delivery_date,HMO_ID,amount,manufacturer)
VALUES
(15855,DATE'2021-02-07',3,20000,'moderna'),
(15856,DATE'2021-02-08',4,15000,'pfizer');
INSERT INTO hmo_inventory(HMO_ID,delivery_ID,manufacturer,amount)
VALUES
(3,15855,'moderna',20000),
(4,15856,'pfizer',15000);
INSERT INTO hmo_inventory_delivery(HMO_ID,delivery_ID)
VALUES
(3,15855),
(4,15856);
$$
DELIMITER ;

INSERT INTO person(first_name,last_name,birthdate,neighborhood,HMO_ID)
VALUES
	('Shlomi','Moshe',DATE'1934-12-15','B',2),
    ('John','Wick',DATE'1951-01-30','C',4);
    
#update statements
UPDATE person SET
person.first_dose_date=CURDATE()
WHERE person.ID=9;

