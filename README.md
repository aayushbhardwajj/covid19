# Covid19 Dataset EDA
Exploratory Data Analysis project on covid-19 worldwide from february 2020 to february 2022

## Tools used
- Microsoft excel
- Bigquery SQL

## Data Sourcing and Processing
- Get raw dataset from [Our World In Data](https://ourworldindata.org/covid-cases)
- Import data into Excel
- Clean Data
  - dropped unwanted rows
  - split data into two tables - deaths and vaccinations
- Import deaths and vaccinations tables into BigQuery
- Creating two different tables which are Deaths and Vaccinations tables from raw dataset

## Analysis

- Selecting data that is to be analysed
``` sql
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
```

- Analyzing for death percentage, shows the chances of dying if you contract covid in particular countries
```sql
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
```

- Analyzing what percentage of population got infected in every countries
```sql
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
```

- Looking for countries with highest infection rate compared to population
```sql
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
```
- find the top countries with the highest death count w.r.t. population
```sql
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
```
- find monthly trends for global deaths due to covid
```sql
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
```
- found daily total vaccinations for each country
```sql
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
```
- found cumulative montly vaccination percentage with total population of each contry, which tells us the efficiency of the vaccination drives of the respective country
```sql
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
```
