-- Select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location =  'China' 
order by 1,2
 
 -- Total Cases vs Population
 select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--WHERE location =  'Pakistan' OR location = 'pakistan'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location , population, MAX(total_cases) as HighestInfecionCount ,MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
group by location,population
order by PercentagePopulationInfected desc

-- Showing Countrties with Highest Death Count per Population
select location ,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing Continent with Highest Death Count per Population
select continent ,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Number 
select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

with PopvsVac (Continent, Location, Date , Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed_per_hundred
, SUM(Cast(vac.new_people_vaccinated_smoothed_per_hundred as float)) OVER 
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed_per_hundred
, SUM(Cast(vac.new_people_vaccinated_smoothed_per_hundred as float)) OVER 
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later Visualisations
drop view if exists PercentPopulationVaccinated
use PortfolioProject
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed_per_hundred
, SUM(Cast(vac.new_people_vaccinated_smoothed_per_hundred as float)) OVER 
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated