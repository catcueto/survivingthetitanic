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
*Overview*: I conducted my entire analysis, made predictive models, and created all visuaizations using R. I first took a look at how the chance of survival was affected by different continuous variables (age and fare), and then I observed how different categorical variables affected the passengers' survival chance. After acquiring some information regarding the most influencing variables on survival, I created three logical regression models to potentially find a cause and effect relationship between variables, but also to forecast future opportunities and threats.

## DATA CLEANING
Because we used read_csv to read the train.csv file, some of the columns were converted into inconvenient data types. I fixed this by doing the following:
- Convert Pclass to the character data type
- Convert SibSp to the character data type
- Convert Parch to the character data type
- After you get the inputs to read_csv() to work correctly, assign the dataset to a variable called train_df

I also added a column to train_df containing a new variable called did_survive. Using the as.logical function, Survived column was converted to the logical datatype.
- Ensure that the dataset contains both the original Survived column as well as the new did_survive column.
- Store this in the same train_df variable
