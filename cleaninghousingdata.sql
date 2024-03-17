CREATE TABLE housingData 
(uniqueID int,
parcelID varchar(50) ,
landUse varchar(50),
propertyAddress varchar(50),
saleDate varchar(50),
salePrice varchar(50),
legalReference varchar(50),
soldAsVacant varchar(25),
ownerName varchar(100),
ownerAddress varchar(50),
acreage numeric,
taxDistrict varchar(50),
landValue numeric,
buildingValue numeric,
totalValue numeric,
yearBuilt numeric,
bedrooms int,
fullBath int,
halfBath int
 );
 
SELECT * FROM housingData;
 
-- chaning date formats, options
--if you want full month name
SELECT saleDate, TO_CHAR(TO_DATE(saleDate, 'Month DD, YYYY'), 'DD Month YYYY') AS formattedDate
FROM housingdata;

--if you only want the number
SELECT TO_CHAR(TO_DATE(saleDate, 'Month DD, YYYY'), 'DD MM YYYY') AS formattedDate
FROM housingdata;

--if you want different order
SELECT saleDate, TO_CHAR(TO_DATE(saleDate, 'Month DD, YYYY'), 'YYYY-DD-MM') AS formattedDate
FROM housingdata;

--Updating the column
UPDATE housingData
SET saleDate=TO_CHAR(TO_DATE(saleDate, 'Month DD, YYYY'), 'YYYY-DD-MM');

SELECT saleDate FROM housingData;

--Chaning address where the field is null
SELECT * FROM housingdata
WHERE propertyAddress IS null;

--Self joining the table to find where address is null, but parcel ID is the same
SELECT hd1.parcelid, hd1.propertyaddress, hd2.parcelid, hd2.propertyaddress 
FROM housingdata HD1
JOIN housingdata HD2
ON hd1.parcelid=hd2.parcelid
AND hd1.uniqueid <> hd2.uniqueid
WHERE hd1.propertyaddress IS NULL;

--Adding new address column
SELECT hd1.parcelid, hd1.propertyaddress, hd2.parcelid, hd2.propertyaddress, 
COALESCE(hd1.propertyaddress, hd2.propertyaddress) AS newAddress
FROM housingdata HD1
JOIN housingdata HD2
ON hd1.parcelid=hd2.parcelid
AND hd1.uniqueid <> hd2.uniqueid
WHERE hd1.propertyaddress IS NULL;

--Updating null fields in propertyAddress
UPDATE housingData AS HD1
SET propertyAddress = COALESCE(HD1.propertyAddress, HD2.propertyAddress)
FROM housingData AS HD2
WHERE hd1.parcelID = hd2.parcelID 
  AND hd1.uniqueID <> hd2.uniqueID 
  AND hd1.propertyAddress IS NULL;
  
--Breaking property address into 2 coulmns - Address, City
SELECT propertyAddress FROM housingdata;

-- Another option SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 2) AS city,
SELECT
    SUBSTRING(propertyAddress FROM 1 FOR POSITION(',' IN propertyAddress) - 1) AS address, --find everything before the comma
    SUBSTRING(propertyAddress FROM POSITION(',' IN propertyAddress) + 1) AS city -- find everything after the comma
FROM housingdata;

--Creating two new columns to put this new, divided info in

ALTER TABLE housingdata
ADD PropertySplitAddress varchar(255);

UPDATE housingdata
SET PropertySplitAddress = SUBSTRING(propertyAddress FROM 1 FOR POSITION(',' IN propertyAddress) - 1);

ALTER TABLE housingdata
ADD PropertySplitCity varchar(255);

UPDATE housingdata
SET PropertySplitCity = SUBSTRING(propertyAddress FROM POSITION(',' IN propertyAddress) + 1);

SELECT propertyAddress, propertySplitAddress, propertySplitCity
FROM housingdata;

--Breaking owner address into 3 columns: address, city and state
SELECT ownerAddress from housingdata;

--Breaking it into three columns
SELECT
    SPLIT_PART(ownerAddress, ',', 1) AS Address,
	SPLIT_PART(SPLIT_PART(propertyAddress, ',', 2), ',', 1) AS City,
	SPLIT_PART(ownerAddress, ',', -1) as State
FROM housingData;

--Adding new columns with the new data

ALTER TABLE housingdata
ADD ownerSplitAddress varchar(255);
UPDATE housingdata
SET ownerSplitAddress = SPLIT_PART(ownerAddress, ',', 1);

ALTER TABLE housingdata
ADD ownerSplitCity varchar(50);
UPDATE housingdata
SET ownerSplitCity = SPLIT_PART(SPLIT_PART(propertyAddress, ',', 2), ',', 1);

ALTER TABLE housingdata
ADD ownerSplitState varchar(50);
UPDATE housingdata
SET ownerSplitState = SPLIT_PART(ownerAddress, ',', -1);

/*
ALTER TABLE housingdata
ADD ownerSplitAddress varchar(255), 
    ownerSplitCity varchar(50), 
    ownerSplitState varchar(50);

UPDATE housingdata
SET ownerSplitAddress = SPLIT_PART(ownerAddress, ',', 1),
	ownerSplitCity = SPLIT_PART(SPLIT_PART(propertyAddress, ',', 2), ',', 1),
	ownerSplitState = SPLIT_PART(ownerAddress, ',', -1);
*/

SELECT ownerAddress, ownerSplitAddress, ownerSplitCity, ownerSplitState
FROM housingdata;

--Changing Y and N to Yes and No
SELECT DISTINCT(soldAsVacant) FROM housingData;

SELECT soldAsVacant, CASE soldAsVacant 
     WHEN 'Y' THEN 'Yes'
     WHEN 'N' THEN 'No'
	 ELSE soldAsVacant
	 END
FROM housingdata;

UPDATE housingdata
SET soldAsVacant = CASE soldAsVacant 
     WHEN 'Y' THEN 'Yes'
     WHEN 'N' THEN 'No'
	 ELSE soldAsVacant
	 END;
	 
--Finding Duplicates
SELECT *,
ROW_NUMBER() OVER (PARTITION BY parcelID, propertyAddress, salePrice, saleDate, legalReference
				  ORDER BY uniqueID) row_num
FROM housingdata;

--Creating new CTE to find duplicates
WITH row_num_cte AS 
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY parcelID, propertyAddress, salePrice, saleDate, legalReference
				  ORDER BY uniqueID) row_num
FROM housingdata)
SELECT parcelID, row_num
FROM row_num_cte
WHERE row_num > 1;

--Delete unused columns
ALTER TABLE housingdata
DROP COLUMN propertyAddress,
DROP COLUMN ownerAddress;

SELECT * FROM housingdata;