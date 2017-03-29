# Lee_Tobacco_Replication (with Chris Zhang)

Code replicating an article by Lee, Landrine, Torres and Gregory: https://www.ncbi.nlm.nih.gov/pubmed/27609780

## Data

1. The TIMS violation data is retrieved from the [FDA website](https://www.accessdata.fda.gov/scripts/oce/inspections/oce_insp_searching.cfm).

2. The ACS data at the census tract level is retrieved from [Social Explorer](http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11099463).

3. The ACS data at the block level is also retrieved from [Social Explorer](http://old.socialexplorer.com/pub/reportdata/CsvResults.aspx?reportid=R11210348).

4. The zipcode to census tract mapping data is available from the [Census Bureau](https://www.census.gov/geo/maps-data/data/relationship.html).

## Programs

- 1.tidy_fda.R cleans the FDA data and saves a csv file to the `data` folder.
- 1a.tidy_fda.py does the same in Python.
- 2.tidy_acs.R cleans the ACS data and saves a csv file to the `data` folder.
