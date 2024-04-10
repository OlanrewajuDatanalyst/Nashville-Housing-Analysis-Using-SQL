## <p align="center"> Business Questions And Analysis

The primary aim is to analyze the Nashville real estate market dynamics, with a focus on understanding key trends, identifying drivers of market fluctuations, and providing strategic recommendations for stakeholders based on the insights derived.

---

### 1. Average sale price and total value of Nashville_Housing
```sql
select 
    	ROUND(avg(saleprice), 2) as AvgSalePrice,
	ROUND(avg(TotalValue), 2) as AvgTotalValue,
	concat('1: ', ROUND(
			(avg(saleprice)/ avg(TotalValue)), 3)
		  ) as Ratio_Value_to_Price
from 
    Nashville_Housing;
```
avgsaleprice | avgtotalvalue | ratio_value_to_price
-- | -- | -- 
327530.43 | 232564.48 | 1: 1.408

### Insight:
The ratio of value to price at 1:1.408 indicates that properties are selling for more than their assessed values on average, suggesting strong demand or potential overvaluation.

---
### 2. Average sale price and total value of Nashville_Housing with it's cities
```sql
select * from (
select 
	distinct city,
	ROUND(avg(saleprice), 2) as AvgSalePrice,
	ROUND(avg(TotalValue), 2) as AvgTotalValue,
	concat('1: ', ROUND(
			(avg(saleprice)/ avg(TotalValue)), 3)
		  ) as Ratio_Value_to_Price
from Nashville_Housing
group by city
order by 4 desc)
where AvgTotalValue is not null
```
### Output:
city | avgsaleprice | avgtotalvalue | ratio_value_to_price
-- | -- | -- | -- 
ANTIOCH | 252798.07 | 111759.52 | 1: 2.262
BELLEVUE | 25000 | 12400 | 1: 2.016
GOODLETTSVILLE | 289639.39 | 147622.03 | 1: 1.962
WHITES CREEK | 168434.26 | 94670.83 | 1: 1.779
HERMITAGE | 199901.82 | 131214.44 | 1: 1.523
NASHVILLE | 366624.76 | 256490.73 | 1: 1.429
OLD HICKORY | 191082.95 | 146235.24 | 1: 1.307
MADISON | 136537.12 | 118732.14 | 1: 1.150
MOUNT JULIET | 243490.19 | 213200 | 1: 1.142
JOELTON | 143239.18 | 136618.18 | 1: 1.048
BRENTWOOD | 312258.06 | 434475.98 | 1: 0.719
NOLENSVILLE | 287143.72 | 1921700 | 1: 0.149

### Insight:
Real estate prices vary significantly across cities, with average sale prices ranging from $25,000 in Bellevue to $366,624.76 in Nashville, indicating diverse property values within the region.

Average total values mirror this variability, reflecting nuanced economic dynamics and market conditions in each city, highlighting the complexity of the real estate landscape.

The ratio of average total value to average sale price, such as Antioch's ratio of 1:2.262 and Nolensville's ratio of 1:0.149, emphasizes the importance of considering both sale prices and total values for informed investment decisions and understanding market trends accurately.

---
### 3. Analyze trends in SalePrice over different year to understand how prices have changed over time in each cities.
```sql
select 
	*	
from crosstab(
		'select
			city,
			Sale_Year,
			ROUND(
				((Averageprice - PrevYearAvgPrice) / PrevYearAvgPrice)* 100, 2
				) as YOY_Change
		from (
			select
				city as city,
				date_part(''Year'', saledate) as Sale_Year,
				avg(saleprice) as Averageprice,
				lag(avg(saleprice)) over(
						partition by city order by date_part(''Year'', saledate)
				    ) as PrevYearAvgPrice
			from nashville_housing
			group by 1, 2
			order by 1, 2)
		where PrevYearAvgPrice is not null')
as result (city varchar, "2014" numeric, "2015" numeric, "2016" numeric)
order by 2 desc
```
### Output: 
Note: The values are in percentages, the values of 2014 is the change from 2013
city | 2014 | 2015 | 2016
-- | -- | -- | --
NASHVILLE | 41.38 | 23.73 | -25.52
MADISON | 36.91 | -10.64 | 0.79
ANTIOCH | 27.27 | 9.65 | -34.40
HERMITAGE | 26.47 | -10.17 | 10.02
WHITES CREEK | 25.03 | -31.17 | 41.62
NOLENSVILLE | 9.91 | -5.74 | 7.62
JOELTON | 1.79 | 5.71 | 29.75
BRENTWOOD | 0.41 | 8.91 | 7.05
GOODLETTSVILLE | -0.33 | -- | -54.00
MOUNT JULIET | -3.36 | 15.58 | 31.54
OLD HICKORY | -6.34 | 15.48 | 17.36

### Insight:
The percentage change in housing prices across various cities in the Nashville area from 2014 to 2016. Noteworthy trends include substantial growth in Nashville and Madison in 2014, followed by mixed performance in subsequent years. Antioch and Whites Creek saw significant declines in 2016, indicating potential market corrections. 

Overall, these fluctuations underscore the importance of thorough market analysis and risk assessment for investors navigating the dynamic real estate landscape of the Nashville region.


---
### 4. Analyze trends in SalePrice over different year to understand how property prices have changed over time.
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
### Output:
sale_year | avg_year_price | prev_year_price | yoy_growth_decline
-- | -- | -- | -- 
2013 | 244577.49 -- | --
2014 | 334351.81 | 244577.49 | 36.71
2015 | 399936.39 | 334351.81 | 19.62
2016 | 301071.39 | 399936.39 | -24.72

### Insight:

From 2013 to 2015, there was substantial growth in yearly property prices, likely due to increased demand and favorable market conditions. However, 2016 saw a sharp decline, signaling a market correction possibly driven by changing economic conditions, buyer sentiment shifts, or market oversupply.

Understanding the 2016 decline's causes is vital for effective strategy adjustment. Diversify portfolios to mitigate risks, consider diverse investments is crucial.

---
### 5. Examine trends in TotalValue over the years to identify patterns in property valuations.
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
### Output:
value_year | avg_year_value | prev_year_value | yoy_value_change
-- | -- | -- | -- 
2013 | 258462.51 | -- | --
2014 | 249163.15 | 258462.51 | -3.6
2015 | 226549.71 | 249163.15 | -9.08
2016 | 201931.01 | 226549.71 | -10.87

### Insight:

The consistent decline in market values, accelerating from -3.6% in 2014 to -10.87% in 2016, signals a bearish market influenced by factors such as reduced demand and or broader economic conditions impacting buyers' purchasing power.

This trend presents opportunities for acquiring properties at lower prices, though it necessitates careful analysis to avoid risks in a declining market. Strategies such as portfolio diversification, renovations, and value-add projects can counteract market downturns.

---
### 6. Determine the correlation between SalePrice and other numerical variables such as Acreage, LandValue, BuildingValue, TotalValue, Bedrooms, to understand their relationships.
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

### Insight:

This reveals that a property's total value, encompassing both building and land value, has a strong correlation with its sale price, making it a reliable predictor of price. This implies that properties with higher values are likely to fetch higher sale prices. 

However, the size of a property, measured in acres, has a weak positive correlation, suggesting that factors like location or condition might be more influential in setting a property's price. 

Similarly, the number of bedrooms has a relatively weak correlation with sale price, indicating that property size (bedrooms) isn't the main determinant of value.

---
### 7. Compare the frequency and distribution of property types based on LandUse.
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
### Output:
landuse | total_properties | property_type_distribution
-- | -- | --  
SINGLE FAMILY | 34117 | 60.52%
RESIDENTIAL CONDO | 14064 | 24.95%
VACANT RESIDENTIAL LAND | 3540 | 6.28%
VACANT RES LAND | 1549 | 2.75%
DUPLEX | 1372 | 2.43%
ZERO LOT LINE | 1047 | 1.86%

### Output:
The dominance of single-family properties at 60.52%, followed by residential condos at 24.95%, underscores the robust demand for traditional housing options in Nashville's real estate market. This trend presents significant opportunities for investors, developers, and stakeholders to capitalize on. 

However, the relatively smaller segments occupied by vacant residential land (5.38%), duplexes (4.29%), and zero lot lines (1.86%) highlight potential areas for expansion and diversification. 

Understanding these dynamics not only allows for strategic investment decisions but also fosters innovation and growth within Nashville's dynamic real estate landscape.

---
### 8. Analyze the frequency and distribution of vacant properties based on SoldAsVacant.
```sql
with cte1 as (
            select
                distinct landuse,
                count(landuse) over() as Total_Properties
            from nashville_housing
            where soldasvacant = 'Yes'),
    cte2 as (
            select 
                landuse,
                count(landuse) as TotalbyLandUse
            from nashville_housing
            where soldasvacant = 'Yes'
            group by 1)
select
    Landuse,
    Tot_Properties,
    Tot_by_Landuse,
    concat(ROUND((Tot_by_Landuse / Tot_Properties)* 100, 2), '%') as SoldAsVacantDist_
from (
        select 
            a.landuse,
            Total_Properties::numeric as Tot_Properties,
            TotalbyLandUse::numeric as Tot_by_Landuse
        from cte2 b
        join cte1 a
            on b.landuse = a.landuse
        order by 3 desc)
```
### Output:
landuse | tot_properties | tot_by_landuse | soldasvacantdist_
-- | -- | -- | -- 
VACANT RESIDENTIAL LAND | 4669 | 2845 | 60.93%
VACANT RES LAND | 4669 | 961 | 20.58%
SINGLE FAMILY | 4669 | 593 | 12.70%
RESIDENTIAL CONDO | 4669 | 223 | 4.78%
RESIDENTIAL COMBO/MISC | 4669 | 13 | 0.28%

---
### 9. Analyze the average SalePrice for different types of Property.
```sql
-- Properties Average Sales price from the highest to...
select * from (
select 
    landuse,
    ROUND(avg(saleprice), 2) AvgSaleprice
from nashville_housing
group by 1
order by 2 desc)
```
### Output:

landuse | avgsaleprice
-- | --
VACANT COMMERCIAL LAND | 3235294.12
APARTMENT: LOW RISE (BUILT SINCE 1960) | 2000000
DAY CARE CENTER | 1577500
CONDO | 1260063.77
CONDOMINIUM OFC  OR OTHER COM CONDO | 1254597.14
PARKING LOT | 1225336.36
LIGHT MANUFACTURING | 1200000
FOREST | 1085330
CHURCH | 840590.91
GREENBELT | 604938.5

---
### 10. Analyze the TotalValue for different types of Property.
```sql
-- Properties Average Total Value from the highest to...
select * from (
select 
    landuse,
    ROUND(avg(Totalvalue), 2) AvgTotalValue
from nashville_housing
group by 1
order by 2 desc)
where AvgTotalValue is not null
```

### Output:
landuse | avgtotalvalue
-- | --
LIGHT MANUFACTURING | 888500
CHURCH | 775258.06
APARTMENT: LOW RISE (BUILT SINCE 1960) | 493300
DAY CARE CENTER | 472750
OFFICE BLDG (ONE OR TWO STORIES) | 459450
SPLIT CLASS | 457046.67
STRIP SHOPPING CENTER | 389900
NON-PROFIT CHARITABLE SERVICE | 379300
FOREST | 310493.4
VACANT RES LAND | 274195.51

---
### 11. Analyze the number of properties sold as vacant compare to those not sold as vacant, and the land use with the most vacant before sale
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
landuse | vacant | notvacant
-- | -- | -- 
SINGLE FAMILY | 33524 | 593
RESIDENTIAL CONDO | 13841 | 223
DUPLEX | 1363 | 9
ZERO LOT LINE | 1047 | 0
VACANT RESIDENTIAL LAND | 695 | 2845
VACANT RES LAND | 588 | 961
CONDO | 247 | 0
TRIPLEX | 90 | 2
RESIDENTIAL COMBO/MISC | 82 | 13
QUADPLEX | 39 | 0

---
### 12. Investigate the average price, total value of properties sold as vacant and those sold as occupied.
```sql
with  cte as (
        select 
            landuse,    
            coalesce(Vacant_price, 0) as Vacant_price,
            coalesce(Occupied_Price, 0) as Occupied_Price,
			coalesce(Vacant_Value, 0) as Vacant_Value,
            coalesce(Occupied_Value, 0) as Occupied_Value
        from(
            select 
                landuse,
                case 
                    when soldasvacant = 'No' then Saleprice
                end Vacant_price,
                case 
                    when soldasvacant = 'Yes' then saleprice
                end Occupied_Price,
				case 
                    when soldasvacant = 'No' then Totalvalue
                end Vacant_Value,
                case 
                    when soldasvacant = 'Yes' then Totalvalue
                end Occupied_Value
            from nashville_housing
            )
        group by 1, 2, 3, 4, 5 
)
select
    Landuse,
    ROUND(Avg(Vacant_price), 2) as AvgVacantPrice,
	ROUND(Avg(Vacant_Value), 2) as AvgVacantvalue,
    ROUND(Avg(Occupied_Price), 2) as AvgOccupiedPrice,
    ROUND(Avg(Occupied_Value), 2) as AvgOccupiedValue
from cte
group by 1
Order by 2 desc
```
### Output:
landuse | avgvacantprice | avgvacantvalue | avgoccupiedprice | avgoccupiedvalue
-- | -- | -- | -- | --
VACANT COMMERCIAL LAND | 2275000 | 5700 | 263888.89 | 9444.44
APARTMENT: LOW RISE (BUILT SINCE 1960) | 2000000 | 493300 | 0 | 0
DAY CARE CENTER | 1577500 | 472750 | 0 | 0
PARKING LOT | 1170790.91 | 46981.82 | 54545.45 | 43900
CHURCH | 836348.48 | 728272.73 | 4242.42	0
GREENBELT | 597138.5 | 153480.7 | 7800 | 5832
SPLIT CLASS | 572221.59 | 391894.12 | 11705.88 | 11382.35
CONDOMINIUM OFC  OR OTHER COM CONDO | 553805.88 | 0 | 10588.24 | 0
STRIP SHOPPING CENTER | 424900 | 389900 | 0 | 0
SMALL SERVICE SHOP | 400000 | 0 | 0 | 0


