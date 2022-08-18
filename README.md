# dataversionr
Create and maintain time-versioned datasets using `arrow`. 

## Installing

This package is not yet on CRAN. Install from github with `devtools::install_github("riazarbi/dataversionr")`.

## Using

This package allows you create, read, update and destroy time versioned datasets at `arrow` SubTreeFileSystem locations. 

At this time, `arrow` supports local disk, S3 API-compatible, and GCS endpoints as FileSystems. Our test suite only runs against local and S3 FileSystems but there is no reason a GCS endpoint should work any differently.

The most high-level functions in this package are intended to introduce as little additional overhead as possible over base `R` `read`, `write` and `unlink` functions:

- `create_dv` : Create a time versioned dataset on either a local hard drive or at an S3 location.
- `read_dv`: retrieve a dataset from the location. Specify a time in the past to obtain an historical version of the dataset.
- `update_dv`: write a new version of the dataset to the location.
- `destroy_dv`: completely erase the files at the location.

These high level functions make use of the other functions in this package to operate correctly. 

We have exported these other functions to the user because they allow for much more fine-grained access to the files that constitute a time versioned dataset. For help on these functions, refer to the documentation for each function, eg. `?get_diffs`.

Here's an example of how to use the above high level functions.

```r
library(dataversionr)
library(dplyr)
location <- tempfile()
new_df <- iris[1:5,3:5] %>% mutate(key = 1:nrow(.))
```

Create a dv:

```r
create_dv(new_df,
          location,
          key_cols = "key",
          diffed = TRUE,
          backup_count = 10L)
```

```
Checking that new_df can be diffed...
Diff test passed.
[1] TRUE
```

Update a dv:

```r
newer_df <- new_df
newer_df [1,1] <- 2
update_dv(newer_df, 
          location)
```

```
[1] TRUE
```

If we try update again:

```r
update_dv(newer_df, 
          location)
```

```
No changes detected. Exiting.
[1] FALSE
```


Delete a row and update:

```r
newest_df <- newer_df[2:5,]
update_dv(newest_df,
          location)
```

```
[1] TRUE
```

Read a dv:

```r
read_dv(location)
```

```
  Petal.Length Petal.Width Species key
1          2.0         0.2  setosa   1
2          1.4         0.2  setosa   2
3          1.3         0.2  setosa   3
4          1.5         0.2  setosa   4
5          1.4         0.2  setosa   5
```

Summarise diffs:

```r
summarise_diffs(location)

```

```
> summarise_diffs(location)
       diff_timestamp new modified deleted
1 2022-08-16 12:58:29   5       NA      NA
2 2022-08-16 12:59:14  NA        1      NA
3 2022-08-16 13:04:15  NA       NA       1
```

Or connect directly to the diff dataset:

```r
get_diffs(location)
```

```
       diff_timestamp operation Petal.Length Petal.Width Species key
1 2022-08-16 12:58:29       new          1.4         0.2  setosa   1
2 2022-08-16 12:58:29       new          1.4         0.2  setosa   2
3 2022-08-16 12:58:29       new          1.3         0.2  setosa   3
4 2022-08-16 12:58:29       new          1.5         0.2  setosa   4
5 2022-08-16 12:58:29       new          1.4         0.2  setosa   5
6 2022-08-16 12:59:14  modified          2.0         0.2  setosa   1
7 2022-08-16 13:04:15   deleted          2.0         0.2  setosa   1
```

Destroy a dv:

```r
destroy_dv(location, prompt = FALSE)
```

```
[1] TRUE
```

## Building and running tests

Clone this repo into a local environment. 

We use the `devtools` package to facilitate package development. Rstudio provides nice integration with this package. 

To initialise the environment, clone this repo into Rstudio and load it as your working project. In your R console - 


### Loading the package 
1. `library(devtools)`
2. To load the package via source, `load_all()`

### Create a function
3. To create a function `use_r("function_name")`
3. To document the function, put your cursor inside the function source code and navigate to Code -> Insert Roxygen Skeleton. Be sure to populate the template correctly. For more details on this, refer to the roxygen2 documentation. 
4. After you've documented the function, run `document()` to create the right documentation files and update your `NAMESPACE` file.
5. Once you are done, `load_all()` again.

### Testing
1. If you want to run additional tests against an S3 endpoint, set the environment variable `TEST_S3` to `TRUE`. `Sys.setenv(TEST_S3=TRUE)`. If you don't do this, you'll still run all the tests, but only against a local file path.
7. To create a test, `use_test("fuction_name")`. Write your test and save it. 
8. To run a test code coverage report `library(covr); cov <- package_coverage()`
9. Check which lines are not covered by your tests `zero_coverage(cov)`

### Checking
6. To check your package is well formed, run `rcmdcheck::rcmdcheck(repos = NULL)`. The `repos = NULL` is applicable if you are running in a firewalled environment like `tiro`.

### Creating a manual
10. To build a PDF manual - `devtools::build_manual()`

