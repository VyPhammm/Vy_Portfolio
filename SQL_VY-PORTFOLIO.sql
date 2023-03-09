
-- Data: Covid 19  
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


SELECT *
FROM VY_PORTFOLIO..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population_density
FROM VY_PORTFOLIO..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- Shows what percentage of population infected with Covid

SELECT location, date, population_density, total_cases,  ROUND( (total_cases/population_density)*100, 3) as PercentPopulationInfected
FROM VY_PORTFOLIO..CovidDeaths
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population_density, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population_density))*100 as PercentPopulationInfected
FROM VY_PORTFOLIO..CovidDeaths
GROUP BY location, population_density
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM VY_PORTFOLIO..CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM VY_PORTFOLIO..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND( SUM(cast(new_deaths as int))/SUM(New_Cases)*100, 3) as DeathPercentage
FROM VY_PORTFOLIO..CovidDeaths
WHERE continent is not null 

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Join

SELECT d.continent, d.location, d.date, d.population_density, v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.Date) as RollingPeopleVaccinated
FROM VY_PORTFOLIO..CovidDeaths d
INNER JOIN VY_PORTFOLIO..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null 
ORDER BY 2,3

-- CTE 

WITH PovsVa (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population_density, v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.Date) as RollingPeopleVaccinated
FROM VY_PORTFOLIO..CovidDeaths d
INNER JOIN VY_PORTFOLIO..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null 
)
SELECT *
FROM PovsVa


-- CREATE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population_density, v.new_vaccinations
	, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
FROM VY_PORTFOLIO..CovidDeaths d
	INNER JOIN VY_PORTFOLIO..CovidVaccinations v
		ON d.location = v.location
		AND d.date = v.date

SELECT *
FROM #PercentPopulationVaccinated



-- CREATE VIEW


CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population_density, v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
FROM VY_PORTFOLIO..CovidDeaths d
INNER JOIN VY_PORTFOLIO..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null 