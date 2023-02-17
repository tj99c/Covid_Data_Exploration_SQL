select *
from Covid_Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Covid_Portfolio_Project..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select Location, Date, total_cases, new_cases, total_deaths, population
from Covid_Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of Dying if you contract Covid in India

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Portfolio_Project..CovidDeaths
where location like 'Australia'
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

select Location, Date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from Covid_Portfolio_Project..CovidDeaths
--where location like 'Australia'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionPercentage
from Covid_Portfolio_Project..CovidDeaths
--where location like 'Australia'
group by location,population
order by InfectionPercentage desc

-- Countries with highest deathcount per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Portfolio_Project..CovidDeaths
--where location like 'Australia'
where continent is not null
group by location
order by TotalDeathCount desc

-- Lets break things down by continent

-- Showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Portfolio_Project..CovidDeaths
--where location like 'Australia'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Portfolio_Project..CovidDeaths
--where location like 'Australia'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Portfolio_Project..CovidDeaths dea
Join Covid_Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Portfolio_Project..CovidDeaths dea
Join Covid_Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Portfolio_Project..CovidDeaths dea
Join Covid_Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Portfolio_Project..CovidDeaths dea
Join Covid_Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated










