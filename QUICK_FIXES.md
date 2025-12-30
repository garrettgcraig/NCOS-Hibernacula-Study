# Quick Dependency Fixes

**Quick reference for immediate improvements - see DEPENDENCY_AUDIT.md for full details**

---

## 🚨 Remove These Lines Immediately (Safe to Delete)

### 1. Line 71 - Redundant dplyr
```r
library(dplyr)        # reloaded to ensure dplyr's functions are used
```
**Why:** Already included in `tidyverse` (line 50)

---

### 2. Line 79 - Redundant ggplot2
```r
library(ggplot2)
```
**Why:** Already included in `tidyverse` (line 50)

---

### 3. Line 2315 - Duplicate car
```r
library(car)          # for outlier tests and VIF
```
**Why:** Already loaded at line 69

---

## 🔧 Fix Package Loading Order

**Move line 70 (MASS) to BEFORE line 50 (tidyverse):**

```r
# CURRENT (WRONG):
library(tidyverse)     # line 50
# ... other packages ...
library(MASS)          # line 70

# CORRECT:
library(MASS)          # Load FIRST to avoid select() conflicts
library(tidyverse)     # Then load tidyverse
```

This eliminates the need for the dplyr reload hack.

---

## 📦 Set Up renv (5 minutes)

**In R console:**
```r
install.packages("renv")
renv::init()
renv::snapshot()
```

**Add to .gitignore:**
```
renv/library/
renv/staging/
renv/local/
```

**Commit to git:**
```
git add renv.lock renv/activate.R renv/settings.dcf
git commit -m "Add renv for dependency management"
```

---

## 📋 To Investigate (requires code review)

1. **Is `simpleboot` used?** If not, remove line 67
2. **Is `stringi` used directly?** If not, remove line 85
3. **Is `RColorBrewer` used?** If not, remove line 75
4. **Is `maps` used?** If not, remove line 81
5. **Is `webshot2` used?** If not, remove line 63

**How to check:**
```r
# Search for direct usage:
grep -r "simpleboot::" NCOS_Hibernacula_Study.qmd
grep -r "stringi::" NCOS_Hibernacula_Study.qmd
grep -r "brewer.pal" NCOS_Hibernacula_Study.qmd
grep -r "map_data\\|map(" NCOS_Hibernacula_Study.qmd
grep -r "webshot" NCOS_Hibernacula_Study.qmd
```

---

## 📊 Before/After Comparison

### BEFORE (35 package loads, 3 duplicates)
- Startup time: ~15-20 seconds
- Namespace conflicts: Yes (MASS::select vs dplyr::select)
- Reproducibility: No version control
- Redundant loads: 3

### AFTER (removing just the 3 duplicates)
- Startup time: ~13-17 seconds
- Namespace conflicts: Resolved
- Reproducibility: With renv - Yes!
- Redundant loads: 0

### AFTER (full optimization - removing 8+ unused packages)
- Startup time: ~10-12 seconds
- Clearer dependencies
- Better maintenance

---

## ⚡ One-Command Fix

**Create this as a patch file and apply:**

```bash
# Remove the three redundant library() calls
sed -i '71d' NCOS_Hibernacula_Study.qmd  # Remove dplyr reload
sed -i '79d' NCOS_Hibernacula_Study.qmd  # Remove ggplot2 reload
sed -i '2315d' NCOS_Hibernacula_Study.qmd  # Remove car duplicate
```

**⚠️ WARNING:** Line numbers shift after each deletion. Better to do manually or use proper patch file.

---

## 🎯 Expected Timeline

- **5 minutes:** Set up renv
- **10 minutes:** Remove 3 redundant lines + reorder MASS
- **30 minutes:** Review code for unused packages (optional)
- **1 hour:** Migrate stargazer → modelsummary (optional)

**Total minimum time:** 15 minutes for significant improvement!

---

## ✅ Testing After Changes

```r
# 1. Clear environment
rm(list = ls())

# 2. Restart R session

# 3. Run the modified script
source("NCOS_Hibernacula_Study.qmd")

# 4. Check for errors
# If no errors, changes are successful!
```

---

## 🔗 Related Files

- **DEPENDENCY_AUDIT.md** - Full analysis and explanations
- **NCOS_Hibernacula_Study.qmd** - Main analysis file to modify
- **README.md** - Update after implementing renv

---

**Questions?** See detailed explanations in DEPENDENCY_AUDIT.md
