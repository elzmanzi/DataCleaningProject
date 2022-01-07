/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM nashvillehousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDataConverted, CONVERT(DATE,saleDate)
FROM nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(DATE,saleDate)

ALTER TABLE Nashvillehousing -- Alter is used to add,delete or modify an existing table
ADD SaleDataConverted Date; -- this adds a new column SaleDataConverted in our table


UPDATE nashvillehousing
SET SaleDataConverted = CONVERT(DATE,saleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM nashvillehousing
 --WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- the update will take property address from table a where is Null and update it with the address in Table b
update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM nashvillehousing a
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM nashvillehousing

-- using substring
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as address --
FROM nashvillehousing

-- Modify the table 
alter Table nashvillehousing
add PropertySplitAdress nvarchar(255);

UPDATE nashvillehousing
set PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 


alter Table nashvillehousing
add PropertySplitCity nvarchar(255);


UPDATE nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM nashvillehousing


-- Going to Owner address and split address into address,city,state
-- we are going to use PARSENAME, it just returns the specified part of the specified object nam

SELECT OwnerAddress
FROM nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add OwnerSplitAdress NVARCHAR(255)

UPDATE nashvillehousing
set OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
Add OwnerSplitCity NVARCHAR(255)

UPDATE nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE nashvillehousing
Add OwnerSplitState NVARCHAR(255)

UPDATE nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),count(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
		CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		End
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		End


--SELECT DISTINCT(SoldAsVacant)
--FROM nashvillehousing
--GROUP BY SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- we are going to use CTE

WITH RowNumCTE as 
(
select *,
	ROW_NUMBER () OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID 
						) row_num
	FROM nashvillehousing
	-- ORDER BY ParcelID
		)

	SELECT * 
	FROM RowNumCTE
	WHERE row_num > 1

	-- Delete them 
WITH RowNumCTE as 
(
select *,
	ROW_NUMBER () OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID 
						) row_num
	FROM nashvillehousing
	-- ORDER BY ParcelID
		)

	Delete 
	FROM RowNumCTE
	WHERE row_num > 1

SELECT *
FROM nashvillehousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate
