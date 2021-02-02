# read in species trees to get the min and max ages of "epochs"
print_nexus_range <- function(fn, host_tree, symb_tree){
    sink(fn)

    cat("#NEXUS\n\n")
    cat("Begin data;\n")

    nranges <- length(getExtant(host_tree, tol=1e-3))
    nsymb <- length(getExtant(symb_tree, tol=1e-3))

    line <- paste0("Dimensions ntax =", nsymb, " nchar =", nranges, ";\n")

    cat(line)
    cat("Format datatype=Standard missing=? gap=- labels=\"01\";\n")
    cat("Matrix\n")

    hosts <- getExtant(host_tree, tol=1e-3)
    symbs <- getExtant(symb_tree, tol=1e-3)
    for(i in 1:length(symbs)){
        # first need to figure out which species associated with
        curr_tip <- str_split(symbs[i], "_")
        sp_indx <- str_locate(hosts, curr_tip[[1]][1])
        sp_indx <- which(!is.na(sp_indx[,1]))
        # next mkae the bit vector and put into the thing
        range_data <- rep(0, times = nranges)
        range_data[sp_indx[1]] <- 1
        range_data_str <- str_flatten(str_c(range_data))

        # now print the data to nexus file
        line <- paste0("\t", symbs[i], "\t", range_data_str, "\n")
        cat(line)
    }
    cat("\t;")
    cat("\nEnd;")
    sink()
}