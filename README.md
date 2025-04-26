# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (Movies vs TV shows).
- Identify the most common ratings for Movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix_data
(
    show_id      VARCHAR(8),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(210),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select 
	type, 
	count(distinct show_id) as total_content
from netflix_data
group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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

-- With CTE

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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select 
	distinct *
from netflix_data
	where type in ('Movie')
	and
	release_year in (2020);
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select
	trim(UNNEST(STRING_TO_ARRAY(country, ','))) as countries,
	count(1) as most_content
from netflix_data
group by 1
order by 2 desc
limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select * from netflix_data
where
	duration = (select max(duration) from netflix_data
				where type in('Movie'));
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select 
	*
from netflix_data
where 
	TO_DATE(date_added, 'MONTH DD, YYYY')>= current_date - INTERVAl '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
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
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select 
	count(show_id) as no_of_content,
	trim(UNNEST(STRING_TO_ARRAY(listed_in,','))) as genre
from netflix_data
GROUP BY 2
order by 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
Sselect 
	EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) as years,
	COUNT(*) as counts,
	CONCAT(ROUND(COUNT(*):: numeric/ (select COUNT(*) from netflix_data where country='India') ::numeric* 100,2),'%') as avg_content
from netflix_data 
Where country = 'India'
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select *
from netflix_data
where 
	type = 'Movie'
		and 
	listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select *
from netflix_data
where 
	director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select *
	from netflix_data
WHERE 
	casts ilike '%Salman Khan%'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10;

```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select count(*) as no_of_movies_acted,
	trim(UNNEST(STRING_TO_ARRAY(casts,','))) as actors
	from netflix_data
WHERE 
	country ilike '%India'
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Author - Nitheesh Krishna

Dive into Netflix data with pure SQL! Using PostgreSQL, this project uncovers hidden insights in the Netflix catalog—genres, release trends, durations, and more

- **LinkedIn**: [LinkedIn](https://www.linkedin.com/in/nitheesh-krishna-08b207258)
- **Email-ID**: [mail](nitheeshkrishbabu@gmail.com)

Thank you!
