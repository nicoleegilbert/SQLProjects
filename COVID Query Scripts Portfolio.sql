--CREATED BY: Nicole Gilbert

--Looking at Total Cases vs Total Deaths. Likelihood of dying of COVID in Mexico.

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage'
--FROM COVID.dbo.CovidDeaths$
--WHERE location = 'Mexico'
--ORDER BY 1,2

--Looking at Total Cases vs Population. Shows what percentage of population contracted COVID

SELECT location, date,  population, total_cases,(total_cases/population)*100 as 'Percentage'
FROM COVID.dbo.CovidDeaths$
--WHERE location = 'Mexico'
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM COVID.dbo.CovidDeaths$
--WHERE location = 'Mexico'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with the highest death count per poulation

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location = 'Mexico'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing Continent Numbers with the highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location = 'Mexico'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as 'DeathPercentage'
FROM COVID.dbo.CovidDeaths$
--WHERE location = 'Mexico'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--TOTAL GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM COVID.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int), 
SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated,

FROM COVID.dbo.CovidDeaths$ dea
JOIN COVID.dbo.covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CT

WITH PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVID.dbo.CovidDeaths$ dea
JOIN COVID.dbo.covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null )

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMPORARY TABLE
DROP TABLE If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVID.dbo.CovidDeaths$ dea
JOIN COVID.dbo.covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating a View to Store data for later visualizations

CREATE VIEW GlobalCovidNumbers as

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location = 'Mexico'
WHERE continent is null
GROUP BY location
--ORDER BY TotalDeathCount desc

SELECT*
FROM GlobalCovidNumbers
