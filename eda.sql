
--------------------------------------------------------------------------------

select * 
from `project-for-portfolio.covid_project.covid_deaths`
order by 3, 4;

--------------------------------------------------------------------------------

select *
from `project-for-portfolio.covid_project.covid_vaccinations`
order by 3, 4;

---------------------------------------------------------------------------------
-- Selecting data that is going to be used in this project

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

----------------------------------------------------------------------------------
-- Looking at total cases vs total deaths
-- shows the chances of dying if you contract covid in particular countries 

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


---------------------------------------------------------------------------------
-- looking at total cases vs population
-- shows what percentage of population got covid

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


---------------------------------------------------------------------------------------
-- looking at countries with hightest infection rate compared to population

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


-----------------------------------------------------------------------------------
-- showing countries with highest death count per population

select
    location,
    max(total_deaths) as total_death_count,
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is not null
group by
    location
order by
    2 desc; 


--------------------------------------------------------------------------------------
-- showing continent with highest death counts (this query is not working properly)

select
    continent,
    max(total_deaths) as total_death_count,
from
    `project-for-portfolio.covid_project.covid_deaths`
where
    continent is not null 
group by
    continent
order by
    2 desc; 


--------------------------------------------------------------------------------------------
-- global numbers

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


--------------------------------------------------------------------------------------
-- looking at total population vs vaccinations

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


-------------------------------------------------------------------------------------------
-- looking percentage of population got vaccinated
-- using CTE to perform percentage calculation

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


