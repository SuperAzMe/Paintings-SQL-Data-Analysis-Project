-- SELECT *
-- FROM canvas_size

-- SELECT *
-- FROM image_link

-- SELECT *
-- FROM museum_hours

-- SELECT *
-- FROM museum

-- SELECT *
-- FROM product_size

-- SELECT *
-- FROM subject

-- SELECT *
-- FROM work x

-- SELECT *
-- FROM artist
-- Querying Questions

/*Q1) Fetch all the paintings which are not displayed on any museums?
SELECT name 
FROM Work 
WHERE museum_id IS NULL;*/

/*Q2) Are there museums without any paintings?
SELECT name 
FROM museum
WHERE NOT EXISTS (
       SELECT * 
       FROM work
       WHERE work.museum_id = museum.museum_id);
      
No, there are no museums which does not have any Paintings*/

/*Q3) How many paintings have an asking price of more than their 
    regular price?
SELECT * FROM 
product_size
WHERE sale_price > regular_price

There is no painting with asking price more than regular price*/

/*Q4) Identify the paintings whose asking price is less than 50% 
    of its regular price
SELECT name 
FROM work
WHERE work_id IN (SELECT work_id
                  FROM product_size
                  WHERE sale_price < regular_price * 0.5)
According to Query there are 34 paintings whose asking price is less 
than 50% of its regular price*/

/*Q5) Which canva size costs the most? 
SELECT cs.label AS canva, ps.sale_price
FROM (
    SELECT *
         , RANK() OVER (ORDER BY sale_price DESC) AS rnk 
    FROM product_size
) ps
JOIN canvas_size cs ON cs.size_id = CAST(ps.size_id AS bigint)
WHERE ps.rnk = 1;*/

/*Q6) Delete duplicate records from work, product_size, 
    subject and image_link tables

-- Identifying the duplicate records and product
DELETE FROM work 
WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM work
						GROUP BY work_id );

DELETE FROM product_size 
WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM product_size
						GROUP BY work_id, size_id );

DELETE FROM subject 
WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM subject
						GROUP BY work_id, subject );

DELETE FROM image_link 
WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM image_link
						GROUP BY work_id ); 
deleted successfully*/

/*Q7) Identify the museums with invalid city information in the given dataset

SELECT *
FROM museum
WHERE city ~ '^[0-9]'

There are 6 records with invalid city information */

/*Q8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

DELETE FROM museum_hours 
	WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM museum_hours
						GROUP BY museum_id, day ); */
/*9) Fetch the top 10 most famous painting subject

SELECT s.subject, COUNT(*) AS cnt AS no_of_paintings,
RANK() OVER (ORDER BY count(*) DESC) AS rnk
FROM subject s
JOIN work ON work.work_id=s.work_id
GROUP BY subject
ORDER BY cnt DESC
LIMIT 10;*/

/*Q10) Identify the museums which are open on both Sunday 
and Monday. Display museum name, city.


SELECT *
FROM museum

SELECT *
FROM museum_hours

SELECT m.name, m.city
FROM museum_hours mh1
JOIN museum m
ON mh1.museum_id = m.museum_id
WHERE mh1.day = 'Sunday'
AND EXISTS(SELECT 1
           FROM museum_hours mh2
           WHERE mh2.museum_id = mh1.museum_id
           AND mh2.day = 'Monday')*/

/*Q11) How many museums are open every single day?
SELECT *
FROM museum_hours

--First off all we saw that there is the error in the value name where
--Thursday is written as 'Thusday' so we need to change it

-- UPDATE museum_hours
-- SET day = 'Thursday'
-- WHERE day = 'Thusday'

-- Hence we updated it
-- Now querying 

SELECT COUNT(*) AS no_of_museums
FROM (
SELECT museum_id, COUNT(*) AS cnt
FROM museum_hours
GROUP BY museum_id
HAVING COUNT(*) = 7)*/

/*Q12) Which are the top 5 most popular museum? 
    (Popularity is defined based on most no of paintings in a museum)

-- a) Using CTE  
WITH painting_group AS (SELECT museum_id, COUNT(*) AS cnt
FROM work
WHERE museum_id IS NOT NULL
GROUP BY museum_id)

SELECT m.name AS museum, m.city, m.country, p.cnt
FROM painting_group p
JOIN museum m 
ON m.museum_id = p.museum_id
ORDER BY p.cnt DESC
LIMIT 5;

-- b) Using Window Function
SELECT m.name AS museum, m.city,m.country,x.no_of_painintgs
from (	SELECT m.museum_id, COUNT(1) AS no_of_painintgs
		, rank() OVER(ORDER BY COUNT(1) DESC) AS rnk
		FROM work w
		JOIN museum m ON m.museum_id=w.museum_id
		GROUP BY m.museum_id) x
JOIN museum m OB m.museum_id=x.museum_id
WHERE x.rnk<=5;*/

/*Q13) Who are the top 5 most popular artist? 
     (Popularity is defined based on most no of paintings done 
     by an artist)

-- a) Using CTE
WITH artist_group AS (SELECT artist_id, COUNT(*) AS cnt
                      FROM work
                      GROUP BY artist_id)
SELECT ag.artist_id, a.full_name, ag.cnt AS no_of_paintings
FROM artist_group ag
JOIN artist a
ON a.artist_id = ag.artist_id
ORDER BY ag.cnt DESC
LIMIT 5;

-- b) Using Window Function
select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;*/

/*Q14) Display the 3 least popular canva sizes

SELECT label,ranking,no_of_paintings
FROM (
	SELECT cs.size_id,cs.label,count(1) as no_of_paintings
	, dense_rank() OVER(ORDER BY count(1) ) AS ranking
	FROM work w
	JOIN product_size ps ON ps.work_id=w.work_id
	JOIN canvas_size cs ON cs.size_id::TEXT = ps.size_id
	GROUP BY cs.size_id,cs.label) x
WHERE x.ranking<=3; */

/*Q15) Which museum is open for the longest during a day. 
     Dispay museum name, state and hours open and which day?

SELECT museum_name,STATE AS city,day, open, close, duration
	FROM (	SELECT m.name AS museum_name, m.state, day, open, close
			, to_timestamp(open,'HH:MI AM') 
			, to_timestamp(close,'HH:MI PM') 
			, to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') AS duration
			, rank() OVER (ORDER BY(to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM')) DESC) AS rnk
			FROM museum_hours mh
		 	JOIN museum m ON m.museum_id=mh.museum_id) x
	WHERE x.rnk=1;*/

/*Q16) Which museum has the most no of most popular painting style?
SELECT *
FROM artist

SELECT *
FROM work

WITH pop_style AS 
		(SELECT style
		,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
		FROM work
		GROUP BY style),
	cte AS
		(SELECT w.museum_id,m.name AS museum_name,ps.style, count(1) AS no_of_paintings
		,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
		FROM work w
		JOIN museum m ON m.museum_id=w.museum_id
		JOIN pop_style ps ON ps.style = w.style
		WHERE w.museum_id IS NOT NULL
		AND ps.rnk=1
		GROUP BY w.museum_id, m.name,ps.style)
SELECT museum_name,style,no_of_paintings
FROM cte 
WHERE rnk=1;
The metropolitan Museum of Art has 
most number of popular painting style with 244 paintings*/


/*Q17) Identify the artists whose paintings are displayed 
     in multiple countries

WITH cte AS
	(SELECT DISTINCT a.full_name AS artist
	--, w.name as painting, m.name as museum
	, m.country
	FROM work w
	JOIN artist a ON a.artist_id=w.artist_id
	JOIN museum m ON m.museum_id=w.museum_id)
SELECT artist, COUNT(1) AS no_of_countries
FROM cte
GROUP BY artist
HAVING COUNT(1)>1
ORDER BY 2 DESC;*/

/*Q18) Display the country and the city with most no of museums. 
       Output 2 seperate columns to mention the city and country. 
       If there are multiple value, seperate them with comma.

SELECT city
FROM (SELECT city, count(*), rank() OVER (ORDER BY count(*) DESC) AS rnk
      FROM museum
      GROUP BY city) x
WHERE rnk = 1*/


WITH 
CTE_country AS 
(SELECT country, COUNT(*) AS cnt,
        RANK() OVER (ORDER BY count(*) DESC) AS rnk
FROM museum
GROUP BY country
ORDER BY cnt DESC),

CTE_city AS 
(SELECT city, COUNT(*) AS cnt, 
        RANK() OVER (ORDER BY count(*) DESC) AS rnk
FROM museum
GROUP BY city
ORDER BY cnt DESC)

SELECT STRING_AGG(DISTINCT(country), ' , ') AS country, 
       STRING_AGG(city, ' , ') AS city
FROM CTE_country c1
CROSS JOIN CTE_city c2
WHERE c1.rnk = 1
AND c2.rnk = 1