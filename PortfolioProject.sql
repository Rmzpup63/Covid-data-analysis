--Note - Renaming table gives me error in my system Hence working with default names .
--     for reference_
--	   ['owid-covid-data$'] -> CovidVaccinationData
--	   ['owid-covid-data$'_xlnm#_FilterDatabase] -> CovidDeathsData

Select *
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent is not null
ORDER BY 2,3

Select location, date, population, total_cases, new_cases,total_deaths
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent is not null
ORDER BY 1

Select location, date, population, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent is not null
and location = 'India'
ORDER BY 1


Select Location, Population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['owid-covid-data$']  
--WHERE location = 'India'
Group by Location, population 
order by PercentPopulationInfected  Desc

Select location, MAX(convert(bigint,total_deaths)) as Totaldeathcount
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent = 'asia'
--and location = 'India' OR location = 'China'
Group BY location
order by Totaldeathcount


Select continent , MAX(convert(bigint,total_deaths)) as Totaldeathcount
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent is NOT NULL
Group BY continent
order by Totaldeathcount desc

 Select date,SUM(new_cases) as totalcases, SUM(cast(new_deaths as bigint) ) as totalDeath 
 ,SUM(cast(new_deaths as bigint) )/SUM(new_cases)*100 as TotalDeathPercentage
 FROM PortfolioProject..['owid-covid-data$']  
 WHERE continent is NOT NULL
 Group by date
 order by 1,2 
 

Select D.continent, D.location, D.date, D.population, V.new_vaccinations
,SUM(cast(V.new_vaccinations as bigint))OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
 From PortfolioProject..['owid-covid-data$'] D
 JOIN PortfolioProject..['owid-covid-data$'_xlnm#_FilterDatabase] V
 on D.location = V.location
 and D.date = V.date

 WHERE D.continent is not null
 Order by 1,2


 WITH Population_Vaccinated_Percentage (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 Select D.continent, D.location, D.date, D.population, V.new_vaccinations
,SUM(cast(V.new_vaccinations as bigint))OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
 From PortfolioProject..['owid-covid-data$'] D
 JOIN PortfolioProject..['owid-covid-data$'_xlnm#_FilterDatabase] V
 on D.location = V.location
 and D.date = V.date

 WHERE D.continent is not null
 )
 Select *,(RollingPeopleVaccinated/population)*100 as People_Vaccinated
 FROM Population_Vaccinated_Percentage


 --Using temp

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
 Select D.continent, D.location, D.date, D.population, V.new_vaccinations
,SUM(cast(V.new_vaccinations as bigint))OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
 From PortfolioProject..['owid-covid-data$'] D
 JOIN PortfolioProject..['owid-covid-data$'_xlnm#_FilterDatabase] V
      on D.location = V.location
      and D.date = V.date

 WHERE D.continent is not null
 
 Select *, (RollingPeopleVaccinated/Population)*100 as People_Vaccinated
From #PercentPopulationVaccinated




Create View Percent_Population_Vaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
,SUM(cast(V.new_vaccinations as bigint))OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
 From PortfolioProject..['owid-covid-data$'] D
 JOIN PortfolioProject..['owid-covid-data$'_xlnm#_FilterDatabase] V
      on D.location = V.location
      and D.date = V.date

 WHERE D.continent is not null


 --FINAL QUERIES FOR DATA VISUALIZATION--

 --1 Death Percentage
 
 Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as bigint) ) as totalDeath 
,SUM(cast(new_deaths as bigint) )/SUM(new_cases)*100 as TotalDeathPercentage
 FROM PortfolioProject..['owid-covid-data$']  
 WHERE continent is NOT NULL
 order by 1,2 

 --2 Total Death count location wise

Select location , MAX(convert(bigint,total_deaths)) as Totaldeathcount
FROM PortfolioProject..['owid-covid-data$']  
WHERE continent is NULL and location not in ('World', 'European Union', 'International')
Group BY location
order by Totaldeathcount desc

--3  Percent Population Infected

Select Location, Population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['owid-covid-data$']  
--WHERE location = 'India'
Group by Location, population 
order by PercentPopulationInfected  Desc

--4 Grouped by date

Select Date,Location, Population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['owid-covid-data$']  
--WHERE location = 'India'
Group by Location, population ,date
order by PercentPopulationInfected  Desc

--5 Data of INDIA

Select  D.location, D.date , V.new_vaccinations, D.new_deaths, D.new_cases
 From PortfolioProject..['owid-covid-data$'] D
 JOIN PortfolioProject..['owid-covid-data$'_xlnm#_FilterDatabase] V
 on D.location = V.location
 and D.date = V.date

 WHERE D.continent is not null and D.location = 'India'