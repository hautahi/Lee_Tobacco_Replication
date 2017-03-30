# This program cleans the ACS data retrieved from 
# hautahi

library(dplyr)

# -----------------
# Load Data
# -----------------

# ACS census tract Level Data (for age and poverty): http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11099463
d <- read.csv("./data/ACS2014_5yr_R11099463_SL140.csv",stringsAsFactors = FALSE,skip = 1) %>%
  select(Geo_FIPS,Geo_NAME,Geo_STATE,Geo_COUNTY,Geo_TRACT,
         kid1 = SE_T007_004,
         kid2 = SE_T007_005,
         pov18=SE_T114_002,
         pov_over=SE_T115_002) %>%
  mutate(kid=kid1+kid2,
         pov=pov18+pov_over,
         fips11=ifelse(nchar(Geo_FIPS)>10,Geo_FIPS,paste(0,Geo_FIPS,sep=""))) %>%
  group_by(fips11) %>%
  summarise(pov=sum(pov),
            kid=sum(kid))

# ACS block Level Data (for race): http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11210348
df <- read.csv("./data/ACS2014_5yr_R11210348_SL150.csv",stringsAsFactors = FALSE,skip = 1) %>%
  select(Geo_FIPS,Geo_NAME,Geo_STATE,Geo_COUNTY,Geo_TRACT,Geo_BLKGRP,
         pop = SE_T013_001,
         white_alone = ACS14_5yr_B02001002,
         pacific_alone = ACS14_5yr_B02001006,
         black=ACS14_5yr_B02009001,
         indian=ACS14_5yr_B02010001,
         hisp=SE_T014_010,
         asian=ACS14_5yr_B02011001) %>% 
  mutate(asian=asian+pacific_alone,
         fips11=ifelse(nchar(Geo_FIPS)>11,Geo_FIPS,paste(0,Geo_FIPS,sep="")),
         fips11=substring(fips11,1,11))

# -----------------
# Construct variables
# -----------------

# Isolation Indices by Tract
x <- df %>% group_by(fips11) %>%
  mutate(sumblk = sum(black),
         index_blk = black/sumblk * black/pop,
         sumhisp = sum(hisp),
         index_hisp = hisp/sumhisp * hisp/pop,
         sumasian = sum(asian),
         index_asian = asian/sumasian * asian/pop,
         sumwhite = sum(white_alone),
         index_white = white_alone/sumwhite * white_alone/pop,
         sumindian = sum(indian),
         index_indian = indian/sumindian * indian/pop) %>%
  summarise(state=mean(Geo_STATE),
            pop = sum(pop),
            white=sum(white_alone),
            black=sum(black),
            asian=sum(asian),
            indian=sum(indian),
            hisp=sum(hisp),
            index_indian=10*sum(index_indian,na.rm=T),
            index_asian=10*sum(index_asian,na.rm=T),
            index_blk=10*sum(index_blk,na.rm=T),
            index_hisp=10*sum(index_hisp,na.rm=T),
            index_white=10*sum(index_white,na.rm=T))

# Proportions (scale by 10 as in the paper)
x <- x %>% left_join(d,by="fips11") %>%
  mutate(white=10*white/pop,
         black=10*black/pop,
         asian=10*asian/pop,
         indian=10*indian/pop,
         hisp=10*hisp/pop,
         pov=10*pov/pop,
         kid=10*kid/pop) %>%
  filter(pop>=100)

# Save
write.csv(x,"./data/ACS_clean.csv")
