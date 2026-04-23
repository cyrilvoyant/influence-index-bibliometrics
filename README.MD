# Influence Index for Institutional Research Evaluation

This repository provides MATLAB scripts and processed datasets used to compute and visualize the **Influence Index (I)**, a scale-independent metric designed to quantify institutional research concentration based on the Top 2% scientists framework.

The approach complements traditional volume-based indicators by focusing on **proportional representation** and **temporal dynamics** of influential researchers.

---

## 📌 Concept

The Influence Index is defined as:

\[
I = \log_2 \left( \frac{p}{p_0} \right)
\]

where:
- \( p = X/N \) is the proportion of Top 2% researchers within an institution,
- \( p_0 = 0.02 \) is the reference baseline.

This logarithmic formulation ensures:
- symmetry between over- and under-representation,
- invariance to institutional size,
- direct interpretability in terms of doubling/halving of research concentration.

---

## 📊 Data Source

The data used in this repository are derived from:

**Baas, Jeroen; Ioannidis, John; Voyant, Cyril; Boverhof, Roy (2025)**  
*Science-wide mapping and ranking of institutions based on affiliated authors*  
Elsevier Data Repository, V1  
DOI: https://doi.org/10.17632/jn5j7gjpzj.1  

The methodology used to construct the institutional dataset is detailed in:

**Voyant et al. (2025)**  
DOI: https://doi.org/10.64898/2025.12.16.694665  

⚠️ Note:  
This repository contains **processed institutional-level data only**.  
The original raw datasets are subject to licensing restrictions and must be obtained from the Elsevier repository.

---

## 📁 Repository Structure
├── code/
│ ├── main_CDF.m
│ ├── main_KDE.m
│ ├── main_Delta.m
│ └── main_addplots.m
├── data/
│ ├── Career.xlsx
│ └── Single.xlsx
├── figures/
└── README.md


---

## ⚙️ Requirements

- MATLAB (tested on R2021b or later)
- No external toolboxes required

---

## 📊 Input Data Format

The scripts expect two Excel files:

### `Career.xlsx` and `Single.xlsx`

Required columns:

- `Institution`
- `Primary analysis authors` (N)
- `Ratio (p)`
- `I`
- `p_lo`, `p_up`
- `I_low`, `I_up`

---

## ▶️ Usage

Run the scripts from the `code/` directory:

- `main_CDF.m`  
  → Empirical cumulative distributions (CDF) of \( I \)

- `main_KDE.m`  
  → Kernel density estimation of \( p \) and \( I \)

- `main_Delta.m`  
  → Distribution of the dynamic contrast \( \Delta I \)

- `main_addplots.m`  
  → Scatter plots, caterpillar plots, and uncertainty analysis

Figures are generated automatically and can be exported for publication.

---

## 🔍 Interpretation

- \( I = 0 \): baseline (2% Top2 researchers)
- \( I = +1 \): doubling (4%)
- \( I = -1 \): halving (1%)

The index captures **research concentration**, not volume.

The dynamic contrast:

\[
\Delta I = I_{\text{cur}} - I_{\text{hist}}
\]

allows distinguishing:
- strengthening institutions (\( \Delta I > 0 \))
- declining institutions (\( \Delta I < 0 \))
- stable profiles (\( \Delta I \approx 0 \))

---

## 📈 Scope

This repository is intended for:

- institutional benchmarking (non-ranking)
- research policy analysis
- scientometric studies
- methodological reproducibility

It is **not designed for competitive ranking or decision-making in isolation**.

---

## 📜 License

This project is licensed under the MIT License.

---

## 📚 Citation

If you use this code or data, please cite:

Voyant, C. et al. (2025).
Influence Index for Institutional Research Evaluation.
[DOI to be added after Zenodo publication]

and the original dataset:Baas, J. et al. (2025).
Science-wide mapping and ranking of institutions.
Elsevier Data Repository, https://doi.org/10.17632/jn5j7gjpzj.1


---

## 🤝 Contact

Cyril Voyant  
Mines Paris – PSL University  
Centre Observation, Impacts, Énergie (O.I.E.)

---

## ⚠️ Disclaimer

Results depend on the underlying Top2% dataset and affiliation aggregation methodology.  
Interpretation should consider disciplinary composition, data coverage, and statistical uncertainty.
