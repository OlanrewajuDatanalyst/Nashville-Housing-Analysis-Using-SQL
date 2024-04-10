-- Populate property address data
select 
	a.parcelid, 
	a.propertyaddress,
	b.parcelid, 
	b.propertyaddress,
	coalesce(a.propertyaddress, b.propertyaddress)
from nashville_housing a
join nashville_housing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null
order by parcelid

-- Real Query
update nashville_housing a
set propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
from nashville_housing b
where a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
and a.propertyaddress is null;


-- Breaking out property address into individual columns (Address, City, State)
select 
substring(propertyaddress, 1, position(',' in propertyaddress) -1) as Address,
substring(propertyaddress, position(',' in propertyaddress) +2) as City
from nashville_housing

alter table nashville_housing
add Propertyaddress_ varchar

update nashville_housing
set Propertyaddress_ = substring(propertyaddress, 1, position(',' in propertyaddress) -1)

alter table nashville_housing
add City varchar

update nashville_housing
set City = substring(propertyaddress, position(',' in propertyaddress) +2)


-- Breaking out owner's address into individual columns (Address, City, State)

select 
	split_part(owneraddress, ', ', 1), 
	split_part(owneraddress, ', ', 2),
	split_part(owneraddress, ', ', 3)
from nashville_housing

alter table nashville_housing
add OwnerStreet varchar

update nashville_housing
set OwnerStreet = split_part(owneraddress, ', ', 1)

alter table nashville_housing
add OwnerCity varchar

update nashville_housing
set OwnerCity = split_part(owneraddress, ', ', 2)

alter table nashville_housing
add OwnerState varchar

update nashville_housing
set OwnerState = split_part(owneraddress, ', ', 3)



-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant) from nashville_housing group by 1

select 
	soldasvacant,
	case
		when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
	end soldasvacant_
from nashville_housing
	
update nashville_housing	
set soldasvacant = case
						when soldasvacant = 'Y' then 'Yes'
						when soldasvacant = 'N' then 'No'
						else soldasvacant
					end 


-- Remove duplicates
with RowNumCTE as (
select *,
	row_number() over(
				partition by parcelid, 
							 propertyaddress,
							Saleprice,
							saledate,
							legalreference
					order by 
							uniqueid
						)as row_num
from nashville_housing
) 
Delete from nashville_housing
where (parcelid, propertyaddress, Saleprice, saledate, legalreference, uniqueid) IN (
    select parcelid, propertyaddress, Saleprice, saledate, legalreference, uniqueid
    from RowNumCTE
    where row_num > 1
)

-- Delete unused column
alter table nashville_housing
drop column OwnerAddress, 
drop column propertyaddress, 
drop column taxdistrict


-- Remove the dollar sign in some of the pricing, just 6 rows
update nashville_housing
set saleprice = replace(saleprice, '$', '')
where saleprice like '%$%';

update nashville_housing
set saleprice = replace(saleprice, ',', '')
where saleprice like '%,%';

alter table nashville_housing
alter column saleprice type integer
using saleprice::integer


-- The trend of the dataset last between 2013 to 2016 but has two rows of 2019 dataset, the 2 rows was removed
alter table nashville_housing
add Salesyear int

update nashville_housing
set Salesyear = date_part('Year', saledate) 

DELETE FROM nashville_housing
WHERE Salesyear = 2019;

