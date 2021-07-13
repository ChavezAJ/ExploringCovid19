-- Covid19 Data Exploration

-- Observing Covid Deaths table

Select *
From PortfolioProject..CovidDeaths


-- Observing Covid Vaccinations table

Select *
From PortfolioProject..CovidVaccinations


-- Converting essential columns to appropriate data types

Alter Table PortfolioProject..CovidDeaths
Alter Column total_cases float;

Alter Table PortfolioProject..CovidDeaths
Alter Column new_cases float;

Alter Table PortfolioProject..CovidDeaths
Alter Column total_deaths float;

Alter Table PortfolioProject..CovidDeaths
Alter Column population float;


-- Select data that we will use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by location, date


-- Looking at Total Cases vs Total Deaths
-- Shows the chances of dying if you contract covid in the United States

Select Location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by location, date


-- Total cases vs Population
-- Percentage of population that contracted Covid

Select Location, date, population, total_cases, (total_cases/NULLIF(population, 0))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by location, date


-- Countries with Highest Infection Rate

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/NULLIF(population,0)))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopInfected desc


-- Countries with Highest Death Count 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location not in ('World','Europe','South America','North America','Asia','Africa','Oceania')
Group by location
Order by TotalDeathCount desc


-- Death Count by Continent

Select top 6 continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by continent
Order by TotalDeathCount 


-- Global Numbers
-- Global death percentages by the day

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Group by date
Order by date, TotalCases


-- Total Population vs Vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date) as RollingPplVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.location not in ('World','Europe','South America','North America','Asia','Africa','Oceania')
Order by d.location, d.date


-- Total Population vs Vaccinations with Percentage of People Vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPplVaccinated)
as 
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date) as RollingPplVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.location not in ('World','Europe','South America','North America','Asia','Africa','Oceania')
)
Select *, (RollingPplVaccinated/NULLIF(population,0))*100 PercentagePplVaccinated
From PopvsVac


-- View to store data for future visualizations
 
Create View GlobalPeopleVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date) as RollingPplVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.location not in ('World','Europe','South America','North America','Asia','Africa','Oceania')
