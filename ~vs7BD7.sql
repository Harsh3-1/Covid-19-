 
Select location,cast(date as date) as Dateonly, total_cases, new_cases, total_deaths, population
from portfolio..CovidDeaths$
order by location,date

--total cases vs total deaths
Select distinct cast(date as date) as dateonly,location, total_cases, total_deaths, (total_deaths/total_cases)*100 as dead_perc
from portfolio..CovidDeaths$
where total_cases is not null
order by location,dateonly

--People who got covid
Select location,date, total_cases, total_deaths,population, (total_cases/population)*100 as affected_population
from portfolio..CovidDeaths$
where location = 'Germany'
order by location,date

Select location,date total_cases,Max(total_cases) as Highestcount,population, max((total_cases/population)*100) as highestaffected_population
from portfolio..CovidDeaths$
where location = 'Germany'
group by location,population,total_cases,date
order by Highestcount desc

Select location, max(cast(total_deaths as int)) as highestdeaths
from portfolio..CovidDeaths$
where location = 'Germany'
group by total_deaths,location
order by highestdeaths desc

Select continent, max(cast(total_deaths as int)) as highestdeaths
from portfolio..CovidDeaths$
where continent is not null
group by continent
order by highestdeaths desc

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as rollingvac
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and population is not null
and new_vaccinations is not null
order by 2,3


with PopvsVac(continent, location, date, population, new_vaccinations, rollingvac)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as rollingvac
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and population is not null
and new_vaccinations is not null
--order by 2,3
)
select *, (rollingvac/population)*100
from PopvsVac