/* 
    1. How many olympics games have been held?
    Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset. 
*/
select count(distinct(games)) as total_olympic_games  from  athleteevents;

/* 
    2. List down all Olympics games held so far.
    Problem Statement: Write a SQL query to list down all the Olympic Games held so far.
 */

    --SELECT SPLIT_PART(games, ' ', 1) AS year,
    --SPLIT_PART(games, ' ', 2) AS season
    --FROM athleteevents; (Postgres)
select distinct year,season,city from athleteevents order by year;

    --select distinct year,season,city,region from athleteevents left join nocregions on nocregions.noc = athleteevents.noc order by year;

/* 
    3. Mention the total no of nations who participated in each olympics game?
    Problem Statement: SQL query to fetch total no of countries participated in each olympic games.
*/

select games, count(distinct(region)) as total_countries 
from athleteevents 
left join nocregions on nocregions.noc=athleteevents.noc  
group by games 
order by games;

-- OR --

--Common Table Expression (CTE) - all_countries:       
with all_countries as
        (select games, nr.region
        from athleteevents ae
        join nocregions nr ON nr.noc = ae.noc
        group by games, nr.region)
        
select games, count(1) as total_countries 
from all_countries
group by games
order by games;

    /* COUNT(1) as a way of counting rows in a table. The 1 doesn't represent any specific column; it's just a placeholder that says "count each row once." So, when you see COUNT(1) in SQL, it's like saying "count all the rows." 
        
    Both COUNT(1) and COUNT(*) are commonly used for counting rows in SQL, and they generally produce the same result. However, COUNT(1) may be slightly faster in some database systems due to its simplicity. */

/* 
    4. Which year saw the highest and lowest no of countries participating in olympics?
    Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries. 
*/

WITH participated_countries AS (
    SELECT 
        year, 
        season, 
        COUNT(DISTINCT noc) AS p_no 
    FROM athleteevents 
    GROUP BY year, season
)                                                                        

SELECT 
    CONCAT(year, ' ', season, ' ', p_no) AS min_max_countries  
FROM participated_countries 
WHERE p_no = (SELECT MIN(p_no) FROM participated_countries) 
   OR p_no = (SELECT MAX(p_no) FROM participated_countries);

-- OR -- 

with all_countries as
        (select games, nr.region
        from athleteevents ae
        join nocregions nr ON nr.noc = ae.noc
        group by games, nr.region),
    tot_countries as
        (select games, count(1) as total_countries
        from all_countries
        group by games)
    select distinct
    concat(first_value(games) over(order by total_countries) 
    
    -- FIRST_VALUE(games): This is the window function that returns the first value of the games column within the current window frame.
    -- OVER: This keyword indicates that a window function is being used.
    , ' - '
    , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
    concat(first_value(games) over(order by total_countries desc)
    , ' - '
    , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
    from tot_countries
    order by 1;

/*  
    5. Which nation has participated in all of the olympic games?
    Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.
*/

    --  select distinct(region),string_agg(distinct games, ',') from athleteevents left join nocregions on nocregions.noc = athleteevents.noc  group by region;

with country_wise_game_participation as ( 
    select distinct(region),count(distinct games) as g_no 
    from athleteevents 
    left join nocregions 
    on nocregions.noc = athleteevents.noc   
    group by region          
 )                                                                                        
 
select region,g_no from country_wise_game_participation where g_no = (select max(g_no) from country_wise_game_participation);

-- OR --

with tot_games as
        (select count(distinct games) as total_games
        from athleteevents),
    countries as
        (select games, nr.region as country
        from athleteevents ae
        join nocregions nr ON nr.noc=ae.noc
        group by games, nr.region),
    countries_participated as
        (select country, count(1) as total_participated_games
        from countries
        group by country)
select cp.*
from countries_participated cp
join tot_games tg on tg.total_games = cp.total_participated_games
order by 1;


/* 
    6. Identify the sport which was played in all summer olympics.
    Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.
 */

with total_summer_games as(
    select count(distinct games) as s_games from athleteevents where season = 'Summer'
),
summer_sports as (
    select sport, count(distinct games) as g_no from athleteevents where season = 'Summer' group by sport
)
select sport, g_no from summer_sports where g_no = (select * from total_summer_games);

-- OR
 
 with t1 as
    (select count(distinct games) as total_games
    from athleteevents where season = 'Summer'),
    t2 as
    (select distinct games, sport
    from athleteevents where season = 'Summer'),
    t3 as
    (select sport, count(1) as no_of_games
    from t2
    group by sport)
select *
from t3
join t1 on t1.total_games = t3.no_of_games;

    -- COUNT(*) counts all the rows including NULLs

    -- COUNT(1) counts all the rows including NULLs

    -- COUNT(column_name) counts all the rows but not NULLs.

/* 
    7. Which Sports were just played only once in the olympics?
    Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.
 */

with games_and_sport as(
    select distinct games,sport from athleteevents
),
once_played_sport as (
    select sport, count(distinct games) as no_of_games from games_and_sport group by sport 
)
select games_and_sport.sport, no_of_games ,games from games_and_sport 
join once_played_sport on once_played_sport.sport=games_and_sport.sport
where once_played_sport.no_of_games = 1
order by games_and_sport.sport;


/* 
    8. Fetch the total no of sports played in each olympic games.
    Problem Statement: Write SQL query to fetch the total no of sports played in each olympics. 
*/

select games,count(distinct sport) as total_sport from athleteevents group by games order by total_sport Desc;

-- OR --

with t1 as
(select distinct games, sport
from athlete_events),
t2 as
(select games, count(1) as no_of_sports
from t1
group by games)
select * from t2
order by no_of_sports desc;


/* 
    9. Fetch details of the oldest athletes to win a gold medal.
    Problem Statement: SQL Query to fetch the details of the oldest athletes to win a 
    gold medal at the olympics. 
*/

select name, sex, age, team, games, city, sport, event, medal 
from athleteevents 
where medal='Gold' and age != 'NA' 
order by age Desc;

-- OR --

with temp as(
    select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
            ,team,games,city,sport, event, medal
        from athlete_events),
    ranking as
        (select *, rank() over(order by age desc) as rnk
        from temp
        where medal='Gold')
select *
from ranking
where rnk = 1;

/* 
    10. Find the Ratio of male and female athletes participated in all olympic games.
    Problem Statement: Write a SQL query to get the ratio of male and female participants 
*/

with t1 as
        (select sex, count(1) as cnt from athleteevents group by sex),
     t2 as
        (select *, row_number() over(order by cnt) as rn from t1),
     min_cnt as
        (select cnt from t2	 where rn = 1),
     max_cnt as
        (select cnt from t2	 where rn = 2)
select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio from min_cnt, max_cnt;

/* 
    11. Fetch the top 5 athletes who have won the most gold medals.
    Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals. 
*/

select name,count(medal) as total_medal  from athleteevents 
where medal='Gold' group by name order by total_medal Desc limit 5;

-- OR --

with t1 as
        (select name, team, count(1) as total_gold_medals
        from athleteevents
        where medal = 'Gold'
        group by name, team
        order by total_gold_medals desc),
    t2 as
        (select *, dense_rank() over (order by total_gold_medals desc) as rnk
        from t1)
select name, team, total_gold_medals
from t2
LIMIT 5;

/* 
    12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
    Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze). 
*/

SELECT name, team, count(medal) as total_medal FROM athleteevents WHERE medal = 'Gold' OR medal ='Silver' OR medal = 'Bronze' GROUP BY name,team ORDER BY total_medal DESC LIMIT 5;

-- OR --

SELECT name, team, count(medal) as total_medal FROM athleteevents WHERE medal in ('Gold','Silver','Bronze') GROUP BY name,team ORDER BY total_medal DESC LIMIT 5;

-- OR --

with t1 as
        (select name, team, count(1) as total_medals
        from athleteevents
        where medal in ('Gold', 'Silver', 'Bronze')
        group by name, team
        order by total_medals desc),
    t2 as
        (select *, dense_rank() over (order by total_medals desc) as rnk
        from t1)
select name, team, total_medals
from t2
where rnk <= 5;


/*
    13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
    Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).
*/

SELECT region as country, count(medal) as total_medals, dense_rank() over(order by count(medal) desc) as rank
FROM athleteevents ae
left join nocregions nr 
on nr.noc=ae.noc  
WHERE medal in ('Gold','Silver','Bronze') 
GROUP BY country 
LIMIT 5;

-- OR --

with t1 as
        (select nr.region, count(1) as total_medals
        from athleteevents ae
        join nocregions nr on nr.noc = ae.noc
        where medal <> 'NA'
        group by nr.region
        order by total_medals desc),
    t2 as
        (select *, dense_rank() over(order by total_medals desc) as rank
        from t1)
select *
from t2
where rnk <= 5;


/*
    14. List down total gold, silver and broze medals won by each country.
    Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
*/
SELECT nr.region as country,
    COUNT( CASE WHEN ae.medal = 'Gold' THEN 1 END ) AS gold_medal,
    COUNT( CASE WHEN ae.medal = 'Silver' THEN 1 END ) AS silver_medal,
    COUNT( CASE WHEN ae.medal = 'Bronze' THEN 1 END ) AS bronze_medal
FROM athleteevents ae
left join nocregions nr
on nr.noc = ae.noc
GROUP BY nr.region
ORDER BY gold_medal DESC;

-- OR --

    -- -- PIVOT
    -- In Postgresql, we can use crosstab function to create pivot table.
    -- crosstab function is part of a PostgreSQL extension called tablefunc.
    -- To call the crosstab function, you must first enable the tablefunc extension by executing the following SQL command:

    -- CREATE EXTENSION TABLEFUNC;

    -- The COALESCE function returns the first non-null argument. It is particularly useful for handling NULL values and substituting them with a default value.

SELECT country, 
    coalesce(gold, 0) as gold, 
    coalesce(silver, 0) as silver, 
    coalesce(bronze, 0) as bronze
FROM CROSSTAB(
        'SELECT nr.region as country, medal, count(1) as total_medals
        FROM athleteevents ae
        JOIN nocregions nr on nr.noc = ae.noc
        where medal <> ''NA''
        GROUP BY nr.region,medal
        order BY nr.region,medal',
        'values (''Bronze''), (''Gold''), (''Silver'')'
    )
AS FINAL_RESULT(country varchar, bronze bigint, gold bigint, silver bigint)
order by gold desc, silver desc, bronze desc;


/*
    15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
    Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.
*/

SELECT ae.games, nr.region as country, 
    COUNT( CASE WHEN ae.medal = 'Gold' THEN 1 END ) AS gold_medal,
    COUNT( CASE WHEN ae.medal = 'Silver' THEN 1 END ) AS silver_medal,
    COUNT( CASE WHEN ae.medal = 'Bronze' THEN 1 END ) AS bronze_medal
FROM athleteevents ae
join nocregions nr
on nr.noc = ae.noc
where medal <> 'NA'
GROUP BY ae.games,nr.region
ORDER BY ae.games,country;

-- OR -- 

        -- -- PIVOT
        -- In Postgresql, we can use crosstab function to create pivot table.
        -- crosstab function is part of a PostgreSQL extension called tablefunc.
        -- To call the crosstab function, you must first enable the tablefunc extension by executing the following SQL command:

        -- CREATE EXTENSION TABLEFUNC;

SELECT substring(games,1,position(' - ' in games) - 1) as games, 
    substring(games,position(' - ' in games) + 3) as country, 
    coalesce(gold, 0) as gold, 
    coalesce(silver, 0) as silver, 
    coalesce(bronze, 0) as bronze
FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games,
                medal,
                count(1) as total_medals
            FROM athleteevents ae
            JOIN nocregions nr on nr.noc = ae.noc
            where medal <> ''NA''
            GROUP BY games,nr.region,medal
            order BY games,medal',
        'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);

/*
    16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
    Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.
*/

    -- Why Use FIRST_VALUE() Instead of RANK()?
        -- FIRST_VALUE() directly extracts the top value, avoiding unnecessary filtering.
        -- RANK() would require an additional filter (WHERE rank = 1), making the query slightly longer.
WITH MedalCounts AS (
    SELECT 
        ae.games, 
        nr.region, 
        COUNT(CASE WHEN ae.medal = 'Gold' THEN 1 END) AS gold_count,
        COUNT(CASE WHEN ae.medal = 'Silver' THEN 1 END) AS silver_count,
        COUNT(CASE WHEN ae.medal = 'Bronze' THEN 1 END) AS bronze_count
    FROM athleteevents ae
    JOIN nocregions nr ON nr.noc = ae.noc
    WHERE ae.medal <> 'NA'
    GROUP BY ae.games, nr.region
)
SELECT DISTINCT 
    games,
    FIRST_VALUE(CONCAT(region, ' - ', gold_count)) 
        OVER (PARTITION BY games ORDER BY gold_count DESC) AS max_gold,
    FIRST_VALUE(CONCAT(region, ' - ', silver_count)) 
        OVER (PARTITION BY games ORDER BY silver_count DESC) AS max_silver,
    FIRST_VALUE(CONCAT(region, ' - ', bronze_count)) 
        OVER (PARTITION BY games ORDER BY bronze_count DESC) AS max_bronze
FROM MedalCounts
ORDER BY games;


-- OR --

    -- -- PIVOT
    -- In Postgresql, we can use crosstab function to create pivot table.
    -- crosstab function is part of a PostgreSQL extension called tablefunc.
    -- To call the crosstab function, you must first enable the tablefunc extension by executing the following SQL command:

    -- CREATE EXTENSION TABLEFUNC;


WITH temp as
    (SELECT substring(games, 1, position(' - ' in games) - 1) as games
        , substring(games, position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                    , medal
                    , count(1) as total_medals
                    FROM athleteevents ae
                    JOIN nocregions nr on nr.noc = ae.noc
                    where medal <> ''NA''
                    GROUP BY games,nr.region,medal
                    order BY games,medal',
                'values (''Bronze''), (''Gold''), (''Silver'')')
                AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint))
select distinct games
    , concat(first_value(country) over(partition by games order by gold desc)
            , ' - '
            , first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    , concat(first_value(country) over(partition by games order by silver desc)
            , ' - '
            , first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    , concat(first_value(country) over(partition by games order by bronze desc)
            , ' - '
            , first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
from temp
order by games;


/*
    17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
    Problem Statement: Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals. Along with this, identify also the country with the most medals in each olympic games.
*/

WITH MedalCounts AS (
    SELECT 
        ae.games, 
        nr.region, 
        COUNT(CASE WHEN ae.medal = 'Gold' THEN 1 END) AS gold_count,
        COUNT(CASE WHEN ae.medal = 'Silver' THEN 1 END) AS silver_count,
        COUNT(CASE WHEN ae.medal = 'Bronze' THEN 1 END) AS bronze_count,
        COUNT(ae.medal) AS total_medal
    FROM athleteevents ae
    JOIN nocregions nr ON nr.noc = ae.noc
    WHERE ae.medal <> 'NA'
    GROUP BY ae.games, nr.region
)
SELECT DISTINCT 
    games,
    FIRST_VALUE(CONCAT(region, ' - ', gold_count)) 
        OVER (PARTITION BY games ORDER BY gold_count DESC) AS max_gold,
    FIRST_VALUE(CONCAT(region, ' - ', silver_count)) 
        OVER (PARTITION BY games ORDER BY silver_count DESC) AS max_silver,
    FIRST_VALUE(CONCAT(region, ' - ', bronze_count)) 
        OVER (PARTITION BY games ORDER BY bronze_count DESC) AS max_bronze,
    FIRST_VALUE(CONCAT(region, ' - ', total_medal)) 
        OVER (PARTITION BY games ORDER BY total_medal DESC) AS max_medal
FROM MedalCounts
ORDER BY games;


-- OR --

with temp as
    (SELECT substring(games, 1, position(' - ' in games) - 1) as games
        , substring(games, position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                    , medal
                    , count(1) as total_medals
                    FROM athleteevents ae
                    JOIN nocregions nr ON nr.noc = ae.noc
                    where medal <> ''NA''
                    GROUP BY games,nr.region,medal
                    order BY games,medal',
                'values (''Bronze''), (''Gold''), (''Silver'')')
                AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    tot_medals as
        (SELECT games, nr.region as country, count(1) as total_medals
        FROM athleteevents ae
        JOIN nocregions nr ON nr.noc = ae.noc
        where medal <> 'NA'
        GROUP BY games,nr.region order BY 1, 2)
select distinct t.games
    , concat(first_value(t.country) over(partition by t.games order by gold desc)
            , ' - '
            , first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
    , concat(first_value(t.country) over(partition by t.games order by silver desc)
            , ' - '
            , first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
    , concat(first_value(t.country) over(partition by t.games order by bronze desc)
            , ' - '
            , first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
    , concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
            , ' - '
            , first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last)) as Max_Medals
from temp t
join tot_medals tm on tm.games = t.games and tm.country = t.country
order by games;

/*
    18. Which countries have never won gold medal but have won silver/bronze medals?
    Problem Statement: Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal. 
*/

    -- COALESCE(..., 0) to handle NULL values
    -- Ensures countries with no medals in a category are represented as 0 instead of NULL.

WITH temp_table AS (
    SELECT nr.region as country,
            COUNT(CASE WHEN ae.medal = 'Gold' THEN 1 END) AS gold_medal, -- OR -- COALESCE(COUNT(CASE WHEN ae.medal = 'Gold' THEN 1 END), 0) AS gold_medal
            COUNT(CASE WHEN ae.medal = 'Silver' THEN 1 END) AS silver_medal, -- COALESCE(COUNT(CASE WHEN ae.medal = 'Silver' THEN 1 END), 0) AS silver_medal,
            COUNT(CASE WHEN ae.medal = 'Bronze' THEN 1 END) AS bronze_medal -- COALESCE(COUNT(CASE WHEN ae.medal = 'Bronze' THEN 1 END), 0) AS bronze_medal
    FROM athleteevents ae
    JOIN nocregions nr ON nr.noc = ae.noc
    GROUP BY nr.region
) 

SELECT *
FROM temp_table
WHERE gold_medal = 0  -- Ensures the country has never won a gold
  AND (silver_medal > 0 OR bronze_medal > 0)  -- Ensures they have won at least silver or bronze
ORDER BY silver_medal DESC;


-- OR --

select * from (
    SELECT country, coalesce(gold,0) as gold, coalesce(silver,0) as silver, coalesce(bronze,0) as bronze
        FROM CROSSTAB('SELECT nr.region as country
                    , medal, count(1) as total_medals
                    FROM athleteevents ae
                    JOIN nocregions nr ON nr.noc = ae.noc
                    where medal <> ''NA''
                    GROUP BY nr.region,medal order BY nr.region,medal',
                'values (''Bronze''), (''Gold''), (''Silver'')')
        AS FINAL_RESULT(country varchar,bronze bigint, gold bigint, silver bigint)
        ) x
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;



/*
    19. In which Sport/event, India has won highest medals.
    Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals. 
*/

SELECT sport, COUNT(medal) AS total_medals
FROM athleteevents
WHERE UPPER(team) LIKE 'INDIA%' AND  medal <> 'NA'
GROUP BY sport 
ORDER BY total_medals DESC
LIMIT 1;

-- OR --

with t1 as
        (select sport, count(1) as total_medals
        from athleteevents
        where medal <> 'NA'
        and team = 'India'
        group by sport
        order by total_medals desc),
    t2 as
        (select *, rank() over(order by total_medals desc) as rnk
        from t1)
select sport, total_medals
from t2
where rnk = 1;

/*
    20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
    Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 
*/

SELECT sport, 
    COUNT(CASE WHEN medal='Gold' THEN 1 END) AS gold_medals,
    COUNT(CASE WHEN medal='Silver' THEN 1 END) AS silver_medals,
    COUNT(CASE WHEN medal='Bronze' THEN 1 END) AS bronze_medals
FROM athleteevents
WHERE UPPER(team) LIKE 'INDIA%' 
    AND  medal <> 'NA' 
    AND UPPER(sport) LIKE 'HOCKEY%'
GROUP BY sport;
 
-------------------------------------------------------- 

SELECT team, sport, games, COUNT(medal) AS total_medals
FROM athleteevents
WHERE UPPER(team) LIKE 'INDIA%' 
    AND  medal <> 'NA' 
    AND UPPER(sport) LIKE 'HOCKEY%'
GROUP BY sport,team,games
ORDER BY total_medals DESC;

-- OR -- 

select team, sport, games, count(1) as total_medals
from athleteevents
where medal <> 'NA'
    and team = 'India' 
    and sport = 'Hockey'
group by team, sport, games
order by total_medals desc;
