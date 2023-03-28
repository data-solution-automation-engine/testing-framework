# Unit Testing Framework
An open-source testing framework that integrates with engine thinking.

---

# Overview

## Test library

The tests are functionally documented in Markdown format, and available in the 'test-library' directory in this repository.

## Test templates

The test code is generated, using the available design metadata that is already required to deliver the data solution. Test templates are therefore managed in the [Virtual Data Warehouse repository](https://github.com/data-solution-automation-engine/virtual-data-warehouse) (in 'templates').

All test templates are recommended to contain a link to the documentation in the test library.

## Data model

The data models for the testing framework are managed in the 'diagrams' directory in this repository.

## Code

The code and examples related to the testing framework are managed in the 'code' directory in this repository. It is expected that the tests are executed (using a wrapper of) a control framework, such as the [DIRECT framework](https://github.com/data-solution-automation-engine/DIRECT).

# Rationale

A testing framework for the engine serves the following purposes:

* To ensure knowledge that is developed as part of the design and implementation is embedded into a shared repository that is accessible to all interested parties
* That individual developers define and apply unit testing with auditable output
* To re-use tests as part of ongoing controls across the data solution, to ensure the solution continues to behave as per the expectations over the long term

A requirement is to have a central repository to which tests can be added (defined and automated). 

The idea is that tests are developed both as unit-tests (throughout the development process) or as a result of feedback or issues encountered during the management of the application. 

As a guideline, a test should be created every single time an exception has been encountered to make sure this specific scenario can be monitored in the future. 

Examples of test cases are:

* Checking data against domain values
* Detecting violation of uniqueness constraints or expectations
* Validating the completeness of timelines in the data (temporarily)
* Understanding if sales or volume is within a certain threshold (e.g. within two standard deviations of the mean) to detect outliers
* Checking if referential integrity has been satisfied

To integrate the testing framework with execution and monitoring (control), in an automated way, tests must be stored in a testing framework. 

This requires:

* A repository to store test cases
* An agreed format to write test cases
* A set of standard functions to evaluate the test cases (assertions, range checks, binary checks)
* A mechanism to call (run/execute) one or more test cases and display the results
