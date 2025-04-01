---1.Count the Number of Movies vs TV Shows
SELECT type,
 COUNT(*)
FROM netflix
GROUP BY 1;

-----2.Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;




--3.List all movies released in a specific year (e.g.2020)

select * from netflix
where type = 'Movie' and release_year=2020;

--4. Find the top 5 countries with the most content on netflix

select unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from netflix
group by 1
order by 2 asc limit 5;

--5.Identify the longest movie?
select type,duration  from netflix 
where type='Movie' and duration = (select max(duration) from netflix);

--6.Find content added in the last 5 years
select * from netflix
where 
To_date(date_added,'Month DD,YYYY')>=Current_date-Interval '5 years';

--7.Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from netflix 
where director like  '%Rajiv Chilaka%';

--8.List all Tv shows with more than 5 seasons

select *
from netflix where type='TV Show' and
split_part(duration,' ',1):: numeric > 5 ;

--9. Count the number of content items in each genre

select unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content from
netflix group by 1;

--10.Find each year and the average number of content release in india on netflix,
----return top 5 year with highest avg content release---

select extract(year from to_date(date_added, 'Month DD,YYYY')) as date,
count(*) as yearly_content,
Round(count(*)::numeric/(select count(*) from netflix where country='India') * 100,2)
as avg_content_india
from netflix
where country = 'India'
group by 1
;

--11. list all movies that are documentries

select * from netflix
where
listed_in like '%Documentaries%';

--12. Find all content without a director
select * from netflix
where director is null;

--13. Find how many movies actor 'salman khan' appeared in last 10 year

select * from netflix
where casts like '%Salman Khan%'
and release_year > Extract(year from current_Date) - 10;

--14. Find the top 10 actors who have appeared in the higest no. of movies produced in india

select 
unnest(string_to_array(casts,',')) as actors,
count(*) as total_content from netflix
where country like '%India%'
group by 1
order by 2 desc
limit 10;

--15.categorize the content based on the presence of the keyword "kill" and "violence" in
--- the descreption field. Label content containing these keyword as 'Bad' and all other 
--- content as 'Good' , count how many items fail into each category

with new_table
as(

select *,case 
       when description like '%kill%' or
	   description like '%violence%' then 'Bad_Content'
	   else 'Good_Content'
	   end category
	   from netflix
)
select category,
count(*) as total_count from new_table
group by 1;
