# Influence Index for Institutional Research Evaluation

This repository provides MATLAB scripts and processed datasets used to compute and visualize the **Influence Index (I)**, a scale-independent metric for institutional research evaluation based on the Top 2% scientists framework.

The approach complements traditional volume-based indicators by focusing on **research concentration** and **temporal dynamics**.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19706465.svg)](https://doi.org/10.5281/zenodo.19706465)
---

## 📌 Concept

The Influence Index is defined as:

I = log2(p / p0)

where:
- p = X / N is the proportion of Top 2% researchers
- p0 = 0.02 is the reference baseline

Interpretation:
- I = 0 → baseline (2%)
- I = +1 → doubling (4%)
- I = -1 → halving (1%)

This formulation ensures:
- symmetry between over- and under-representation
- independence from institutional size
- direct interpretability

---

## 📊 Data Source

The data are derived from:

Baas, J.; Ioannidis, J.; Voyant, C.; Boverhof, R. (2025)  
Science-wide mapping and ranking of institutions based on affiliated authors  
Elsevier Data Repository  
https://doi.org/10.17632/jn5j7gjpzj.1  

Methodology:

Voyant et al. (2025)  
https://doi.org/10.64898/2025.12.16.694665  

⚠️ Note:  
Only processed institutional-level data are provided here.  
Raw datasets are subject to licensing restrictions.

---

## 📁 Repository Structure

- code/  
  MATLAB scripts for generating figures

- data/  
  Processed datasets:
  - Career.xlsx  
  - Single.xlsx  

- figures/  
  Output directory for plots

---

## ⚙️ Requirements

- MATLAB (R2021b or later)
- No additional toolboxes required

---

## 📊 Input Data Format

Both Career.xlsx and Single.xlsx must contain:

- Institution
- Primary analysis authors (N)
- Ratio (p)
- I
- p_lo, p_up
- I_low, I_up

---

## ▶️ Usage

Run the scripts from the `code/` folder:

- main_CDF.m → cumulative distributions of I
- main_KDE.m → density distributions of p and I
- main_Delta.m → distribution of ΔI
- main_addplots.m → scatter, caterpillar and uncertainty plots

---

## 🔍 Interpretation

The index captures **research concentration**, not volume.

The dynamic contrast is defined as:

ΔI = I_cur − I_hist

- ΔI > 0 → increasing concentration
- ΔI < 0 → decreasing concentration
- ΔI ≈ 0 → stable profile

---

## 📈 Scope

This repository is intended for:

- institutional benchmarking (non-ranking)
- research policy analysis
- scientometric studies

It is not designed for competitive ranking or standalone decision-making.

---

## 📜 License

MIT License

---

## 📚 Citation

If you use this work, please cite:

Voyant, C. et al. (2025)  
Influence Index for Institutional Research Evaluation  
[DOI to be added after Zenodo publication]

and:

Baas, J. et al. (2025)  
Science-wide mapping and ranking of institutions  
https://doi.org/10.17632/jn5j7gjpzj.1  

---

## 🤝 Contact

Cyril Voyant  
Mines Paris – PSL University  
Centre Observation, Impacts, Énergie (O.I.E.)

---

## ⚠️ Disclaimer

Results depend on the underlying dataset and affiliation aggregation methodology.  
Interpretation should consider statistical uncertainty and disciplinary differences.
