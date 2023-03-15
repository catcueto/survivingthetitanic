#--------------------------------------------FINAL ANALYSIS------------------------------------------

#install packages
install.packages("tidyverse") #calculations
install.packages("ggmosaic")

#load libraries 
library(tidyverse)
library(ggmosaic)

#load original .csv files, change columns to character data type to avoid running into problems when analyzing data
train_df <- read_csv(file = "train.csv",
col_types = cols(
Pclass = col_character(),
SibSp = col_character(),
Parch = col_character()
))

#add a column with a new variable called did_survive, and convert the Survived column to the logical datatype
train_df <- train_df %>%
mutate(
did_survive = as.logical(Survived)
)

#observe how the chance of survival is affected by different continuous variables
pivot_longer(cols = Fare|Age, names_to="variable", values_to = "value") #continuous explanatory variables %>%
ggplot() +
#create a histogram of the distributions depending on whether the passengers survived or not
train_df %>%
geom_histogram(
mapping=aes(x = value, fill = did_survive), #add fill to produce an effective viz
position = "identity",
alpha = 0.4) +
facet_wrap(~variable, scales = "free")

#observing how the chance of survival is affected by different variables will allow us to determine which variables are most useful for predicting survival
#observe how the chance of survival is affected by different categorical variables
train_df %>%
pivot_longer(cols = Pclass|Sex|Parch|SibSp, names_to="variable", values_to = "value") %>%
ggplot() +
geom_bar(aes(x = value, fill = did_survive)) +
facet_wrap(~variable, scales = "free")

#investigate the interaction (potential interrelatedness) between two categorical variables: gender and passenger. How does   how one categorical variable affects the distribution of another categorical variable
train_df %>%
ggplot() +
geom_mosaic(mapping = aes(x = product(Sex, Pclass), fill = Sex)) +
facet_grid(. ~ did_survive, scales="free") +
labs(
x = "Passenger class",
y = "Gender",
title = "Mosaic plot of who survived the Titanic")

#calculate amount of missing data in the Age column
train_df %>%
summarize(
count = n(),
missing = sum(is.na(Age)),
fraction_missing = missing/count
)

#imputation process: filling in the missing data with best guesses/estimates
train_imputed <- train_df %>%
mutate(
age_imputed = if_else(
condition = is.na(Age),
#replace missing ages with the median of non-missing ages
true = median(Age, na.rm = TRUE),
false = Age
)
)

#checking to see if there is any missing data in the new train_imputed dataframe
train_imputed %>%
summarize(
count = n(),
missing = sum(is.na(age_imputed)),
fraction_missing = missing/count
)

#create a first logistic regression model using the train_imputed dataframe with the Survived column as your response variable and age_imputed as the explanatory variable
model_1 <- glm(
Survived ~ age_imputed,
family = binomial (),
data = train_imputed
)

# calculate our model's predictions on the training data (train_imputed)
# store the output dataframe with the 2 new columns: pred and outcome in a variable called model_1_preds
model_1_preds <- train_imputed %>%
add_predictions(
model_1,
type = "response"
) %>%
mutate(
outcome = if_else(
condition = pred > 0.5,
true = 1,
false = 0
)

#calculate the accuracy of our model on the train_imputed dataframe
model_1_preds %>%
#create a new column: correct, then ompare the Survived and outcome columns
mutate(
correct = if_else(
condition = Survived==outcome,
#if they contain the same values, then you should put a 1 in the correct column. Otherwise, you should put a 0 in the correct column.
true = 1, 
false = 0
)
) %>%
summarize(
total_correct = sum(correct),
accuracy = total_correct/n() #calculate the accuracy as the number of passengers that we correctly predicted divided by the total number of passenger
)

#use k-fold cross-validation to measure our model's performance on data that is has not seen
logistic_cv1 <- cv.glm(train_imputed, model_1, cost, K=5) #3rd argument is a cost function to calculate the validation error, which calculates 1 - accuracy (i.e. the inaccuracy)
#K is the number of ways the dataset will be divived up for cross-validation

#save cross-validation output in a variable called logistic_cv1, and report its error
logistic_cv1$delta #delta contains the overall cross-validaton error score 
  
#create a second multivariate logistic regression model using the age_imputed, SibSp, Pclass, and Sex variables as predictor variables
model_2<- glm(
Survived ~ age_imputed + SibSp + Pclass + Sex,
family = binomial (),
data = train_imputed
)

 #run cross-validation on model_2 to calculate its error
logistic_cv2 <- cv.glm(train_imputed, model_2, cost, K=5)

#save cross-validation output in a variable called logistic_cv2, and report its error
logistic_cv2$delta

#create a third logistic regression model with interaction between some of the variables
model_3<- glm(
#observe if age interacts with gender and class on survival
Survived ~ age_imputed * Pclass * Sex + SibSp, #interacting variables: age_imputed, Pclass, and Sex
family = binomial (),
data = train_imputed
)

#run cross-validation on this model and report its error
logistic_cv3 <- cv.glm(train_imputed, model_3, cost, K=5)
logistic_cv3$delta


  
