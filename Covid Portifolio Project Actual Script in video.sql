select * from dbo.CovidDeaths
where continent is  null

select location, date, total_cases, new_cases, 
total_deaths, population 
from dbo.CovidDeaths 
order by 1,2
-- convert nvarchar to numeric type
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths numeric NULL
ALTER TABLE CovidDeaths ALTER COLUMN total_cases numeric NULL

-- looking at total death vs total cases
-- show likelihood of dying if contract covid in your country
select location, date, total_cases, 
total_deaths,(total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths 
where location like '%state%'
order by 1,2

-- looking at population vs total_cases
-- show precent of population got covid
select location, date, population,total_cases, 
(total_cases/population)*100 as Cases_percentage
from dbo.CovidDeaths 
where location like '%state%'
order by 1,2

-- looking at countries with highest infection rate compared population
select location,population, MAX(total_cases) as highest_infection,
max((total_cases/population))*100 as highest_Cases_percentage
from CovidDeaths
group by location, population
order by highest_Cases_percentage desc

-- looking at countries with highest death rate compared population
select location,population, MAX(total_deaths) as highest_deid,
max((total_deaths/population))*100 as highest_death_percentage
from CovidDeaths
group by location, population
order by highest_death_percentage desc

-- let's break things ddown continents
select continent, MAX(total_deaths) as highest_deid,
max((total_deaths/population))*100 as highest_death_percentage
from CovidDeaths
where continent !=''
group by continent 
order by highest_death_percentage desc
-- this is correct precentage because some country not found in continents
select location, MAX(total_deaths) as highest_deid,
max((total_deaths/population))*100 as highest_death_percentage
from CovidDeaths
where continent =''
group by location 
order by highest_death_percentage desc


-- showing total death and cases around world 
select date , MAX(new_cases)  as total_cases,
MAX(new_deaths)as total_death 
,(MAX(new_deaths)/iif(MAX(new_cases)!=0,MAX(new_cases),null))*100 as precentage_deaths_for_cases
from CovidDeaths
where continent ='' 
group by date
order by 1

select date , MAX(new_cases)  as total_cases,
MAX(new_deaths)as total_death 
,(MAX(new_deaths)/iif(MAX(new_cases)!=0,MAX(new_cases),null))*100 as precentage_deaths_for_cases
from CovidDeaths
where continent ='' 
group by date
order by 1

-- looking at total population vs vaccinations

--use CTE
with peopvsvac(continent,location,date,population
,new_vaccinations,rollingpeoplevaccianted)
as
(select dea.continent,dea.location, dea.date,
dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations))
over(partition by vac.location order by vac.location,vac.date)
as rollingpeoplevaccianted
from CovidVaccinations vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
--order by 1,2,3
)
select * , (rollingpeoplevaccianted/population)*100 from peopvsvac


--use temp table
create table #precentpeoplevaccianted
(continent varchar(50),location varchar(50), date datetime
,population numeric, new_vaccinations numeric,
rollingpeoplevaccianted numeric)

insert into #precentpeoplevaccianted
select dea.continent,dea.location, dea.date,
dea.population,convert(float,vac.new_vaccinations),
sum(convert(float,vac.new_vaccinations))
over(partition by vac.location order by vac.location,vac.date)
as rollingpeoplevaccianted
from CovidVaccinations vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
--order by 1,2,3

select * , (rollingpeoplevaccianted/population)*100 from #precentpeoplevaccianted

-- to drop table if it exists
drop table if exists #precentpeoplevaccianted

-- create view to store data for later visualization

create view precentpeoplevaccianted as
select dea.continent,dea.location, dea.date,
dea.population,convert(float,vac.new_vaccinations) as new_vaccinations,
sum(convert(float,vac.new_vaccinations))
over(partition by vac.location order by vac.location,vac.date)
as rollingpeoplevaccianted
from CovidVaccinations vac
join CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
--order by 1,2,3

select * from precentpeoplevaccianted