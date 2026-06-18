CREATE DATABASE SmartTelAI;
GO

USE SmartTelAI;
GO

CREATE TABLE CustomerChurn
(
    customerID VARCHAR(255),
    gender VARCHAR(255),
    SeniorCitizen INT,
    Partner VARCHAR(255),
    Dependents VARCHAR(255),
    tenure INT,
    PhoneService VARCHAR(255),
    MultipleLines VARCHAR(255),
    InternetService VARCHAR(255),
    OnlineSecurity VARCHAR(255),
    OnlineBackup VARCHAR(255),
    DeviceProtection VARCHAR(255),
    TechSupport VARCHAR(255),
    StreamingTV VARCHAR(255),
    StreamingMovies VARCHAR(255),
    Contract VARCHAR(255),
    PaperlessBilling VARCHAR(255),
    PaymentMethod VARCHAR(255),
    MonthlyCharges FLOAT,
    TotalCharges FLOAT,
    Churn VARCHAR(255)
);
SELECT COUNT(*) FROM CustomerChurn;

TRUNCATE TABLE CustomerChurn;

WITH DuplicateRows AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY customerID
               ORDER BY customerID
           ) AS rn
    FROM CustomerChurn
)
DELETE FROM DuplicateRows
WHERE rn > 1;

SELECT customerID,
       COUNT(*)
FROM CustomerChurn
GROUP BY customerID
HAVING COUNT(*) > 1;

UPDATE CustomerChurn
SET TotalCharges = MonthlyCharges
WHERE LTRIM(RTRIM(TotalCharges)) = '';

UPDATE CustomerChurn
SET TotalCharges = MonthlyCharges
WHERE LTRIM(RTRIM(TotalCharges)) = '';

SELECT *
FROM CustomerChurn
WHERE TotalCharges IS NULL;

SELECT *
FROM CustomerChurn
WHERE MonthlyCharges > 100;

CREATE TABLE DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(50),
    Gender VARCHAR(20),
    SeniorCitizen INT,
    Partner VARCHAR(10),
    Dependents VARCHAR(10)
);

CREATE TABLE DimService
(
    ServiceKey INT IDENTITY(1,1) PRIMARY KEY,

    InternetService VARCHAR(50),
    OnlineSecurity VARCHAR(50),
    OnlineBackup VARCHAR(50),
    DeviceProtection VARCHAR(50),
    TechSupport VARCHAR(50),
    StreamingTV VARCHAR(50),
    StreamingMovies VARCHAR(50)
);

CREATE TABLE DimContract
(
    ContractKey INT IDENTITY(1,1) PRIMARY KEY,

    Contract VARCHAR(50),
    PaperlessBilling VARCHAR(10)
);

CREATE TABLE DimPayment
(
    PaymentKey INT IDENTITY(1,1) PRIMARY KEY,

    PaymentMethod VARCHAR(100)
);

CREATE TABLE FactCustomerChurn
(
    FactID INT IDENTITY(1,1) PRIMARY KEY,

    CustomerKey INT,
    ServiceKey INT,
    ContractKey INT,
    PaymentKey INT,

    Tenure INT,
    MonthlyCharges FLOAT,
    TotalCharges FLOAT,
    Churn VARCHAR(10),

    FOREIGN KEY(CustomerKey)
    REFERENCES DimCustomer(CustomerKey),

    FOREIGN KEY(ServiceKey)
    REFERENCES DimService(ServiceKey),

    FOREIGN KEY(ContractKey)
    REFERENCES DimContract(ContractKey),

    FOREIGN KEY(PaymentKey)
    REFERENCES DimPayment(PaymentKey)
);

INSERT INTO DimCustomer
(
CustomerID,
Gender,
SeniorCitizen,
Partner,
Dependents
)
SELECT DISTINCT
customerID,
gender,
SeniorCitizen,
Partner,
Dependents
FROM CustomerChurn;

INSERT INTO DimService
(
InternetService,
OnlineSecurity,
OnlineBackup,
DeviceProtection,
TechSupport,
StreamingTV,
StreamingMovies
)
SELECT DISTINCT
InternetService,
OnlineSecurity,
OnlineBackup,
DeviceProtection,
TechSupport,
StreamingTV,
StreamingMovies
FROM CustomerChurn;

INSERT INTO DimContract
(
Contract,
PaperlessBilling
)
SELECT DISTINCT
Contract,
PaperlessBilling
FROM CustomerChurn;

INSERT INTO DimPayment
(
PaymentMethod
)
SELECT DISTINCT
PaymentMethod
FROM CustomerChurn;


INSERT INTO FactCustomerChurn
(
CustomerKey,
ServiceKey,
ContractKey,
PaymentKey,
Tenure,
MonthlyCharges,
TotalCharges,
Churn
)
SELECT

dc.CustomerKey,
ds.ServiceKey,
dco.ContractKey,
dp.PaymentKey,

c.tenure,
c.MonthlyCharges,
c.TotalCharges,
c.Churn

FROM CustomerChurn c

JOIN DimCustomer dc
ON c.customerID = dc.CustomerID

JOIN DimService ds
ON c.InternetService = ds.InternetService
AND c.OnlineSecurity = ds.OnlineSecurity
AND c.OnlineBackup = ds.OnlineBackup
AND c.DeviceProtection = ds.DeviceProtection
AND c.TechSupport = ds.TechSupport
AND c.StreamingTV = ds.StreamingTV
AND c.StreamingMovies = ds.StreamingMovies

JOIN DimContract dco
ON c.Contract = dco.Contract
AND c.PaperlessBilling = dco.PaperlessBilling

JOIN DimPayment dp
ON c.PaymentMethod = dp.PaymentMethod;

SELECT COUNT(*)
FROM FactCustomerChurn;

SELECT Contract,
       Churn,
       COUNT(*) TotalCustomers
FROM CustomerChurn
GROUP BY ROLLUP(Contract, Churn);


SELECT Gender,
       Contract,
       COUNT(*) Customers
FROM CustomerChurn
GROUP BY CUBE(Gender, Contract);


SELECT Contract,
       InternetService,
       COUNT(*) Customers
FROM CustomerChurn
GROUP BY GROUPING SETS
(
(Contract),
(InternetService),
(Contract, InternetService)
);


SELECT customerID,
       MonthlyCharges,
       ROW_NUMBER()
       OVER(ORDER BY MonthlyCharges DESC) AS RowNum
FROM CustomerChurn;


SELECT customerID,
       MonthlyCharges,
       RANK()
       OVER(ORDER BY MonthlyCharges DESC) AS Ranking
FROM CustomerChurn;


SELECT customerID,
       MonthlyCharges,
       NTILE(4)
       OVER(ORDER BY MonthlyCharges DESC) AS Quartile
FROM CustomerChurn;


SELECT customerID,
       tenure,
       LEAD(tenure)
       OVER(ORDER BY tenure) AS NextTenure
FROM CustomerChurn;