SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations

-- Select data we are going to use

SELECT 
Location,Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- looking at total cases VS total deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT 
Location,Date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS "Death Percentage"
FROM CovidDeaths
WHERE Location LIKE 'Egypt'
AND continent is not null
ORDER BY 1,2

-- looking at the total cases VS the population
-- shows what percentage of population got COVID
SELECT 
Location,Date, population,total_cases, (total_cases/population) * 100 AS "Cases Percentage"
FROM CovidDeaths
WHERE Location LIKE 'Egypt'
AND continent is not null
ORDER BY 1,2 

--Looking at countries with highest infection rate compared to population

SELECT 
Location, population,MAX(total_cases) AS "highest infection count", MAX(total_cases/population) * 100 AS "Percent of population infected"
FROM CovidDeaths
WHERE continent is not null
--WHERE Location LIKE 'Egypt'
GROUP BY location, population
ORDER BY "Percent of population infected" DESC

-- showing countries with highest death count per population

SELECT 
Location, MAX(cast(Total_deaths as int)) AS totalDeathCount
FROM CovidDeaths
--WHERE Location LIKE 'Egypt'
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount DESC

-- lets break things down by continent
SELECT 
Location, MAX(cast(Total_deaths as int)) AS totalDeathCount
FROM CovidDeaths
--WHERE Location LIKE 'Egypt'
WHERE continent is null
GROUP BY Location
ORDER BY totalDeathCount DESC

-- showing the continents with the highest death count

SELECT 
Continent, MAX(cast(Total_deaths as int)) AS totalDeathCount
FROM CovidDeaths
--WHERE Location LIKE 'Egypt'
WHERE continent is not null
GROUP BY Continent
ORDER BY totalDeathCount DESC

-- GLOBAL NUMBERS

SELECT 
Date, SUM(new_cases) AS "Total Cases", SUM(CAST(new_deaths AS int)) AS "Total Deaths", SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100  AS "Death Percentage"
FROM CovidDeaths
--WHERE Location LIKE 'Egypt'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at total population VS Vaccination

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS int)) OVER (Partition by DEA.Location order by DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
     ON DEA.Location = VAC.Location
	 AND DEA.date = VAC.date
WHERE DEA.Continent is not null
ORDER BY 2,3

-- USE CTE

WITH POPvsVAC (continent, Location, date, population, new_vaccination,  RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS int)) OVER (Partition by DEA.Location order by DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
     ON DEA.Location = VAC.Location
	 AND DEA.date = VAC.date
WHERE DEA.Continent is not null
--ORDER BY 2,3
)
SELECT *, ( RollingPeopleVaccinated / Population)*100
FROM POPvsVAC

-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS int)) OVER (Partition by DEA.Location order by DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
     ON DEA.Location = VAC.Location
	 AND DEA.date = VAC.date
--WHERE DEA.Continent is not null
--ORDER BY 2,3

SELECT *, ( RollingPeopleVaccinated / Population)*100
FROM #PercentPopulationVaccinated

-- create view for data visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS int)) OVER (Partition by DEA.Location order by DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
     ON DEA.Location = VAC.Location
	 AND DEA.date = VAC.date
WHERE DEA.Continent is not null
--ORDER BY 2,3
