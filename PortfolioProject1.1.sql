--select * from PortfolioProject..CovidDeaths
--order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location = 'canada'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From CovidDeaths
Where location = 'canada'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From CovidDeaths
Group by location, population
order by PercentPopulationInfected DESC


-- Showing the countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount DESC



-- Let's break things down by continent
-- Showing the continents with highest death count PER POPULATION

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC



-- Global numbers

Select SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
--group by date
order by 1,2



--VACCINATION

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




-- TEMP Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated






-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated