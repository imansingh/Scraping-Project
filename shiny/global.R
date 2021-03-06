library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(DT)
library(data.table)
library(tm)
library(wordcloud)
library(memoise)

 string_data <- fread("string_data_wrangled.csv")

# string_data <- read.csv(file = "./stringforum.csv")

# UI
## Functions to generate checkboxinput items from dataframe columns

# text to show next to the 'none' checkbox
none_text = 'None Listed' 

# capitalize first letter of each word in a string
simpleCap = function(string){
  split_string = strsplit(string, ' ')[[1]]
  paste(toupper(substring(split_string, 1, 1)), substring(split_string, 2),
        sep = '', collapse = ' ')
}

# get checkbox items names if df column is a vector

get_checkbox_items_vec = function(string){
  raw_strings = unique(string_data[[string]][!is.na(string_data[[string]])])
  processed_strings = unname(sort(sapply(gsub('_', ' ', raw_strings), simpleCap)))
  return(c(sort(processed_strings), none_text))
}

# get checkboax item names if df column is a list
get_checkbox_items_list = function(string){
  raw_strings = unique(unlist(string_data[[string]]
                              [!is.na(string_data[[string]])]))
  processed_strings = unname(sapply(gsub('_', ' ', raw_strings), simpleCap))
  return(c(sort(processed_strings), none_text))
}

# ## models_by_manufacturer
# # Create nested list of racquet models by manufacturer
# models_by_manufacturer = list()
# for(manufacturer in unique(string_data$racquet_manufacturer[
#   string_data$racquet_manufacturer != ''])){
#   models_by_manufacturer[[manufacturer]] = 
#     sort(unique(string_data$racquet_model[
#       string_data$racquet_manufacturer == manufacturer]))
# }

adjectives_list = c('soft', 'comfortable', 'flexible', 'precise',
                   'resilient', 'explosive', 'innovative', 'unique',
                   'spongy', 'stiff', 'dull', 'lively', 'stretchy',
                   'crispy', 'boring', 'elastic', 'solid', 'rough',
                   'wire_like', 'springy', 'sluggish', 'outdated')

characteristics_list = c('comfort', 'control', 'durability', 'feel', 'power', 
                         'spin', 'tension_stability', 'overall_satisfaction')

# selection lists for string_material, string_construction and string_features
string_material_list =c( 'Aramid', 'Polyester', 'Co-Polyester', 'Polyamid', 
                         'Polyethylene', 'Polyurethane', 'Zyex', 'Natural Gut')

string_construction_list = c('Monofilament', 'Central Core with One Wrap',
                             'Central Core with Two Wraps', 'Multifilament',
                             'Ribbon Construction')

string_features_list = c('Structured Surface', 'Titanium Coating', 
                         'Titanium Fibers', 'Hybrid String')



brks_percentile = seq(5,95,5)
brks_z = qnorm(seq(.05,.95,.05))


clrs <- c(
  round(seq(40, 255, length.out = 10), 0) %>%
  {paste0("rgb(255,", ., ",", ., ")")},
  round(seq(255, 40, length.out = 10), 0) %>%
  {paste0("rgb(", ., ",255,", ., ")")}
)

## Create nested list of racquet models by manufacturer
models_by_manufacturer = list()
for(manufacturer in unique(string_data$racquet_manufacturer[
  string_data$racquet_manufacturer != ''])){
  models_by_manufacturer[[manufacturer]] = 
    sort(unique(string_data$racquet_model[
      string_data$racquet_manufacturer == manufacturer]))
}

## get_adjective_pct
# create vec that gives percentage of of strings in vec that match

get_adjective_pct = function(string_list, str_to_match){
  sapply( # this takes list of logical vectors and divides sum/length to get pct
    sapply(string_list[!(is.na(string_list))],  # this returns list of logical vectors
           function(string_vec) grepl(str_to_match, string_vec)),
    function(logical_vec) round(sum(logical_vec)/length(logical_vec) * 100, 1))
}



# #creating dataframes with mean values per group
# string_means = string_grouped %>% summarise(reviews = n(), comfort = mean(comfort, na.rm=TRUE), control = mean(control, na.rm=TRUE), durability = mean(durability, na.rm=TRUE), feel = mean(feel, na.rm=TRUE), power = mean(power, na.rm=TRUE), spin = mean(spin, na.rm=TRUE), tension_stab = mean(tension_stability, na.rm=TRUE), satisfaction = mean(tester_satisfaction, na.rm=TRUE))
# tester_means = tester_grouped %>% summarise(reviews = n(), comfort = mean(comfort, na.rm=TRUE), control = mean(control, na.rm=TRUE), durability = mean(durability, na.rm=TRUE), feel = mean(feel, na.rm=TRUE), power = mean(power, na.rm=TRUE), spin = mean(spin, na.rm=TRUE), tension_stab = mean(tension_stability, na.rm=TRUE), satisfaction = mean(tester_satisfaction, na.rm=TRUE))
# racquet_means = racquet_grouped %>% summarise(reviews = n(), comfort = mean(comfort, na.rm=TRUE), control = mean(control, na.rm=TRUE), durability = mean(durability, na.rm=TRUE), feel = mean(feel, na.rm=TRUE), power = mean(power, na.rm=TRUE), spin = mean(spin, na.rm=TRUE), tension_stab = mean(tension_stability, na.rm=TRUE), satisfaction = mean(tester_satisfaction, na.rm=TRUE))

# #cleaning up the grouped means - removing meaningless/generic racquet types and anonymous reviews
# tester_means_clean = tester_means %>% filter(str_detect(tester_name, 'anonymous') == FALSE)
# racquet_means_clean = racquet_means %>% slice(30:1382)
# 
# #dataframes with detailed review info
# detailed_reviews = string_data %>% select(string_name, price, tester_name, tester_racquet, tester_tension, tester_style, review_text, review_adjectives, comfort, control, durability, feel, power, spin, tension_stability, tester_satisfaction)
# 
# genders = c('Male', 'Female')
