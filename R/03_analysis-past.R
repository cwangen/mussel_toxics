#### Load libraries ####

library(MASS)
library(tidyverse)
library(here)
library(lme4)
library(RLRsim)


#### Create Dataframes ####

# set directories
clean_data_dir <- here("data", "clean")

# get excel file name
totals <- "totals_all.csv"

# load dataframe
mussel_df <- read_csv(here(clean_data_dir, totals), show_col_types = FALSE)

#abs of dry value for now
mussel_df$dry_value <- abs(mussel_df$dry_value)

#years as year from 2010
#mussel_df$year <- mussel_df$year - 2010

#years as category
mussel_df$year <- as.factor(mussel_df$year)

#create simple regions based on longitude
# mussel_df <- mussel_df %>% mutate(region = case_when(longitude > -122.75 & latitude > 47.6 ~  'Northeast',
#                                                      longitude > -122.75 & latitude < 47.6 ~  'Southeast',
#                                                      longitude < -122.75 ~ 'West'
# ))
# mussel_df$region <- as.factor(mussel_df$region)



#create analyte dataframes
PB_df <- mussel_df %>%
  filter(mussel_df$analyte == "SumPBDEs11")
PB_df <- PB_df[complete.cases(PB_df),]


PC_df <- mussel_df %>%
  filter(mussel_df$analyte == "SumPCBs2x17")
PC_df <- PC_df[complete.cases(PC_df),]

PA_df <- mussel_df %>%
  filter(mussel_df$analyte == "SumPAHs16")
PA_df <- PA_df[complete.cases(PA_df),]


#### LMM PBDEs ####

##fit model with RE for lat and lon
PB_LMM <- lmer(log(dry_value) ~
                 year +
                 time +
                 mean_is_au +
                  county_name +
                 (1|latitude)+
                 (1|longitude),
               data = PB_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PB_LMM))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.44

##fit model no time 
PB_LMM_no_time <- lmer(log(dry_value) ~
                 year +
                 mean_is_au +
                 (1|latitude)+
                 (1|longitude),
               data = PB_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PB_LMM_no_time))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.28

##fit model no lon 
PB_LMM_lat <- lmer(log(dry_value) ~
                         year +
                         time +
                         mean_is_au +
                         (1|latitude),
                       data = PB_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PB_LMM_lat))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.51

#fit model no lat 
PB_LMM_lon <- lmer(log(dry_value) ~
                     year +
                     time +
                     mean_is_au +
                     (1|longitude),
                   data = PB_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PB_LMM_lon))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.45

##fit model with RE for lat and lon, squat lat
PB_df2 <- PB_df
PB_df2$latitude <- PB_df2$latitude*PB_df2$latitude

PB_LMM_x2 <- lmer(log(dry_value) ~
                 year +
                 time +
                 mean_is_au +
                 (1|latitude)+
                 (1|longitude),
               data = PB_df2)



#### PBDE FIT ####

#compare AIC for RE same (best with all variables)
PB_LMM_no_year <- lmer(log(dry_value) ~
                         time +
                         mean_is_au +
                         (1|longitude),
                       data = PB_df)

anova(PB_LMM,PB_LMM_no_time, PB_LMM_no_year)

#single random effect comparisons 
exactRLRT(PB_LMM_lat,PB_LMM,PB_LMM_lon) #p-value ~0.2045
exactRLRT(PB_LMM_lon,PB_LMM,PB_LMM_lat) #p-value 0.2022

#summary
summary(PB_LMM)

#QQ plots
## set plot area
par(mai = c(0.9, 0.9, 0.6, 0.1),
    omi = c(0, 0, 0, 0),
    mfrow = c(1,2), cex.lab = 1.2)

## residuals
qqnorm(residuals(PB_LMM), main = "QQ plot (residuals)", las = 1, pch = 1)
qqline(residuals(PB_LMM))

## Random effects
qqnorm(unlist(ranef(PB_LMM)), main = "QQ plot (RE's)", las = 1, pch = 1)
qqline(unlist(ranef(PB_LMM)))

## residuals vs fitted
plot(fitted(PB_LMM), residuals(PB_LMM), las = 1, pch = 1,
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
abline(h=0, lty = "dashed")

##### LMM PCBs ####

##fit model with RE for lat and lon
PC_LMM <- lmer(log(dry_value) ~
                 year +
                 time +
                 mean_is_au +
                 (1|latitude)+
                 (1|longitude),
               data = PC_df)


#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PC_LMM))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.11

##fit model no time
PC_LMM_no_time <- lmer(log(dry_value) ~
                         year +
                         mean_is_au +
                         (1|latitude)+
                         (1|longitude),
                       data = PC_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PC_LMM_no_time))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.10

##fit model no lon 
PC_LMM_lat <- lmer(log(dry_value) ~
                     year +
                     time +
                     mean_is_au +
                     (1|latitude),
                   data = PC_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PC_LMM_lat))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.72

#fit model no lat 
PC_LMM_lon <- lmer(log(dry_value) ~
                     year +
                     time +
                     mean_is_au +
                     (1|longitude),
                   data = PC_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PC_LMM_lon))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.66


#### PCB FIT ####

## Complete Model ##

#compare AIC for RE same (better without year but not by much)
PC_LMM_no_year <- lmer(log(dry_value) ~
                         time +
                         mean_is_au +
                         (1|longitude) +
                         (1|latitude),
                       data = PC_df)

anova(PC_LMM,PC_LMM_no_time, PC_LMM_no_year)


#single random effect comparisons 
exactRLRT(PC_LMM_lat,PC_LMM,PC_LMM_lon) #p-value ~0.34
exactRLRT(PC_LMM_lon,PC_LMM,PC_LMM_lat) #p-value 0.019

#summary
summary(PC_LMM)

#QQ plots
## set plot area
par(mai = c(0.9, 0.9, 0.6, 0.1),
    omi = c(0, 0, 0, 0),
    mfrow = c(1,2), cex.lab = 1.2)

## residuals
qqnorm(residuals(PC_LMM), main = "QQ plot (residuals)", las = 1, pch = 1)
qqline(residuals(PC_LMM))

## Random effects
qqnorm(unlist(ranef(PC_LMM)), main = "QQ plot (RE's)", las = 1, pch = 1)
qqline(unlist(ranef(PC_LMM)))

## residuals vs fitted
plot(fitted(PC_LMM), residuals(PC_LMM), las = 1, pch = 1,
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
abline(h=0, lty = "dashed")

## Without year and latitude ##
PC_LMM_no_year_lat <- lmer(log(dry_value) ~
                         time +
                         mean_is_au +
                         (1|longitude),
                       data = PC_df)

summary(PC_LMM_no_year_lat)

#QQ plots
## set plot area
par(mai = c(0.9, 0.9, 0.6, 0.1),
    omi = c(0, 0, 0, 0),
    mfrow = c(1,2), cex.lab = 1.2)

## residuals
qqnorm(residuals(PC_LMM_no_year_lat), main = "QQ plot (residuals)", las = 1, pch = 1)
qqline(residuals(PC_LMM_no_year_lat))

## Random effects
qqnorm(unlist(ranef(PC_LMM_no_year_lat)), main = "QQ plot (RE's)", las = 1, pch = 1)
qqline(unlist(ranef(PC_LMM_no_year_lat)))

## residuals vs fitted
plot(fitted(PC_LMM_no_year_lat), residuals(PC_LMM_no_year_lat), las = 1, pch = 1,
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
abline(h=0, lty = "dashed")

##### LMM PAHs ####

##fit model with RE for lat and lon
PA_LMM <- lmer(log(dry_value) ~
                 year +
                 time +
                 mean_is_au +
                 (1|latitude)+
                 (1|longitude),
               data = PA_df)


#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PA_LMM))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.05

##fit model no time
PA_LMM_no_time <- lmer(log(dry_value) ~
                         year +
                         mean_is_au +
                         (1|latitude)+
                         (1|longitude),
                       data = PA_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PA_LMM_no_time))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.04

##fit model no lon 
PA_LMM_lat <- lmer(log(dry_value) ~
                     year +
                     time +
                     mean_is_au +
                     (1|latitude),
                   data = PA_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PA_LMM_lat))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.91

#fit model no lat 
PA_LMM_lon <- lmer(log(dry_value) ~
                     year +
                     time +
                     mean_is_au +
                     (1|longitude),
                   data = PA_df)

#check correlation among random effects
# get variation of RE
var_re_latlon <- as.data.frame(VarCorr(PA_LMM_lon))

## variance of random effects
sigma2_alpha <- var_re_latlon$vcov[1]
## variance of residuals
sigma2_epsilon <- var_re_latlon$vcov[2]
## calculate the correlation among RE's
rho <- sigma2_alpha / (sigma2_alpha + sigma2_epsilon)
## rho ~0.92


#### PAH FIT ####

## Complete Model ##

#compare AIC for RE same (better without year but not by much)
PA_LMM_no_year <- lmer(log(dry_value) ~
                         time +
                         mean_is_au +
                         (1|longitude) +
                         (1|latitude),
                       data = PA_df)

anova(PA_LMM,PA_LMM_no_time, PA_LMM_no_year)


#single random effect comparisons 
exactRLRT(PA_LMM_lat,PA_LMM,PA_LMM_lon) #p-value ~0.18
exactRLRT(PA_LMM_lon,PA_LMM,PA_LMM_lat) #p-value ~2e-04

#summary
summary(PA_LMM)

#QQ plots
## set plot area
par(mai = c(0.9, 0.9, 0.6, 0.1),
    omi = c(0, 0, 0, 0),
    mfrow = c(1,2), cex.lab = 1.2)

## residuals
qqnorm(residuals(PA_LMM), main = "QQ plot (residuals)", las = 1, pch = 1)
qqline(residuals(PA_LMM))

## Random effects
qqnorm(unlist(ranef(PA_LMM)), main = "QQ plot (RE's)", las = 1, pch = 1)
qqline(unlist(ranef(PA_LMM)))

## residuals vs fitted
plot(fitted(PA_LMM), residuals(PA_LMM), las = 1, pch = 1,
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
abline(h=0, lty = "dashed")

## Without year and latitude ##
PA_LMM_no_year_lat <- lmer(log(dry_value) ~
                             time +
                             mean_is_au +
                             (1|longitude),
                           data = PA_df)

summary(PA_LMM_no_year_lat)

#QQ plots
## set plot area
par(mai = c(0.9, 0.9, 0.6, 0.1),
    omi = c(0, 0, 0, 0),
    mfrow = c(1,2), cex.lab = 1.2)

## residuals
qqnorm(residuals(PA_LMM_no_year_lat), main = "QQ plot (residuals)", las = 1, pch = 1)
qqline(residuals(PA_LMM_no_year_lat))

## Random effects
qqnorm(unlist(ranef(PA_LMM_no_year_lat)), main = "QQ plot (RE's)", las = 1, pch = 1)
qqline(unlist(ranef(PA_LMM_no_year_lat)))

## residuals vs fitted
plot(fitted(PA_LMM_no_year_lat), residuals(PA_LMM_no_year_lat), las = 1, pch = 1,
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
abline(h=0, lty = "dashed")



