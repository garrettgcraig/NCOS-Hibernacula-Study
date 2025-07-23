# NCOS Hibernacula Study

This repository contains the data analysis and reproducible workflow for the NCOS Hibernacula Study, a research project examining how wildlife utilize constructed hibernacula (buried multi-rock refugia) compared to natural habitat features (logs and boulders) in the North Campus Open Space (NCOS) restoration area.

## Project Overview

This study builds on prior work ([see here](https://escholarship.org/uc/item/4qb9s50f)), expanding the focus from simply recording wildlife presence at various habitat features to evaluating the ecological function of these structures in a restored landscape. The primary objectives are to:

- Compare rates and patterns of wildlife visitation among constructed hibernacula, logs, and boulders.
- Assess the impact of habitat type and proximity to trails on wildlife use of these features.
- Provide robust statistical analysis and data visualizations to support ecological conclusions.

## Methods Summary

- **Field Data Collection:** Motion-sensor camera traps were deployed at 5 boulder sites, 8 log sites, and 14 constructed hibernacula, with most sites monitored by two cameras for ~5 days.
- **Image Review:** Photographs were uploaded to [Wildlife Insights](https://app.wildlifeinsights.org/manage/organizations/2002131/projects/2003592/summary?), where wildlife were identified to the lowest possible taxonomic level.
- **Data Processing:** R scripts clean and merge multiple sources of observation and deployment metadata, remove duplicate detections, and prepare summary tables.
- **Analysis:** Statistical models (t-tests, linear regression, Poisson/quasi-Poisson GLMs) compare wildlife activity rates between feature types and examine the influence of habitat and trail proximity.
- **Visualization:** The repository includes scripts for generating publication-ready plots of abundance, species richness, and temporal activity patterns.

## Repository Structure

- `hibernacula-analysis-updated-7-18-25.qmd`: Main analysis script (Quarto; R Markdown format).
- `/data/`: Raw and processed data files (camera deployments, species observations, site metadata).
- `/figures/` (if present): Output plots and figures.
- Additional scripts or templates for data wrangling and reproducibility.

## Getting Started

### Prerequisites

- R (≥4.0)
- R packages: `tidyverse`, `janitor`, `lubridate`, `broom`, `readxl`, `stargazer`, `ggtext`, `patchwork`, `scales`, `effsize`, `simpleboot`, `boot`, `car`, `leaflet`, `RColorBrewer`, `stringi`, `fuzzyjoin`, `IRanges`, etc.
- Quarto (for rendering `.qmd` files)

### To Reproduce the Analysis:

1. Clone the repository:
    ```sh
    git clone https://github.com/garrettgcraig/NCOS-Hibernacula-Study.git
    ```
2. Place required data files in the `/data/` directory.
3. Open the main `.qmd` file in RStudio or your preferred editor.
4. Render the analysis:
    ```sh
    quarto render hibernacula-analysis-updated-7-18-25.qmd
    ```

## Citation

If using results or code from this repository, please cite:



## Contact

For questions or collaborations, please contact 

---

_This project supports evidence-based ecological restoration and adaptive management at NCOS and similar sites._
