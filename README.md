### Overview:
- This project uses Stata to simulate survey data and to evaluate the treatment effects of two different advertisement campaigns ("Reason" and "Emotions") on COVID-19 vaccination uptake. 

- The simulation process involves creating baseline demographics and vaccination status, randomizing treatment assignments, simulating endline vaccination outcomes. Finally, the project conducts statistical analysis to assess the treatment effects.


### Author:
- Name: Zerui Wu
- Date: 04/06/2025


### Requirements:
- Software: Stata 16 SE or later
- No additional packages required, except for `esttab` and `coefplot` for exporting and plotting regression results


### File Structure:
- `/raw_data/`: Contains the simulated baseline, randomization, and endline datasets.
- `/clean_data/`: Stores the merged final dataset used for analysis.
- `/output/`: Stores generated figures and regression tables.
- `stata code_Zerui Wu.do`: The Stata code that runs the full pipeline.
- `data task report_Zerui Wu.pdf`: The PDF printout that reports (1) processes and assumptions for the data simulation, (2) process for merging three simulated datasets, and (3) the analysis of treatment evaluation.


### How to Run the Pipeline:
- (1) Open Stata do file `stata code_Zerui Wu.do`.
- (2) Set the working directory to match the project folder: `cd "/your/local/path/to/data_task"`
- (3) Keep the seed as 1 before each data simulation in the given block.
- (4) Run the Stata code blocks in order. The simulation is run by the order. Note that if you are interested in the part of analysis, please go to `Analyze Treatment Effect`, and use `clean_data/final_data_clean.dta` for Figure 1, Figure 2, and Table 1. 


### Data Descriptions:
**Baseline Survey Data**: Stored at `raw_data/survey_data_baseline.dta`.
- 5,000 individuals are simulated.
- Variables include:
  `id`: Unique identifier.
  
  `vac_takeup0`: Baseline vaccination status. Bernoulli variable with p = 0.3.
  
  `age`: Age. Uniformly distributed from 18 to 80
  
  `female`: Female dummy. Bernoulli variable with p = 0.5
  
  `edu`: Education level derived from uniform distribution: (1) 10% Less than High School (2) 30% High School (3) 20% Some College (4) 40% College or higher.
  
  `college`: Binary indicator for College+.
  

**Randomization Data**: Store at `raw_data/randomization_data.dta`.
- 5,000 individuals are simulated.
- `id`: Unique identifier.
- `Treatment`: Treatment assignment is divided evenly into three groups: (1) Reason Ad, (2) Emotions Ad, and (3) Control.

**Endline Survey Data**: Store at `raw_data/survey_data_endline.dta`.
- A random sample of 4,500 individuals is selected to simulate attrition.
- `id`: Unique identifier.
- `vac_takeup1`: Endline vaccination status is generated based on: (1) If vaccinated at baseline: remains vaccinated;  (2) If not, probability of endline vaccination depends on treatment group: Reason: 55% of vaccination, Emotions: 70% of vaccination, and Control: 30% of vaccination.


### Merging Datasets: 
- Merge baseline data with randomization data using `id` as key (1:1 merge).
- Merge the above result with endline data on `id`.
- Drop 500 unmatched observations (treated as attrition).
- Final merged dataset saved in `clean_data/final_data_clean.dta`.


### Analysis:
**Balance Check**
- (Lines 204–213) One-way ANOVA and Chi-squared tests confirm that baseline characteristics (age, gender, college education, and vaccination status) are well balanced across the three treatment groups.

**Treatment Effects**

(1). (Lines 216-220) Check for Equality of Group Proportion (Endline):
- Chi-squared test shows significant differences in vaccination rates at endline across groups (p < 0.001).

(2). (Lines 279 - 297) Regression (LPM) with robust SE:
- Outcome: endline vaccination status
- Interested Variables: treatment
- Controls: age, gender, college, baseline vaccination status
- Regression results exported to `output/table_regression.tex`


### Output:
- Figure 1: Bar chart comparing baseline and endline vaccination rates across groups, with 95% confidence intervals. Saved at `output/figure_bar_graph_treatment_effects.png`
- Figure 2: Coefficient plot showing estimated treatment effects (with 95% CIs) for two campaigns from the LPM. Saved at: `output/figure_coefficients_treatment_effects.png`
- Table 1: Regression table. Save at `output/table_regression.tex`.


### Notes:
- Random seed (set seed 1) is set for reproducibility.
