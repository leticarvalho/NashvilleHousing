/* 

Cleanin Data in SQL Queries

*/

SELECT * 
FROM NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS SaleDateConverted
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD COLUMN SaleDateConverted DATE

update NashvilleHousing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d, %Y')
WHERE SaleDate is not null and SaleDate <> ''

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing

-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

UPDATE NashvilleHousing
SET PropertyAddress = NULL 
WHERE PropertyAddress = ''

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress
FROM NashvilleHousing as T1
JOIN NashvilleHousing as T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.UniqueID <> T2.UniqueID
WHERE T1.PropertyAddress is null 

UPDATE NashvilleHousing as T1
JOIN NashvilleHousing as T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.UniqueID <> T2.UniqueID
SET T1.PropertyAddress = IFNULL(T1.PropertyAddress, T2.PropertyAddress)
WHERE T1.PropertyAddress is null 

-- Breaking out Property Address into Individual Columns (Address, City)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress))

SELECT *
FROM NashvilleHousing

-- Breaking out Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) as City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) as State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1)

SELECT *
FROM NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END AS STATUS
FROM NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates 

DELETE FROM NashvilleHousing
WHERE UniqueID IN (
	SELECT UniqueID FROM (
		SELECT	UniqueID, 
			ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
			ORDER BY UniqueID) AS row_num 
		FROM NashvilleHousing) AS t 
	WHERE row_num > 1)
	
-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict