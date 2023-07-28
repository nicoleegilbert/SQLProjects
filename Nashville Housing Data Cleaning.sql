-- Created By: Nicole Gilbert
-- Project: Data Cleaning Project

SELECT* 
FROM [Hotel Nashville].dbo.NashvilleHotel

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM [Hotel Nashville].dbo.NashvilleHotel

UPDATE [Hotel Nashville].dbo.NashvilleHotel -- This code didn't work. So we used the Alter Table Code and Update Below.
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD SaleDateConverted Date; 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate) --Writing code again to see if the conversion worked. It did!!
FROM [Hotel Nashville].dbo.NashvilleHotel

/* Populate Property Address Data. When going through the data. Some of the Property Address fields are empty. You will notice
that they also have a Parcel ID. So we will fill in the missing Property Address fields based on an address already on record
with the same Parcel ID to obtain some missing data. */

SELECT* 
FROM [Hotel Nashville].dbo.NashvilleHotel
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM [Hotel Nashville].dbo.NashvilleHotel a
JOIN [Hotel Nashville].dbo.NashvilleHotel b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM [Hotel Nashville].dbo.NashvilleHotel a
JOIN [Hotel Nashville].dbo.NashvilleHotel b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Hotel Nashville].dbo.NashvilleHotel
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(Propertyaddress,1,CHARINDEX(',', propertyaddress) -1) as Address
,SUBSTRING(Propertyaddress,CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress)) as City
FROM [Hotel Nashville].dbo.NashvilleHotel

ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD PropertySplitAddress Nvarchar(255); 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET PropertySplitAddress = SUBSTRING(Propertyaddress,1,CHARINDEX(',', propertyaddress) -1)

ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD PropertySplitCity Nvarchar(255); 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET PropertySplitCity = SUBSTRING(Propertyaddress,CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress))


SELECT *
FROM [Hotel Nashville].dbo.NashvilleHotel


SELECT OwnerAddress
FROM [Hotel Nashville].dbo.NashvilleHotel

SELECT --Seperating out the Owner Address. ParseName parses on a period, so we had to replace commas with periods. 
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM [Hotel Nashville].dbo.NashvilleHotel


ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD OwnerSplitAddress Nvarchar(255); 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD OwnerSplitCity Nvarchar(255); 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE [Hotel Nashville].dbo.NashvilleHotel
ADD OwnerSplitState Nvarchar(255); 

UPDATE [Hotel Nashville].dbo.NashvilleHotel
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)

SELECT *
FROM [Hotel Nashville].dbo.NashvilleHotel


--Changing Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct(soldasvacant), COUNT(soldasvacant)
FROM [Hotel Nashville].dbo.NashvilleHotel
GROUP BY SoldAsVacant
Order BY 2


SELECT SoldAsVacant--I converted Y/N to Yes/No
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Hotel Nashville].dbo.NashvilleHotel
ORDER BY 1

UPDATE [Hotel Nashville].dbo.NashvilleHotel-- I made sure it was updated in the table.
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Hotel Nashville].dbo.NashvilleHotel

--Removing Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) row_num
FROM [Hotel Nashville].dbo.NashvilleHotel
--ORDER BY parcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER By Propertyaddress

--DELETE Unused Columns. Keeping the usable columns we created. Should be done in Views not on raw data.

SELECT *
FROM [Hotel Nashville].dbo.NashvilleHotel
ORDER BY ParcelID

ALTER Table [Hotel Nashville].dbo.NashvilleHotel
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER Table [Hotel Nashville].dbo.NashvilleHotel
DROP COLUMN saledate
