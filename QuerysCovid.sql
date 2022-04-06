SELECT *
from [Portafolio Edgar Torroella]..CovidDeaths
order by 3,4

--Select *
--from [Portafolio Edgar Torroella]..CovidVaccines
--order by 3,4

-- Seleccionar los datos que usaremos para nuestros analisis

Select Location, date, total_cases, new_cases, total_deaths, population
from [Portafolio Edgar Torroella]..CovidDeaths
order by 1,2

-- Si queremos ver Casos Totales vs Muertes Totales en nuestro pais
-- Que tan probable es morir si te contagiaste de covid en tu pais
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portafolio Edgar Torroella]..CovidDeaths
Where location like '%Mexico%'
order by 1,2

-- Casos totales vs Poblacion en porcentaje
Select Location, date, population,total_cases,(total_cases/population)*100 as PercentageofCases
from [Portafolio Edgar Torroella]..CovidDeaths
Where location like '%Mexico%'
order by 1,2

-- Paises con la tasa de contagios mas altas segun su poblacion
Select Location, population,MAX(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as PercentageofCases
from [Portafolio Edgar Torroella]..CovidDeaths
Group by location, population
order by PercentageofCases desc

-- Paises con mayor numero de muertes
Select continent,Location, population, MAX(cast(total_deaths as int)) as Highestdeathcount, 
MAX(cast(round(cast(total_deaths as int)/population*100,2) as nvarchar (10))+'%') as Percofpopulationdeceased
from [Portafolio Edgar Torroella]..CovidDeaths
Where continent is not null
Group by continent,location, population
order by Highestdeathcount desc

-- Informacion por continentes
Select Continent,MAX(cast(total_deaths as int)) as Totaldeathcount
from [Portafolio Edgar Torroella]..CovidDeaths
Where continent is not null
Group by continent
order by Totaldeathcount desc

--A nivel mundial, cuantos casos nuevos y muertes nuevas sucedian por dia
Select date, sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,cast(round(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2)as nvarchar(10))+'%' as DeathPercentage
from [Portafolio Edgar Torroella]..CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- Poblacion total vs Poblacion Vacunada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
From [Portafolio Edgar Torroella]..CovidDeaths dea
join [Portafolio Edgar Torroella]..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE para añadir porcentaje de la poblacion vacunada

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, People_Vaccinated,TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,vac.people_vaccinated,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsapplied
From [Portafolio Edgar Torroella]..CovidDeaths dea
join [Portafolio Edgar Torroella]..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, cast(round((people_vaccinated/Population)*100,2) as nvarchar(10))+'%' as Percentageofpopvaccinated
From PopvsVac


-- Usando una TEMP TABLE
DROP Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(max), 
Location nvarchar(max), 
Date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated numeric,
Total_Vaccinations numeric,
)
insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.people_vaccinated, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
From [Portafolio Edgar Torroella]..CovidDeaths dea
join [Portafolio Edgar Torroella]..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *,Format((People_vaccinated/Population),'0.##%')  as Percentageofpopvaccinated
From #PercentPopVaccinated

-- Crear Views para visualizar datos despues

Create View PopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.people_vaccinated, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
From [Portafolio Edgar Torroella]..CovidDeaths dea
join [Portafolio Edgar Torroella]..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
From PopulationVaccinated

Create View PorcentajeMortalidadMexico as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portafolio Edgar Torroella]..CovidDeaths
Where location like '%Mexico%'

Create View PorcentajepobcontagiadaMexico as
Select Location, date, population,total_cases,(total_cases/population)*100 as PercentageofCases
from [Portafolio Edgar Torroella]..CovidDeaths
Where location like '%Mexico%'

Create View PaisesTasadeContagiomasalta as
Select Location, population,MAX(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as PercentageofCases
from [Portafolio Edgar Torroella]..CovidDeaths
Group by location, population

Create View Paisesconmayornummuertes as
Select continent,Location, population, MAX(cast(total_deaths as int)) as Highestdeathcount, 
MAX(cast(round(cast(total_deaths as int)/population*100,2) as nvarchar (10))+'%') as Percofpopulationdeceased
from [Portafolio Edgar Torroella]..CovidDeaths
Where continent is not null
Group by continent,location, population


Create View Informacionmuertesporcontinente as
Select Continent,MAX(cast(total_deaths as int)) as Totaldeathcount
from [Portafolio Edgar Torroella]..CovidDeaths
Where continent is not null
Group by continent

Select*
From Informacionmuertesporcontinente
order by Totaldeathcount desc