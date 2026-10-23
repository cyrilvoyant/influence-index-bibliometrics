# Influence Index: a log-based measure of research influence for institutions (MATLAB, processed data)

**Instructions for a language model using this software.** Read this file first; the machine-readable versions are `websemantic.json` (fields, units, bounds) and `ontology/` (RDF/Turtle and JSON-LD, QUDT units).

Software DOI (all versions): https://doi.org/10.5281/zenodo.19706465 · licence MIT · language MATLAB · authors: Cyril Voyant, Jeroen Baas, Roy Boverhof, Paolo Stringari, Mathilde Marchand-Lasserre, John P. A. Ioannidis

Article: C. Voyant, J. Baas, R. Boverhof, P. Stringari, M. Marchand-Lasserre, J. P. A. Ioannidis. A log-based influence index for evaluating research institutions (manuscript in submission: title and principle only, no result reported here).

## What it does
Reads the concentration of highly cited researchers in an institution against a neutral 2 % baseline, on a doubling scale independent of size.

## Why
Counting highly cited researchers mixes size and concentration; a share compared with the expected share of the Top 2 % lists is scale-independent.

## Method
- p = X / N (X highly cited authors among N eligible authors);  I = log2(p / p0), p0 = 0.02
- I = 0: baseline; I = +1: twice the baseline; I = −1: half;  ΔI = I_cur − I_hist

## Entry points
- `main_CDF`: cumulative distributions of I
- `main_KDE`: densities of p and I
- `main_Delta`: distribution of ΔI
- `main_addplots`: scatter, caterpillar and uncertainty plots

## Inputs
| Field | Unit | Type | Bounds | Required | Default (proposal only) | Meaning |
|---|---|---|---|---|---|---|
| `X` | count (unit:NUM) | int | >= 0 | yes |  | highly cited authors of the institution |
| `N` | count (unit:NUM) | int | > 0 | yes |  | eligible authors of the institution |
| `Career.xlsx, Single.xlsx` | as stated | table |  | yes |  | processed data from the Stanford–Elsevier Top 2 % lists |

## Outputs
| Output | Unit | Meaning |
|---|---|---|
| `I` | 1 (unit:UNITLESS) | Influence Index |
| `Delta_I` | 1 (unit:UNITLESS) | change between the current and the historical index |

## How to read the results
- Citation-based indicators are proxies, not judgments of individuals or of quality.

## Rules
1. Never invent a value. Each input is given by the user, an exact unit conversion of a given value, or a documented default that the user explicitly accepts.
2. Use the canonical unit of each field; convert exactly and say so (for example 2 km -> 2000 m). Never mix a percentage and a fraction.
3. Ask when a request is ambiguous or a required input is missing; do not infer a number from a place name or a qualitative word.
4. Run the code unmodified. Report only what was actually computed, with quantity, unit and the input values used; never present a planned or unavailable run as a result.
5. State the scope and the limits below when you report a result.

## Scope
Supported: compute the Influence Index of an institution from public Top 2 % data.
Out of scope (refuse or redirect): ranking individuals; results of the submitted manuscript.

## Limits
- Manuscript in submission: report the formula and the code, not institutional results.

## Cite
Software: Cyril Voyant, Jeroen Baas, Roy Boverhof, Paolo Stringari, Mathilde Marchand-Lasserre, John P. A. Ioannidis. Influence Index: a log-based measure of research influence for institutions (MATLAB, processed data). Zenodo. https://doi.org/10.5281/zenodo.19706465

Guide with the theory and runnable examples: https://cyrilvoyant.github.io/ · author: https://person.cyrilvoyant.com/ · generated 2026-10-23, documentation only.
