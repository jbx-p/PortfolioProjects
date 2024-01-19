

Select *
From PorfolioProject..CovidDeaths$
Order by 3,4

--Select *
--From PorfolioProject..CovidVaccinations$
--Order by 3,4

-- Let Select data that we will be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths$
Order by 1,2

-- Looking at TOtal Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From PorfolioProject..CovidDeaths$
Where location like '%congo%'
Order by 1,2

-- Let look at the  total cases vs Populations
-- this will show us the percentage population infected with Covid

Select location, date, total_cases, population,(total_cases/population)* 100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths$
Where location like '%congo%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths$
--Where location like '%congo%'
Group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--Where location like '%congo%'
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--Where location like '%Congo%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths$
--Where location like '%congo%'
where continent is not null 
--Group By date
order by 1,2

-- LOoking at Total Population vs Vaccinatons

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date ) 
as RollingPoepleVaccinated
--, (RollingPoepleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
   On dea.location =  vac.location
   and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac ( continent, location, date, population,new_vaccinations, RollingPoepleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date ) 
as RollingPoepleVaccinated
--, (RollingPoepleVaccinated/population)*100
From PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
   On dea.location =  vac.location
   and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPoepleVaccinated/population)*100
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
From PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
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
From PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 