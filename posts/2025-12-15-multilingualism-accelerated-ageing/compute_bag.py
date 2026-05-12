import numpy as np
import pandas as pd
import random
import warnings

from scipy.stats import linregress
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from skopt import BayesSearchCV
from skopt.space import Integer, Real

def Regression_GBR(data, predictors, outcome, block, n_inner_splits = 5, random_seed = None):
    """
    Compute BAGs and correct them for regression to the mean.
    The BAGs computed are out-of-fold predictions produced
    by gradient boosting.
    Blocked cross-validation (leave-one-country-out) was used;
    hyperparameters were tuned within each run using n_inner_splits-fold cross-validation.
    
    :param X: Predictor variables.
    :param y: Outcome variable.
    :param block: Block variable.
    :param n_inner_splits: Number of inner splits used during hyperparameter tuning.
    """
    if (random_seed is not None):
        random.seed(random_seed)

    blocks = set(data[block])

    y_labels = []
    y_predicts = []
    y_pred_ = []
    y_test_ = []
    results_labels_df = pd.DataFrame(columns= list(data.columns) + ['predicted_age', 'GAP', 'GAP_corrected'])
    
    scaler = MinMaxScaler((0.05, 0.95))
    param_space = {
        'n_estimators': Integer(50, 500),  
        'learning_rate': Real(0.01, 0.5, prior='log-uniform'),  
        'max_depth': Integer(1, 5),               
        'min_samples_split': Integer(2, 10),      
        'min_samples_leaf': Integer(1, 10),      
    }
    model_hyper = GradientBoostingRegressor(loss = 'squared_error')
    bayes_search = BayesSearchCV(
        estimator = model_hyper,
        search_spaces = param_space,
        n_iter = 3,             
        scoring = 'neg_mean_squared_error', 
        cv = n_inner_splits,                  
        n_jobs = -1
    )
    
    iter_ = 1
    for current_block in blocks:
        warnings.filterwarnings("ignore") # refactor to get rid of warnings
        print(f"Block {iter_} of {len(blocks)} left out: {current_block}.")
        in_fold = data[data[block] != current_block]
        oof = data[data[block] == current_block]
        
        X_train, X_test = in_fold[predictors], oof[predictors]
        y_train, y_test = in_fold[outcome], oof[outcome]
        
        # Scale
        scaling_data = scaler.fit_transform(X_train)
        X_train = pd.DataFrame(scaling_data, columns = X_train.columns, index = X_train.index)
        scaling_data = scaler.transform(X_test)
        X_test = pd.DataFrame(scaling_data, columns = X_test.columns, index = X_test.index)

        print("    Tuning hyperparameters...")
        X_train_hyper, _, y_train_hyper, _ = train_test_split(X_train, y_train, test_size = 0.2)
        bayes_search.fit(X_train_hyper, y_train_hyper)
        
        print("    Fitting model...")
        model = GradientBoostingRegressor(**bayes_search.best_params_)
        model.fit(X_train, y_train)
        predicted_values = model.predict(X_test)
        y_labels.extend(list(y_test))
        y_predicts.extend(list(predicted_values))
        y_pred_.extend(list(predicted_values))
        y_test_.extend(y_test)

        # unadjusted BAG
        gap_test = predicted_values - y_test

        print("    Correcting BAGs for linear regression to the mean...")            
        gap_train = model.predict(X_train) - y_train
        slope, intercept, _, _, _ = linregress(y_train, gap_train)
        corrected_gap = gap_test - (intercept + slope * y_test)

        result = np.column_stack((oof, model.predict(X_test), gap_test, corrected_gap))
        temp_df = pd.DataFrame(result, columns= list(oof.columns) + ['predicted_age', 'GAP', 'GAP_corrected'])
        results_labels_df = pd.concat([results_labels_df, temp_df], ignore_index = True)

        iter_ += 1
    
    return results_labels_df

if __name__ == "__main__":
    print("Reading in data...")
    data = pd.read_csv("data/data.csv", index_col = 0)
    vars_list = ['Sex_1F_2M', 'Education', 'Barthel', 'Diabetes_1Y_0N', 'Hypertension_1Y_0N',
                 'Heart_Disease_1Y_0N', 'Physical_activity_1Y_0N', 'Cognition', 'Well_being_domain',
                 'Sleep_problems_1Y_0N', 'Audition_problems', 'Vision_problems']
    
    # No country-level data available for Slovak Republic in supplementary materials.
    data = data[data["country"] != "Slovak Republic"]

    print("Computing and correcting BAGs...")
    results = Regression_GBR(data, predictors = vars_list, outcome = "Age", block = "country", n_inner_splits = 5)
    results.to_csv("data_predictions.csv", index = False)
    print("Results stored to data_predictions.csv.")