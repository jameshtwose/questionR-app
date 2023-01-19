## Install required packages
# install.packages(c("DBI", "RODBC", "odbc", "dplyr", "dbplyr"))
# install.packages("dotenv")
# install.packages("RPostgres")

library(dotenv)
load_dot_env(file = ".env")

## Import required packages
library(DBI)
# library(RODBC)
# library(odbc)
library(dplyr)
library(dbplyr)
library(RPostgres)


## Connect RStudio to PostgreSQL database

## Check whether a connect exists
con <- dbCanConnect(RPostgres::Postgres(),
                    host = Sys.getenv("POSTGRESQL_ADDON_HOST"),
                    dbname = Sys.getenv("POSTGRESQL_ADDON_DB"),
                    port = 5432,
                    user = Sys.getenv("POSTGRESQL_ADDON_USER"),
                    password = Sys.getenv("POSTGRESQL_ADDON_PASSWORD"))

## Print the result
con

con <- dbConnect(RPostgres::Postgres(),
                    host = Sys.getenv("POSTGRESQL_ADDON_HOST"),
                    dbname = Sys.getenv("POSTGRESQL_ADDON_DB"),
                    port = 5432,
                    user = Sys.getenv("POSTGRESQL_ADDON_USER"),
                    password = Sys.getenv("POSTGRESQL_ADDON_PASSWORD"))

## Print the result
con

## List out all views and tables in the employees 
dbListTables(con)

## Save this result as an R object
df <- dbGetQuery(con, "SELECT * FROM questions_db")

dbDisconnect(con)