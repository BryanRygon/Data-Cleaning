-- Cleaning Data in SQL Queries

Select *
From dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From dbo.NashvilleHousing

-- This command does not work sometimes, more reliable to use Alter Table
--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- Step 1, where i find out which property address is null, and create a new column to fill in these nulls by their parcelID & uniqueID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Step 2, updating the table to fill in null values
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing


-- SQL Query to split Property Address into 2 columns)
SELECT 
   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress, 
   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing;

-- SQL Query to Alter and update the columns in for PropertySplitAddress
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- SQL Query to Alter and update the columns in for PropertySplitCity
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing


-- Using PARSENAME to split Owner Address up, but PARSENAME can only be used with '.' hence we have to replace ','

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From dbo.NashvilleHousing

-- SQL Query to Alter and update the columns in for OwnerSplitAddress
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- SQL Query to Alter and update the columns in for OwnerSplitCity
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- SQL Query to Alter and update the columns in for OwnerSplitState
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field (Using Case statement)

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant
	 END
From dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant
	 END

------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (Not used often, usually use a temp table)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
					) row_num

From dbo.NashvilleHousing
--Order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------
