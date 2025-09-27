---Covid 19 Data Exploration project using sql
-- 1.Total Cases vs Total Deaths
-- 2.Total Cases vs Population
-- 3.Countries with Highest Infection Rate compared to Population
-- 4.Countries with Highest Death Count per Population
-- 5.Show contintents with the highest death count per population
-- 6.GLOBAL NUMBERS
-- 7.Total Population vs Vaccinations
-- 8.Using CTE to perform Calculation on Partition By in previous query
-- 9.Using Temp Table to perform Calculation on Partition By in previous query
-- 10.Creating View to store data for later visualizations
SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4 
-- SELECT *
--FROM CovidVaccinations
--order by 3,4
select location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2
--totalcase vs totaldeath
select location,date,total_cases,total_deaths,(total_deaths/ total_cases)*100 as deathpercentage
FROM CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--totalcase vs population
select location,date,total_cases,population,( total_cases/population)*100 as deathpercentage
FROM CovidDeaths
WHERE continent is not null
--where location like '%states%'
order by 1,2


--COUNTRIES WITH HIGH INFECTION RATE

select location,MAX(total_cases) as highinfection,population,MAX(( total_cases/population))*100 as infectionpercent
FROM CovidDeaths
--where location like '%states%'
WHERE continent is not null
group  by location,population
order by infectionpercent desc


--country with high deathrate
select location,MAX(CAST(total_deaths AS INT)) AS totaldeathpercent
FROM CovidDeaths
WHERE continent is null
group by location
order by totaldeathpercent desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
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
From .CovidDeaths dea
Join CovidVaccinations vac
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
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

