SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is  not  null
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases and total deaths
-- Shows the likelihood dying if you are contacted to covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2

--Looking at the  total_cases vs population
--Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as Percentpopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%India%'
ORDER BY 1,2

--Looking at countries with highest infection rate

SELECT Location, population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as Percentpopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%India%'
GROUP BY Location, population
ORDER BY  Percentpopulationinfected

--Showing Countries with death count per population

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%India%'
WHERE continent is  not  null
GROUP BY Location
ORDER BY TotalDeathCounts desc

-- Breaking this down

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%India%'
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCounts desc


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%India%'
WHERE continent is NOT null
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs total vaccinations


SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER(partition by dea.location,dea.date) as Rollingpeplevaccinated
--,(Rollingpeplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.Location = vac.Location
  AND dea.date= vac.date
  WHERE dea.continent is not null
  order by 2,3

  --with CTE

  with popvsvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
  as
(  
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations )) OVER(partition by dea.location ORDER BY dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date= vac.date
  WHERE dea.continent is not null
  --order by 2,3
  )
  SELECT *, (Rollingpeoplevaccinated/population)*100
  FROM popvsvac


  --temp table

 
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
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--creating views to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
