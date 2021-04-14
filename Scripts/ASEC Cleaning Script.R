
######################
# 
# COLIN WICK - SCRIPT FOR CLEANING ASEC DATA
# CREATE MEDICAID ELIGIBILITY INDICATOR
# SIGNIFICANT DIFFERENCE IN BEHAVIOR BETWEEN THOSE WITH/WITHOUT MEDICAID BOTH QUALIFYING AND WITHIN THOSE WHO HAVE
# 
# 
######################

library(tidyverse)
library(lubridate)

hhdf <- read.csv("UT/Spring 2021/Causal/Data/ASEC/hhpub20.csv")

## Federal Poverty calc is based on 

hhdf$HUNDER18

hhdf %>%
  filter(HMCAID == NOW_HMCAID & NOW_HMCAID != 0) %>%
  ggplot(aes(x=HTOTVAL))+
  geom_histogram(bins = 1000)
  #facet_wrap(.~HMCAID)

ppdf <- read.csv("UT/Spring 2021/Causal/Data/ASEC/pppub20.csv",nrows=100000)

ppdf %>%
  filter(PTOTVAL != 0) %>%
  ggplot()+
  geom_histogram(aes(x=PTOTVAL),binwidth = 1000)+
  xlim(0,350000)+
  geom_vline(xintercept =(1.38*21720))

######################
#
# https://www.kff.org/medicaid/state-indicator/medicaid-income-eligibility-limits-for-other-non-disabled-adults/?currentTimeframe=0&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D
# CODING MEDICAID ELIGIBILITY BASED ON THIS GUIDELINE
#
# Hawaii - 15 and Alaska - 02
#
######################

contig_us <- c(01,03:14,16:56)

hhdf %>%
  filter(H_NUMPER != 0) %>%
  mutate(hh_numper_spillover = case_when(H_NUMPER > 8 ~ H_NUMPER-8)) %>%
  mutate(hh_poverty = case_when(
    (GESTFIPS %in% contig_us & (
        H_NUMPER == 1 & HTOTVAL <= 12760 |
        H_NUMPER == 2 & HTOTVAL <= 17240 |
        H_NUMPER == 3 & HTOTVAL <= 21720 |
        H_NUMPER == 4 & HTOTVAL <= 26200 |
        H_NUMPER == 5 & HTOTVAL <= 30680 |
        H_NUMPER == 6 & HTOTVAL <= 35160 |
        H_NUMPER == 7 & HTOTVAL <= 39640 |
        H_NUMPER == 8 & HTOTVAL <= 44120 |
        hh_numper_spillover > 0  & hh_numper_spillover*4480 + HTOTVAL < hh_numper_spillover*4480 + 44120
    )) ~ TRUE,
    (GESTFIPS == 15 & (
        H_NUMPER == 1 & HTOTVAL <= 14680 |
        H_NUMPER == 2 & HTOTVAL <= 19830 |
        H_NUMPER == 3 & HTOTVAL <= 24980 |
        H_NUMPER == 4 & HTOTVAL <= 30130 |
        H_NUMPER == 5 & HTOTVAL <= 35280 |
        H_NUMPER == 6 & HTOTVAL <= 40430 |
        H_NUMPER == 7 & HTOTVAL <= 45580 |
        H_NUMPER == 8 & HTOTVAL <= 50730 |
        hh_numper_spillover > 0  & hh_numper_spillover*5150 + HTOTVAL < hh_numper_spillover*5150 + 50730
    )) ~ TRUE,
    (GESTFIPS == 02 & (
        H_NUMPER == 1 & HTOTVAL <= 15950 |
        H_NUMPER == 2 & HTOTVAL <= 21550 |
        H_NUMPER == 3 & HTOTVAL <= 27150 |
        H_NUMPER == 4 & HTOTVAL <= 32750 |
        H_NUMPER == 5 & HTOTVAL <= 38350 |
        H_NUMPER == 6 & HTOTVAL <= 43950 |
        H_NUMPER == 7 & HTOTVAL <= 49550 |
        H_NUMPER == 8 & HTOTVAL <= 55150 |
        hh_numper_spillover > 0  & hh_numper_spillover*5600 + HTOTVAL < hh_numper_spillover*5600 + 55150
    )) ~ TRUE,
    TRUE ~ FALSE
  ))

hhdf %>%
  filter(H_NUMPER == 3) %>%
  ggplot()+
  geom_histogram(aes(x=HTOTVAL,y = stat(count / sum(count)),weight=HSUP_WGT),binwidth = 2500)+
  xlim(0,250000)+
  ylim(0,.025)+
  geom_vline(xintercept = 21720*1.38,size=2,color="dark red")
