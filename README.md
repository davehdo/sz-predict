# sz-predict
This is my entry for the American Epilepsy Society Seizure Prediction Challenge (Kaggle.com)

## How it works
This extracts several features based on a FFT, and trains a random forest classifier 

## The EEG data
The training and test data sets are not included here. They are recorded from implanted electrodes in animal subjects. It may be useful to note that each subject has a different electrode configuration and localization of epilepsy, so the algorithm should be invariant to electrode (or channel) number.

## Getting started
1. Download data from Kaggle.com
2. Run main.m
