# This program cleans publicly available FDA TIMS violations data
# hautahi

# Packages
library(dplyr); library(lubridate)

# ---------------------
# Clean original data
# ---------------------

# Load three years of FDA data from https://www.accessdata.fda.gov/scripts/oce/inspections/oce_insp_searching.cfm
d17 <- read.csv("./data/OCE_FY2017.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))
d16 <- read.csv("./data/OCE_FY2016.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))
d15 <- read.csv("./data/OCE_FY2015.csv",stringsAsFactors = F) %>% setNames(tolower(names(.)))

# Combine FDA data and extract year of interest
d <- bind_rows(d15,d16,d17) %>% 
  mutate(date=as.Date(decision.date,"%m/%d/%Y"),
         year=year(date))
  
# Extract years of interest
fda15 <- d %>% filter(year==2015)
fda16 <- d %>% filter(year==2016)
n0 <- nrow(fda15)

# Exclude inspections where minor wasn't involved
fda15 <- fda15 %>% filter(minor.involved!="No")
fda16 <- fda16 %>% filter(minor.involved!="No")
n1 <- nrow(fda15)

# Exclude NA inspection results
fda15 <- fda15 %>% filter(!is.na(decision.type))
fda16 <- fda16 %>% filter(!is.na(decision.type))
n2 <- nrow(fda15)

# Save
write.csv(fda15,"./data/FDA_2015.csv")
write.csv(fda16,"./data/FDA_2016.csv")

# This data is then sent away to be scrubbed and geotagged