# Surviving the Titanic - Analysis

## BACKGROUND
I will use machine learning to develop a predictive model to determine who would have survived the Titanic. The British passenger liner tragedy stands out in history as one of the deadliest commercial maritime disasters during peacetime. More than half of the passengers and crew died, due in large part to poor safety standards, such as not having enough lifeboats or not ensuring all lifeboats were filled to capacity during evacuation.

### ABOUT THE DATASET
The dataset contains information about the passengers on the Titanic, the British passenger liner that crashed into an iceberg during its maiden voyage and sank early in the morning on April 15, 1912. This dataset presents the most up-to-date knowledge about the passengers that were on the Titanic, including whether or not they survived. The dataset was downloaded from Kaggle.com and has already been split into a training set (in the train.csv file) and test set (in the train.csv file).

The dataset contains the following variables:

| Variable    | Description                                                           |
| :-----------| :-------------------------------------------------------------------- |
| `PassengerId`    | A unique number identifying each passenger.                          |
| `Survived`  | Whether this passenger survived (0 = No; 1 = Yes). (This variable is not present in the test dataset file.)                     |
| `Pclass`    | Passenger Class (1 = 1st; 2 = 2nd; 3 = 3rd)                           |
| `Name`      | Name                                                                  |
| `Sex`       | Sex                                                                   |
| `Age`       | Age                                                                   |
| `SibSp`     | Number of Siblings or Spouses Aboard                                     |
| `Parch`     | Number of Parents or Children Aboard                                     |
| `Ticket`    | Ticket Number                                                         |
| `Fare`      | Passenger Fare (British pound)                                        |
| `Cabin`     | Cabin                                                                 |
| `Embarked`  | Port of Embarkation (C = Cherbourg; Q = Queenstown; S = Southampton)  |


Also note that the following definitions were used for `SibSp` and `Parch`:

| Label        | Definition                                                                   |
| :----------- | :--------------------------------------------------------------------        |
| Sibling      | Brother, Sister, Stepbrother, or Stepsister of Passenger Aboard Titanic      |
| Spouse       | Husband or Wife of Passenger Aboard Titanic (Mistresses and Fiances Ignored) |
| Parent       | Mother or Father of Passenger Aboard Titanic                                 |
| Child        | Son, Daughter, Stepson, or Stepdaughter of Passenger Aboard Titanic          |

## PROCESS
**Question of Interest:** Who would have survived the Titanic?

**Overview**: I conducted my entire analysis, made predictive models, and created all visuaizations using R. I first took a look at how the chance of survival was affected by different continuous variables (age and fare), and then I observed how different categorical variables affected the passengers' survival chance. After acquiring some information regarding the most influencing variables on survival, I created three logical regression models to potentially find a cause and effect relationship between variables, but also to forecast future opportunities and threats.

## DATA CLEANING
Because we used read_csv to read the train.csv file, some of the columns were converted into inconvenient data types. I fixed this by doing the following:
- Convert Pclass to the character data type
- Convert SibSp to the character data type
- Convert Parch to the character data type
- After you get the inputs to read_csv() to work correctly, assign the dataset to a variable called train_df

I also added a column to train_df containing a new variable called did_survive. Using the as.logical function, Survived column was converted to the logical datatype.
- Ensure that the dataset contains both the original Survived column as well as the new did_survive column.
- Store this in the same train_df variable

## DATA ANALYSIS

**Observe how the chance of survival is affected by fare and age (continuous variables)**
```
train_df %>%
pivot_longer(cols = Fare|Age, names_to="variable", values_to = "value") %>%
ggplot() +
geom_histogram(
mapping=aes(x = value, fill = did_survive),
position = "identity",
alpha = 0.4) +
facet_wrap(~variable, scales = "free")
```

![image](https://user-images.githubusercontent.com/106201440/225178489-8739335d-1813-4bcf-9726-e98e4227efee.png)

*Interpretation: Looking at the graphs above, the passengers had a higher probability of survival when they are between 20 and 40 years old. For the Fare variable, we can observe a higher probability of survival when the ticket price was below 50 pounds. Both distributions showed a larger quantity of passengers who did not survive despite of their ages or fare. Although I dont’t believe a single observation provide us enough information to predict survival rates just yet, these differences can
be helpful for getting a picture about who survived.*

**Observe how the chance of survival is affected by different categorical variables (number of parents or children aboard, passenger's class, sex, and number of siblings or spouses aboard)**
```
train_df %>%
pivot_longer(cols = Pclass|Sex|Parch|SibSp, names_to="variable", values_to = "value") %>%
ggplot() +
geom_bar(aes(x = value, fill = did_survive)) +
facet_wrap(~variable, scales = "free")
```
![image](https://user-images.githubusercontent.com/106201440/225178977-268cef29-4191-48ab-9752-7c774504d471.png)

*Interpretation: Both the Pclass (passenger’s class) and Sex variables contributed to an individual’s chance of survival, while the SibSp (Number of Siblings or Spouses Aboard) and Parch didn’t have much impact on survival rates, at least as separate variables. Perhaps, if we analyze SibSp and Parch as combined feature, we would be able to observe more significant differences. The categorical variables Sex and Pclass have the most noticeable differences in their distributions; therefore,
these will be the most useful for predicting survival.*

**Observe how the interaction of gender and passenger class affected survival**

```
train_df %>%
ggplot() +
geom_mosaic(mapping = aes(x = product(Sex, Pclass), fill = Sex)) +
facet_grid(. ~ did_survive, scales="free") +
labs(
x = "Passenger class",
y = "Gender",
title = "Mosaic plot of who survived the Titanic")
```

![image](https://user-images.githubusercontent.com/106201440/225181229-4d99c6d3-ed2c-4556-974d-1c7b7cbb08fd.png)

*Interpretation: For both male and female passengers, ticketed class appears to have a strong influence on the relationship with survival. The mosaic plot above shows a visible relationship between passenger class, sex, and survival. Although there were several more men than women in the Titanic, a proportionally larger amount of females  survived.*

Considering that the Age column contains a large amount of missing data, **calculate the amount of missing data**

```
train_df %>%
summarize(
count = n(),
missing = sum(is.na(Age)),
fraction_missing = missing/count
)
```
![image](https://user-images.githubusercontent.com/106201440/225182160-fa1b8671-2165-405b-8530-8636a20375c5.png)

The predictive models we wish to use cannot be trained with missing data; therefore, we need to fill in the missing data with best guesse or estimates. **To impute the missing ages, mutate a new column, age_imputed using an if_else function** 

```
train_imputed <- train_df %>%
mutate(
age_imputed = if_else(
condition = is.na(Age),
true = median(Age, na.rm = TRUE),
false = Age
)
)
```
*Interpretation: I decided to replace the missing ages with the median of the non-missing ages. This will consequently lead to a large amount of error in our imputed values, but it has the advantage of being simple to implement.

**Check to see if there is now any missing data by running train_imputed**

```
train_imputed %>%
summarize(
count = n(),
missing = sum(is.na(age_imputed)),
fraction_missing = missing/count
)
```
![image](https://user-images.githubusercontent.com/106201440/225183612-84809e87-cd6b-4aeb-8325-5a3c15462f0f.png)


**Create first logistic regression model using the train_imputed dataframe with the Survived column as the response variable and age_imputed as the explanatory variable**
```
model_1 <- glm(
Survived ~ age_imputed,
family = binomial (),
data = train_imputed
)
```

**Calculate my first model's predictions on the training data (train_imputed)**

*Notes: Store the output dataframe with the 2 new columns: pred and outcome in a variable called model_1_preds*

```
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
)
```
**Calculate the accuracy of my first model on the train_imputed dataframe**
```
model_1_preds %>%
mutate(
correct = if_else(
condition = Survived==outcome,
true = 1,
false = 0
)
) %>%
summarize(
total_correct = sum(correct),
accuracy = total_correct/n()
)
```
![image](https://user-images.githubusercontent.com/106201440/225184211-db318853-b749-4d5a-8c60-ddafb12c7c2b.png)

*Interpretation: The accuracy of my model is 0.6156 or 61.6%, and I can say that is **good** considering that it correctly predicted that 61% of the passengers died. IN the RMS Titanic, there was an estimated 2,224 passengers and crew aboard the ship, and more than 1,500 died, yielding a death rate of 66%.**

**Use k-fold cross-validation to measure our model's performance on data that is has not seen**
```
logistic_cv1 <- cv.glm(train_imputed, model_1, cost, K=5)
logistic_cv1$delta
```
![image](https://user-images.githubusercontent.com/106201440/225464838-72cb5db0-b015-4e1f-b9c9-8b22e97bf47a.png)

**Train a second, multivariate logistic regression model, using the age_imputed, SibSp, Pclass, and Sex variables as predictor variables**
```
model_2<- glm(
Survived ~ age_imputed + SibSp + Pclass + Sex,
family = binomial (),
data = train_imputed
)
```

**Run cross-validation on second model to calculate its error**
```
logistic_cv2 <- cv.glm(train_imputed, model_2, cost, K=5)
logistic_cv2$delta
```
![image](https://user-images.githubusercontent.com/106201440/225464994-e3b2354a-b05e-4b09-9644-acde18069de7.png)

**Train a third logistic regression model with interaction between some of the variables**
```
model_3<- glm(
Survived ~ age_imputed * Pclass * Sex + SibSp,
family = binomial (),
data = train_imputed
)
```

**Run cross-validation on third model to calculate its error**
```
logistic_cv3 <- cv.glm(train_imputed, model_3, cost, K=5)
logistic_cv3$delta
```

*Interpretation: model_3 has the most accurate and smallest validation error. Since we are training on more data for our third model, this is expected as the predictive power of a model usually increases with its complexity. 



