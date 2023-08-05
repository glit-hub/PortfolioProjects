--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths in the United Kingdom
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%United Kingdom%' AND (total_cases IS NOT NULL AND total_deaths IS NOT NULL)
Order By 1,2

--Looking at Total Cases vs Population in the United Kingdom
--Shows what percentage of population contracted COVID-19
SELECT location, date, population, total_cases, (CAST(total_cases AS float) / population) * 100 AS InfectedPercentage
FROM CovidDeaths
WHERE location LIKE '%United Kingdom%' AND (total_cases IS NOT NULL AND total_deaths IS NOT NULL)
Order By 1,2

--Look at countries with the highest infection rate compared to population
/*SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%United Kingdom%' AND (total_cases IS NOT NULL AND total_deaths IS NOT NULL)
GROUP BY location, population
Order By PercentPopulationInfected DESC
*/

--Showing Countries with Highest Death Count per population
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--GROUPING THE DEATH COUNTS BY CONTINENTS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--LETS CONNECT TOTAL CASES WITH TOTAL DEATHS BY CONTINENTS


SELECT continent, MAX(CAST(total_cases AS int)) AS TotalCases, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalCases DESC

--Showing continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases) *100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases IS NOT NUll
ORDER BY 1,2


WITH PopvsVac (continents, location, date, population, new_vaccinations,RollingVaccinations) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingVaccinations / Population)*100 AS PercentRollingVaccinationsToPopulation
FROM PopvsVac
WHERE location LIKE 'United States' AND date >= '2020-12-13'
ORDER BY location, date

--Let's create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3