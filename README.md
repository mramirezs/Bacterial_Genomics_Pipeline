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

## 🛠️ Instalación y Configuración del Entorno

Para garantizar la reproducibilidad y evitar conflictos de dependencias, utilizamos **Conda** (a través de **Miniforge/Mamba**) para gestionar todo el software bioinformático.

### 1. Pre-requisitos: Instalar Miniforge

Si aún no tienes un gestor de paquetes instalado en el servidor, recomendamos **Miniforge** por su velocidad y configuración nativa con `conda-forge`.

```bash
# Descargar e instalar Miniforge (Linux x86_64)
wget "[https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh](https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh)"
bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3

# Inicializar y activar
$HOME/miniforge3/bin/conda init bash
source ~/.bashrc

# Verificar instalación de Mamba
mamba --version
```

# Crear el entorno usando Mamba (recomendado por velocidad)
mamba env create -f bact_pipeline.yml

# Activar el entorno
mamba activate bact_pipeline

