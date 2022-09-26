select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

-- select data that we are going to use 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- seeing at Total Cases VS Total Deaths
select location, date, total_cases, total_deaths,  (total_deaths / total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

--Seeing at Total Cases VS Population
-- It shows that what percentage of population got covid
select location, date,  population, total_cases, (total_cases / population)*100 as Infection_rate
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, date, population, max(total_cases) as Highest_infection_count, max((total_cases / population))*100 as Infection_rate
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location,population, date
order by Infection_rate desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Looking countries with highest death rate
select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by  location
order by Total_Death_count desc

--showing continent with highest date count per population

select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by  location
order by Total_Death_count desc

--Global Numbers

select Sum(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int)) / Sum(New_cases) * 100 as Deathpercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert( int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 --,(RollingPeopleVaccinated / population) * 100 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --Use CTE
 with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeoplevaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert( int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 --,(RollingPeopleVaccinated / population) * 100 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select (RollingPeoplevaccinated/population)*100
 from PopVsVac


 --TempDB
 drop table if exists percentpopulationvaccinated
 create table percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar (255),
 date datetime,
 population numeric,
 New_vaccinations numeric, 
 RollingPeopleVaccinated numeric 
 )


 Insert into percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeoplevaccinated
 --,(RollingPeopleVaccinated / population) * 100 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
 select *, (RollingPeoplevaccinated/population)*100
 from percentpopulationvaccinated



 --Creating a view to store data for later visualizations

 create view  Percentagevaccinatedpeople as 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeoplevaccinated
 --,(RollingPeopleVaccinated / population) * 100 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select * 
 from Percentagevaccinatedpeople


 select location , SUM(cast(new_deaths as int)) as Totaldeathcount
 from PortfolioProject..CovidDeaths$
 where continent is null 
 and location not in ('world', 'European union', 'International')
 Group by location
 order by Totaldeathcount Desc