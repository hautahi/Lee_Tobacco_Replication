# This program cleans publicly available FDA TIMS violations data
# hautahi

# Packages
library(dplyr); library(lubridate)

# Load three years of FDA data from https://www.accessdata.fda.gov/scripts/oce/inspections/oce_insp_searching.cfm
d17 <- read.csv("./data/OCE_FY2017.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))
d16 <- read.csv("./data/OCE_FY2016.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))
d15 <- read.csv("./data/OCE_FY2015.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))

# Combine FDA data and extract year of interest
d <- bind_rows(d15,d16,d17) %>% 
  mutate(date=as.Date(decision.date,"%m/%d/%Y"),
         year=year(date)) %>%
  filter(year==2016)

# Drop duplicates and others
d <- d %>% mutate(dup=duplicated(d[c("street.address",'city', 'state', 'zip', 'date')])) %>%
  filter(minor.involved!="No",
                  !is.na(decision.type),
                  dup==FALSE) %>%
  select(-dup,-link)

# Save
write.csv(d,"./data/FDA_2016.csv")

# -------
# Maybe match with tract data later
# -------

# Load Census Relationship file from https://www.census.gov/geo/maps-data/data/relationship.html
#zipmap <- read.csv("./data/zcta_tract_rel_10.txt", stringsAsFactors = F) %>% select(zip=ZCTA5,STATE,TRACT,GEOID)
#d <- left_join(d,zipmap,by="zip")