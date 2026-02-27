--1.	Count total number of titles.
select count(title)from netflix_project

--2.	Count number of Movies vs TV Shows.
select distinct(count(Type)) Count_Dis,
type
from netflix_project
Group by Type

--3.	Find the most common content rating (TV-MA, PG, etc.).
select top 1 
count(Rating) Count_per_rating,
rating
from netflix_project
group by rating
order by  Count_per_rating desc

--4.	Find the top 5 countries producing most content.
select top 5 
count(country) as content_percountry,
Country
from netflix_project
group by Country
order by content_percountry desc


--5.	Find how many titles were added each year.
select year(Date_added)as year_added,
count(title) as title_added,
lag(count(title)) over (order by year(Date_added)) as pervious_year_titles
from netflix_project
group by year(Date_added)
order by year_added

--6.	Find the oldest movie available.
select Title,Release_year,Type
from netflix_project
where type='movie' and 
release_year =(select min(release_year) as oldest_movie 
from netflix_project 
where Type='movie' );

--7.	Find the longest movie duration.
select Title,release_year,Duration from netflix_project where type='movie' and cast(replace(Duration,'min',' ')as int) =(select
max(cast(replace(Duration,'min',' ')as int))
from netflix_project
where type='movie');

--8.	Find top 10 genres with most content.
select top 10 
count(Listed_in) as content_Per_genre,
Listed_in
from netflix_project
group by Listed_in
order by content_Per_genre desc

--9.	Find average movie duration.
select avg(cast(replace(Duration,'min',' ')as int)) as avg_movie_duration
from netflix_project
where type='movie'

--10.	Find how many TV Shows have more than 3 seasons.
select count(*) from netflix_project
where type='TV show'and duration>'3 seasons'

--11.	Find content added in last 5 years.
select  top 5 year(Date_added)as year_added,
count(title) as Content_added
--lag(count(title)) over (order by year(Date_added)) as pervious_year_titles
from netflix_project
group by year(Date_added)
order by  year_added desc

--12.	Find which year had highest content addition.
select top 1 year(Date_added)as year_added,
count(title) as title_added
--lag(count(title)) over (order by year(Date_added)) as pervious_year_titles
from netflix_project
group by year(Date_added)
order by title_added desc

--13.	Find percentage of Movies vs TV Shows.
select
type,
count(type)total_count,
concat(round(100*count(type)/sum(count(type)) over(),3),'%') as percentage
from netflix_project
group by type

--14.	Find genre-wise growth over time.
;WITH genre_yearly AS (
    SELECT
        YEAR(date_added) AS year_added,
        LTRIM(RTRIM(value)) AS genre,
        COUNT(DISTINCT show_id) AS titles_added
    FROM netflix_project
    CROSS APPLY STRING_SPLIT(listed_in, ',')
    WHERE date_added IS NOT NULL
    GROUP BY YEAR(date_added), LTRIM(RTRIM(value))
)

SELECT
    year_added,
    genre,
    titles_added,
    LAG(titles_added) OVER (PARTITION BY genre ORDER BY year_added) AS prev_year_titles,
    ROUND(
        (titles_added - LAG(titles_added) OVER (PARTITION BY genre ORDER BY year_added))
        * 100.0 /
        NULLIF(LAG(titles_added) OVER (PARTITION BY genre ORDER BY year_added), 0),
        2
    ) AS yoy_growth_percent
FROM genre_yearly
ORDER BY genre, year_added;

--15.	Find country-wise Movie vs TV Show split.
select 
trim(country) as country,
type,
count(type)  
from netflix_project
cross apply string_split(country,',')
group by trim(country),type
order by country,type
--16.	Rank countries by number of TV Shows produced.
select
country,
count(type) total_tv_shows,
dense_rank() over(order by count(type) desc) as rank_country
from netflix_project
where type='TV show'
group by country
order by total_tv_shows desc


--17.	Find top 3 genres per year.
select 
listed_in,
years,
total_count from (select 
listed_in,
year(date_added) as years,
count(listed_in) as total_count,
row_number() over(partition by  year(date_added) order by count(listed_in)desc)as rn
from netflix_project 
group by year(date_added),Listed_in) ranked 
where rn<=3
order by years,total_count desc
--18.find year over year growth rate

;WITH yearly_titles AS (
    SELECT 
        YEAR ( date_added) AS year_added,
        COUNT(DISTINCT show_id) AS titles_added
    FROM netflix_project
    WHERE date_added IS NOT NULL
    GROUP BY YEAR(date_added)
)
SELECT
    year_added,
    titles_added,
    LAG(titles_added) OVER (ORDER BY year_added) AS previous_year_titles,
    ROUND(
        (titles_added - LAG(titles_added) OVER (ORDER BY year_added)) 
        * 100.0 
        / LAG(titles_added) OVER (ORDER BY year_added),
        2
    ) AS yoy_growth_percent
FROM yearly_titles
ORDER BY year_added;
*/
