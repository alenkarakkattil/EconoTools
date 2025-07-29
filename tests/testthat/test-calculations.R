# Load the testthat library
library(testthat)
# Load the package being tested (or use devtools::load_all())
library(EconoTools)

context("Testing calculation functions")

test_that("calculate_sma works correctly", {
  # Create a simple test data frame
  test_data <- data.frame(date = seq.Date(from = as.Date("2023-01-01"), by = "day", length.out = 10),
                          value = c(10, 12, 11, 15, 14, 16, 18, 20, 19, 22))

  # Calculate SMA with window size 5
  result <- calculate_sma(test_data, n = 5)

  # Check that the output is a data frame
  expect_s3_class(result, "data.frame")

  # Check that the 'sma' column was added
  expect_true("sma" %in% names(result))

  # Check the first few NA values
  expect_true(all(is.na(result$sma[1:4])))

  # Check the first calculated SMA value
  # (10+12+11+15+14)/5 = 12.4
  expect_equal(result$sma[5], 12.4)

  # Check the last calculated SMA value
  # (14+16+18+20+19+22)/5 -> (16+18+20+19+22)/5 = 19
  expect_equal(result$sma[10], 19)
})

test_that("calculate_sma handles errors", {
    # Test for not enough observations
    test_data_short <- data.frame(value = 1:3)
    expect_error(calculate_sma(test_data_short, n = 5),
                 "Not enough observations to calculate moving average of size n.")

    # Test for incorrect data structure
    expect_error(calculate_sma(list(value = 1:10), n = 5),
                 "'data' must be a data frame with a 'value' column.")
})