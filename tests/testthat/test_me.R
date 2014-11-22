# Generate some data to test on
x <- rnorm(100, 0, 1)
y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)

# Test the lmspline function:

# Run some tests on the number of knots
test_that("num knots is positive", {
	expect_error(lmspline(x, y, nknots = -1), 'The number of knots must be a positive integer.')
})
test_that("num knots is an integer", {
	expect_error(lmspline(x, y, nknots = 3.14), 'The number of knots must be a positive integer.')
})
test_that("num knots is numeric", {
	expect_error(lmspline(x, y, nknots = "foo"), 'The number of knots must be a numeric value.')
})

# Run a test on the output
test_that("return value is a list", {
	expect_is(lmspline(x, y, 2), "list")
})

# Run a test on the input
test_that("x values were given", {
	expect_error(lmspline(y = y, nknots = 2), 'argument "x" is missing, with no default')
})
test_that("y values were given", {
	expect_error(lmspline(x, nknots = 2), 'argument "y" is missing, with no default')
})

# Test the pred.spline function:

lspline <- lmspline(x, y, 2)

# Run a test on the output
test_that("return values are numeric", {
	expect_is(pred.spline(x, lspline), "numeric")
})

# Run a test on the input
test_that("x values were given", {
	expect_error(pred.spline(lspline = lspline), 'argument "x" is missing, with no default')
})
test_that("lspline object was given", {
	expect_error(pred.spline(x), 'argument "lspline" is missing, with no default')
})
