library(tidyverse)

cps <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/cps_00014.csv") %>%
  filter(YEAR > 2003)

attach(cps)

cps %>%
  filter(AGE < 55) %>%
  filter(INCTOT < 4e05 & INCTOT > 100) %>%
  filter(YEAR > 2014) %>%
  select(INCTOT,EARNWT,HIMCAIDLY,YEAR) %>%
  mutate(bin = cut(x = INCTOT,breaks=seq(100,2055999,2055999/1000))) %>%
  ggplot() +
  geom_histogram(aes(x=INCTOT,weight=EARNWT),na.rm = TRUE,bins=100)+
  facet_grid(YEAR~HIMCAIDLY)+
  geom_vline(xintercept =1.38*21720)

fpl <- read.csv("UT/Spring 2021/Causal/MedicaidLabor/Data/FPL_byyear.csv",strip.white = T) %>%
mutate(FIRST_PERSON = as.numeric(str_remove(FIRST_PERSON,pattern = ",")),
       PER_PERSON = as.numeric(str_remove(PER_PERSON,pattern = ",")))

cps <- cps %>%
  merge(fpl,"YEAR","YEAR",all.x = T,all.y = F) 

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
states <- names(tmcaid_1[c(2:52)])
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

tmcaid_1$mcaid_fpl_cutoff_family[is.na(as.numeric(tmcaid_1$mcaid_fpl_cutoff_family))] <- 0

#cps <- cps %>%
#  select(-mcaid_fpl_cutoff_indiv)

cps <- cps %>%
  #select(YEAR,STATEFIP) %>%
  filter(YEAR %in% factor(tmcaid_1$Year) | YEAR %in% factor(tmcaid_2$Year)) %>%
  merge(tmcaid_1,by.x = c("YEAR","STATEFIP"),by.y=c("Year","FIPS"),all.x=TRUE) %>%
  merge(tmcaid_2,by.x = c("YEAR","STATEFIP"),by.y=c("Year","FIPS"),all.x=TRUE)

#cps <- cps %>%
#  select(-`mcaid_fpl_cutoff_family`,-mcaid_fpl_cutoff_indiv)

cps <- cps %>%
  mutate(mcaid_fpl_cutoff_indiv = as.numeric(mcaid_fpl_cutoff_indiv),
         mcaid_fpl_cutoff_family = as.numeric(mcaid_fpl_cutoff_family),
         mcaid_cutoff = ifelse(FAMSIZE == 1,FPL * mcaid_fpl_cutoff_indiv,FPL * mcaid_fpl_cutoff_family))

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


cps %>%
  #filter(FAMSIZE == 1) %>%
  filter(AGE > 25 & AGE <= 65) %>%
  #filter(RELATE == 101) %>%
  filter(YEAR %in% c(2013:2017)) %>%
  ggplot()+
  geom_histogram(aes(x=FTOTVAL,group=as.factor(CAIDLY),fill=as.factor(CAIDLY),weight=ASECWT),
                 bins = 30,alpha=.8)+
  facet_grid(mcaid_qual_fam~YEAR,
             labeller = labeller(mcaid_qual_fam = c("0"="Income too High","1"="Within Income Threshold")))+
  xlim(0,250000)+
  xlab("Family Income")+
  scale_fill_manual(name = "Ever had Medicaid last year?",
                    labels = c("no","yes"),
                    values = c("tomato2","steelblue3"))

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
# Just trying a linear model
#
#####

library(plm)

names(cps)
table(cps$REL_TIME)
testlm <- cps %>%
  filter(AGE > 25 & AGE < 60) %>%
  filter(FTOTVAL < 100000) %>%
  filter(REL_TIME >= -5) %>%
  filter(UHRSWORKLY != 999 & CITIZEN == 1) %>%
  filter(WORKLY == 2) %>%
  lm(formula = FTOTVAL ~ TREATMENT + factor(REL_TIME) + factor(STATEFIP),
      weights = EARNWT)
summary(testlm)

#####
#
# Putting together engineered variables 
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
         CAIDLY = CAIDLY-1)

#####
#
# Putting together a more nimble dataset
#
#####
summary(abs(cps$mcaid_diff_fam))

testlm <- cps %>%
  #filter(AGE > 25 & AGE < 60) %>%
  #filter(abs(mcaid_diff_fam) < 10000) %>%
  filter(l_FTOTVAL > 0 & FTOTVAL < 100000) %>%
  filter(REL_TIME >= -5 & REL_TIME != 0) %>%
  filter(UHRSWORKLY != 999 & CITIZEN == 1) %>%
  #filter(WORKLY == 2) %>%
  lm(formula = l_FTOTVAL ~ TREATMENT * (mcaid_diff_fam + hourly) + d_MARST + black + college + in_school + CAIDLY + factor(REL_TIME) + factor(STATEFIP),
     weights = EARNWT)
summary(testlm)

