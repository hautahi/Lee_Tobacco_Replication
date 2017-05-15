# This program assigns census tracts to the geotagged FDA TIMS violations data
# hautahi

# Packages
library(dplyr)

# Load scrubbed and geotagged FDA data
# The "scrubber" variable states which scrubber was used. Using ZP4 for now because unsure of permissions for Aaron's USP scrubber)
fda15 <- read.csv("./data/2015/publicOCE_y2015_miYes_XY_finalAfterRound2.csv",stringsAsFactors = F) %>% filter(scrubber=="ZP4")
fda16 <- read.csv("./data/2016/publicOCE_y2016_miYes_XY_finalAfterRound2.csv",stringsAsFactors = F) %>% filter(scrubber=="ZP4")

# Load census tract shapefiles
library(rgdal)
tractshp <- readOGR(dsn = "data/convert gis", layer = "censustract")

# Make fda data spatial
coordinates(fda15) <- ~ X+Y
proj4string(fda15) <- proj4string(tractshp)

coordinates(fda16) <- ~ X+Y
proj4string(fda16) <- proj4string(tractshp)

# Assign each inspection to a tract polygon
d15 <- over(fda15,tractshp)
d16 <- over(fda16,tractshp)

# Combine
d15 <- cbind(fda15@data,d15)
d16 <- cbind(fda16@data,d16)

# Reduce
d15 <- d15 %>% select(ADDRESS,ZIP,FIPS,Decision.Type,Decision.Date,Minor.Involved,Sale.to.Minor)
d16 <- d16 %>% select(ADDRESS,ZIP,FIPS,Decision.Type,Decision.Date,Minor.Involved,Sale.to.Minor)

# Save
write.csv(d15,"./data/FDA_2015.csv",row.names = F)
write.csv(d16,"./data/FDA_2016.csv",row.names = F)