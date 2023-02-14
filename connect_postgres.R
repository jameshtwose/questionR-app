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
library(ggplot2)


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

# key <- 3
# update_value <- 300
# insert_statement <- paste0("UPDATE questions_db SET importance = ",
#                            update_value,
#                           " WHERE index = ", key, ";")

## Update value in a row
# dbExecute(con, insert_statement)

## Save this result as an R object
df <- dbGetQuery(con, "SELECT * FROM questions_db")

# df[df$index==2, "importance"] + 1

dbDisconnect(con)

df %>% 
  ggplot(aes(x = strength,
             y = opportunity,
             # size = importance, 
             colour = valence)) +
  geom_point() +
  annotate(geom = "text", x = 100, y = 53, label = "Vahvuuksia", hjust = 0) +
  annotate(geom = "text", x = 001, y = 53, label = "Heikkouksia", hjust = 1) +
  annotate(geom = "text", x = 49, y = 110, label = "Tilaisuuksia", hjust = 1) +
  annotate(geom = "text", x = 49, y = -10, label = "Uhkia", hjust = 1) +
  geom_hline(yintercept = 50) +
  geom_vline(xintercept = 50) +
  scale_colour_viridis_d(option = "inferno",
                         end = 0.8) +
  ggrepel::geom_text_repel(aes(label = narrativeTitle),
                           size = 2,
                           min.segment.length = 0) +
  coord_cartesian(xlim = c(-10, 110),
                  ylim = c(-10, 110)) +
  labs(x = NULL,
       y = NULL) +
  theme_void() +
  theme(legend.position = "none")

