SELECT *
FROM Products.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- SELECT *
-- FROM Products.covidvaccinationscleannew
-- ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Products.coviddeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       (total_deaths/total_cases)*100 AS Death_Percentage
FROM Products.coviddeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM Products.coviddeaths
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2;


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, 
       population, 
       MAX(total_cases) AS highest_infection_count, 
       MAX((total_cases/population)*100) AS Percentage_Population_Infected
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
GROUP BY 1,2
ORDER BY Percentage_Population_Infected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location,
	MAX(total_deaths) AS Total_Death_Count
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location,
	MAX(total_deaths) AS Total_Death_Count
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;


-- Showing Continents with the highest death counts per population

SELECT continent,
	MAX(total_deaths) AS Total_Death_Count
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- GLOBAL NUMBERS

SELECT date, 
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS Death_Percentage
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT date, SUM(new_cases)
FROM Products.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS Total_Cases, 
       SUM(new_deaths) AS Total_Deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM Products.coviddeaths
-- WHERE location LIKE '%United Kingdom%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT *
FROM Products.coviddeaths AS dea
JOIN Products.covidvaccinations AS vac
ON dea.continent = vac.continent
AND dea.date = vac.date;

SELECT DEA.continent,
       DEA.location,
       DEA.date,
       DEA.population,
       VAC.new_vaccinations
FROM Products.coviddeaths AS DEA
     INNER JOIN Products.covidvaccinations AS VAC
     ON DEA.continent = VAC.continent
     AND DEA.date = VAC.date
     WHERE DEA.continent IS NOT NULL
     ORDER BY 2,3;
     
SELECT DEA.continent,
       DEA.location,
       DEA.date,
       DEA.population,
       VAC.new_vaccinations,
       SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS Rolling_People_Vaccinated
FROM Products.coviddeaths AS DEA
     INNER JOIN Products.covidvaccinations AS VAC
     ON DEA.continent = VAC.continent
     AND DEA.date = VAC.date
     WHERE DEA.continent IS NOT NULL
     ORDER BY 2,3;


-- USE CTE

WITH PopsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT DEA.continent,
       DEA.location,
       DEA.date,
       DEA.population,
       VAC.new_vaccinations,
       SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS Rolling_People_Vaccinated
FROM Products.coviddeaths AS DEA
     INNER JOIN Products.covidvaccinations AS VAC
     ON DEA.continent = VAC.continent
     AND DEA.date = VAC.date
     WHERE DEA.continent IS NOT NULL
) 
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopsVac;    


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent,
       DEA.location,
       DEA.population,
       VAC.new_vaccinations,
       SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS Rolling_People_Vaccinated
FROM Products.coviddeaths AS DEA
     INNER JOIN Products.covidvaccinations AS VAC
     ON DEA.continent = VAC.continent
     AND DEA.date = VAC.date
     WHERE DEA.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated; 
