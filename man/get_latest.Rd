% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_latest.R
\name{get_latest}
\alias{get_latest}
\title{Get latest}
\usage{
get_latest(destination, collect = TRUE)
}
\arguments{
\item{destination}{a local directory path or an arrow SubTreeFileSystem}

\item{collect}{should we return a data frame (TRUE) or an arrow dataset connection (FALSE)}
}
\value{
a data frame or an arrow dataset
}
\description{
Read in the latest version of a versioned dataset to a data frame
}
\examples{
temp_dir <- tempfile()
dir.create(temp_dir, recursive = TRUE)
df <- data.frame(a = 1:5, b = letters[1:5])
put_latest(df, temp_dir)

get_latest(temp_dir)

unlink(temp_dir)

}
