## These functions create a special matrix object for the purpose
## of efficiently retrieving the inverse of that matrix.

## makeCacheMatrix creates the special matrix object and has four
## methods: set, get, setinverse, getinverse.
##
##    Example: a=matrix(c(1,2,3,4),nrow=2,ncol=2)
##             b<-makeCacheMatrix(a)

makeCacheMatrix <- function(x = matrix()) {
  z <- NULL
  set <- function(y) {
    x <<- y
    z <<- NULL
  }
  get <- function() x
  setinverse <- function(inverse) z <<- inverse
  getinverse <- function() z
  list(set = set, get = get,
       setinverse = setinverse,
       getinverse = getinverse)
}


## cachesolve either calculates the inverse of the special
## matrix object or retrieves it from the environment(cache)
##
##    Example: b=makeCacheMatrix(a)
##             c=cacheSolve(b)

cacheSolve <- function(x, ...) {
  ## Return a matrix that is the inverse of 'x'
  z <- x$getinverse()
  if(!is.null(z)) {
    print(z)
    message("getting cached data")
    return(z)
  }
  data <- x$get()
  z <- solve(data)
  x$setinverse(z)
  return(z)
}
