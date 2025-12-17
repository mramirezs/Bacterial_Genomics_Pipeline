# 🧬 Proyecto: Vigilancia Genómica y Análisis de Resistencia en *E. coli*

Este repositorio documenta el flujo de trabajo bioinformático para el análisis de una cepa clínica de *Escherichia coli*. El objetivo es detectar genes de resistencia a antimicrobianos (AMR) y variantes genéticas mediante dos estrategias complementarias: **Resecuenciamiento (Mapeo)** y **Ensamblaje De Novo (No Híbrido)**.

## 📂 Estructura del Proyecto

El proyecto sigue una organización estricta para garantizar la reproducibilidad en entornos HPC:

```text
Ecoli_Project/
├── 00_raw_data/              # Datos crudos (Enlaces simbólicos)
│   ├── illumina/             # URO5550422 (PE)
│   └── nanopore/             # FRAN93 (Long Reads)
├── 01_reference/             # Genoma de referencia (E. coli K-12 MG1655)
├── 02_qc/                    # Control de calidad (FastQC, NanoPlot)
├── 03_mapping/               # Análisis de Variantes (BWA, Minimap2)
├── 04_assembly/              # Ensamblaje De Novo (Separado)
│   ├── illumina_only/        # Spades
│   └── nanopore_only/        # Flye
├── 05_amr_screening/         # Detección de genes (Abricate, RGI, AMRFinder)
└── scripts/                  # Scripts de automatización
```

