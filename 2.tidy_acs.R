# This program cleans the ACS data retrieved from Social Explorer
# hautahi

library(dplyr); library(stringr)

# -----------------
# Load Data
# -----------------
# Change from pacific alone


# Define function to read block level ACS data
read_block = function(fname,year) {
  
  filename = paste("./data/SocialExplorer/",fname,".csv",sep="")
  vname = paste("ACS",year,"_5yr_",sep="")
  
  # Read in data
  block <- read.csv(filename,stringsAsFactors = FALSE,skip = 1)
  
  # Remove year specific variable names
  names(block) <- str_replace(names(block), vname, "")
  
  # Extract Necessary Data
  block <- block %>%
    select(Geo_FIPS,Geo_NAME,Geo_STATE,Geo_COUNTY,Geo_TRACT,
           pop = B02001001,
           white_alone = B02001002,
           pacific_alone = B02001006,
           black= B02009001,
           indian= B02010001,
           hisp= ifelse(year!="14",B03003003,SE_T014_010),
           asian= B02011001) %>% 
    mutate(asian=asian+pacific_alone,
           fips11=ifelse(nchar(Geo_FIPS)>11,Geo_FIPS,paste(0,Geo_FIPS,sep="")),
           fips11=substring(fips11,1,11))
  
  return(block)
}

# ACS block Level Data (for race):
block9 <- read_block("R11383984_SL150","09")
block10 <- read_block("R11383969_SL150","10")
block11 <- read_block("R11383952_SL150","11")
block12 <- read_block("R11383940_SL150","12")
block13 <- read_block("R11383894_SL150","13")
block14 <- read_block("R11210348_SL150","14")
block15 <- read_block("R11382087_SL150","15")

# 2009 ACS census tract Level Data (for age and poverty): http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11099463
tract9 <- read.csv("./data/SocialExplorer/ACS2009_5yr_R11385144_SL140.csv",stringsAsFactors = FALSE,skip = 1) %>%
  select(Geo_FIPS,Geo_NAME,Geo_STATE,Geo_COUNTY,Geo_TRACT,
         kid1 = SE_T007_004,
         kid2 = SE_T007_005,
         pov18=SE_T114_002,
         pov_over=SE_T115_002) %>%
  mutate(kid=kid1+kid2,
         pov=pov18+pov_over,
         fips11=ifelse(nchar(Geo_FIPS)>10,Geo_FIPS,paste(0,Geo_FIPS,sep="")))

# 2014 ACS census tract Level Data (for age and poverty): http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11099463
tract14 <- read.csv("./data/SocialExplorer/ACS2014_5yr_R11099463_SL140.csv",stringsAsFactors = FALSE,skip = 1) %>%
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

# 2015 ACS census tract Level Data (for age and poverty): http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11099463
tract15 <- read.csv("./data/SocialExplorer/R11382097_SL140.csv",stringsAsFactors = FALSE,skip = 1) %>%
  select(Geo_FIPS,Geo_NAME,Geo_STATE,Geo_COUNTY,Geo_TRACT,
         kid1 = SE_T007_004,
         kid2 = SE_T007_005,
         pov18=SE_T114_002,
         pov_over=SE_T115_002) %>%
  mutate(kid = kid1+kid2,
         pov = pov18+pov_over,
         fips11 = ifelse(nchar(Geo_FIPS)>10,Geo_FIPS,paste(0,Geo_FIPS,sep=""))) %>%
  group_by(fips11) %>%
  summarise(pov=sum(pov),
            kid=sum(kid))


# -----------------
# Construct variables
# -----------------

merge_acs = function(block,tract) {

  # Isolation Indices by Tract
  x <- block %>% group_by(fips11) %>%
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
  x <- x %>% left_join(tract,by="fips11") %>%
    mutate(white=10*white/pop,
           black=10*black/pop,
           asian=10*asian/pop,
           indian=10*indian/pop,
           hisp=10*hisp/pop,
           pov=10*pov/pop,
           kid=10*kid/pop) %>%
    filter(pop>=100)

  return(x)
}

# Save 2009
x <- merge_acs(block9,tract9)
write.csv(x,"./data/ACS2009_clean.csv")

# Save 2014
x <- merge_acs(block14,tract14)
write.csv(x,"./data/ACS2014_clean.csv")

# Save 2015
x <- merge_acs(block15,tract15)
write.csv(x,"./data/ACS2015_clean.csv")
