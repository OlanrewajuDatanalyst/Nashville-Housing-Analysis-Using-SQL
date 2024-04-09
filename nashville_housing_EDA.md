### 1. Average selling price of Nashville_Housing
```sql
select 
    ROUND(avg(saleprice), 2) as AvgSalePrice
from 
    Nashville_Housing;
```


### 2. Count the frequency of different LandUse categories.
```sql
select 
    landuse,
    count(*) as frequency
from nashville_housing
group by 1
order by 2 desc
```

### 3. Analyze trends in SalePrice over different year to understand how property prices have changed over time.
```sql
select 
    *,
    lag(Avg_Year_Price) over() as Prev_Year_Price, 
    ROUND(((Avg_Year_Price - lag(Avg_Year_Price) over()) 
    / lag(Avg_Year_Price) over()* 100), 2) 
    as YOY_Growth_Decline
from (
    select
        date_part('Year', saledate) as Sale_Year,
        ROUND(Avg(saleprice), 2) as Avg_Year_Price
    from nashville_housing
    group by 1
    order by 1
    )
```

### 4. Examine trends in TotalValue over the years to identify patterns in property valuations.
```sql
select 
    *,
    lag(Avg_Year_Value) over() as Prev_Year_Value,
    ROUND(((Avg_Year_Value - lag(Avg_Year_Value) over()) 
    / lag(Avg_Year_Value) over()* 100), 2) 
    as YOY_Value_Change
from (
    select
        date_part('Year', saledate) as Value_Year,
        ROUND(Avg(totalvalue), 2) as Avg_Year_Value
    from nashville_housing
    group by 1
    order by 1
    )
```

### 5. Determine the correlation between SalePrice and other numerical variables such as Acreage, LandValue, BuildingValue, TotalValue, Bedrooms, to understand their relationships.
```sql
select 
    ROUND(corr(SalePrice, Acreage)::numeric, 3) as Acreage,
    ROUND(corr(SalePrice, TotalValue)::numeric, 3) as TotalValue,
    ROUND(corr(SalePrice, buildingvalue)::numeric, 3) as BuildingValue,
    ROUND(corr(SalePrice, landvalue)::numeric, 3) as LandValue,
    ROUND(corr(SalePrice, bedrooms)::numeric, 3) as Bedrooms
from nashville_housing;
```
### Output:
acreage	| totalvalue | buildingvalue | landvalue | bedrooms
-- | -- | -- | -- | --
0.201	| 0.662	| 0.575	| 0.604	| 0.373




### 6. Analyze the average SalePrice or TotalValue for different types of properties.
```sql
select * from (
select 
    landuse,
    ROUND(avg(saleprice), 2) AvgSaleprice,
    ROUND(avg(Totalvalue), 2) AvgTotalValue,
from nashville_housing
group by 1
order by 2 desc)
```


### 7.This is to check the number of properties sold as vacant compare to those not sold as vacant, and the land use with the most vacant before sale
```sql
select 
    landuse,
    count(soldasvacant_) Vacant,
    count(notsoldasvacant) Notvacant
from(
    select 
        landuse,
        case 
            when soldasvacant = 'No' then 'No'
        end soldasvacant_,
        case 
            when soldasvacant = 'Yes' then 'Yes'
        end notsoldasvacant 
    from nashville_housing
    )
group by 1
order by 2 desc
```

### 8.Investigate the average price, total value and difference in SalePrice between properties sold as vacant and those sold as occupied.
```sql
with  cte as (
        select 
            landuse,    
            coalesce(Vacant_price, 0) as Vacant_price,
            coalesce(Occupied_Price, 0) as Occupied_Price
        from(
            select 
                landuse,
                case 
                    when soldasvacant = 'No' then Saleprice
                end Vacant_price,
                case 
                    when soldasvacant = 'Yes' then saleprice
                end Occupied_Price
            from nashville_housing
            )
        group by 1, Vacant_price, Occupied_Price 
)
select
    Landuse,
    ROUND(Avg(Vacant_price), 2) as AvgVacantPrice,
    ROUND(Avg(Occupied_Price), 2) as AvgOccupiedPrice,
    ROUND((Avg(Occupied_Price) - Avg(Vacant_price)), 2) Avg_Price_Difference
from cte
group by 1
Order by 4
```


### 9.Compare the distribution of property types based on LandUse.
```sql
select
    *,
    concat(ROUND(
                (Total_Properties / sum(Total_Properties) over())* 100, 2
                ), '%') as Property_type_distribution
from (
    select 
        distinct landuse as landuse,
        count(1) as Total_Properties
    from nashville_housing
    group by landuse
    order by 2 desc
    )
```


### Analyze the frequency and distribution of vacant properties based on SoldAsVacant.
```sql
with cte1 as (          
            select 
                landuse,
                count (1) as Soldasvacant_
            from nashville_housing
            where soldasvacant = 'No'
            group by 1
            ),
    cte2 as (
            select
                landuse,
                count(1) as Landuse_Tot
            from nashville_housing
            group by 1
            )
    -- cte3 as (
    --      select
    --          sum(landuse) as Total_properties 
    --      from cte2
    --      )
select
    b.landuse,
    b.Soldasvacant_,
    a.Landuse_Tot 
--  c.Total_properties 
from cte2 a
right join cte1 b
    on a.landuse = b.landuse
--join cte3 c
--  on a.landuse = c.landuse
```
