
CREATE TABLE Q2_headstart (
    name varchar(50),
    typeString varchar(50),
    addressLineOne varchar(50),
    addressLineTwo varchar(50),
    city varchar(50),
    state varchar(50),
    zipFive varchar(50),
    zipFour varchar(50),
    county varchar(50),
    isPoBoxLocation Boolean,
    phone varchar(50),
    drivingDirectionsLink varchar(100),
    grantNumber varchar(50),
    delegateNumber varchar(50),
    programName varchar(50),
    programAddressLineOne varchar(50),
    programAddressLineTwo varchar(50),
    programCity	programState varchar(50),
    programZipFive varchar(50),
    programZipFour varchar(50),
    programCounty varchar(50),
    programPhone varchar(50),
    programRegistrationPhone varchar(50),
    latitude varchar(50),
    longitude varchar(50)
);


LOAD DATA LOCAL INFILE '<path-to-headstart>/headstart_wa.csv'
INTO TABLE Q2_ncesdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE Q2_ncesdata (
NCES_School_ID  varchar(50),
State_School_ID  varchar(50),
NCES_District_ID  varchar(50),
State_District_ID  varchar(50),
Low_Grade  varchar(50),
High_Grade  varchar(50),
School_Name  varchar(50),
District varchar(50),
County_Name varchar(50),
Street_Address varchar(50),
City varchar(50),
State varchar(50),
ZIP varchar(50),
ZIP_4_digit varchar(50),
Phone varchar(50),
Locale_Code varchar(50),
Locale varchar(50),
Charter varchar(50),
Magnet varchar(50),
Title_I_School varchar(50),
Title_I_School_Wide varchar(50),
Students varchar(50),
Teachers varchar(50),
Student_Teacher_Ratio varchar(50),
Free_Lunch varchar(50),
Reduced_Lunch varchar(50)
);


LOAD DATA LOCAL INFILE '<path-to-ncesdata>/ncesdata_wa.csv'
INTO TABLE Q2_ncesdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



SELECT DISTINCT addressLineOne, addressLineTwo, city, state, zipFive, zipFour county FROM Q2_headstart;

SELECT DISTINCT County_Name,Street_Address,City,State,ZIP,ZIP_4_digit FROM Q2_headstart;

SELECT
    hs.*,
    CASE
    WHEN nces.NCES_School_ID IS NOT NULL THEN 1 ELSE 0
    END AS is_match
FROM Q2_headstart hs
LEFT JOIN Q2_ncesdata nces
ON hs.city = nces.City
    AND hs.state = nces.State
    AND hs.name = nces.School_Name
    AND hs.county = nces.County_Name

WITH JoinedData AS (
    SELECT
        hs.*,
        CASE
        WHEN nces.NCES_School_ID IS NOT NULL THEN 1 ELSE 0
        END AS is_match
    FROM Q2_headstart hs
    LEFT JOIN Q2_ncesdata nces
    ON hs.city = nces.City
        AND hs.state = nces.State
        AND hs.name = nces.School_Name
        AND hs.county = nces.County_Name
    )
SELECT JoinedData.name AS match_schools
FROM JoinedData
WHERE is_match = 1;