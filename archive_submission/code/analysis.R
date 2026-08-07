# =============================================================================
# Wildlife utilization of artificial refuges at a restoration site
# Dobson, Craig, Joyce & Stratton
#
# Reproduces the negative binomial model selection, model averaging, and
# diagnostics reported in the manuscript, from the archived cleaned data.
#
# Run from the archive root:  source("code/analysis.R")
# =============================================================================

library(dplyr); library(readr); library(MASS); library(MuMIn)
library(DHARMa); library(spdep)

# DHARMa residual simulation is stochastic; fix the seed so the diagnostic
# p-values below are reproducible exactly.
set.seed(20210525)

d <- read_csv("data/camera_stations.csv", show_col_types = FALSE) %>%
  mutate(
    # Reference levels as reported in the manuscript
    feature_type   = factor(feature_type,   levels = c("Artificial Refuge","Boulder","Log")),
    habitat_type   = factor(habitat_type,   levels = c("Grassland","Marsh","Scrub")),
    trail_adjacent = factor(trail_adjacent, levels = c("no","yes"))
  )
stopifnot(nrow(d) == 27)

# ---- 1. Candidate model set ------------------------------------------------
# All models carry log(camera hours) as an offset for sampling effort.
f <- function(rhs) as.formula(paste("total_detections ~", rhs,
                                    "+ offset(log(total_camera_hours))"))
models <- list(
  "Feature Type"                        = f("feature_type"),
  "Trail"                               = f("trail_adjacent"),
  "Habitat Type"                        = f("habitat_type"),
  "Feature Type + Trail"                = f("feature_type + trail_adjacent"),
  "Feature Type + Habitat Type"         = f("feature_type + habitat_type"),
  "Trail + Habitat Type"                = f("trail_adjacent + habitat_type"),
  "Feature Type + Trail + Habitat Type" = f("feature_type + trail_adjacent + habitat_type"),
  "Feature Type x Habitat Type"         = f("feature_type * habitat_type")
) |> lapply(function(x) glm.nb(x, data = d))

# NOTE: feature type x trail adjacency is deliberately absent. All five
# trail-adjacent features are artificial refuges, so the boulder:trail and
# log:trail cells are empty and those terms are aliased; glm.nb drops them
# silently and the model collapses onto its additive counterpart. Guard here.
stopifnot(all(vapply(models, function(m) !any(is.na(coef(m))), logical(1))))

# ---- 2. Diagnostics, assessed BEFORE selection ------------------------------
diag_tbl <- do.call(rbind, lapply(names(models), function(nm) {
  s  <- simulateResiduals(models[[nm]], plot = FALSE, n = 1000)
  tt <- testResiduals(s, plot = FALSE)
  data.frame(Model = nm,
             KS = tt$uniformity$p.value,
             Dispersion = tt$dispersion$p.value,
             Outlier = tt$outliers$p.value)
}))
cat("\n=== DHARMa diagnostics (all candidate models) ===\n"); print(diag_tbl, row.names = FALSE)

listw <- nb2listw(knn2nb(knearneigh(as.matrix(d[, c("longitude","latitude")]), k = 5)), style = "W")
moran_tbl <- do.call(rbind, lapply(names(models), function(nm) {
  mt <- moran.test(residuals(models[[nm]], type = "deviance"), listw)
  data.frame(Model = nm, Morans_I = unname(mt$estimate[1]), p = mt$p.value)
}))
cat("\n=== Moran's I (all candidate models) ===\n"); print(moran_tbl, row.names = FALSE)

# ---- 3. AICc model selection ------------------------------------------------
aicc <- data.frame(Model = names(models),
                   df   = sapply(models, function(m) attr(logLik(m), "df")),
                   AICc = sapply(models, MuMIn::AICc)) %>%
  mutate(delta_AICc = AICc - min(AICc),
         weight     = exp(-0.5*delta_AICc) / sum(exp(-0.5*delta_AICc))) %>%
  arrange(delta_AICc)
cat("\n=== AICc comparison ===\n"); print(aicc, row.names = FALSE, digits = 4)

competitive <- aicc$Model[aicc$delta_AICc < 2]
cat(sprintf("\nCompetitive set (dAICc < 2): %d models, %.1f%% of total weight\n",
            length(competitive), 100*sum(aicc$weight[aicc$delta_AICc < 2])))

# ---- 4. Model averaging over the competitive set -----------------------------
avg <- model.avg(model.sel(models[competitive], rank = "AICc"), revised.var = TRUE)
ct  <- as.data.frame(coefTable(avg, full = FALSE))
ct  <- ct[!is.na(ct$Estimate), ]
ct$IRR      <- exp(ct$Estimate)
ct$CI_lower <- exp(ct$Estimate - 1.96*ct$`Std. Error`)
ct$CI_upper <- exp(ct$Estimate + 1.96*ct$`Std. Error`)
cat("\n=== Model-averaged coefficients (conditional) ===\n"); print(round(ct, 3))

# ---- 5. Sensitivity: interior features only ---------------------------------
di <- droplevels(filter(d, trail_adjacent == "no"))
int <- list(
  "Null"                        = glm.nb(total_detections ~ 1 + offset(log(total_camera_hours)), data = di),
  "Feature Type"                = glm.nb(f("feature_type"), data = di),
  "Habitat Type"                = glm.nb(f("habitat_type"), data = di),
  "Feature Type + Habitat Type" = glm.nb(f("feature_type + habitat_type"), data = di)
)
ia <- data.frame(Model = names(int), AICc = sapply(int, MuMIn::AICc)) %>%
  mutate(delta_AICc = AICc - min(AICc),
         weight = exp(-0.5*delta_AICc)/sum(exp(-0.5*delta_AICc))) %>% arrange(delta_AICc)
cat(sprintf("\n=== Interior features only (n = %d) ===\n", nrow(di)))
print(ia, row.names = FALSE, digits = 4)
