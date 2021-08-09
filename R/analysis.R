# analysis script

library(RevGadgets)
library(coda)
library(ggplot2)
library(ggtree)
library(grid)
library(gridExtra)
library(stringr)
# specify the input file

DR0ER0_dir <- "output/DR0ER0/"
DR0.5ER0_dir <- "output/DR0.5ER0/"
DR1ER0_dir <- "output/DR1ER0/"

n <- 100
read_log_files <- function(dir, num_sim) {
  sims <- seq(from = 1, to = num_sim, by = 1)  
  sim_name <- str_split(dir, "/")
  
  fns <- lapply(sims, FUN = function(x) {paste0(dir,
                                                x, "/",
                                                sim_name[[1]][2],
                                                ".", x, ".model.log")})
  unlist(fns)
}

log_fns <- read_log_files(DR1ER0_dir, n)

read_traces <- function(filenames, burnin) {
  lapply(filenames, FUN = function(x) {try(readTrace(x, burnin = burnin),
                                           silent = TRUE)})
}
trace_quant_list <- read_traces(log_fns, 0.1)


#trace_quant <- removeBurnin(trace = trace_quant, burnin = 0.1)


get_mcmc <- function(trace_quants) {
  lapply(trace_quants, FUN = function(x) {as.mcmc(x[[1]])})
}

trace_quant_MCMC_list <- get_mcmc(trace_quant_list)

get_ess_list <- function(tq_MCMC) {
  lapply(tq_MCMC, FUN = function(x) {try(effectiveSize(x),
                                         silent=TRUE)})
}
ess <- get_ess_list(trace_quant_MCMC_list)

#traceplot(trace_quant_MCMC)

summarize_traces <- function(trace_quants, vars) {
    lapply(trace_quants, FUN = function(x) {
        try(summarizeTrace(trace = x, vars = vars),
            silent = TRUE)
  })
}

vs <-   c("rate_bg", 
          "extirpation_rate",
          "p_clado[1]",
          "p_clado[2]",
          "p_clado[3]")
trace_summaries <- summarize_traces(trace_quant_list, vars = vs)



drop_empties <- function(summaries, ess) {
    bool_list <- unlist(lapply(summaries, FUN = function(x) { is.list(x) }))
    indices <- which(bool_list)
    final_indices <- drop_low_ess(indices, ess)
    trimmed_summaries <- summaries[indices]
    trimmed_summaries[final_indices]
}


drop_low_ess <- function(indices, ess, cutoff = 400) {
    ess <- ess[indices]
    ess_dropped <- unlist(lapply(ess, FUN  = function(x) {x['Posterior'] > cutoff}), 
                          use.names = FALSE)
    which(ess_dropped)
}

tr_summ <- drop_empties(trace_summaries, ess)

convert_summary_to_df <- function(summaries, vars) {
    rate_bg   <-  lapply(summaries, FUN = function(x) {x[[vars[1]]]$trace_1})
    extp_rate <-  lapply(summaries, FUN = function(x) {x[[vars[2]]]$trace_1})
    p_clado1  <-  lapply(summaries, FUN = function(x) {x[[vars[3]]]$trace_1})
    p_clado2  <-  lapply(summaries, FUN = function(x) {x[[vars[4]]]$trace_1})
    p_clado3  <-  lapply(summaries, FUN = function(x) {x[[vars[5]]]$trace_1})
    big_df <- data.frame(matrix(nrow=0, ncol=6))
    colnames(big_df) <- c("param", "mean", "median", "MAP", 
                          "quantile_2.5", "quantile_97.5")
    make_row <- function(param, row, df) {
        df[nrow(df)+1,] <- c(param, row)
        df
    }
    for(i in seq_len(length(rate_bg))) {
        big_df <- make_row("rate_bg", rate_bg[[i]], big_df)
        big_df <- make_row("extirpation_rate", extp_rate[[i]], big_df)
        big_df <- make_row("p_clado[1]", p_clado1[[i]], big_df)
        big_df <- make_row("p_clado[2]", p_clado2[[i]], big_df)
        big_df <- make_row("p_clado[3]", p_clado3[[i]], big_df)
        
    }
    big_df$mean <- as.numeric(big_df$mean)
    big_df$median <- as.numeric(big_df$median)
    big_df$MAP <- as.numeric(big_df$MAP)
    big_df$quantile_2.5 <- as.numeric(big_df$quantile_2.5)
    big_df$quantile_97.5 <- as.numeric(big_df$quantile_97.5)
    big_df
}

df <- convert_summary_to_df(tr_summ, vs)
df_p_clado1 <- subset(df, param == "p_clado[1]")
df_p_clado2 <- subset(df, param == "p_clado[2]")
df_p_clado3 <- subset(df, param == "p_clado[3]")
df_p_clado <- rbind(df_p_clado1, df_p_clado2, df_p_clado3)
df_ratebg <- subset(df, param == "rate_bg")
df_extp <- subset(df, param == "extirpation_rate")
df_rate <- rbind(df_ratebg, df_extp)

ggplot(data=df_p_clado, aes(x=param, y=MAP)) + geom_boxplot() + theme_bw()
ggplot(data=df_rate, aes(x = param, y = MAP)) + geom_boxplot() + theme_bw()
