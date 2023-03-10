###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the processed_data folder
#
# Note the ## ---- name ---- notation
# This is done so one can pull in the chunks of code into the Quarto document
# see here: https://bookdown.org/yihui/rmarkdown-cookbook/read-chunk.html


## ---- packages --------
#load needed packages. make sure they are installed.
library(readxl) #for loading Excel files
library(dplyr) #for data processing/cleaning
library(tidyr) #for data processing/cleaning
library(skimr) #for nice visualization of data 
library(here) #to set paths

## ---- loaddata --------
#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","raw_data","exampledata2.xlsx")

#load data. 
#note that for functions that come from specific packages (instead of base R)
# I often specify both package and function like so
#package::function() that's not required one could just call the function
#specifying the package makes it clearer where the function "lives",
#but it adds typing. You can do it either way.
rawdata <- readxl::read_excel(data_location)

## ---- exploredata --------
#take a look at the data
dplyr::glimpse(rawdata)

#another way to look at the data
summary(rawdata)

#yet another way to get an idea of the data
head(rawdata)

#this is a nice way to look at data
skimr::skim(rawdata)

# looks like we have the following data
# height (seems like it's in centimeters) 
# weight (seems to be in kilogram)
# Sex



## ---- cleandata1 --------
# Inspecting the data, we find some problems that need addressing:
# First, there is an entry for height which says "sixty" instead of a number. 
# Does that mean it should be a numeric 60? It somehow doesn't make
# sense since the weight is 60kg, which can't happen for a 60cm person (a baby)
# Since we don't know how to fix this, we might decide to remove the person.
# This "sixty" entry also turned all Height entries into characters instead of numeric.
# That conversion to character also means that our summary function isn't very meaningful.
# So let's fix that first.

d1 <- rawdata %>% dplyr::filter( Height != "sixty" ) %>% 
                  dplyr::mutate(Height = as.numeric(Height))


# look at partially fixed data again
skimr::skim(d1)
hist(d1$Height)


## ---- cleandata2 --------
# Now we see that there is one person with a height of 6. 
# that could be a typo, or someone mistakenly entered their height in feet.
# Since we unfortunately don't know, we might need to remove this person, which we'll do here.
d2 <- d1 %>% dplyr::filter(Height != 6)

#height values seem ok now
skimr::skim(d2)


## ---- cleandata3 --------
# now let's look at weight
# there is a person with weight of 7000, which is impossible,
# and one person with missing weight.
# to be able to analyze the data, we'll remove those individuals as well
d3 <- d2 %>%  dplyr::filter(Weight != 7000) %>% tidyr::drop_na()
skimr::skim(d3)


## ---- cleandata4 --------
# last problems is that Sex should be a categorical/factor variable
# we can do that with simple base R code to mix things up
d3$Sex <- as.factor(d3$Sex)  
skimr::skim(d3)


## ---- cleandata5 --------
#now we see that there is another NA, but it's not "NA" from R 
#instead it was loaded as character and is now considered as a category
#well proceed here by removing that individual
#since this keeps an empty category for Sex, I'm also using droplevels() to get rid of it
d4 <- d3 %>% dplyr::filter(Sex != "NA") %>% droplevels()
skimr::skim(d4)



## ---- savedata --------
# all done, data is clean now. 
# Let's assign at the end to some final variable
# makes it easier to add steps above
processeddata <- d4
# location to save file
save_data_location <- here::here("data","processed_data","processeddata.rds")
saveRDS(processeddata, file = save_data_location)



## ---- notes --------
# anything you don't want loaded into the Quarto file but 
# keep in the R file, just give it its own label and then don't include that label
# in the Quarto file

# Dealing with NA or "bad" data:
# removing anyone who had "faulty" or missing data is one approach.
# it's often not the best. based on your question and your analysis approach,
# you might want to do cleaning differently (e.g. keep individuals with some missing information)

# Saving data as RDS:
# I suggest you save your processed and cleaned data as RDS or RDA/Rdata files. 
# This preserves coding like factors, characters, numeric, etc. 
# If you save as CSV, that information would get lost.
# However, CSV is better for sharing with others since it's plain text. 
# If you do CSV, you might want to write down somewhere what each variable is.
# See here for some suggestions on how to store your processed data:
# http://www.sthda.com/english/wiki/saving-data-into-r-data-format-rds-and-rdata



