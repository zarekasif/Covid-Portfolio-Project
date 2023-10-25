select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4


-- Looking at Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate
select Location,population, Max(total_cases) as HighestInfected, max((total_deaths/total_cases)) *100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null 
group by location, population
order by PercentagePopulationInfected desc


--Showing Countries with th Highest Death count per population
select Location, Max(cast(total_deaths as int)) as HighestDeaths
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by HighestDeaths desc


--Lets break things by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location is ike '%states%'
where continent is not null 
group by continent 
order by TotalDeathCount desc


-- Global Numbers 
select sum((new_cases)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2

-- Looking at total popuation vs vaccinations
with PopvsVac (Continent, location, date, popuation, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--where dea.new_vaccinations is not null
--order by 2,3
)

-- USE CTE
select *, (RollingPeopleVaccinated/popuation)*100
from PopvsVac


--TEMP TABLE
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--where dea.new_vaccinations is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--where dea.new_vaccinations is not null
--order by 2,3
