--Data Cleaning Questions
--1.Write a query to show all rows where rating cannot be converted into a decimal number.

SELECT *
from [dbo].[swiggy_cleaned(in)]
WHERE TRY_CAST(rating AS DECIMAL(3,1)) IS NULL
AND rating IS NOT NULL;


--2.Write a query to update the table so that invalid rating values become NULL.

Update [dbo].[swiggy_cleaned(in)]
set rating= null
WHERE TRY_CAST(rating AS DECIMAL(3,1)) IS NULL
AND rating IS NOT NULL;


-- 3: Clean time_minutes Column

SELECT *
from [dbo].[swiggy_cleaned(in)]
where TRY_CAST(time_minutes as int) is null
and time_minutes is not null;

update [dbo].[swiggy_cleaned(in)]
SET time_minutes = TRY_CAST(LEFT(time_minutes, CHARINDEX('-', time_minutes) - 1) AS INT)
where  time_minutes like '%-%';

-- 4 to find all rows where offer_above cannot be converted into an INT
SELECT *
from [dbo].[swiggy_cleaned(in)]
where TRY_CAST(offer_above as int) is null
and offer_above is not null

update [dbo].[swiggy_cleaned(in)]
set offer_above = null
where TRY_CAST(offer_above as int)is NULL
and offer_above is not null
--nvarchar  →  int
alter table [dbo].[swiggy_cleaned(in)]
alter column offer_above  int;

--5 (to find all rows where offer_percentage cannot be converted into an INT.
SELECT *
from [dbo].[swiggy_cleaned(in)]
where TRY_CAST(offer_percentage as int) is null
and offer_percentage is not null

update [dbo].[swiggy_cleaned(in)]
set offer_percentage = null
where TRY_CAST(offer_percentage as int)is NULL
and offer_percentage is not null
alter table [dbo].[swiggy_cleaned(in)]
alter column offer_percentage int;


--6. to remove leading & trailing spaces from hotel_name.

update [dbo].[swiggy_cleaned(in)]
set hotel_name=upper(left(trim(hotel_name),1))+
lower(SUBSTRING(trim(hotel_name),2,len(trim(hotel_name))));


--7. find duplicate restaurants

select hotel_name ,location ,count(*) as dupicate_count
from [dbo].[swiggy_cleaned(in)]
group by  hotel_name ,location 
having count(*) >1

--DATA EXPLORATION

--1 Restaurant Distribution Analysis
select location , count(*)as Restaurant_Count
from [swiggy_cleaned(in)]
group by location 
order by Restaurant_Count desc

--2 Delivery Speed Performance

SELECT location,
    CASE
        WHEN time_minutes <= 25 THEN 'Fast'
        WHEN time_minutes BETWEEN 26 AND 35 THEN 'Medium'
        WHEN time_minutes > 35 THEN 'Slow'
    END AS delivery_speed,
    COUNT(*) AS restaurant_count
FROM [swiggy_cleaned(in)]
WHERE time_minutes IS NOT NULL
GROUP BY location,
    CASE
        WHEN time_minutes <= 25 THEN 'Fast'
        WHEN time_minutes BETWEEN 26 AND 35 THEN 'Medium'
        WHEN time_minutes > 35 THEN 'Slow'
    END
ORDER BY location, restaurant_count DESC;

--3 Average Delivery Time by Location
select location ,
round(avg(time_minutes),1) as avg_DeliveryTime 
from [swiggy_cleaned(in)]
WHERE time_minutes IS NOT NULL
group by location 

--4 Offer Strategy Effectiveness
SELECT Offer_Strategy , COUNT(*) AS restaurant_count
FROM (
    SELECT 
        location,
        CASE
        WHEN offer_above BETWEEN 0 AND 50 THEN '0–50'
        WHEN offer_above BETWEEN 51 AND 100 THEN '51–100'
        WHEN offer_above BETWEEN 101 AND 200 THEN '101–200'
        WHEN offer_above > 200 THEN 'Above 200'
        ELSE 'No Offer'
        END AS Offer_Strategy
    FROM [swiggy_cleaned(in)]
) x
GROUP BY  Offer_Strategy;


--5 Food Category Popularity
select 
LTRIM(RTRIM(value)) as food_category ,
count (value) as restaurant_count
from [swiggy_cleaned(in)]
cross apply
string_split(food_type ,',')
group by LTRIM(RTRIM(value))
order by restaurant_count desc


--6 Average Discount by Food Category
select 
LTRIM(RTRIM(value)) as food_category ,
avg(offer_percentage) as avg_Discount
from [swiggy_cleaned(in)]
cross apply
string_split(food_type ,',')
where offer_percentage is not null
group by LTRIM(RTRIM(value))

--7 High-Value & High-Performance Restaurants
select hotel_name, location ,rating,time_minutes ,offer_percentage
from [swiggy_cleaned(in)]
where rating >4.3 and time_minutes <=25 and offer_percentage >=30
order by rating desc,time_minutes asc

--8 Delivery Speed Performance by Location
SELECT location, delivery_speed , avg_delivery_time ,count (hotel_name) as restaurant_count
     FROM (
        SELECT
            location,hotel_name,
            CASE
             when time_minutes <= 25 then 'fast'
             when time_minutes BETWEEN 26 AND 35 then 'Medium'
             when time_minutes > 35 then 'low'
            END AS delivery_speed,
            AVG(time_minutes) OVER (PARTITION BY location) AS avg_delivery_time
        FROM [swiggy_cleaned(in)]
        where time_minutes is not null
    ) t
GROUP BY location ,delivery_speed , avg_delivery_time
having count (hotel_name )>10
ORDER BY location, avg_delivery_time;
