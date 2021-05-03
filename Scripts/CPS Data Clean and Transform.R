library(tidyverse)

print("Loading")

cps <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/cps_00015.csv") %>%
  filter(YEAR > 2003)

print("Loaded")

fpl <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/FPL_byyear.csv",strip.white = T) %>%
mutate(FIRST_PERSON = as.numeric(str_remove(FIRST_PERSON,pattern = ",")),
       PER_PERSON = as.numeric(str_remove(PER_PERSON,pattern = ",")))

cps <- cps %>%
  merge(fpl,"YEAR","YEAR",all.x = T,all.y = F) 

# This loads basic federal poverty line data by state into the CPS data 
# and creates a basic "family size" variable based on marital status and number of own children in HH
# Eliminates NIU incomes and calculates a poverty gap measure based on FPL on a family-size basis

cps <- cps %>%
  mutate(FAMSIZE = case_when(MARST == 1 ~ 2 + NCHILD,
                             TRUE ~ 1 + NCHILD),
         FPL = FIRST_PERSON + (FAMSIZE-1)*PER_PERSON) %>%
  filter(INCTOT != 999999999) %>%
  mutate(POVERTY_GAP = INCTOT - FPL)

####
#
# Medicaid cutoffs from kaiser family foundation
#
####

fips <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/StateFIPS.csv",col.names = c("FIPS","STATE"))

mcaid_1 <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/Medicaid_FPL_Parents_Time.csv")
names(mcaid_1)[1] <- "State"
tmcaid_1 <- data.frame(t(mcaid_1)[-1,])
names(tmcaid_1) <- unlist(t(mcaid_1)[1,])
tmcaid_1$Date <- as.Date(row.names(tmcaid_1),format="X%m.%d.%Y")
tmcaid_1$Year <- c("2002","2003","2004","2005","2006","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020")
tmcaid_1 <- bind_rows(tmcaid_1,tmcaid_1[tmcaid_1$Year=="2006",c(1:53)])
tmcaid_1$Year[is.na(tmcaid_1$Year)] <- "2007"
tmcaid_1 <- tmcaid_1 %>%
  select(-`United States`) %>%
  group_by(Year) %>%
  pivot_longer(cols=states,names_to = "State",names_repair = "minimal") %>%
  select(-Date) %>%
  rename("mcaid_fpl_cutoff_family"="value") %>%
  merge(fips,by.x = "State",by.y="STATE",all.x=TRUE) %>%
  select(-State)

mcaid_2 <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/Medicaid_FPL_nonDisabled.csv")
names(mcaid_2)[1] <- "State"
tmcaid_2 <- data.frame(t(mcaid_2)[-1,])
names(tmcaid_2) <- unlist(t(mcaid_2)[1,])
tmcaid_2$Date <- as.Date(row.names(tmcaid_2),format="X%m.%d.%Y")
tmcaid_2$Year <- c("2011","2012","2013","2014","2015","2016","2017","2018","2019","2020")

tmcaid_2 <- tmcaid_2 %>%
  select(-`United States`,-Date) %>%
  group_by(Year) %>%
  pivot_longer(cols=states,names_to = "State",names_repair = "minimal") %>%
  rename("mcaid_fpl_cutoff_indiv"="value") %>%
  merge(fips,by.x = "State",by.y="STATE",all.x=TRUE) %>%
  select(-State)

tmcaid_1$mcaid_fpl_cutoff_family[is.na(as.numeric(tmcaid_1$mcaid_fpl_cutoff_family))]

# From the KFF, there are yearly medicaid cutoffs going back to 2002 for families and 2011 for individuals
# Using this table, we can append each record with an individualized measure of the medicaid cutoff
# The script above adds this data to the CPS records

cps <- cps %>%
  #select(YEAR,STATEFIP) %>%
  filter(YEAR %in% factor(tmcaid_1$Year) | YEAR %in% factor(tmcaid_2$Year)) %>%
  merge(tmcaid_1,by.x = c("YEAR","STATEFIP"),by.y=c("Year","FIPS"),all.x=TRUE) %>%
  merge(tmcaid_2,by.x = c("YEAR","STATEFIP"),by.y=c("Year","FIPS"),all.x=TRUE)

cps <- cps %>%
  mutate(mcaid_fpl_cutoff_indiv = as.numeric(mcaid_fpl_cutoff_indiv),
         mcaid_fpl_cutoff_family = as.numeric(mcaid_fpl_cutoff_family),
         mcaid_cutoff = ifelse(FAMSIZE == 1,FPL * mcaid_fpl_cutoff_indiv,FPL * mcaid_fpl_cutoff_family))

# Here we constructed an individualized medicaid cutoff by year. For individuals we use the ACA income cutoff
# For families we calculate that family's FPL and Medicaid cutoff

cps <- cps %>%
  mutate(mcaid_qual_fam = case_when(FAMSIZE == 1 & mcaid_cutoff == 0 ~ 0,
                                FAMSIZE == 1 & mcaid_cutoff >= FTOTVAL ~ 1,
                                FAMSIZE > 1  & mcaid_cutoff >= FTOTVAL ~ 1,
                                FAMSIZE > 1  & mcaid_cutoff < FTOTVAL ~ 0,
                                TRUE ~ 0),
         mcaid_qual_indiv = case_when(FAMSIZE == 1 & mcaid_cutoff == 0 ~ 0,
                                    FAMSIZE == 1 & mcaid_cutoff >= INCTOT ~ 1,
                                    FAMSIZE > 1  & mcaid_cutoff >= INCTOT ~ 1,
                                    FAMSIZE > 1  & mcaid_cutoff < INCTOT ~ 0,
                                    TRUE ~ 0)
         )

# Because CPS gives both family and individual-level income, we calculate medicaid qualification using both numbers
# For the analysis, we will use family-level constructed qualification.

######
#
# adding treatments to data
#
######

exp <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/expansion_year.csv")
exp <- exp %>%
  merge(fips,by="STATE") %>%
  select(-STATE)

cps$TREATMENT <- 0
cps$REL_TIME <- 0
exp <- exp %>% filter(TREAT != 0)
for(i in c(1:nrow(exp))){
  cps$TREATMENT[cps$YEAR >= exp$TREAT[i] & cps$STATEFIP == exp$FIPS[i]] <- 1
  cps$REL_TIME[cps$STATEFIP == exp$FIPS[i]] <- cps$YEAR[cps$STATEFIP == exp$FIPS[i]] - exp$TREAT[i]
}

#####
#
# Putting together engineered variables. The basic econ control variables of relevance.
#
#####

cps <- cps %>%
  mutate(mcaid_diff_indiv = INCTOT - mcaid_cutoff,
         mcaid_diff_fam = FTOTVAL - mcaid_cutoff,
         d_MARST = ifelse(MARST==1,1,0),
         black = ifelse(RACE %in% c(200,801,805:807,810,811,814,816,818),1,0),
         college = ifelse(EDUC > 80 & EDUC != 999,1,0),
         in_school = ifelse(SCHLCOLL == 5,1,0),
         hourly = ifelse(PAIDHOUR==2,1,0),
         l_FTOTVAL = ifelse(FTOTVAL > 0,log(FTOTVAL),0),
         l_INCTOT = ifelse(INCTOT > 0,log(INCTOT),0),
         first_treated = ifelse(STATEFIP %in% exp$FIPS[exp$TREAT == "2014"],1,0),
         ever_treated = ifelse(STATEFIP %in% exp$FIPS,1,0),
         hourly_wage = INCWAGE / (UHRSWORKLY*WKSWORK1),
         yearly_hrs = UHRSWORKLY*WKSWORK1,
         insured = ifelse(PHINSUR==2|HIMCAIDLY==2|HIMCARELY==2,1,0),
         mcaidstatus = case_when(DISABWRK == 2 & HIMCAIDLY == 2 ~ "MCAID&DISAB",
                                 DISABWRK == 1 & HIMCAIDLY == 2 ~ "MCAID&Non-DISAB",
                                 TRUE ~ "No MCAID"),
         HIMCAIDLY_r = HIMCAIDLY - 1)

#cps %>%
#  filter(hourly==1) %>%
#  mutate(rand = runif(n())) %>%
#  filter(rand < .4) %>%
#  mutate(incwage1 = HOURWAGE * UHRSWORKLY * WKSWORK1) %>%
#  filter(INCWAGE < 50000 & incwage1 < 50000) %>%
#  select(incwage1,INCWAGE) %>%
#  mutate(diff = incwage1 - INCWAGE) %>%
#  summarize(avg = mean(diff,na.rm=T),
#            sd = sd(diff,na.rm = T)/sqrt(n()))
#  ggplot()+
#  geom_point(aes(y=incwage1,x=INCWAGE),alpha=.2)+
#  geom_smooth(aes(y=incwage1,x=INCWAGE),method="lm")+
#  xlim(0,50000)+ylim(0,50000)+xlab("Reported Wage Income")+ylab("Constructed Wage Income")