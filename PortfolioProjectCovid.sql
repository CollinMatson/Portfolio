SELECT * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths$
group by location, population
order by InfectionRate desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the Death Count by continent
-- Had to change total_deaths from nvarchar255 to int using CAST

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- NOW LET'S BREAK IT DOWN BY COUNTRY
-- Showing the countries with the highest Deatch Count per Population
-- Had to change total_deaths from nvarchar(255) to int using CAST

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- First Query shows new cases across the world by date
SELECT date, SUM(new_cases)--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
group by date
order by 1,2

-- Second Query shows new cases per day compared to the number of deaths on that day and its percentage
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
group by date
order by 1,2

-- Third Query we comment out the date to show overall numbers, and death rate
-- Shows 150,574,977 cases and 3,180,206 deats for a death rate of 2.11%
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
t
-- Gives a running count of vaccinations over time using 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE to create a table showing a rolling count of people vaccinated and matching percentage of a countries population that is vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac

-- TEMP TABLE
-- Added Drop Table incase I ever want to make alterations
Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
Select *, (rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3







