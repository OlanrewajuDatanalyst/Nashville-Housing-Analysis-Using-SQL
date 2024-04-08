Create table Nashville_Housing 
(
	UniqueID integer,	
	ParcelID varchar,
	LandUse varchar,
	PropertyAddress varchar,
	SaleDate date,
	SalePrice integer,
	LegalReference varchar,
	SoldAsVacant varchar,
	OwnerName varchar,
	OwnerAddress varchar,
	Acreage numeric,
	TaxDistrict varchar,
	LandValue integer,
	BuildingValue integer,
	TotalValue integer,
	YearBuilt varchar,
	Bedrooms integer,
	FullBath integer,
	HalfBath integer
)


alter table Nashville_Housing
alter column saleprice type varchar


copy Nashville_Housing  FROM 'C:\Users\Benedicta Martins\OneDrive\Documents\LANRE\BUSINESS TRAINING\My Portfolio\SQL\Data Cleaning _ Housing Estates\Nashville Housing Data.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE Nashville_Housing
ALTER COLUMN saledate TYPE DATE USING saledate::DATE;
