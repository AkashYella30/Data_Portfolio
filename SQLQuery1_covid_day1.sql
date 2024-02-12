select * from portfolio..CovidDeaths$
where continent is not null
order by 3,4



--select * from portfolio..CovidVaccinations$
--order by 3,4


--Select data that we are using 

Select Location,date,total_cases,new_cases,total_deaths,population
From portfolio..CovidDeaths$
where continent is not null
Order By 1,2


--Looking at Total Cases VS Total Deaths
--This shows the likelihood of dying if you contact covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
Where location like '%states%'
AND continent is not null
Order By 1,2


--Looking at Total Cases vs Population
--This shows what percentage of population got Covid

Select Location,date,total_cases,population,(total_cases/POPULATION)*100 as PercentPopulationInfected
From portfolio..CovidDeaths$
Where location like '%states%'
AND continent is not null
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/POPULATION))*100 as PercentPopulationInfected
From portfolio..CovidDeaths$
where continent is not null
--Where location like '%states%'
Group by Location,Population
Order By PercentPopulationInfected desc


--DOWN BY CONTINENT
--Showing the Continents with the highest death count
Select location,MAX(cast(Total_deaths as INT)) as TotalDeathCount
From portfolio..CovidDeaths$
where continent is null
Group by location
Order By TotalDeathCount desc


--Showing Countries with Highest Death Count per Population
Select continent,MAX(cast(Total_deaths as INT)) as TotalDeathCount
From portfolio..CovidDeaths$
where continent is not null
Group by continent
Order By TotalDeathCount desc


--GLOBAL NUMBERS
Select date,SUM((new_cases)) as total_cases,SUM(cast(new_deaths as int )) as total_deaths,SUM(cast(new_deaths as int ))/SUM(New_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by date
Order By 1,2

--LOOKING at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
where dea.continent is not null
order by 2,3


--
with PopvsVac (Continent, Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,
from portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac


--Temp table

DROP TABLE IF EXISTS #PERCENTPopulationVaccinated
CREATE TABLE #PERCENTPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PERCENTPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 
from #PERCENTPopulationVaccinated


--Creating view to store data for later visualization
USE Portfolio
GO
CREATE View 
PERCENTPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
where dea.continent is not null
--order by 2,3