# This program merges ACS and FDA data
# hautahi

library(dplyr); library(lme4); library(stargazer); library(plyr)

# -----------------
# Merge geotaged FDA data with ACS Data
# -----------------

fda15 <- read.csv("./data/FDA_2015.csv",stringsAsFactors = F) %>%
  mutate(fips11=FIPS) %>% filter(!is.na(fips11))

#fda15 <- read.csv("./data/FDA_2015_fullscrub.csv",stringsAsFactors = F) %>%
#  mutate(fips11=FIPS) %>% filter(!is.na(fips11))

#fda16 <- read.csv("./data/FDA_2016_zp4.csv",stringsAsFactors = F) %>%
#  select(fips11=GEOID,Sale_to_Mi,Decision_D)

fda16 <- read.csv("./data/FDA_2016.csv",stringsAsFactors = F) %>%
  mutate(fips11=FIPS) %>% filter(!is.na(fips11))

# Load ACS data
acs14 <- read.csv("./data/ACS2014_clean.csv",stringsAsFactors = F)
acs15 <- read.csv("./data/ACS2015_clean.csv",stringsAsFactors = F)

# Merge data
d15 <- left_join(fda15,acs14,by="fips11") %>%
  filter(pop>100) %>% mutate(y=ifelse(Sale.to.Minor=="Yes",1,0))

d16 <- left_join(fda16,acs15,by="fips11") %>%
  filter(pop>100) %>% mutate(y=ifelse(Sale.to.Minor=="Yes",1,0))

# Drop repeat inspections
# d15 <- d15 %>% mutate(dup=duplicated(d15[c("ADDRESS",'ZIP', 'FIPS')])) %>%
#  filter(dup==FALSE) %>% select(-dup)
d15 <- d15 %>% mutate(dup=duplicated(d15[c("ADDRESS",'ZIP', 'FIPS','Decision.Date')])) %>%
  filter(dup==FALSE) %>% select(-dup)

d16 <- d16 %>% mutate(dup=duplicated(d16[c("ADDRESS",'ZIP', 'FIPS')])) %>%
  filter(dup==FALSE) %>% select(-dup)

# Save
write.csv(d15,"./data/analysis2015.csv",row.names = F)
write.csv(d16,"./data/analysis2016.csv",row.names = F)

# -----------------
# Analysis
# -----------------
d <- d15

# Unadjusted Regressions
lm2 <- glmer(y ~ pov + (1 | state), data = d, family = binomial, control = glmerControl(optimizer = "bobyqa"),nAGQ = 14)
se <- sqrt(diag(vcov(lm2)))
tab <- data.frame(cbind(Est = fixef(lm2), LL = fixef(lm2) - 1.96 * se, UL = fixef(lm2) + 1.96 *se))
int<-c(exp(tab[1,1]))
df<-exp(tab[2,])

indep = c("indian","index_indian","asian","index_asian","black","index_blk", "hisp", "index_hisp","white","index_white","kid")

for (x in indep) {
  
  lm <- glmer(as.formula(paste("y ~",x,"+ (1 | state)")), data = d,
              family = binomial, control = glmerControl(optimizer = "bobyqa"),nAGQ = 14)
  se <- sqrt(diag(vcov(lm)))
  tab <- data.frame(cbind(Est = fixef(lm), LL = fixef(lm) - 1.96 * se, UL = fixef(lm) + 1.96 *se))
  
  df <-rbind(df,exp(tab[2,]))
  int <-c(int,exp(tab[1,1]))
  
}

df <- df %>% mutate(int=int,
                    CI=paste(format(round(LL, 2),nsmall=2)," to ", format(round(UL, 2),nsmall=2),sep=""),
                    first=paste(format(round(int,2),nsmall=2),", ",format(round(Est,2),nsmall=2),sep="")) %>%
  select(`Intercept, unadjusted OR`=first,`95% CI`=CI)

# Adjusted Regression
lm <- glmer(y ~ pov+indian+asian+black+hisp+kid+(1 | state), data = d,
            family = binomial, control = glmerControl(optimizer = "bobyqa"),nAGQ = 9)
se <- sqrt(diag(vcov(lm)))
tab <- data.frame(cbind(Est = fixef(lm), LL = fixef(lm) - 1.96 * se, UL = fixef(lm) + 1.96 *se))
tab<-exp(tab[2:length(tab[,1]),]) %>% mutate(CI=paste(format(round(LL, 2),nsmall=2)," to ", format(round(UL, 2),nsmall=2),sep="")) %>%
  select(`Adjusted OR`=Est,`95% CI `=CI)

# -----------------
# Combine Results
# -----------------

results <- left_join(df %>% mutate(Symbol = rownames(df)), tab %>% mutate(Symbol = rownames(tab)),by = 'Symbol') %>%
  select(-Symbol)
rownames(results) <- rownames(df)

intercept=exp(fixef(lm)[[1]])
stargazer(results, type = "text",summary=FALSE,digits=2,digits.extra = 1,
          out = "./output/table2015fda_adjusted.txt")

stargazer(results, type = "latex",summary=FALSE,
          title = "Retailer illegal sales to minors predicted by neighbourhood characteristics (NH,DC,HI)",
          out = "./output/table2015fda_new.tex")
