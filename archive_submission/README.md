# Wildlife utilization of artificial refuges at a restoration site

Data and code accompanying:

> Dobson, A., Craig, G., Joyce, F. H., & Stratton, L. Wildlife utilization of
> artificial refuges at a restoration site.

Camera-trap study of wildlife use of constructed artificial refuges (piled
concrete rubble in excavated holes) compared with logs and boulders, at North
Campus Open Space (NCOS), Goleta, California, USA. Two five-week deployments:
winter (2 February – 9 March 2021) and spring (22 April – 25 May 2021).

## Related deposits

This study is archived across two repositories. Each holds one half of the
material; together they reproduce the published analysis.

| Component | Repository | DOI |
|---|---|---|
| Data | Dryad | [10.5061/dryad.7m0cfxqc2](https://doi.org/10.5061/dryad.7m0cfxqc2) |
| Analysis code | Zenodo | [10.5281/zenodo.21830069](https://doi.org/10.5281/zenodo.21830069) |

To reproduce the analysis you need both: download the data files from Dryad
into `data/`, and the code from Zenodo into `code/`, following the layout under
"Contents" below.

## Contents

```
data/
  camera_stations.csv              site-level analysis dataset (spring; n = 27)
  species_detections_spring.csv    cleaned, deduplicated detection sequences
  hourly_presence_combined.csv     hourly presence records, both study periods
  site_to_habitat_crosswalk.csv    site -> habitat / trail lookup
  spatial/                         NCOS boundary and habitat polygons (ESRI shapefiles)
code/
  analysis.R                       reproduces model selection, averaging, diagnostics
  sessionInfo.txt                  full R session record
outputs/
  table1_competitive_models.csv    manuscript Table 1
  table2_model_averaged.csv        manuscript Table 2
```

These are **cleaned, analysis-ready** files. Raw camera-trap exports are not
redistributed here; spring-study images were processed through the Wildlife
Insights platform (Ahumada et al. 2020).

If the spatial layers were downloaded as a single `ncos_spatial_layers.zip`
(as distributed by some repositories, which require the components of an ESRI
shapefile to stay bundled), unzip it so that its contents sit at
`data/spatial/` before running anything that reads them.

## Reproducing the analysis

From the archive root:

```r
source("code/analysis.R")
```

Produces, in order: DHARMa residual diagnostics for all eight candidate models;
Moran's I spatial autocorrelation tests; the AICc model comparison with Akaike
weights; model-averaged coefficients across the competitive set (ΔAICc < 2);
and the interior-only sensitivity analysis.

Requires R (>= 4.4) with `dplyr`, `readr`, `MASS`, `MuMIn`, `DHARMa`, `spdep`.
Exact versions used are in `code/sessionInfo.txt`. A seed is set so the
simulation-based DHARMa p-values reproduce exactly.

## Data dictionary

### camera_stations.csv — one row per camera station (n = 27)

| Column | Description |
|---|---|
| `station_id` | Camera station identifier |
| `longitude`, `latitude` | Station coordinates (WGS 84, decimal degrees) |
| `feature_type` | `Artificial Refuge` (n=14), `Boulder` (n=5), or `Log` (n=8) |
| `habitat_type` | `Grassland`, `Marsh`, or `Scrub` |
| `trail_adjacent` | `yes` if within 10 m of a public trail, else `no` |
| `notable_entrances` | Count of burrow entrances ≥ 5 cm wide at/near the feature |
| `total_camera_days` | Camera deployment duration (days) |
| `total_camera_hours` | Deployment duration (hours); model offset is `log()` of this |
| `total_detections` | Total wildlife detections (model response) |
| `detections_per_camera_day` | `total_detections / total_camera_days` |

### species_detections_spring.csv — one row per detection sequence

| Column | Description |
|---|---|
| `station_id` | Camera station identifier |
| `feature_type`, `habitat_type` | As above |
| `class` | Taxonomic class |
| `common_name`, `genus_species` | Species identification |
| `obs_date`, `obs_time` | Sequence start date and time (local) |
| `group_size` | Maximum individuals in a single image of the sequence |

Humans, domestic cats, and insects removed; duplicate sequences captured
simultaneously by paired cameras collapsed to one record.

### hourly_presence_combined.csv — one row per species-hour-station

| Column | Description |
|---|---|
| `station_id` | Camera station identifier |
| `study_part` | `winter` or `spring` |
| `feature_type`, `habitat_type` | As above |
| `common_name` | Species |
| `obs_day`, `obs_hour` | Date and hour (0–23) of detection |

Binary hourly presence: a species is counted at most once per hour per station
per day, standardising the differing image-processing methods between periods.

### spatial/ — site boundary and habitat polygons (ESRI shapefile)

| Layer | Features | Coordinate reference system |
|---|---|---|
| `ncos_shp` | 1 | WGS 84 / Pseudo-Mercator (EPSG:3857) |
| `ncos_habitats_june_2021/NCOS_Habitats_June2021_Simple` | 131 | NAD83(2011) / California zone 5, ftUS (EPSG:6424) |

Note the two layers are in **different coordinate reference systems**; reproject
before overlaying them. Each shapefile is a set of sidecar files sharing a base
name (`.shp`, `.shx`, `.dbf`, `.prj`, …) and all must be kept together.

These layers are used only for the map figures in the manuscript. They are not
read by `code/analysis.R`, and no result reported in the paper depends on them.

## Notes and caveats

- **Reference levels.** Models use artificial refuge, grassland habitat, and
  interior (non-trail-adjacent) as reference categories.
- **Non-identifiable interaction.** Feature type × trail adjacency cannot be
  estimated: all five trail-adjacent features are artificial refuges, so the
  boulder × trail and log × trail cells are empty. Models containing that
  interaction are excluded from the candidate set; `analysis.R` asserts this.
- **Habitat polygon geometry.** One of the 131 habitat polygons contains a ring
  self-intersection and is therefore topologically invalid. This is present in
  the source layer as supplied and has been left unaltered to preserve
  provenance. It does not affect any reported result: habitat assignment comes
  from `site_to_habitat_crosswalk.csv` rather than a spatial join, and the
  polygons serve only as map shading. Software that requires valid geometry may
  warn or error; `sf::st_make_valid()` resolves it.
- **Basemap imagery.** Figure code in the full manuscript source downloads Esri
  satellite tiles at render time and therefore needs a network connection. No
  figure in this archive depends on it.
## License

Data: CC0 1.0 Universal. Code: MIT.
