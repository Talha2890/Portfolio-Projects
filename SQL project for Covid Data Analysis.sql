select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..covidDeaths
where continent is not NULL
order by 1,2

--Looking at the Total Cases vs Total Deaths
-- Shows likelihood of die.. if you contract with COVID in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_Percentage
from portfolioProject..covidDeaths
--where location like '%states%'
where continent is not NULL
order by 1,2

--Looking at the Total Cases vs Population
-- Shows Percentage of People Got COVID +ve in your country
select location, date, population,total_cases,  (total_cases/population)*100 AS Covid_Cases
from portfolioProject..covidDeaths
where location like '%states%'
and continent is not NULL
order by 1,2

-- Shows Percentage of People Got COVID +ve in your country
select location, population, MAX(total_cases) as HighestInfectedCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
from portfolioProject..covidDeaths
where continent is not NULL
Group by Location, population
Order by PercentPopulationInfected DESC

-- Showing Countries with Highest Deaths Count Per Population
select location, population, MAX(total_deaths) as HighestDeaths,  MAX((total_deaths/population))*100 AS HighestPercent_ofDeaths
from portfolioProject..covidDeaths
Group by Location, population
Order by HighestPercent_ofDeaths DESC


-- Highest Deaths
select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..covidDeaths
where continent is not NULL
Group by Location
Order by TotalDeathsCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the Highest Deaths Count
select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from portfolioProject..covidDeaths
where continent is not NULL
Group by continent
Order by TotalDeathsCount DESC

-- Global Numbers

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 
 AS Deaths_Percentage
from portfolioProject..covidDeaths
--where location like '%states%'
where continent is not NULL
Group by Date
Order by 1,2


--Withouts Date

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 
 AS Deaths_Percentage
from portfolioProject..covidDeaths
--where location like '%states%'
where continent is not NULL
--Group by Date
Order by 1,2

--Looking at Total Population vs Vaccination

Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
		from PortfolioProject..CovidDeaths dea
		Join PortfolioProject..CovidVaccinations vac
			ON dea.location= vac.location
			and dea.date= vac.date
		where dea.continent is not NULL
		order by 2,3
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated) as
(
	Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated 
	--(RollingPeopleVaccinated/population)*100
			from PortfolioProject..CovidDeaths dea
			Join PortfolioProject..CovidVaccinations vac
				ON dea.location= vac.location
				and dea.date= vac.date
			where dea.continent is not NULL
		--order by 2,3
)
Select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
	Drop Table if exists #percentPopulationVaccinated
	Create Table #percentPopulationVaccinated
	(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccinations numeric,
		RollingPeopleVaccinated numeric
	)

	insert into #percentPopulationVaccinated
	Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated 
	--(RollingPeopleVaccinated/population)*100
			from PortfolioProject..CovidDeaths dea
			Join PortfolioProject..CovidVaccinations vac
				ON dea.location= vac.location
				and dea.date= vac.date
			where dea.continent is not NULL
	
	Select * ,(RollingPeopleVaccinated/population)*100
	from #percentPopulationVaccinated


-- Create View for Later Visualization
USE PortfolioProject
GO
Create View percentPopulationVaccinated as
	Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated 
		--(RollingPeopleVaccinated/population)*100
			from PortfolioProject..CovidDeaths dea
			Join PortfolioProject..CovidVaccinations vac
				ON dea.location= vac.location
				and dea.date= vac.date
			where dea.continent is not NULL
		--order by 2,3

select *
from percentPopulationVaccinated
