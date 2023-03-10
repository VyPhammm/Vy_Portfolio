
-- Cleaning DATA in SQL


Select *
From VY_PORTFOLIO..NashvilleHousing



-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Address data


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From VY_PORTFOLIO..NashvilleHousing a
JOIN VY_PORTFOLIO..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From VY_PORTFOLIO..NashvilleHousing a
JOIN VY_PORTFOLIO..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From VY_PORTFOLIO..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From VY_PORTFOLIO..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From VY_PORTFOLIO..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From VY_PORTFOLIO..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From VY_PORTFOLIO..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
From	VY_PORTFOLIO..NashvilleHousing
GROUP BY SoldAsVacant


Select	SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' Then 'No'
	 WHEN SoldAsVacant = 'Y' Then 'Yes'
	 ELSE SoldAsVacant
	 END
From VY_PORTFOLIO..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'N' Then 'No'
	 WHEN SoldAsVacant = 'Y' Then 'Yes'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From VY_PORTFOLIO..NashvilleHousing

)

DELETE * 
From RowNumCTE
Where row_num > 1


Select *
From VY_PORTFOLIO..NashvilleHousing



-- Delete Unused Columns


Select *
From VY_PORTFOLIO..NashvilleHousing

ALTER TABLE VY_PORTFOLIO..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
