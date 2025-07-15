SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Selecting data going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2


--Total cases vs Total deaths in Kenya
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Kenya%'
ORDER BY 1,2


--Looking at Total cases vs Population in Kenya
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS covidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY 1,2


--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS percentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percentagePopulationInfected DESC


--Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY totalDeathCount DESC


--Viewing the death count per population by continent

SELECT location, MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY totalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY totalDeathCount DESC


--Global totals

SELECT SUM(new_cases) as totalCases, SUM(CAST(new_deaths AS int)) AS totalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2



--Joining death and vaccinations data and looking at total population vs vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY 
	d.location, d.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null
ORDER BY 2,3


--Using Common Table Expression(CTE)

WITH popVSvac (continent, location, date, population, new_vaccinations, rollingVaccinations)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY 
	d.location, d.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null
)
SELECT *, (rollingVaccinations/population)*100
FROM popVSvac


--Using Temp Table

DROP TABLE if EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingVaccinations numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY 
	d.location, d.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null

SELECT *, (rollingVaccinations/population)*100
FROM #PercentagePopulationVaccinated


--Creating view for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY 
	d.location, d.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null

SELECT *
FROM PercentagePopulationVaccinated