SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1;

-- Total cases vs total deaths 
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathsPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%Israel%'
ORDER BY 1;

-- Total cases vs population
-- Shows what percentage of population got covid
SELECT 
    location,
    date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100, 2) AS CovidPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%Israel%'
ORDER BY 1;

-- countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(ROUND((total_cases / population) * 100, 2)) AS CovidPercentage
FROM
    coviddeaths
GROUP BY 1 , 2
ORDER BY CovidPercentage DESC;

-- Showing countries with highest death count per population
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    location NOT IN ('World' , 'Europe', 'North America', 'European Union',
					 'South America', 'Asia', 'Africa', 'Oceania')
GROUP BY 1
ORDER BY TotalDeathCount DESC;


-- break things down by continent
-- Showing continents with highest deaths count

SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    location IN ('Europe' , 'North America', 'South America', 'Asia', 'Africa', 'Oceania')
GROUP BY 1
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS deaths_percentage
FROM
    coviddeaths
WHERE
    continent IS NOT NULL AND continent != ''
ORDER BY 2;


-- population vs vaccinations
DROP TABLE IF EXISTS population_vs_vaccinations;
CREATE TEMPORARY TABLE population_vs_vaccinations
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea 
	JOIN
covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL AND dea.continent != '' 
ORDER BY 2;


SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS percentage_of_vaccinations
FROM
    population_vs_vaccinations;

-- create view to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT 
	dea.continent,
    dea.location,
    dea.date, dea.population,
    vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	coviddeaths dea 
	JOIN 
covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE 
	dea.continent IS NOT NULL AND dea.continent != '' 
ORDER BY 2;


-- extra query
SELECT 
    Location,
    Population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY Location , Population , date
ORDER BY PercentPopulationInfected DESC

