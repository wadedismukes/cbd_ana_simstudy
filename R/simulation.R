## ----setup, include=FALSE---------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----parameters-------------------------------------------------------------------------------------------------------------------------------
library(treeducken)
library(stringr)
sb_sd_mat <- matrix(nrow = 10, ncol = 2)
sb_sd_mat[,1] <- c(0, 1, 2, 3, 1, 2, 3, 2, 3, 3) 
sb_sd_mat[,2] <- c(0, 0, 0, 0, 1, 1, 1, 2, 2, 3)
dispersal_extinction_pairs <- data.frame(sb_sd_mat)
colnames(dispersal_extinction_pairs) <- c("DispersalRates", "ExtirpationRates")
lambda_s <- 0.5
lambda_c <- 1
lambda_h <- 0.5
chi <- 2.0
mu_s <- 0.0
mu_h <- 0.0

time_to_sim <- 1

host_limit <- 2
number_to_sim <- 2


## ----simulation-------------------------------------------------------------------------------------------------------------------------------
sim_namer <- function(input_rates_matrix) {
    s <- vector(length = nrow(input_rates_matrix), mode = "character")
    for(r in seq_len(nrow(input_rates_matrix))) {
       s[r] <-  stringr::str_c("DR", input_rates_matrix[r, 1], "ER", input_rates_matrix[r, 2])
    }
    print(s)
    s
}

names_s <- sim_namer(sb_sd_mat)
names_s <- sort(rep(names_s, times = number_to_sim))
sims <- vector(length = length(names_s))
names(sims) <- as.list(names_s)
sims <- as.list(sims)
j <- 1
for(i in seq_len(length(sims))) {
    sims[[i]] <- sim_cophyBD_ana(hbr = lambda_h,
                                     hdr = mu_h,
                                     sbr = lambda_s,
                                     sdr = mu_s,
                                     cosp_rate = lambda_c,
                                     host_exp_rate = chi,
                                     host_limit = host_limit,
                                     s_disp_r = sb_sd_mat[j,1],
                                     s_extp_r = sb_sd_mat[j,2],
                                     time_to_sim = time_to_sim,
                                     numbsim = number_to_sim)
    dir.create(paste0("data/", names_s[i], "/", (i %% number_to_sim) + 1 , "/"), recursive = T)
    if(i == number_to_sim) {
        j <- j + 1
    }

}


## ----convert-cophylo-to-biogeo-like-----------------------------------------------------------------------------------------------------------
write_range_nexus <- function(A, sim_name, k ) {
    hosts <- names(A[,1])
    symbs <- names(A[1,])
    symb_names <- paste0(symbs, collapse="")
    n_hosts <- nrow(A)
    n_symbs <- ncol(A)
    lines <- "#NEXUS"
    lines <- c(lines, "Begin data;")
    lines <- c(lines, paste0("Dimensions ntax=", n_hosts, " nchar=", n_symbs))
    lines <- c(lines, "Format datatype=Standard missing=? gap=- labels=\"01\";")
    lines <- c(lines, "Matrix")
    l <- paste0("\t\t\t[", symb_names, "]")
    lines <- c(lines, l)
    for(i in seq_len(n_hosts)) {
        range <- vector(length = n_symbs)
        range <- ""
        for(j in seq_len(n_symbs)) {
            range <- c(range, as.character(A[i,j]))
        }
        range <- paste0(range, collapse="")
        lines <- c(lines, paste0("\t", hosts[i], "\t\t", unname(range)))
    }
    lines <- c(lines, "\t;")
    lines <- c(lines,"End;")
    readr::write_lines(x = lines,
                       file = paste0("data/", sim_name, "/", k, "/", 
                                     sim_name, "_range.nex"))
}


## ---------------------------------------------------------------------------------------------------------------------------------------------
write_times <- function(host_tre, sim_name, j) {
    br_times <- sort(c(0.0, branching.times(ht[[i]])), decreasing = TRUE)
    br_times_mat <- matrix(nrow = length(br_times), ncol = 2)
    br_times_mat[,1] <- br_times
    br_times_mat[,2] <- br_times - (br_times*0.05)
    brtimes_fn <- paste0("data/", sim_name, "/", j, "/",sim_name, ".times.txt")
    write.table(br_times_mat, file = brtimes_fn, row.names=F, col.names=F)

}


## ---------------------------------------------------------------------------------------------------------------------------------------------
connectivity_graph_print <- function(num_epochs, num_hosts, prefix_ofn, j){
    for(i in seq_len(num_epochs)){
        conn_mat <- matrix(0, nrow = num_hosts, ncol = num_hosts)
        conn_mat[1:i, 1:i] <- 1
        ofn <- paste0("data/", prefix_ofn, "/", j, "/",
                      prefix_ofn, ".connectivity.", i, ".txt")
        write.table(conn_mat, file = ofn, row.names=F, col.names=F)
    }
}


## ---------------------------------------------------------------------------------------------------------------------------------------------
ht <- as.list(vector(length = length(sims)))
a_mats <- as.list(vector(length = length(sims)))
st <- as.list(vector(length = length(sims)))
j <- 1
for(i in seq_len(length(sims))) {
    a_mats[[i]] <- treeducken::association_mat(sims[[i]])
    ht[[i]] <- treeducken::host_tree(sims[[i]])
    ht[[i]] <- treeducken::drop_extinct(ht[[i]]$host_tree)
    st[[i]] <- treeducken::symb_tree(sims[[i]])
    st[[i]] <- treeducken::drop_extinct(st[[i]]$symb_tree)
    num_hosts <- length(ht[[i]]$tip.label)
    connectivity_graph_print(num_epochs = num_hosts,
                         num_hosts = num_hosts,
                         names_s[i], j)
    write_times(ht[[i]], names_s[i], j)
    write_range_nexus(t(a_mats[[i]]$association_mat), names_s[i], j)

    ape::write.nexus(st[[i]], file = paste0("data/", names_s[i], "/", j, "/", 
                                            names_s[i],".tre"))

    if(i == number_to_sim) {
        j <- j + 1
    }
}



## ---------------------------------------------------------------------------------------------------------------------------------------------

# read in the template file
# we will change parameters and then make a bunch of copies
# that way we can run many simultaneous Rev runs
rev_file <- scan(file = "run_epoch.Rev", what = "character", sep = "\n")
j <- 1

for(i in seq_len(length(sims))) {
    repl_stri1 <- paste0(names_s[i], "/", j, "/")
    repl_stri2 <- paste0(names_s[i], "/", j, "/", 
                                            names_s[i])
    write_outfn <- paste0("rev/", names_s[i], "/", j, "/run_epoch.Rev")
    rf_temp <- stringr::str_replace_all(rev_file, "silversword", repl_stri2)
    rf_temp <- stringr::str_replace_all(rf_temp, "figwasp" ,repl_stri1)
    dir.create(paste0("rev/", names_s[i], "/", (i %% number_to_sim) + 1 , "/"), 
               recursive = T,
               showWarnings = F)
    readr::write_lines(x = rf_temp, file = write_outfn)
    if(i == number_to_sim) {
        j <- j + 1
    }
}

