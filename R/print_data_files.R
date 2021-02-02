library(tidyr)

print_connectivity_graph <- function(num_epochs, num_hosts, prefix_ofn){
    for(i in sort(1:(num_epochs), decreasing = TRUE)){
        conn_mat <- matrix(0, nrow = num_hosts, ncol = num_hosts)
        conn_mat[1:i, 1:i] <- 1
        ofn <- paste0(prefix_ofn, ".", i, ".txt")
        write.table(conn_mat, file = ofn, row.names=F, col.names=F)
    }
}


print_host_distance_matrix <- function(host_tree) {
}

print_epoch_times <- function(host_tree, outfn) {
    br_times <- sort(c(0.0, ape::branching.times(host_tree)), decreasing = TRUE)
    br_times_mat <- matrix(nrow = length(br_times), ncol = 2)
    br_times_mat[,1] <- br_times
    br_times_mat[,2] <- br_times - (br_times*0.05)
    write.table(br_times_mat, file = brtimes_out_fn, row.names=F, col.names=F)
}

# read in species trees to get the min and max ages of "epochs"
print_nexus_range <- function(fn, cophylo){
    lines_vector <- c("#NEXUS\n\n", "Begin data;")
    pruned_host <- treeducken::host_tree(cophylo) %>%
                    treeducken::drop_extinct()
    nranges <- length(pruned_host$tip.label)
    pruned_symb <- treeducken::symb_tree(cophylo) %>%
        treeducken::drop_extinct()
    nsymb <- length(pruned_symb$tip.label)

    line <- paste0("Dimensions ntax =", nsymb, " nchar =", nranges, ";")
    lines_vector <- c(lines_vector, line,
                      "Format datatype=Standard missing=? gap=- labels=\"01\";",
                      "Matrix")

    hosts <- pruned_host$tip.label
    symbs <- pruned_symb$tip.label

    symbs <- stringr::str_replace(symbs, "([0-9]+)", "_\\1")
    association_matrix <- treeducken::association_mat(cophylo)
    rownames(association_matrix) <- symbs
    line <- paste0("\t\t\t", "[", stringr::str_flatten(as.character(hosts)), "]")
    lines_vector <- c(lines_vector, line)

    for(i in seq_len(length(symbs))){
        print(association_matrix[symbs[i],])
        host_repertoire <- association_matrix[symbs[i],]
        line <- paste0("\t", symbs[i], "\t",  stringr::str_flatten(as.character(host_repertoire)))
        lines_vector <- c(lines_vector, line)
    }
    lines_vector <- c(lines_vector, "\t;", "\nEnd;")
    readr::write_lines(lines_vector, file = fn)
}
