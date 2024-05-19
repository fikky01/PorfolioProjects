
select * from PortfolioProject..['covid deaths]
where continent is not null
order by 3,4 


--select * from PortfolioProject..[CovidVacinnations]
--order by 3,4 


select location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid deaths]
order by 1,2

--Total Cases vs. Total Deaths
select location, date,total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Death_percentage
from PortfolioProject..['covid deaths]
order by 1,2

--total Cases vs. Population
--This shows the percentage of population that got covid
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulatonInfected
from PortfolioProject..['covid deaths]
--where location like '%nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestInfectionCount, max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulatonInfected
from PortfolioProject..['covid deaths]
--where location like '%nigeria%'
group by location, population
order by PercentPopulatonInfected desc

--showing Countries with the highest death count per population
select location, max(cast(total_deaths as int))  as TotalDeathCount
from PortfolioProject..['covid deaths]
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--showing total deaths by continent
select continent, max(cast(total_deaths as int))  as TotalDeathCount
from PortfolioProject..['covid deaths]
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int))  as TotalDeathCount
from PortfolioProject..['covid deaths]
where continent is  null
group by location
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases), 0)*100 as Death_percentage
from PortfolioProject..['covid deaths]
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


--Total Population vs. Vaccination
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as peopleVacinated
from PortfolioProject..['covid deaths] dea
join PortfolioProject..CovidVacinnations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--use CTE
with popsvsvac(continent, location, date, population, new_vaccinations, peopleVacinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as peopleVacinated
from PortfolioProject..['covid deaths] dea
join PortfolioProject..CovidVacinnations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
 select * , (peopleVacinated/population) * 100
 from popsvsvac


 --Temp Table
 --drop table if exists  #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 ( continent nvarchar(225),
 location nvarchar(225),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 peopleVaccinated numeric)

 insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as peopleVacinated
from PortfolioProject..['covid deaths] dea
join PortfolioProject..CovidVacinnations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 select * , (peopleVaccinated/population) * 100
 from #PercentPopulationVaccinated

--creating views to save for later visualization

--Percentage of population Vaccinated
create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as peopleVacinated
from PortfolioProject..['covid deaths] dea
join PortfolioProject..CovidVacinnations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--Visualization of Total Deaths by Continent
create view TotalDeathCount as
select continent, max(cast(total_deaths as int))  as TotalDeathCount
from PortfolioProject..['covid deaths]
where continent is not null
group by continent
--order by TotalDeathCount desc

--Visualization of Rolling People Vaccinated
create view peopleVaccinated as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as peopleVacinated
from PortfolioProject..['covid deaths] dea
join PortfolioProject..CovidVacinnations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3