SELECT * FROM EV_Population;

--This gives the percent of teslas over all electric cars
WITH new_cte AS(
SELECT COUNT(VIN) AS TeslaPopulation
FROM EV_Population
WHERE Make like 'Tesla'
)
--SELECT * FROM new_cte;

, new_cte2 AS(
SELECT COUNT(VIN) AS TotalPopulation
FROM EV_Population
)
--SELECT * FROM new_cte2

SELECT ROUND((TeslaPopulation / CAST(TotalPopulation AS FLOAT)) * 100, 2) AS PercentTeslas
FROM new_cte
CROSS JOIN new_cte2;

------------------
--Shows percent of each vehicle make in Washington state vs totalpopulation of EV
WITH new_cte AS(
SELECT Make, COUNT(VIN) AS MakePopulation
FROM EV_Population
GROUP BY Make)

, new_cte2 AS(
SELECT COUNT(VIN) AS TotalPopulation
FROM EV_Population
)

SELECT new_cte.Make, ROUND((MakePopulation / CAST(TotalPopulation AS FLOAT)) * 100, 2) AS PercentOfPopulation
FROM new_cte
CROSS JOIN new_cte2
ORDER BY PercentOfPopulation DESC;

---------

--Showing Number of EV models in King County
SELECT TOP 10 Make, Model, COUNT(VIN) AS NumberOfVehicles, Electric_Vehicle_Type
FROM EV_Population
WHERE County LIKE 'King%'
GROUP BY Make, Model, Electric_Vehicle_Type
ORDER BY NumberOfVehicles DESC;

-- Gives percent of Teslas in each county

WITH new_cte AS(
SELECT County, COUNT(VIN) AS TeslaPopulation
FROM EV_Population
WHERE Make like 'Tesla' AND STATE = 'WA'
GROUP BY County
)

, new_cte2 AS(
SELECT County, COUNT(VIN) AS TotalPopulation
FROM EV_Population
WHERE STATE = 'WA'
GROUP BY County
)
SELECT new_cte.County, ROUND((TeslaPopulation / CAST(TotalPopulation AS FLOAT))*100, 2) AS PercentTesla
FROM new_cte
JOIN new_cte2
ON new_cte.County = new_cte2.county
ORDER BY PercentTesla DESC

----------
--Shows percent of different teslas of all teslas

WITH Tesla_CTE AS (
    SELECT Make, Model, COUNT(VIN) AS TeslaModel
    FROM EV_Population
    WHERE Make LIKE 'Tesla' AND STATE = 'WA'
    GROUP BY Make, Model
),

Tesla_CTE2 AS (
    SELECT COUNT(VIN) AS TeslaCount
    FROM EV_Population
    WHERE Make LIKE 'Tesla' AND STATE = 'WA'
)

SELECT tc.Make, tc.Model, TeslaModel, ROUND((tc.TeslaModel * 100.0 / tc2.TeslaCount), 2) AS TeslaModelPercent
FROM Tesla_CTE tc
CROSS JOIN Tesla_CTE2 tc2
ORDER BY TeslaModelPercent DESC;



----
SELECT City, COUNT(VIN) AS NumberOfTeslas
FROM EV_Population
WHERE make = 'Tesla'
GROUP BY City
ORDER BY NumberOfTeslas DESC
