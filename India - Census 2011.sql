use census_project

 SELECT * FROM [ District]
SELECT * FROM [ Area]

-- count number of rows in dataset 

SELECT COUNT(*) FROM [ District]
SELECT COUNT(*) FROM [ Area]

-- DATASET FROM JHARKHAND AND BIHAR 

SELECT * 
FROM  [ District]
WHERE State in ('Jharkhand', 'Bihar') 

-- Total Population of India 

SELECT SUM(Population) AS total_population
FROM [ Area]

-- STATEWISE TOTAL POPULATION

SELECT state, SUM(population) AS total_population
FROM [ Area]
GROUP BY State
ORDER BY total_population DESC


--Total_Average_growth

SELECT ROUND(AVG(Growth),4)*100 AS total_growth_rate
FROM [ District]


-- Statewise Average Growth Rate

SELECT state, ROUND(AVG(Growth),3)*100 AS average_growth_rate 
FROM [ District] 
GROUP By State
ORDER BY average_growth_rate DESC


-- Top 5 state by Avg_growth
 SELECT TOP 5 state, ROUND(AVG(Growth),3)*100 AS  growth_rate 
FROM [ District] 
GROUP By State
ORDER BY growth_rate DESC



-- Top 5 State by HIGH Sex Ratio

SELECT TOP 5 state, ROUND(AVG(Sex_Ratio),0)  AS sex_ratio
FROM [ District] 
GROUP By State
ORDER BY  sex_ratio desc


--- States having Literacy Rate Greater Than 80
SELECT state, ROUND(AVG(Literacy),2) AS literacy_rate
FROM [ District]
GROUP BY State
HAVING ROUND(AVG(Literacy),2) > 80
ORDER BY literacy_rate DESC


--  Statewise Top 3 districts having Highest Literacy Rate using Window Function

 SELECT a.* FROM
( SELECT district, state,literacy,rank() over(partition by state order by literacy desc) rnk FROM [ District]) a
WHERE a.rnk in (1,2,3) 
ORDER BY state


-- Statewise Total Males and Females
 SELECT d.state , SUM(d.males) total_males, SUM(d.females) total_females FROM 
(SELECT c.district,c.state state, ROUND(c.population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females FROM 
(SELECT a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population FROM
[ District] a inner join  [ Area] b 
ON a.district=b.district ) c) d
GROUP BY d.state;


-- Statewise Total Literate and Illiterate Population 

 SELECT c.state, SUM(literate_people) total_literate_pop, SUM(illiterate_people) total_iliterate_pop FROM
 ( SELECT d.district,d.state, ROUND(d.literacy_ratio*d.population,0) literate_people, ROUND((1-d.literacy_ratio)* d.population,0) illiterate_people FROM
 ( SELECT a.district,a.state,a.literacy/100 literacy_ratio,b.population FROM
 [ District] a  inner join [ Area] b 
ON a.district=b.district) d) c
GROUP BY c.state


 -- population vs area

SELECT (g.total_area/g.previous_census_population) AS previous_census_population_vs_area, (g.total_area/g.current_census_population) AS 
current_census_population_vs_area FROM
(SELECT q.*,r.total_area FROM (

SELECT '1' AS keyy,n.* FROM
(SELECT SUM(m.previous_census_population) previous_census_population,SUM(m.current_census_population) current_census_population FROM(
SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population FROM
(SELECT d.district,d.state, ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population FROM
(SELECT a.district,a.state,a.growth growth,b.population from  [ District] a inner join  [ Area] b ON a.district=b.district) d) e
 GROUP BY e.state)m) n) q inner join (

SELECT '1' AS keyy,z.* FROM (
SELECT SUM(area_km2) total_area FROM  [ Area])z) r ON q.keyy=r.keyy)g
 




  

