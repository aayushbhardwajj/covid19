-- Selecting data that is to be analysed

select
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
from
    `project-for-portfolio.covid_project.covid_deaths`
order by
    1, 2;

-- Analyzing for death percentage, shows the chances of dying if you contract covid in particular countries

select
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as deaths_percentage
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    location = "India"
order by
    1, 2;


-- Analyzing what percentage of population got infected in every countries


select
    location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 as percent_of_population_infected
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    location = "India"
order by
    1, 2;


-- Looking for countries with highest infection rate compared to population

select
    location, 
    population,
    max(total_cases) as highest_infection_count,
    max((total_cases/population))*100 as percent_of_population_infected
from
    `project-for-portfolio.covid_project.covid_deaths`
-- where
--     location = "India"
group by
    location, population
order by
    4 desc;


-- find the top countries with the highest death count w.r.t. population

select
    location,
    max((total_deaths/population))*100 as total_death_count,
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is not null
group by
    location
order by
    2 desc; 

-- find monthly trends for global deaths due to covid

select
    date,
    sum(new_cases) as total_cases,
    sum(new_deaths) as total_deaths,
    sum(new_deaths)/sum(new_cases)*100 as death_percentage
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is not null
group by
    date
order by
    1;

-- found daily total vaccinations for each country

select
    deas.continent,
    deas.location,
    deas.date,
    deas.population,
    vacs.new_vaccinations,
    sum(vacs.new_vaccinations)
        over (
            partition by
                deas.location
            order by
                deas.location,
                deas.date
        ) as total_vaccinations_till_date
from
    `project-for-portfolio.covid_project.covid_deaths` as deas
join
    `project-for-portfolio.covid_project.covid_vaccinations` as vacs
    on deas.location = vacs.location
    and deas.date = vacs.date
where
    deas.continent is not null
order by
    2, 3;

-- found cumulative montly vaccination percentage with total population of each contry, which tells us the efficiency of the vaccination drives of the respective country

with popvsvac
as
(
    select
        deas.continent,
        deas.location,
        deas.date,
        deas.population,
        vacs.new_vaccinations,
        sum(vacs.new_vaccinations)
        over (
            partition by
                deas.location
            order by
                deas.location,
                deas.date
        ) as total_vaccinations_till_date
from
    `project-for-portfolio.covid_project.covid_deaths` as deas
join
    `project-for-portfolio.covid_project.covid_vaccinations` as vacs
on 
    deas.location = vacs.location
    and deas.date = vacs.date
where
    deas.continent is not null
)
select
    *,
    (total_vaccinations_till_date/population)*100 as vaccinations_percentage
from
    popvsvac


-- SQl query for visual representation

-- Found the gobal numbers of total cases, total deaths and death percentage

Select
    sum(new_cases) as total_cases,
    sum(new_deaths) as total_deaths,
    sum(new_deaths)/sum(new_cases)*100 as death_percentage
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is not null
order by
    1, 2;

-- I took some data out as they were not needed and wanted to stay consistent

select
    location,
    sum(new_deaths) as total_death_count
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is null
    and
    location not in('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by
    location
order by
    total_death_count desc;

looking at countries with hightest infection rate compared to population
select
    location, 
    population,
    max(total_cases) as highest_infection_count,
    max((total_cases/population))*100 as percent_of_population_infected
from
    `project-for-portfolio.covid_project.covid_deaths`
group by
    location,
    population
order by
    4 desc;

-- Looked for total cases vs population and show what percentage of population got infected.

select
    location,
    population,
    date,
    max(total_cases) as highest_infection_count,
    max(total_cases/population)*100 as percent_of_population_infected
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    location = "India"
group by
    location,
    population,
    date
order by
    5 desc;