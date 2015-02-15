x <- matrix(c(4,2,7,6), nrow=2, ncol=2)
y <- makeCacheMatrix(x)
z <- cacheSolve(y)
print(z)
z <- cacheSolve(y)
print(z)
m = x %*% z
print(m)
y$set(matrix(c(3,2,7,6), nrow=2, ncol=2))
z <- cacheSolve(y)
print(z)
m = y$get() %*% z
print(m)