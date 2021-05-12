Medicaid Expansion Effects on Labor
================
Colin Wick
5/12/2021

### Background & Intro

The average health insurance premium cost for a single individual rose
from $3,000 to $7,000 from 1999 to 2018. Over the same period, family
coverage increased from $6000 to $20,000 per year [Health Affairs
(2018)](healthaffairs.org/doi/10.1377/hlthaff.2018.1001) . In 2010, the
Affordable Care Act included provisions for expansion of Medicaid for
low-income individuals up to 138% of the federal poverty line. Though
not a perfect program, qualifying for medicaid, in a sense, represents a
transfer of value to an individual or family, respectively, at no cost.

After clearing the initial Supreme Court challenges, 27 states expanded
Medicaid on the first year of the program’s availability with another 10
expanding over the following 7 years. 4 states are currently in the
process of implementing their expansions.

Given the stark cutoff of eligibility and relatively large income
transfer that the program represents, bunching around the eligibility
cutoff would be expected. This would be consistent with Saez (2010).
However, in Miller (2019) they find little evidence of the kind of
bunching present around the EITC trapezoid vertices. However, access to
Medicaid is very different in terms of both public awareness and access.
Even without bunching around the cutoff, there may still be some
influence on labor decisions (or reporting) based on expanding
eligibility.

Analysis from the Kaiser Family foundation found that removal of the
asset test only resulted in a 3% increase in program uptake, meaning
eligibility and qualification mainly rest on family income. Using this
assumption, we are able to reconstruct Medicaid eligibility using
reported family income from the ASEC (the economic supplement to the
Census’s CPS). Income-based Medicaid eligibility is computed as a
function of the Federal poverty line, which itself is a function of
family size. Each of these variables is included in the ASEC (variables:
NCHILD, FTOTVAL, MARST). Then using year-state Medicaid eligibility
cutoffs as reported by the Kaiser Family Foundation, each observation of
the ASEC can be coded with the exact difference between their family
income and the state-year Medicaid threshold.

#### Definition of Population of Interest

This study specifically analyzes the population of families within
$10,000 of medicaid coverage in either direction. This is the rough
estimate of the “medicaid gap” which conceptually developed alongside
the ACA’s implementation but existed before as well. Though a relatively
arbitrary cutoff, the $10,000 cutoff is made where those at the high end
would qualify for ACA Silver Plan Benchmarks and Medicaid coverage would
not be worth reducing income. Similarly, for the low end, $10,000
represents adding 2 full 8-hour days of work at $12/hr. This cutoff
represents utting down all Americans to a reasonable population
represents those who are certainly affected by Medicaid’s income cutoff
out to the edges of that income-qualification decision.

The population of interest is workers age 26-60. This population
represents those most closely on the margin of the Medicaid cutoff. By
the same logic other studies cut off health outcomes at the
near-Medicare cohort, this study rather focuses on those for whom
exogenous health effects may play less of a role in labor decisions. The
lower bound of 26 is chosen due to the ACA’s rule allowing children to
stay on parent’s health insurance policy until 26, which would distort
estimates. I further limit the data to those who worked within the past
year and did not report disability income to focus on marginal hours and
wages rather than entering the labor force.

#### Theoretical Basis

Under the current system of Medicaid qualification, if a family is below
their state’s threshold, they qualify for the program. There are cases
where disabled people and children have extra access to similar programs
without means testing or with higher thresholds. However, the coverage
offered for Medicaid/Medicare disability, CHIP, or similar programs
often does not extend to parents or caretakers.

Healthcare in the United States is completely unaffordable, especially
among the population where Medicaid coverage is a relevant question. As
established before, insurance premiums cost on average $6,000 per year
for an individual. Under a utility-maximizing theory of households,
access to healthcare is at least 1:1 substitutable with cash on hand, if
not more. Therefore, if a worker is near the Medicaid threshold, they
will adjust income (if possible) to get access to the program so long as
the change in income is less than the in-kind utility of the program.

Countless economic research demonstrates wage stickiness for both hourly
and salaried employees. However, even for relatively powerless people
(hourly workers at the bottom of the income distribution), they can
still exert some control over the marginal number of hours they work per
week. This may mean taking an extra shift or dropping a shift, for
example.

Small shifts in weekly hours can amount to relatively large changes in
yearly income, to the point where it may affect household medicaid
eligibility. For example, dropping one 8-hour shift per week represents
a $4,000 change in yearly income for a 50-week $10/hour worker. For
those making between $10,000 and $20,000 (the medicaid-expansion
relevant population), this could represent the difference between
qualifying and not qualifying. It is also immediately clear that this
difference would represent a net +$2,000 household income increase
taking the $6,000 average cost of an individual plan.

#### Visual Parallel Trends

The first step in a difference-in-differences study is to establish
parallel trends for the variables of interest. In this case, the main
variable is average hours worked. The following three charts visually
represent a break in parallel trends for the variables of interest. The
clearest break is in reported hours-per-week, which just visually shows
a dramatic \~2hr increase relative to “parallel trend” in this sample.
This represents a 5-10% increase in hours per week (and therefore
income) for those near the Medicaid threshold.

The other two key measurements show a less dramatic visual difference.
Hourly wage is far less marginally adjustable by workers, so the
relatively stable trend between expansion and non-expansion states is
expected. Wage income is reported as a separate variable but could also
be constructed using CPS data. For the purposes of this study, reported
wage income is used, since it reduces respondent bias. Multiplying
reported hours per week, weeks worked, and hourly wage would each be
subject to a whole number bias respectively, while wage income is only
subject once.

<img src="Paper-Markdown_files/figure-gfm/parallel-trends-avg-hrs-1.png" style="display: block; margin: auto;" />

<img src="Paper-Markdown_files/figure-gfm/parallel-trends-hrlywage-1.png" style="display: block; margin: auto;" />

The next step is to statistically define these parallel trends using an
event-study methodology to ensure there are measurable differences in
the treated population over this time period for our variable of
interest (Medicaid eligibility).

## Methodology & Establishing Causal Baseline

The intention of the study is to focus on a more narrow question. For
those near the Medicaid eligibility cutoff, did the “shock” of the ACA
cause those around the cutoff to increase their economic output, as
measured by weekly hours.

The study design is based, in part, off of Miller (2019) which similarly
uses non-linked CPS data with an eligibility construction. Under a
non-linked circumstance, the only means for analysis are in aggregate
and by-cohort. The first step in building the difference-in-differences
estimator is to establish parallel trends across the states, both in
insurance rates and in labor output. By construction, this estimator is
showing the probability (or level) for untreated

<img src="Paper-Markdown_files/figure-gfm/miller-2019-insured-1.png" style="display: block; margin: auto;" />

<img src="Paper-Markdown_files/figure-gfm/miller-2019-priv-hi-1.png" style="display: block; margin: auto;" />

This one is interesting, because we find an increase in private health
insurance uptake. This is partially explained by the ACA subsidies which
brought down the cost of private insurance for households and the upper
side of this population’s income distribution may qualify depending on
the number of children in their family and state-level health insurance
arrangement.

<img src="Paper-Markdown_files/figure-gfm/miller-2019-mcaid-qual-1.png" style="display: block; margin: auto;" />

For the population of interest, we find that treatment had a dramatic
effect on insurance rate. This is consistent with Miller 2019, both
reaffirming the eligibility construction and showing that there are
detectable state-level effects on insurance rates.

The first step in this analysis established that there may be a
detectable treatment effect over time, but it is also necessary to
establish this across the medicaid income threshold before and after
treatment. The effects of increasing the medicaid threshold affect those
above and below differently, so those just above may reduce hours while
those below may increase hours when the Medicaid cutoff becomes a
relevant choice in labor decisions. The next step in shaving off other
potential causal factors is differences by demographics across the
relevant threshold. Similar to the work in Hansen (2015) which shows
that there is not a relevant discontinuity across the BAC threshold.

<img src="Paper-Markdown_files/figure-gfm/demo-discontinuity-1.png" style="display: block; margin: auto;" />

#### Placebo & Weighting

The process of post-constructing medicaid eligibility also yields a
simple placebo mechanism by which the outcomes of a difference in
differences can be measured. The standard conception of the medicaid gap
is $10,000, meaning those outside of that threshold on either side will
not face the same kind of imminent consideration on labor decisions, but
will still have similar demographics and constraints as those just over
the $10,000 threshold.

Similarly, those closest to the Medicaid threshold could stand to gain
the most from qualifying (or disqualifying) for Medicaid, which
motivates the use of RDD-style triangular or quadratic weighting
mechanism for those closest to that threshold to upweight the marginal
decisions of those who are closest. This intuitively makes sense, since
someone who merely needs to work one-fewer shifts per month, or
one-fewer hours per week may opt to do so when that would qualify them
for medicaid. Similarly, those who might have been bunching just-below
the threshold have flexibility to work the corresponding marginal hour.
On the contrary, few people (especially those for whom Medicaid is
relevant) will not be able to simply choose to make or forego $10,000
based on marginal labor decisions.

## Model Specification

The first model employed is a standard difference-in-difference model to
establish a relationship with respect to expansion. In this sample, only
looking at states which expanded immediately after the law went into
effect. Where each individual (*i*) in state (*s*) is treated at time
(*t*) with controls for each state and year effects, as well as a vector
of demographic control variables *μ*. For this regression, using the
formula:

*H*<sub>*i*, *s*, *t*</sub> = *α* + *γ* ⋅ *T**r**e**a**t* + *β* ⋅ *P**o**s**t* + *δ* ⋅ *T**r**e**a**t* ⋅ *P**o**s**t* + *μ*<sub>*i*</sub> + *ϵ*

Second model employs the strategy highlighted in Black (2019) and Miller
(2019), which accounts for lingering effects of treatment, setting “D”
as a dummy representing ever receiving treatment and R representing a
dummy for each relative event time. Using the formula:

*H*<sub>*i*, *t*, *s*</sub> = *α* + *γ* \* (*D* = 1) + *δ*(*R*<sub>*t*, *s*</sub> = 1) + *β*<sub>*s*</sub> + *β*<sub>*t*</sub> + *μ*<sub>*i*</sub> + *ϵ*<sub>*i*, *s*, *t*</sub>

To estimate whether these effects are most prevalent on the margin, I
employ a weighted regression model using both a triangular and quadratic
scheme following the following formulas. A triangular scheme will
greatly weight the effects for those closest to the relevant margin,
while the quadratic model will maintain the weights for those slightly
further away from the threshold.

$W\_{tri} = 1-\\frac{abs(x)-10000}{10000} \* W\_{ASEC}$

$W\_q = 1-\\frac{x^2}{10000^2} \* W\_{ASEC}$

The weighting scheme equals 1 for those directly on the threshold, and
eventually equals 0 for those furthest. This method is commonly employed
in a regression discontinuity design, but is relevant in this case for
isolating *whether* this effect is happening on the margin or across the
entire workforce. By isolating this marginal movement as statistically
distinct from the entire near-medicaid workforce, there is a stronger
case to be made that the threshold itself is the cause of the behavior,
not secular trends among all low-income individuals.

<img src="Paper-Markdown_files/figure-gfm/weighting-visual-1.png" style="display: block; margin: auto;" />

Finally, these models look at aggregate effects across the entire
near-Medicaid workforce, including those above but near the threshold.
This presents two key problems with causal inference. The near-medicaid
population is, by definition, living near-poverty, meaning other
state-level or macroeconomic changes may affect labor outcomes. Merely
running the same regression on those strictly below the Medicaid
threshold will increase the intensity of this selection effect.

Secondly, this data is not linked and the incomes measured in the data
are within a tight band. Though incomes are relatively sticky, workers
could easily have moved across or within the $10,000 threshold region
over the time period studied. To account for this, testing against
incomes well-above the threshold will work against this effect, though
not perfectly.

To account for this, I employ a simple placebo testing framework.
Setting a dummy variable equal to 1 if the observation is in the “above”
threshold. With each observation taking a value of 1 or 0 for B =
Placebo, P = Post, and T = Treat.

*H*<sub>*i*, *s*, *t*</sub> = *α* + *θ*<sub>1</sub> ⋅ *B* + *θ*<sub>2</sub> ⋅ *T* + *θ*<sub>3</sub> ⋅ *P* + *θ*<sub>4</sub> ⋅ *B* ⋅ *T* + *θ*<sub>5</sub> ⋅ *B* ⋅ *P* + *θ*<sub>6</sub> ⋅ *T* ⋅ *P* + *θ*<sub>7</sub> ⋅ *B* ⋅ *T* ⋅ *P* + *μ*<sub>*i*</sub> + *ϵ*

*θ*<sub>7</sub> is the triple-difference parameter of interest, which
isolates the effect for low-income individuals against the effect for
those sufficiently above the medicaid threshold. I also run this same
model for those just above the medicaid threshold against those
well-below to estimate whether those above adjusted income down to
qualify for medicaid.

## Results

#### Diff-in-Diff regressions

    ## 
    ## Table 1: Diff-in-Diff Results
    ## ======================================================================================
    ##                                         Dependent variable:                           
    ##               ------------------------------------------------------------------------
    ##                                             Weekly Hours                              
    ##                   Basic DiD        Event Study    Triangular Weights Quadratic Weights
    ##                      (1)               (2)               (3)                (4)       
    ## --------------------------------------------------------------------------------------
    ## DiD Estimator 2.454*** (0.169)                                                        
    ## Year 0                          2.978*** (0.202)   3.346*** (0.204)  3.189*** (0.203) 
    ## Year 1                          2.873*** (0.262)   3.055*** (0.265)  2.984*** (0.264) 
    ## Year 2                          2.979*** (0.265)   2.993*** (0.268)  2.921*** (0.267) 
    ## Year 3                          2.381*** (0.283)   2.719*** (0.288)  2.601*** (0.287) 
    ## Year 4                          2.478*** (0.293)   3.116*** (0.301)  2.978*** (0.299) 
    ## Year 5                          2.073*** (0.334)   2.251*** (0.339)  2.238*** (0.339) 
    ## Intercept     36.528*** (0.460) 36.539*** (0.459) 35.932*** (0.476)  36.120*** (0.474)
    ## --------------------------------------------------------------------------------------
    ## Observations       96,543            96,543             96,543            96,543      
    ## ======================================================================================
    ## Note:                                                      *p<0.1; **p<0.05; ***p<0.01

Regardless of weighting scheme, the same 2-3 hour difference appears in
each regression. This in important in two ways. First, it validates the
theoretical notion that those closer to the relevant constraint will be
more sensitive to it.

Secondly, the triangular weighting scheme’s effectiveness both motivates
and gives validity to a placebo test. Under a circumstance where those
far from the cutoff are driving results, an effective placebo group
would not be available. In this case, with the effect concentrated at
the cutoff, those far from the cutoff can serve as a placebo.

Table 2 shows two placebo tests, breaking out the group “just below” and
“just above” the cutoff to further isolate the effects of expansion.
Placebo groups were selected across the threshold and sufficiently far
away.

#### Placebo Regressions

<img src="Paper-Markdown_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

    ## 
    ## Table 2: Triple-Diff Results
    ## =========================================================================
    ##                                      Dependent variable:                 
    ##                     -----------------------------------------------------
    ##                                         Weekly Hours                     
    ##                             Just Below                 Just Above        
    ##                                (1)                        (2)            
    ## -------------------------------------------------------------------------
    ## Constant                40.848*** (0.446)          34.917*** (1.058)     
    ## Treatment                 -0.458 (0.653)             1.033 (1.299)       
    ## Post                    -2.805*** (0.323)          -10.841*** (1.208)    
    ## Treated                 -4.607*** (0.244)           1.678** (0.660)      
    ## Treatment * Post         1.151*** (0.211)           6.852*** (1.169)     
    ## Treatment * Treated      1.722*** (0.279)           1.393** (0.701)      
    ## Post * Treated          -1.919*** (0.397)           5.900*** (1.167)     
    ## Triple Difference        2.007*** (0.442)          -4.118*** (1.209)     
    ## -------------------------------------------------------------------------
    ## Observations                  61,517                     34,045          
    ## R2                            0.096                      0.106           
    ## Adjusted R2                   0.095                      0.104           
    ## Residual Std. Error    388.132 (df = 61434)       421.758 (df = 33962)   
    ## F Statistic         79.990*** (df = 82; 61434) 48.942*** (df = 82; 33962)
    ## =========================================================================
    ## Note:                                         *p<0.1; **p<0.05; ***p<0.01

Table 2 shows a very different effect depending on the relationship to
the medicaid cutoff. Those who are “just above” the cutoff reduce work
hours by 3-5 hours per week while those “just below” increase hours by
1.5-2.5 hours.

### Conclusion

Low-income people in the United States face an impossible set of
circumstances for healthcare, especially those in or near the Medicaid
Gap. The ACA’s expansion of Medicaid eligibility to those at 138% of the
federal poverty line represented a massive shift in access to medicine
for some of the poorest families in America.

Previously it has been shown there is not a large amount of bunching
along the Medicaid cutoff, partially due to the fluid nature of
“potential” Medicaid coverage being enough for hospitals to treat
patients. However, in the aggregate, there is evidence of people
adjusting their behavior in response to the Medicaid cutoff.

Taking the placebo estimates from Table 2, the change in number of hours
worked represents a substantial change in income over the year. By those
estimates, at the average hourly wage for this cohort ($12), those “just
below” the Medicaid cutoff increased yearly wages by $1,200 while
maintaining pseudo-coverage on Medicaid.

Perhaps more starkly, those “just above” the threshold reduced income by
$2,400. This is consistent with a rational, utility-maximizing consumer
theory since the average cost of a health insurance plan is $6,000.

In a broader context, this shows the effectiveness of a healthcare
system not linked to an employment scheme. Also, keeping in mind the
kinds of positions which offer $12/hr tend not to be positions which
offer generous benefits packages. Across this cohort, the only “work
reducing” effect of this program is for those reducing labor output in
order to get access to healthcare. The oppressive costs of healthcare in
the United States have a massive distortionary effect on labor output,
as illustrated in this relatively small example. Under a similar theory
of healthcare access as a preferred outcome of a utility-maximizing
household, there is reason to believe a similar effect is taking place
among those in higher income cohorts as well.
