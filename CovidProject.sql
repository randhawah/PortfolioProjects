SELECT *
FROM coviddeaths
ORDER BY 3 , 4;


-- select * from covidvaccines order by 3,4;

-- select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the total cases VS total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
Where location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the total cases VS the population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM coviddeaths
Where location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Let's break things down by continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers by date
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total Global Deaths and Death Percentage
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- View table CovidVaccinations
SELECT *
FROM covidvaccines;

-- Join 2 tables
SELECT *
FROM coviddeaths dea
JOIN covidvaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date;

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Looking at total population vs vaccinations and TotalPercent Vaccinated by location
-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- and dea.location like '%canada%'
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac;

-- Using Temp Table 
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY Table PercentPopulationVaccinated
(
	Continent nvarchar(255), 
	Location nvarchar(255), 
	Date datetime, 
	Population numeric, 
	New_Vaccinations numeric, 
	RollingPeopleVaccinated numeric
);

	INSERT INTO PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	FROM coviddeaths dea
	JOIN covidvaccines vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3;

	SELECT * 
	FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- View the View
SELECT * 
FROM PercentPopulationVaccinated;





