a <- data.frame(matrix(c(1,2,3,4,5,6),byrow = TRUE,ncol=3))
a <- a %>%
  pivot_longer(X3)
