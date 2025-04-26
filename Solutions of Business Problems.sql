-- Netflix Project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix_data
(
	show_id	VARCHAR(8),
	type VARCHAR(10),	
	title VARCHAR(150),
	director VARCHAR(210),	
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

select * from netflix_data;

select 
	count(*) as total_content 
from netflix_data;

select 
	distinct type 
from netflix_data;

-- 15 Business Problems

-- Q1. Count the number of Movies vs TV Shows

select 
	type, 
	count(distinct show_id) as total_content
from netflix_data
group by type;

-- Q2. Find the most common rating for movies and TV shows

--- With SubQueries

select 
	type, 
	rating, 
	most_common_rating
	from
(
		select *,
		rank() over(partition by type order by most_common_rating desc) as ranks
	from
	(
		select 
			type,rating,
			count(rating) as most_common_rating
		from netflix_data
		where rating is not null
		group by type,rating
	) as x) as y where ranks =1;

--With CTE

WITH common_rating as
(
	select 
		type,
		rating,
		count(rating) as most_common_rating,
		rank() over(partition by type order by count(rating) desc) as ranks
	from netflix_data
	where rating is not null
	group by type,rating
	order by 1

)

select 
	type,
	rating
from common_rating
where ranks = 1;
	
-- Q3. List all movies released in a specific year (e.g., 2020)

select 
	distinct *
from netflix_data
	where type in ('Movie')
	and
	release_year in (2020);

-- Q4. Find the top 5 countries with the most content on Netflix

select
	UNNEST(STRING_TO_ARRAY(country, ',')) as countries,
	count(1) as most_content
from netflix_data
group by 1
order by 2 desc
limit 5;

-- Q5. Identify the longest movie

select * from netflix_data
where
	duration = (select max(duration) from netflix_data
				where type in('Movie'));

-- Q6. Find content added in the last 5 years

select 
	*
from netflix_data
where 
	TO_DATE(date_added, 'MONTH DD, YYYY')>= current_date - INTERVAl '5 years';
	

-- Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

-- Using 'ILike' operator:

select 
	* 
from netflix_data
where director ILIKE '%Rajiv Chilaka%';

-- Using UNNEST, STRING_TO_ARRAY, TRIM and SubQueries:

select * from
(
	select 
		*,
		trim(valuee) as directors from
	(
		select *,
			UNNEST(STRING_TO_ARRAY(director,',')) as valuee
		from netflix_data
	) as x
) as y 
where directors ='Rajiv Chilaka';
	
-- Q8. List all TV shows with more than 5 seasons

select * from
(
	select 
		* 
	from netflix_data
	where duration ~* 'Seasons' -- '~* same as ILIKE'
	AND
	cast(regexp_replace(duration, '[^0-9]', '', 'g') AS INTEGER) > 5
) as a 
where type = 'TV Show';

-- Q9. Count the number of content items in each genre

select 
	count(show_id) as no_of_content,
	trim(UNNEST(STRING_TO_ARRAY(listed_in,','))) as genre
from netflix_data
GROUP BY 2
order by 1;

-- Q10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

select 
	EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) as years,
	COUNT(*) as counts,
	CONCAT(ROUND(COUNT(*):: numeric/ (select COUNT(*) from netflix_data where country='India') ::numeric* 100,2),'%') as avg_content
from netflix_data 
Where country = 'India'
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;

-- Q11. List all movies that are documentaries

select *
from netflix_data
where 
	type = 'Movie'
		and 
	listed_in ILIKE '%Documentaries%';

-- Q12. Find all content without a director

select *
from netflix_data
where 
	director IS NULL;

-- Q13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
	from netflix_data
WHERE 
	casts ilike '%Salman Khan%'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select count(*) as no_of_movies_acted,
	trim(UNNEST(STRING_TO_ARRAY(casts,','))) as actors
	from netflix_data
WHERE 
	country ilike '%India'
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

select Category, count(description) as total_count
from
(
	select description,
		case 	
			when description ~* '\mviolence' 
			OR 
			description ~* '\mkill' then 'Bad_Content'
			else 'Good_Content'
		end as Category
	from netflix_data
) as x 
GROUP BY 1;

-- End Of the Project















 


