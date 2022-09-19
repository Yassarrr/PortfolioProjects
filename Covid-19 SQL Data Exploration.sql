SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

--Looking at the Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
Where location Like '%Africa%'
ORDER BY 1,2 

--looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Africa%'
ORDER BY 1,2 

--looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Africa%'
ORDER BY 1,2 

--looking at Countries with highest infection Rate to Population

SELECT location, population, MAX(total_cases) AS Higest_infectionCount, MAX((total_cases/population))*100 AS InfectedPopulation_Percentage
FROM PortfolioProject..CovidDeaths    
--WHERE location like '%Africa%'
GROUP BY location, Population
ORDER BY InfectedPopulation_Percentage 

--This is showing the countris with highest death counts per poplutaion

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking it down by continent

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location Like '%Africa%'
WHERE continent is not NULL
Group BY date
ORDER BY 1,2 

--Global total cases, deaths, and percentage

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location Like '%Africa%'
WHERE continent is not NULL
--Group BY date
ORDER BY 1,2 

--Joining the two tables of CovidDeaths and CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--looking at the total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
ORDER BY 2,3

---Looking at Rolling People Vaccinated
--USING CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--ORDER BY 2,3 
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac 
 

 ---Temp Table
 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--ORDER BY 2,3 

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated 

--Creating View to store data for later visualizations 

Create View PercentPopulationVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
