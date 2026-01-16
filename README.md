# 🧬 Pipeline de Vigilancia Genómica y Análisis de Resistencia Antimicrobiana en Bacterias

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bioinformatics](https://img.shields.io/badge/Bioinformatics-Pipeline-blue.svg)]()
[![Status](https://img.shields.io/badge/Status-Production-green.svg)]()

Este repositorio documenta un flujo de trabajo bioinformático completo para el análisis de genomas bacterianos clínicos utilizando datos de secuenciación de nueva generación (NGS). El pipeline integra tres estrategias de ensamblaje complementarias: **Ensamblaje con Illumina**, **Ensamblaje con Nanopore** y **Ensamblaje Híbrido (Illumina + Nanopore)**, junto con detección exhaustiva de genes de resistencia a antimicrobianos (AMR) y análisis de variantes genómicas.

**🎯 Caso de Estudio**: *Klebsiella pneumoniae* URO5550422 con genoma multi-secuencia (1 cromosoma + 6 plásmidos)

---

## 📋 Tabla de Contenidos

- [⚠️ Antes de Comenzar](#️-antes-de-comenzar)
- [Características del Pipeline](#-características-del-pipeline)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación y Configuración](#️-instalación-y-configuración)
- [Configuración del Proyecto](#-configuración-del-proyecto)
- [Dataset de Ejemplo](#-dataset-de-ejemplo)
- [Flujo de Trabajo](#-flujo-de-trabajo)
- [Resultados Esperados](#-resultados-esperados)
- [Interpretación de Resultados](#-interpretación-de-resultados)
- [Checklist de Validación](#-checklist-de-validación)
- [Solución de Problemas](#-solución-de-problemas)
- [Casos de Uso](#-casos-de-uso)
- [Limitaciones Conocidas](#️-limitaciones-conocidas)
- [Referencias](#-referencias)

---

## ⚠️ Antes de Comenzar

### Requisitos Previos

- [ ] **Datos de secuenciación** en formato FASTQ (Illumina y/o Nanopore)
- [ ] **~100-200 GB** de espacio libre en disco por muestra
- [ ] **Sistema Linux/Unix** (Ubuntu 20.04+, CentOS 7+, o similar)
- [ ] **Acceso a internet** para descargar herramientas y bases de datos
- [ ] **Tiempo estimado**: 4-8 horas por muestra (dependiendo de hardware)

### 🚀 Inicio Rápido

```bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/Bacterial_Genomics_Project.git
cd Bacterial_Genomics_Project

# 2. Crear estructura y descargar referencia
bash setup_project_structure.sh

# 3. Configurar ambientes Conda (primera vez - ~45 minutos)
bash scripts/setup_environments.sh

# 4. Verificar instalación
bash scripts/verify_installation.sh

# 5. Enlazar datos de secuenciación
bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore

# 6. Ejecutar pipeline completo
bash scripts/run_full_pipeline.sh URO5550422

# 7. Ver resultados
firefox 08_results/FINAL_REPORT.html
```

### 📊 ¿Qué Puedo Hacer con Este Pipeline?

✅ **Ensamblar genomas bacterianos** de alta calidad  
✅ **Identificar genes de resistencia** a antibióticos (AMR)  
✅ **Detectar variantes genómicas** (SNPs, INDELs)  
✅ **Anotar genes y funciones** biológicas  
✅ **Comparar diferentes estrategias** de ensamblaje  
✅ **Analizar cromosomas y plásmidos** por separado  
✅ **Tipificar cepas** (MLST, detección de plásmidos)  
✅ **Generar reportes automatizados** para vigilancia epidemiológica  

---

## 🎯 Características del Pipeline

### Tecnologías Soportadas
- **Illumina** (lecturas cortas, paired-end): Alta precisión, ideal para SNPs/INDELs
- **Oxford Nanopore** (lecturas largas): Ensamblajes contiguos, cierre de plásmidos
- **Híbrido** (Illumina + Nanopore): Combina precisión y continuidad

### Análisis Incluidos
- ✅ Control de calidad exhaustivo (raw y trimmed reads)
- ✅ Tres estrategias de ensamblaje independientes
- ✅ Mapeo contra genoma multi-secuencia (cromosoma + plásmidos)
- ✅ Análisis de cobertura por secuencia individual
- ✅ Detección de genes AMR con múltiples bases de datos
- ✅ Anotación funcional de genomas
- ✅ Evaluación de calidad de ensamblajes
- ✅ MLST typing y detección de plásmidos
- ✅ Identificación de factores de virulencia
- ✅ Visualización y reportes integrados

### Características Especiales para *K. pneumoniae*
- 🔬 Análisis separado de cromosoma y 6 plásmidos
- 🧬 Detección de genes AMR en elementos móviles
- 📊 Perfiles de resistencia específicos de la especie
- 🗺️ Mapeo optimizado para genomas multi-secuencia

---

## 📂 Estructura del Proyecto

```text
Bacterial_Genomics_Project/
├── 00_raw_data/                    # Datos crudos de secuenciación
│   ├── illumina/                   # Lecturas paired-end
│   │   ├── URO5550422_1.fastq.gz  # Forward reads
│   │   └── URO5550422_2.fastq.gz  # Reverse reads
│   ├── nanopore/                   # Lecturas largas ONT
│   │   └── URO5550422_1.fastq.gz  # Long reads (nota: mismo nombre, diferente tecnología)
│   └── sample_metadata.txt         # Metadata de la muestra
│
├── 01_reference/                   # Genoma de referencia K. pneumoniae
│   ├── GCF_000240185.1_ASM24018v2_genomic.fna  # Referencia completa
│   ├── reference.fasta             # Enlace simbólico
│   └── reference_sequences.txt     # Índice: 1 cromosoma + 6 plásmidos
│
├── 02_qc/                          # Control de calidad
│   ├── 01_illumina_raw/            # FastQC de datos crudos Illumina
│   ├── 02_illumina_trimmed/        # FastQC post-trimming + reportes fastp
│   ├── 03_nanopore_raw/            # NanoPlot de datos crudos ONT
│   ├── 04_nanopore_filtered/       # NanoPlot post-filtrado
│   └── 05_multiqc/                 # Reporte consolidado MultiQC
│
├── 03_assembly/                    # Ensamblajes de novo
│   ├── 01_illumina_only/           # SPAdes (solo Illumina)
│   │   ├── contigs.fasta
│   │   ├── scaffolds.fasta
│   │   └── assembly_graph.fastg
│   ├── 02_nanopore_only/           # Flye (solo Nanopore)
│   │   ├── assembly.fasta
│   │   ├── assembly_info.txt
│   │   └── assembly_graph.gfa
│   ├── 03_hybrid/                  # Unicycler (Illumina + Nanopore)
│   │   ├── assembly.fasta
│   │   └── assembly.gfa
│   └── 04_quast_evaluation/        # Evaluación comparativa QUAST
│       └── report.html
│
├── 04_mapping/                     # Mapeo y análisis de variantes
│   ├── 01_illumina/                # BWA + Samtools
│   │   ├── aligned_sorted.bam
│   │   ├── flagstat.txt
│   │   └── coverage.txt
│   ├── 02_nanopore/                # Minimap2 + Samtools
│   │   ├── aligned_sorted.bam
│   │   └── coverage.txt
│   ├── 03_variants/                # BCFtools variant calling
│   │   ├── illumina_variants.vcf
│   │   ├── nanopore_variants.vcf
│   │   └── consensus.fasta
│   └── 04_coverage_analysis/       # Cobertura por cromosoma/plásmidos
│       ├── Chromosome.bam          # Cobertura solo cromosoma
│       ├── Plasmid_pKPHS1.bam      # Cobertura plásmido 1
│       ├── [...más plásmidos...]
│       └── coverage_summary.txt    # Resumen por secuencia
│
├── 05_annotation/                  # Anotación funcional
│   ├── 01_prokka/                  # Anotación Prokka
│   │   ├── URO5550422.gff
│   │   ├── URO5550422.gbk
│   │   ├── URO5550422.faa
│   │   └── URO5550422.ffn
│   ├── 02_bakta/                   # Anotación Bakta (alternativa)
│   └── prokka_config.txt           # Configuración específica K. pneumoniae
│
├── 06_amr_screening/               # Detección de genes AMR
│   ├── amrfinder_db/               # Base de datos local AMRFinderPlus
│   │   └── latest/
│   ├── 01_amrfinder/               # Resultados AMRFinderPlus (NCBI)
│   │   ├── amrfinder_results.tsv
│   │   └── amrfinder_summary.txt
│   ├── 02_abricate/                # Resultados Abricate (múltiples DBs)
│   │   ├── card_results.tsv
│   │   ├── resfinder_results.tsv
│   │   ├── ncbi_results.tsv
│   │   └── abricate_summary.tsv
│   └── 03_rgi/                     # Resultados RGI/CARD
│       ├── rgi_results.txt
│       └── rgi_heatmap.png
│
├── 07_typing/                      # Tipificación molecular
│   ├── mlst/                       # MLST typing
│   │   └── mlst_results.txt
│   ├── plasmids/                   # Detección de plásmidos
│   │   ├── plasmidfinder_results.txt
│   │   └── plasmid_reconstruction/
│   └── virulence/                  # Factores de virulencia
│       └── vfdb_results.txt
│
├── 08_results/                     # Resultados consolidados y figuras
│   ├── figures/
│   │   ├── assembly_comparison.png
│   │   ├── coverage_plot.png
│   │   └── amr_heatmap.png
│   ├── tables/
│   │   ├── amr_summary.xlsx
│   │   └── variant_summary.xlsx
│   └── reports/
│       ├── quality_dashboard.html
│       └── FINAL_REPORT.html
│
├── envs/                           # Archivos YAML de ambientes Conda
│   ├── bact_main.yml
│   ├── bact_amr.yml
│   └── bact_rgi.yml
│
├── scripts/                        # Scripts de automatización
│   ├── setup_environments.sh       # Instalación de ambientes
│   ├── verify_installation.sh      # Verificación de instalación
│   ├── link_raw_data.sh            # Enlazar datos crudos
│   ├── run_full_pipeline.sh        # Pipeline completo
│   ├── 01_qc_illumina.sh
│   ├── 02_qc_nanopore.sh
│   ├── 03_assembly_illumina.sh
│   ├── 04_assembly_nanopore.sh
│   ├── 05_assembly_hybrid.sh
│   ├── 06_mapping.sh
│   ├── 07_annotation.sh
│   ├── 08_amr_screening.sh
│   ├── 09_typing.sh
│   └── utils/
│       ├── analyze_coverage_per_sequence.sh  # Análisis cromosoma/plásmidos
│       ├── calculate_metrics.sh
│       ├── compare_amr_tools.py
│       ├── generate_plots.py
│       └── extract_plasmids.sh
│
├── test_data/                      # Datos de prueba
│
├── logs/                           # Logs de ejecución
│   └── [timestamp]_pipeline.log
│
├── setup_project_structure.sh      # Script de configuración inicial
├── PROJECT_CONFIG.md               # Configuración del proyecto
├── README.md                       # Este archivo
└── LICENSE                         # Licencia MIT
```

---

## 💻 Requisitos del Sistema

### Hardware Recomendado

| Componente | Mínimo | Recomendado | Óptimo |
|------------|--------|-------------|--------|
| **CPU** | 4 cores | 8 cores | 16+ cores |
| **RAM** | 16 GB | 32 GB | 64+ GB |
| **Almacenamiento** | 50 GB/muestra | 100 GB/muestra | SSD 200 GB/muestra |
| **Red** | 10 Mbps | 100 Mbps | 1 Gbps |

### Software Base
- **Sistema Operativo**: Linux/Unix (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- **Shell**: Bash 4.0+
- **Git**: 2.0+
- **Wget/Curl**: Para descargas
- **Conexión a internet**: Requerida para instalación inicial

### Tiempo de Ejecución Estimado

| Análisis | Hardware Mínimo | Hardware Recomendado |
|----------|-----------------|---------------------|
| QC Completo | 30-60 min | 15-30 min |
| Ensamblaje Illumina | 2-4 horas | 1-2 horas |
| Ensamblaje Nanopore | 1-2 horas | 30-60 min |
| Ensamblaje Híbrido | 4-8 horas | 2-4 horas |
| Mapeo + Variantes | 1-2 horas | 30-60 min |
| Detección AMR | 30-60 min | 15-30 min |
| Anotación | 30-60 min | 15-30 min |
| **Pipeline Completo** | **10-18 horas** | **5-9 horas** |

---

## 🛠️ Instalación y Configuración

### Paso 1: Clonar el Repositorio

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/Bacterial_Genomics_Project.git
cd Bacterial_Genomics_Project

# Verificar contenido
ls -lh
```

### Paso 2: Instalar Miniforge (Gestor de Paquetes)

Si aún no tienes un gestor de ambientes Conda instalado:

```bash
# Descargar Miniforge para Linux x86_64
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"

# Instalar
bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3

# Inicializar
$HOME/miniforge3/bin/conda init bash
source ~/.bashrc

# Verificar instalación
mamba --version
conda --version
```

### Paso 3: Configurar Canales de Bioconda

```bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

### Paso 4: Crear los Tres Ambientes Especializados

Debido a conflictos de dependencias entre herramientas bioinformáticas, el pipeline utiliza **tres ambientes Conda separados** para garantizar compatibilidad y reproducibilidad.

#### 🧬 Ambiente 1: `bact_main` (Pipeline Principal)

Contiene herramientas para QC, mapeo, ensamblaje y detección básica de AMR.

```bash
# Crear ambiente base
mamba create -n bact_main -c conda-forge -c bioconda -c defaults \
  python=3.10 pip pigz openjdk=11 -y

# Activar
conda activate bact_main

# Instalar herramientas de control de calidad
mamba install fastqc multiqc fastp nanoplot filtlong -y

# Instalar herramientas de mapeo y análisis de variantes
mamba install bwa minimap2 samtools bcftools bedtools blast -y

# Instalar ensambladores
mamba install unicycler flye spades quast bandage -y

# Instalar herramientas AMR y typing
mamba install ncbi-amrfinderplus barrnap mlst -y

# Instalar herramientas adicionales
mamba install seqtk kraken2 -y

# Configurar base de datos AMRFinderPlus (primera vez)
mkdir -p 06_amr_screening/amrfinder_db
amrfinder_update --database 06_amr_screening/amrfinder_db

# Actualizar base de datos MLST
mlst --list
```

**⏱️ Tiempo de instalación**: ~20 minutos  
**📦 Descarga de base de datos**: ~700 MB adicionales

#### 🦠 Ambiente 2: `bact_amr` (Anotación y AMR)

Dedicado a Prokka y Abricate, que requieren versiones específicas de Perl.

```bash
# Crear ambiente
mamba create -n bact_amr -c conda-forge -c bioconda -c defaults \
  python=3.9 prokka abricate -y

# Activar y configurar bases de datos
conda activate bact_amr
abricate --setupdb

# Verificar bases de datos disponibles
abricate --list
```

**⏱️ Tiempo de instalación**: ~15 minutos  
**📦 Descarga de bases de datos**: ~150 MB adicionales

#### 🧪 Ambiente 3: `bact_rgi` (AMR Avanzado)

Para RGI (Resistance Gene Identifier) con base de datos CARD.

```bash
# Crear ambiente
mamba create -n bact_rgi -c conda-forge -c bioconda -c defaults \
  python=3.11 rgi -y

# Activar
conda activate bact_rgi

# Descargar y cargar base de datos CARD
mkdir -p 06_amr_screening/rgi
cd 06_amr_screening/rgi
wget https://card.mcmaster.ca/latest/data
tar -xvf data ./card.json
rgi load --card_json card.json --local
cd ../..

# Verificar carga
rgi database --version --local
```

**⏱️ Tiempo de instalación**: ~10 minutos  
**📦 Descarga de base de datos CARD**: ~50 MB

### Paso 5: Script de Instalación Automatizada (Recomendado)

En lugar de instalar manualmente cada ambiente, usa el script automatizado:

```bash
# Dar permisos de ejecución
chmod +x scripts/setup_environments.sh

# Ejecutar instalación automatizada
bash scripts/setup_environments.sh

# Tiempo total estimado: ~45 minutos
```

Este script:
- ✅ Configura los 3 ambientes automáticamente
- ✅ Descarga todas las bases de datos necesarias
- ✅ Verifica que todo esté correctamente instalado
- ✅ Muestra un resumen al finalizar

### Paso 6: Verificar Instalación

```bash
# Ejecutar script de verificación
bash scripts/verify_installation.sh

# Salida esperada:
# ========================================
# Verificación de Instalación
# ========================================
# 
# [Ambiente: bact_main]
# ✓ FastQC: OK
# ✓ fastp: OK
# ✓ BWA: OK
# ✓ Samtools: OK
# ✓ SPAdes: OK
# ✓ Flye: OK
# ✓ Unicycler: OK
# ✓ QUAST: OK
# ✓ AMRFinderPlus: OK
# ✓ MLST: OK
# 
# [Ambiente: bact_amr]
# ✓ Prokka: OK
# ✓ Abricate: OK
# 
# [Ambiente: bact_rgi]
# ✓ RGI: OK
# 
# [Bases de Datos]
# ✓ AMRFinderPlus DB: Instalada
# ✓ Abricate DBs: 8 bases disponibles
# ✓ CARD DB: Instalada
# 
# ========================================
# ✓ TODAS LAS VERIFICACIONES PASARON
# El sistema está listo para usar
# ========================================
```

### Paso 7: Exportar Ambientes (Reproducibilidad)

```bash
# Crear directorio
mkdir -p envs

# Exportar ambientes
conda activate bact_main
conda env export --no-builds > envs/bact_main.yml

conda activate bact_amr
conda env export --no-builds > envs/bact_amr.yml

conda activate bact_rgi
conda env export --no-builds > envs/bact_rgi.yml

echo "Ambientes exportados en envs/"
```

**💡 Uso de ambientes exportados**:

```bash
# En otro servidor, recrear ambientes desde archivos YAML
mamba env create -f envs/bact_main.yml
mamba env create -f envs/bact_amr.yml
mamba env create -f envs/bact_rgi.yml

# Luego configurar bases de datos
bash scripts/setup_databases.sh
```

---

## 🔧 Configuración del Proyecto

### Paso 1: Crear Estructura y Descargar Referencia

```bash
# Ejecutar script de configuración inicial
bash setup_project_structure.sh

# Este script automáticamente:
# 1. Crea todos los directorios necesarios
# 2. Descarga el genoma de referencia K. pneumoniae (GCF_000240185.1)
# 3. Crea archivo de metadata
# 4. Genera documentación del proyecto
# 5. Crea scripts auxiliares
```

**Salida esperada**:

```
========================================
Configuración del Proyecto de Genómica Bacteriana
========================================

Muestra: URO5550422
Organismo: Klebsiella pneumoniae
Cepa de referencia: HS11286

[Paso 1/9] Creando estructura de directorios
✓ Creado: 00_raw_data/illumina
✓ Creado: 00_raw_data/nanopore
✓ Creado: 01_reference
[...más directorios...]

[Paso 2/9] Creando archivo de metadata
✓ Archivo de metadata creado

[Paso 3/9] Descargando genoma de referencia
ℹ Descargando GCF_000240185.1_ASM24018v2_genomic.fna.gz...
✓ Descarga completada
✓ Genoma de referencia listo

[Paso 4/9] Creando índice de secuencias de referencia
✓ Índice creado: 01_reference/reference_sequences.txt

[...más pasos...]

========================================
✓ Configuración Completada
========================================

Próximos pasos:
1. Enlazar datos de secuenciación
2. Ejecutar pipeline completo
```

### Paso 2: Revisar Información del Genoma de Referencia

```bash
# Ver información de las secuencias
cat 01_reference/reference_sequences.txt
```

**Contenido esperado**:

```
# Secuencias del Genoma de Referencia
# Klebsiella pneumoniae HS11286
# Accession: GCF_000240185.1

SeqID           Length      Type            Description
NC_016845.1     5333942     Chromosome      Cromosoma principal
NC_016838.1     122799      Plasmid         Plásmido pKPHS1
NC_016846.1     111195      Plasmid         Plásmido pKPHS2
NC_016839.1     105974      Plasmid         Plásmido pKPHS3
NC_016840.1     3751        Plasmid         Plásmido pKPHS4
NC_016847.1     3353        Plasmid         Plásmido pKPHS5
NC_016841.1     1308        Plasmid         Plásmido pKPHS6

# Total Genome Size: 5,682,322 bp
# Chromosome: 5,333,942 bp (93.9%)
# Plasmids: 348,380 bp (6.1%)
```

### Paso 3: Leer Configuración Completa del Proyecto

```bash
# Ver documentación completa
cat PROJECT_CONFIG.md

# O abrirlo con editor
nano PROJECT_CONFIG.md
```

Este archivo contiene:
- ✅ Información detallada de la muestra
- ✅ Descripción de las 7 secuencias (cromosoma + plásmidos)
- ✅ Consideraciones importantes para el análisis
- ✅ Comandos específicos para K. pneumoniae
- ✅ Referencias y próximos pasos

---

## 📊 Dataset de Ejemplo: URO5550422

### Información de la Muestra

- **ID**: URO5550422
- **Organismo**: *Klebsiella pneumoniae*
- **Origen**: Aislado clínico (urinario)
- **Referencia**: K. pneumoniae subsp. pneumoniae HS11286 (GCF_000240185.1)

### Archivos de Secuenciación

#### Illumina (Paired-end)
```
00_raw_data/illumina/
├── URO5550422_1.fastq.gz    # Forward reads (R1)
└── URO5550422_2.fastq.gz    # Reverse reads (R2)
```

**Especificaciones**:
- Plataforma: Illumina (MiSeq/NextSeq/NovaSeq)
- Química: Paired-end
- Longitud esperada: 150-300 bp
- Cobertura esperada: >50x

#### Nanopore (Long reads)
```
00_raw_data/nanopore/
└── URO5550422_1.fastq.gz    # Long reads
```

**⚠️ NOTA IMPORTANTE**: Este archivo tiene el mismo nombre que el R1 de Illumina, pero corresponde a **tecnología Nanopore**. Los archivos deben estar en directorios separados.

**Especificaciones**:
- Plataforma: Oxford Nanopore (MinION/GridION)
- Longitud esperada: 1-50 kb
- Cobertura esperada: >30x
- Calidad esperada: Q10-Q15

### Genoma de Referencia

**Archivo**: `GCF_000240185.1_ASM24018v2_genomic.fna`

**Composición genómica**:

| Secuencia | Accesión | Longitud (bp) | Tipo | % del Genoma |
|-----------|----------|---------------|------|--------------|
| Chromosome | NC_016845.1 | 5,333,942 | Cromosoma | 93.9% |
| pKPHS1 | NC_016838.1 | 122,799 | Plásmido | 2.2% |
| pKPHS2 | NC_016846.1 | 111,195 | Plásmido | 2.0% |
| pKPHS3 | NC_016839.1 | 105,974 | Plásmido | 1.9% |
| pKPHS4 | NC_016840.1 | 3,751 | Plásmido | 0.07% |
| pKPHS5 | NC_016847.1 | 3,353 | Plásmido | 0.06% |
| pKPHS6 | NC_016841.1 | 1,308 | Plásmido | 0.02% |
| **TOTAL** | - | **5,682,322** | - | **100%** |

### Enlazar Datos de Secuenciación

Una vez que tengas tus archivos de secuenciación, enlázalos al proyecto:

```bash
# Opción 1: Archivos en directorios separados (RECOMENDADO)
bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore

# Opción 2: Archivos en el mismo directorio
# (El script los diferenciará por subdirectorio de destino)
bash scripts/link_raw_data.sh /ruta/datos /ruta/datos

# Verificar enlaces
ls -lh 00_raw_data/illumina/
ls -lh 00_raw_data/nanopore/

# Salida esperada:
# 00_raw_data/illumina/URO5550422_1.fastq.gz -> /ruta/real/URO5550422_1.fastq.gz
# 00_raw_data/illumina/URO5

# README.md - Parte 2: Flujo de Trabajo Completo

## 🔬 Flujo de Trabajo Completo

Esta sección documenta el pipeline paso a paso para el análisis de *Klebsiella pneumoniae* URO5550422.

---

## Fase 1: Preparación de Datos

### 1.1 Verificar Estructura del Proyecto

```bash
# Verificar que la estructura esté creada
tree -L 2 -d

# Verificar genoma de referencia
ls -lh 01_reference/

# Verificar metadata
cat 00_raw_data/sample_metadata.txt
```

### 1.2 Enlazar Datos de Secuenciación

```bash
# Enlazar datos desde ubicación original
# IMPORTANTE: Illumina y Nanopore deben estar en directorios separados
bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore

# Verificar enlaces simbólicos
echo "=== Archivos Illumina ==="
ls -lh 00_raw_data/illumina/

echo "=== Archivos Nanopore ==="
ls -lh 00_raw_data/nanopore/

# Verificar tamaño de archivos
du -sh 00_raw_data/illumina/*
du -sh 00_raw_data/nanopore/*
```

**Salida esperada**:
```
=== Archivos Illumina ===
lrwxrwxrwx URO5550422_1.fastq.gz -> /datos/illumina/URO5550422_1.fastq.gz
lrwxrwxrwx URO5550422_2.fastq.gz -> /datos/illumina/URO5550422_2.fastq.gz

=== Archivos Nanopore ===
lrwxrwxrwx URO5550422_1.fastq.gz -> /datos/nanopore/URO5550422_1.fastq.gz
```

---

## Fase 2: Control de Calidad (QC)

### 2.1 QC de Lecturas Illumina

#### Script Automatizado

```bash
# Activar ambiente
conda activate bact_main

# Ejecutar QC de Illumina
bash scripts/01_qc_illumina.sh

# Tiempo estimado: 15-30 minutos
```

#### Comandos Detallados (Paso a Paso)

```bash
conda activate bact_main

# Crear directorios
mkdir -p 02_qc/01_illumina_raw 02_qc/02_illumina_trimmed

# Variables
SAMPLE="URO5550422"
R1="00_raw_data/illumina/${SAMPLE}_1.fastq.gz"
R2="00_raw_data/illumina/${SAMPLE}_2.fastq.gz"
THREADS=8

echo "========================================"
echo "QC Illumina - Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Paso 1: FastQC en datos crudos
echo "[1/3] FastQC en datos crudos..."
fastqc ${R1} ${R2} \
  -o 02_qc/01_illumina_raw/ \
  -t ${THREADS}

# Paso 2: Limpieza y recorte con fastp
echo "[2/3] Limpieza con fastp..."
fastp \
  -i ${R1} \
  -I ${R2} \
  -o 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz \
  -O 02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz \
  --detect_adapter_for_pe \
  --cut_front --cut_tail \
  --cut_window_size 4 \
  --cut_mean_quality 20 \
  --trim_poly_g \
  --qualified_quality_phred 20 \
  --unqualified_percent_limit 40 \
  --n_base_limit 5 \
  --length_required 50 \
  --thread ${THREADS} \
  --html 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html \
  --json 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json

# Paso 3: FastQC en datos limpios
echo "[3/3] FastQC en datos trimmed..."
fastqc 02_qc/02_illumina_trimmed/*_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ \
  -t ${THREADS}

echo "✓ QC Illumina completado"
echo "  Reportes en: 02_qc/01_illumina_raw/ y 02_qc/02_illumina_trimmed/"
```

#### Interpretar Resultados de fastp

```bash
# Ver resumen de fastp
cat 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json | grep -A 5 "summary"

# O abrir reporte HTML
firefox 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html
```

**📊 Métricas Clave a Verificar**:

| Métrica | Valor Esperado | Qué Indica |
|---------|----------------|------------|
| Total reads | >1M | Profundidad de secuenciación |
| % Reads passed filter | >95% | Calidad general buena |
| % Bases ≥Q30 | >90% | Alta calidad de bases |
| GC content | 55-58% | Normal para K. pneumoniae |
| % Duplicación | <20% | Buena complejidad de librería |
| % Adaptadores | <5% after trim | Limpieza efectiva |

**🚨 Señales de Alerta**:
- ❌ Q30 <80%: Secuenciación de baja calidad
- ❌ Duplicación >40%: Posible sobre-amplificación
- ❌ Reads passed filter <90%: Problemas con la librería
- ❌ GC content <50% o >65%: Posible contaminación

---

### 2.2 QC de Lecturas Nanopore

#### Script Automatizado

```bash
# Activar ambiente
conda activate bact_main

# Ejecutar QC de Nanopore
bash scripts/02_qc_nanopore.sh

# Tiempo estimado: 10-20 minutos
```

#### Comandos Detallados

```bash
conda activate bact_main

# Crear directorios
mkdir -p 02_qc/03_nanopore_raw 02_qc/04_nanopore_filtered

# Variables
SAMPLE="URO5550422"
NANOPORE="00_raw_data/nanopore/${SAMPLE}_1.fastq.gz"
THREADS=8

echo "========================================"
echo "QC Nanopore - Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Paso 1: NanoPlot en datos crudos
echo "[1/3] NanoPlot en datos crudos..."
NanoPlot \
  --fastq ${NANOPORE} \
  -o 02_qc/03_nanopore_raw/ \
  -t ${THREADS} \
  --plots kde dot \
  --N50 \
  --title "${SAMPLE} - Raw Nanopore Data"

# Paso 2: Filtrado con Filtlong
echo "[2/3] Filtrado con Filtlong..."
filtlong \
  --min_length 1000 \
  --keep_percent 90 \
  --target_bases 500000000 \
  ${NANOPORE} | \
  pigz -p ${THREADS} > 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz

# Paso 3: NanoPlot en datos filtrados
echo "[3/3] NanoPlot en datos filtrados..."
NanoPlot \
  --fastq 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ \
  -t ${THREADS} \
  --plots kde dot \
  --N50 \
  --title "${SAMPLE} - Filtered Nanopore Data"

echo "✓ QC Nanopore completado"
echo "  Reportes en: 02_qc/03_nanopore_raw/ y 02_qc/04_nanopore_filtered/"
```

#### Interpretar Resultados de NanoPlot

```bash
# Ver estadísticas principales
cat 02_qc/03_nanopore_raw/NanoStats.txt
cat 02_qc/04_nanopore_filtered/NanoStats.txt

# Comparar antes/después del filtrado
echo "=== COMPARACIÓN RAW vs FILTERED ==="
echo -n "Raw - Total bases: "
grep "Total bases:" 02_qc/03_nanopore_raw/NanoStats.txt | awk '{print $3}'

echo -n "Filtered - Total bases: "
grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt | awk '{print $3}'

echo -n "Raw - Mean read length: "
grep "Mean read length:" 02_qc/03_nanopore_raw/NanoStats.txt | awk '{print $4}'

echo -n "Filtered - Mean read length: "
grep "Mean read length:" 02_qc/04_nanopore_filtered/NanoStats.txt | awk '{print $4}'
```

**📊 Métricas Clave Nanopore**:

| Métrica | Raw (Esperado) | Filtered (Esperado) | Qué Indica |
|---------|----------------|---------------------|------------|
| Total reads | 50K-200K | 45K-180K | Rendimiento del flowcell |
| Mean read length | 3-10 kb | 4-12 kb | Calidad de extracción DNA |
| Read length N50 | 5-15 kb | 6-18 kb | Distribución de tamaños |
| Mean quality score | 10-13 | 11-14 | Calidad general de basecalling |
| Total bases | 300M-1G | 250M-900M | Cobertura esperada |

**🎯 Objetivos de Filtrado**:
- ✅ Eliminar reads <1 kb (fragmentos cortos)
- ✅ Mantener 90% de los datos de mejor calidad
- ✅ Mejorar N50 en 10-20%
- ✅ Alcanzar cobertura >30x para genoma de ~5.7 Mb

**Cálculo de Cobertura**:
```bash
# Cobertura = Total bases / Tamaño genoma
# Ejemplo: 500 Mb / 5.7 Mb = ~88x cobertura
TOTAL_BASES=$(grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt | awk '{print $3}' | sed 's/,//g')
GENOME_SIZE=5682322
COVERAGE=$(echo "scale=1; $TOTAL_BASES / $GENOME_SIZE" | bc)
echo "Cobertura estimada: ${COVERAGE}x"
```

---

### 2.3 Reporte Consolidado con MultiQC

```bash
conda activate bact_main

mkdir -p 02_qc/05_multiqc

SAMPLE="URO5550422"

# Generar reporte integrado de todos los análisis QC
multiqc 02_qc/ \
  -o 02_qc/05_multiqc/ \
  --filename ${SAMPLE}_multiqc_report \
  --title "QC Report - ${SAMPLE}" \
  --comment "Klebsiella pneumoniae - Illumina + Nanopore" \
  --force

echo "✓ Reporte MultiQC generado"
echo "  Abrir: firefox 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html"
```

**📊 Reporte MultiQC Incluye**:
- ✅ FastQC de datos Illumina (raw y trimmed)
- ✅ Estadísticas de fastp
- ✅ Distribuciones de calidad y longitud
- ✅ Contenido GC
- ✅ Niveles de duplicación
- ✅ Presencia de adaptadores

---

## Fase 3: Estrategias de Ensamblaje

### 3.1 Ensamblaje Solo Illumina (SPAdes)

#### Script Automatizado

```bash
conda activate bact_main

# Ejecutar ensamblaje Illumina
bash scripts/03_assembly_illumina.sh

# Tiempo estimado: 1-3 horas
```

#### Comandos Detallados

```bash
conda activate bact_main

mkdir -p 03_assembly/01_illumina_only

SAMPLE="URO5550422"
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
THREADS=8
MEMORY=16

echo "========================================"
echo "Ensamblaje Illumina (SPAdes)"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Ensamblaje con SPAdes
spades.py \
  -1 ${R1_TRIM} \
  -2 ${R2_TRIM} \
  -o 03_assembly/01_illumina_only/ \
  --isolate \
  --careful \
  -t ${THREADS} \
  -m ${MEMORY} \
  --cov-cutoff auto

# Copiar contigs finales
cp 03_assembly/01_illumina_only/contigs.fasta \
   03_assembly/01_illumina_only/assembly_illumina.fasta

# Estadísticas básicas del ensamblaje
echo ""
echo "=== ESTADÍSTICAS DEL ENSAMBLAJE ==="
echo -n "Número de contigs: "
grep -c ">" 03_assembly/01_illumina_only/assembly_illumina.fasta

echo -n "Contig más largo: "
cat 03_assembly/01_illumina_only/assembly_illumina.fasta | \
  awk '/^>/ {if (seqlen){print seqlen}; seqlen=0; next} {seqlen += length($0)} END {print seqlen}' | \
  sort -rn | head -1

echo -n "Tamaño total: "
cat 03_assembly/01_illumina_only/assembly_illumina.fasta | \
  grep -v ">" | tr -d '\n' | wc -c

echo ""
echo "✓ Ensamblaje Illumina completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de SPAdes Explicados**:
- `--isolate`: Optimizado para genomas bacterianos aislados
- `--careful`: Minimiza mismatches y pequeños indels
- `--cov-cutoff auto`: Elimina contigs de baja cobertura automáticamente
- `-t 8`: Usar 8 threads
- `-m 16`: Límite de memoria 16 GB

**📊 Resultados Esperados para K. pneumoniae**:

| Métrica | Valor Esperado | Interpretación |
|---------|----------------|----------------|
| Número de contigs | 50-150 | Aceptable para Illumina |
| Contig más largo | 200-800 kb | Buena continuidad |
| Tamaño total | 5.3-5.9 Mb | Cercano al genoma de referencia |
| N50 | 100-300 kb | Calidad buena |
| L50 | 10-30 | Ensamblaje fragmentado pero útil |

---

### 3.2 Ensamblaje Solo Nanopore (Flye)

#### Script Automatizado

```bash
conda activate bact_main

# Ejecutar ensamblaje Nanopore
bash scripts/04_assembly_nanopore.sh

# Tiempo estimado: 30-90 minutos
```

#### Comandos Detallados

```bash
conda activate bact_main

mkdir -p 03_assembly/02_nanopore_only

SAMPLE="URO5550422"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8

echo "========================================"
echo "Ensamblaje Nanopore (Flye)"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Ensamblaje con Flye
flye \
  --nano-raw ${NANOPORE_FILT} \
  --out-dir 03_assembly/02_nanopore_only/ \
  --genome-size 5.7m \
  --threads ${THREADS} \
  --iterations 3 \
  --meta

# Copiar ensamblaje final
cp 03_assembly/02_nanopore_only/assembly.fasta \
   03_assembly/02_nanopore_only/assembly_nanopore.fasta

# Estadísticas del ensamblaje
echo ""
echo "=== ESTADÍSTICAS DEL ENSAMBLAJE ==="
cat 03_assembly/02_nanopore_only/assembly_info.txt

echo ""
echo "✓ Ensamblaje Nanopore completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de Flye Explicados**:
- `--nano-raw`: Lecturas Nanopore sin corregir
- `--genome-size 5.7m`: Tamaño esperado (5.7 Mb para K. pneumoniae)
- `--iterations 3`: Pulir 3 veces (mejora calidad)
- `--meta`: Modo metagenoma (útil para detectar múltiples replicons)

**📊 Resultados Esperados**:

| Métrica | Valor Esperado | Interpretación |
|---------|----------------|----------------|
| Número de contigs | 2-10 | Muy buena continuidad |
| Contig más largo | 5-5.5 Mb | Probablemente cromosoma completo |
| Tamaño total | 5.5-6.0 Mb | Incluye cromosoma + plásmidos |
| Contigs circulares | 1-7 | Cromosoma + plásmidos cerrados |

**🔍 Análisis del archivo assembly_info.txt**:

```bash
# Ver información de circularidad
echo "=== CONTIGS CIRCULARES ==="
grep "circular=Y" 03_assembly/02_nanopore_only/assembly_info.txt

# Identificar posible cromosoma (contig más largo)
echo "=== POSIBLE CROMOSOMA ==="
awk '$2 > 5000000' 03_assembly/02_nanopore_only/assembly_info.txt

# Identificar posibles plásmidos (contigs circulares pequeños)
echo "=== POSIBLES PLÁSMIDOS ==="
awk '$2 < 200000 && $4 == "Y"' 03_assembly/02_nanopore_only/assembly_info.txt
```

---

### 3.3 Ensamblaje Híbrido (Unicycler)

#### Script Automatizado

```bash
conda activate bact_main

# Ejecutar ensamblaje híbrido
bash scripts/05_assembly_hybrid.sh

# Tiempo estimado: 3-6 horas
```

#### Comandos Detallados

```bash
conda activate bact_main

mkdir -p 03_assembly/03_hybrid

SAMPLE="URO5550422"
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8

echo "========================================"
echo "Ensamblaje Híbrido (Unicycler)"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Ensamblaje híbrido con Unicycler
unicycler \
  -1 ${R1_TRIM} \
  -2 ${R2_TRIM} \
  -l ${NANOPORE_FILT} \
  -o 03_assembly/03_hybrid/ \
  --threads ${THREADS} \
  --mode normal \
  --min_fasta_length 200

# Copiar ensamblaje final
cp 03_assembly/03_hybrid/assembly.fasta \
   03_assembly/03_hybrid/assembly_hybrid.fasta

# Estadísticas básicas
echo ""
echo "=== ESTADÍSTICAS DEL ENSAMBLAJE ==="
grep ">" 03_assembly/03_hybrid/assembly_hybrid.fasta | \
  sed 's/.*length=\([0-9]*\).*/\1/' | \
  awk '{
    count++; 
    total+=$1; 
    if($1>max) max=$1;
    lengths[count]=$1
  } 
  END {
    print "Número de contigs:", count;
    print "Tamaño total:", total, "bp";
    print "Contig más largo:", max, "bp";
    print "Tamaño promedio:", int(total/count), "bp"
  }'

echo ""
echo "✓ Ensamblaje Híbrido completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de Unicycler Explicados**:
- `--mode normal`: Balance entre velocidad y calidad
- `--min_fasta_length 200`: Descartar contigs <200 bp
- Unicycler usa Illumina para corregir errores de Nanopore

**📊 Resultados Esperados (MEJOR CALIDAD)**:

| Métrica | Valor Esperado | Por Qué es Mejor |
|---------|----------------|------------------|
| Número de contigs | 1-10 | Continuidad de Nanopore |
| Contig más largo | 5.3-5.4 Mb | Cromosoma completo cerrado |
| Tamaño total | 5.6-5.8 Mb | Genoma completo + plásmidos |
| Precisión | >99.99% | Corrección con Illumina |
| Contigs circulares | 3-7 | Cromosoma + plásmidos principales |

**🎯 Ventajas del Ensamblaje Híbrido**:
- ✅ **Continuidad**: Lecturas largas resuelven repeticiones
- ✅ **Precisión**: Illumina corrige errores de Nanopore
- ✅ **Plásmidos cerrados**: Mejor para caracterizar elementos móviles
- ✅ **Genoma completo**: Mayor probabilidad de cromosoma circular cerrado

---

### 3.4 Evaluación Comparativa de Ensamblajes (QUAST)

```bash
conda activate bact_main

mkdir -p 03_assembly/04_quast_evaluation

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"

echo "========================================"
echo "Evaluación de Ensamblajes (QUAST)"
echo "========================================"

# Evaluar los tres ensamblajes contra referencia
quast.py \
  03_assembly/01_illumina_only/assembly_illumina.fasta \
  03_assembly/02_nanopore_only/assembly_nanopore.fasta \
  03_assembly/03_hybrid/assembly_hybrid.fasta \
  -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads 8 \
  --labels "Illumina,Nanopore,Hybrid" \
  --glimmer \
  --min-contig 200

echo ""
echo "✓ Evaluación QUAST completada"
echo "  Reporte: 03_assembly/04_quast_evaluation/report.html"
echo ""

# Abrir reporte
firefox 03_assembly/04_quast_evaluation/report.html &

# Ver resumen en terminal
cat 03_assembly/04_quast_evaluation/report.txt
```

**📊 Tabla Comparativa Ejemplo**:

```
Métrica                    | Illumina  | Nanopore | Híbrido  | Mejor
---------------------------|-----------|----------|----------|-------
# contigs (>= 0 bp)       | 98        | 7        | 4        | Híbrido
# contigs (>= 1000 bp)    | 87        | 7        | 4        | Híbrido
Total length (>= 0 bp)    | 5,612,345 | 5,723,892| 5,689,234| Nanopore
Largest contig            | 387,234   | 5,334,567| 5,335,123| Híbrido
N50                       | 145,678   | 5,334,567| 5,335,123| Híbrido
L50                       | 12        | 1        | 1        | Híbrido
GC (%)                    | 57.12     | 57.08    | 57.10    | -
# genes                   | 5,234     | 5,412    | 5,398    | Nanopore
Genome fraction (%)       | 98.76     | 99.82    | 99.95    | Híbrido
Mismatches per 100 kbp    | 12.3      | 145.7    | 8.9      | Híbrido
Indels per 100 kbp        | 5.6       | 387.2    | 4.1      | Híbrido
```

**🏆 Selección del Mejor Ensamblaje**:

```bash
# Criterio de decisión automatizado
echo "=== CRITERIOS DE SELECCIÓN ==="
echo "1. Menor número de contigs: Híbrido/Nanopore"
echo "2. Mayor N50: Híbrido/Nanopore"
echo "3. Mejor cobertura del genoma: Híbrido"
echo "4. Menor tasa de errores: Híbrido/Illumina"
echo ""
echo "🏆 RECOMENDACIÓN: Usar ensamblaje HÍBRIDO para análisis downstream"
echo ""

# Copiar mejor ensamblaje para análisis posteriores
cp 03_assembly/03_hybrid/assembly_hybrid.fasta 03_assembly/BEST_ASSEMBLY.fasta
echo "✓ Mejor ensamblaje copiado a: 03_assembly/BEST_ASSEMBLY.fasta"
```

---

## Fase 4: Mapeo y Análisis de Variantes

⚠️ **IMPORTANTE para K. pneumoniae**: El genoma de referencia contiene 7 secuencias (1 cromosoma + 6 plásmidos). El mapeo debe hacerse contra el archivo completo.

### 4.1 Indexar Genoma de Referencia

```bash
conda activate bact_main

REFERENCE="01_reference/reference.fasta"

echo "========================================"
echo "Indexando Genoma de Referencia"
echo "========================================"

# Índice para BWA (Illumina)
echo "[1/3] Creando índice BWA..."
bwa index ${REFERENCE}

# Índice para Samtools
echo "[2/3] Creando índice FAI..."
samtools faidx ${REFERENCE}

# Índice para Minimap2 (Nanopore) - opcional, se puede hacer on-the-fly
echo "[3/3] Creando índice Minimap2..."
minimap2 -d ${REFERENCE}.mmi ${REFERENCE}

echo "✓ Índices creados"
ls -lh 01_reference/
```

---

### 4.2 Mapeo de Lecturas Illumina

```bash
conda activate bact_main

mkdir -p 04_mapping/01_illumina

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
THREADS=8

echo "========================================"
echo "Mapeo Illumina - Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Mapeo con BWA-MEM
echo "[1/4] Mapeo con BWA-MEM..."
bwa mem -t ${THREADS} \
  -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
  ${REFERENCE} \
  ${R1_TRIM} \
  ${R2_TRIM} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/01_illumina/aligned_sorted.bam

# Indexar BAM
echo "[2/4] Indexando BAM..."
samtools index 04_mapping/01_illumina/aligned_sorted.bam

# Estadísticas de mapeo
echo "[3/4] Calculando estadísticas..."
samtools flagstat 04_mapping/01_illumina/aligned_sorted.bam > \
  04_mapping/01_illumina/flagstat.txt

samtools coverage 04_mapping/01_illumina/aligned_sorted.bam > \
  04_mapping/01_illumina/coverage.txt

samtools depth 04_mapping/01_illumina/aligned_sorted.bam | \
  awk '{sum+=$3; count++} END {print "Mean Depth:", sum/count}' > \
  04_mapping/01_illumina/mean_depth.txt

# Análisis por secuencia (cromosoma y plásmidos)
echo "[4/4] Análisis de cobertura por secuencia..."
bash scripts/utils/analyze_coverage_per_sequence.sh \
  04_mapping/01_illumina/aligned_sorted.bam \
  04_mapping/04_coverage_analysis/illumina

echo "✓ Mapeo


# README.md - Parte 3: Anotación, Detección AMR y Tipificación

## Fase 4: Mapeo y Análisis de Variantes (Continuación)

### 4.3 Mapeo de Lecturas Nanopore

```bash
conda activate bact_main

mkdir -p 04_mapping/02_nanopore

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8

echo "========================================"
echo "Mapeo Nanopore - Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Mapeo con Minimap2
echo "[1/4] Mapeo con Minimap2..."
minimap2 -ax map-ont -t ${THREADS} \
  ${REFERENCE} \
  ${NANOPORE_FILT} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/02_nanopore/aligned_sorted.bam

# Indexar BAM
echo "[2/4] Indexando BAM..."
samtools index 04_mapping/02_nanopore/aligned_sorted.bam

# Estadísticas
echo "[3/4] Calculando estadísticas..."
samtools flagstat 04_mapping/02_nanopore/aligned_sorted.bam > \
  04_mapping/02_nanopore/flagstat.txt

samtools coverage 04_mapping/02_nanopore/aligned_sorted.bam > \
  04_mapping/02_nanopore/coverage.txt

samtools depth 04_mapping/02_nanopore/aligned_sorted.bam | \
  awk '{sum+=$3; count++} END {print "Mean Depth:", sum/count}' > \
  04_mapping/02_nanopore/mean_depth.txt

# Análisis por secuencia
echo "[4/4] Análisis de cobertura por secuencia..."
bash scripts/utils/analyze_coverage_per_sequence.sh \
  04_mapping/02_nanopore/aligned_sorted.bam \
  04_mapping/04_coverage_analysis/nanopore

echo "✓ Mapeo Nanopore completado"
echo "  Fin: $(date)"

# Mostrar resumen
cat 04_mapping/02_nanopore/flagstat.txt
echo ""
cat 04_mapping/04_coverage_analysis/nanopore/coverage_summary.txt
```

**📊 Comparar Cobertura Illumina vs Nanopore**:

```bash
echo "=== COMPARACIÓN DE COBERTURA POR SECUENCIA ==="
echo ""
echo "ILLUMINA:"
cat 04_mapping/04_coverage_analysis/illumina/coverage_summary.txt
echo ""
echo "NANOPORE:"
cat 04_mapping/04_coverage_analysis/nanopore/coverage_summary.txt
```

---

### 4.4 Llamado de Variantes

#### Variantes de Lecturas Illumina

```bash
conda activate bact_main

mkdir -p 04_mapping/03_variants

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"
BAM_ILLUMINA="04_mapping/01_illumina/aligned_sorted.bam"

echo "========================================"
echo "Llamado de Variantes - Illumina"
echo "========================================"

# Llamado de variantes con BCFtools
echo "[1/3] Generando pileup..."
bcftools mpileup -Ou -f ${REFERENCE} ${BAM_ILLUMINA} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz

# Indexar VCF
echo "[2/3] Indexando VCF..."
bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz

# Estadísticas de variantes
echo "[3/3] Generando estadísticas..."
bcftools stats 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_illumina_variants_stats.txt

# Filtrar variantes de alta calidad
bcftools view -i 'QUAL>=30 && DP>=10' \
  04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz

echo "✓ Llamado de variantes Illumina completado"

# Resumen de variantes
echo ""
echo "=== RESUMEN DE VARIANTES ==="
bcftools stats 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz | \
  grep "^SN" | grep -E "SNPs|indels|MNPs"
```

#### Variantes de Lecturas Nanopore

```bash
conda activate bact_main

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"
BAM_NANOPORE="04_mapping/02_nanopore/aligned_sorted.bam"

echo "========================================"
echo "Llamado de Variantes - Nanopore"
echo "========================================"

# Llamado de variantes
bcftools mpileup -Ou -f ${REFERENCE} ${BAM_NANOPORE} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz

# Estadísticas
bcftools stats 04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_nanopore_variants_stats.txt

echo "✓ Llamado de variantes Nanopore completado"
```

#### Generar Secuencia Consenso

```bash
conda activate bact_main

SAMPLE="URO5550422"
REFERENCE="01_reference/reference.fasta"

echo "========================================"
echo "Generando Secuencia Consenso"
echo "========================================"

# Consenso basado en variantes Illumina (mayor precisión)
bcftools consensus -f ${REFERENCE} \
  04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_consensus_illumina.fasta

echo "✓ Secuencia consenso generada"
echo "  Archivo: 04_mapping/03_variants/${SAMPLE}_consensus_illumina.fasta"
```

**📊 Tipos de Variantes Detectadas**:

| Tipo | Illumina | Nanopore | Confianza |
|------|----------|----------|-----------|
| SNPs | Alto | Bajo | Mayor en Illumina |
| INDELs pequeños (<50bp) | Alto | Medio | Validar ambos |
| INDELs grandes (>50bp) | Bajo | Alto | Mayor en Nanopore |
| Variantes estructurales | No detecta | Sí detecta | Nanopore único |

---

## Fase 5: Anotación Funcional

### 5.1 Anotación con Prokka

```bash
conda activate bact_amr

mkdir -p 05_annotation/01_prokka

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"  # Usar mejor ensamblaje (híbrido)
THREADS=8

echo "========================================"
echo "Anotación con Prokka"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Anotar genoma
prokka \
  --outdir 05_annotation/01_prokka/ \
  --prefix ${SAMPLE} \
  --kingdom Bacteria \
  --genus Klebsiella \
  --species pneumoniae \
  --strain ${SAMPLE} \
  --gram neg \
  --usegenus \
  --addgenes \
  --addmrna \
  --rfam \
  --cpus ${THREADS} \
  ${ASSEMBLY}

echo ""
echo "✓ Anotación Prokka completada"
echo "  Fin: $(date)"

# Mostrar resumen
echo ""
echo "=== RESUMEN DE ANOTACIÓN ==="
cat 05_annotation/01_prokka/${SAMPLE}.txt
```

**📊 Archivos Generados por Prokka**:

| Archivo | Descripción | Uso |
|---------|-------------|-----|
| `*.gff` | Anotaciones en formato GFF3 | Visualización en genome browsers |
| `*.gbk` | Formato GenBank | Análisis filogenético |
| `*.faa` | Secuencias proteicas | Búsqueda de homología |
| `*.ffn` | Secuencias de genes (DNA) | Análisis de expresión |
| `*.fna` | Secuencias de contigs | Secuencia anotada |
| `*.txt` | Resumen estadístico | Reporte rápido |

**🔍 Análisis del Resumen**:

```bash
SAMPLE="URO5550422"

echo "=== ESTADÍSTICAS DE ANOTACIÓN ==="
grep "CDS" 05_annotation/01_prokka/${SAMPLE}.txt
grep "rRNA" 05_annotation/01_prokka/${SAMPLE}.txt
grep "tRNA" 05_annotation/01_prokka/${SAMPLE}.txt
grep "tmRNA" 05_annotation/01_prokka/${SAMPLE}.txt

echo ""
echo "=== GENES TOTALES ==="
grep -c "CDS" 05_annotation/01_prokka/${SAMPLE}.gff

echo ""
echo "=== GENES CON FUNCIÓN ASIGNADA ==="
grep "CDS" 05_annotation/01_prokka/${SAMPLE}.gff | grep -v "hypothetical" | wc -l

echo ""
echo "=== GENES HIPOTÉTICOS ==="
grep "hypothetical protein" 05_annotation/01_prokka/${SAMPLE}.gff | wc -l
```

**📊 Valores Esperados para K. pneumoniae**:

| Característica | Cantidad Esperada |
|----------------|-------------------|
| Genes (CDS) | 5,000 - 5,500 |
| rRNA | 7-9 (3 operones x 3) |
| tRNA | 75-85 |
| tmRNA | 1 |
| CRISPR arrays | 0-3 |
| Genes con función | 70-80% |
| Genes hipotéticos | 20-30% |

---

### 5.2 Anotación con Bakta (Alternativa Moderna - Opcional)

```bash
conda activate bact_main

# Nota: Bakta requiere base de datos grande (~30 GB)
# Descarga solo si tienes espacio y tiempo

# Descargar base de datos (solo primera vez)
# mkdir -p 05_annotation/bakta_db
# bakta_db download --output 05_annotation/bakta_db --type full

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"
THREADS=8

echo "========================================"
echo "Anotación con Bakta (Opcional)"
echo "========================================"

# Anotar con Bakta
bakta \
  --db 05_annotation/bakta_db \
  --output 05_annotation/02_bakta/ \
  --prefix ${SAMPLE} \
  --locus-tag ${SAMPLE} \
  --threads ${THREADS} \
  --genus Klebsiella \
  --species pneumoniae \
  --strain ${SAMPLE} \
  ${ASSEMBLY}

echo "✓ Anotación Bakta completada"
```

**💡 Bakta vs Prokka**:

| Característica | Prokka | Bakta |
|----------------|--------|-------|
| Velocidad | Rápido (15-30 min) | Moderado (30-60 min) |
| Base de datos | RefSeq | UniProt + RefSeq |
| Actualización | Estática | Regular |
| Calidad anotación | Buena | Excelente |
| Espacio en disco | ~1 GB | ~30 GB |
| **Recomendación** | Rutina | Publicación |

---

## Fase 6: Detección de Genes de Resistencia Antimicrobiana (AMR)

### 6.1 AMRFinderPlus (NCBI - Recomendado)

```bash
conda activate bact_main

mkdir -p 06_amr_screening/01_amrfinder

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"
PROTEINS="05_annotation/01_prokka/${SAMPLE}.faa"
DB_PATH="06_amr_screening/amrfinder_db"
THREADS=8

echo "========================================"
echo "Detección AMR - AMRFinderPlus"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Verificar y actualizar base de datos
echo "[1/3] Verificando base de datos..."
amrfinder_update --database ${DB_PATH}

# Ejecutar AMRFinderPlus en nucleótidos (ensamblaje)
echo "[2/3] Buscando genes AMR en ensamblaje..."
amrfinder \
  --nucleotide ${ASSEMBLY} \
  --database ${DB_PATH} \
  --organism Klebsiella \
  --output 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_nucleotide.tsv \
  --plus \
  --name ${SAMPLE} \
  --threads ${THREADS}

# Ejecutar AMRFinderPlus en proteínas (mayor sensibilidad)
echo "[3/3] Buscando genes AMR en proteínas..."
amrfinder \
  --protein ${PROTEINS} \
  --database ${DB_PATH} \
  --organism Klebsiella \
  --output 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_protein.tsv \
  --plus \
  --threads ${THREADS}

echo ""
echo "✓ AMRFinderPlus completado"
echo "  Fin: $(date)"

# Generar resumen
echo ""
echo "=== RESUMEN DE GENES AMR ==="
echo "Genes AMR detectados (proteínas):"
grep -v "^#" 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_protein.tsv | wc -l

echo ""
echo "Por clase de antibiótico:"
grep -v "^#" 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_protein.tsv | \
  cut -f11 | sort | uniq -c | sort -rn
```

**📊 Interpretar Resultados de AMRFinderPlus**:

```bash
SAMPLE="URO5550422"
RESULT_FILE="06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_protein.tsv"

# Crear resumen legible
cat > 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_summary.txt << EOF
# Resumen AMRFinderPlus - ${SAMPLE}
# Generado: $(date)

=== GENES AMR POR CLASE DE ANTIBIÓTICO ===
EOF

# Agrupar por clase
grep -v "^#" ${RESULT_FILE} | \
  awk -F'\t' '{print $11}' | \
  sort | uniq -c | sort -rn >> \
  06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_summary.txt

cat >> 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_summary.txt << EOF

=== GENES AMR DE ALTA CONFIANZA (>95% identidad, >95% cobertura) ===
EOF

grep -v "^#" ${RESULT_FILE} | \
  awk -F'\t' '($9 >= 95 && $10 >= 95) {printf "%-20s %-30s %5.1f%% %5.1f%%\n", $6, $11, $9, $10}' >> \
  06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_summary.txt

echo ""
cat 06_amr_screening/01_amrfinder/${SAMPLE}_amrfinder_summary.txt
```

**🎯 Genes AMR Importantes en K. pneumoniae**:

| Gen | Clase Antibiótico | Impacto Clínico | Localización Típica |
|-----|-------------------|-----------------|---------------------|
| **blaKPC** | Carbapenems | 🚨 CRÍTICO | Plásmido |
| **blaNDM** | Carbapenems | 🚨 CRÍTICO | Plásmido |
| **blaOXA-48** | Carbapenems | 🚨 CRÍTICO | Plásmido |
| **blaCTX-M** | Cefalosporinas | ⚠️ ALTO | Plásmido |
| **blaSHV** | β-lactámicos | ⚠️ ALTO | Cromosoma/Plásmido |
| **blaTEM** | β-lactámicos | ⚠️ ALTO | Plásmido |
| **qnr** | Quinolonas | ⚠️ MEDIO | Plásmido |
| **aac(6')-Ib** | Aminoglicósidos | ⚠️ MEDIO | Plásmido |
| **fosA** | Fosfomicina | ℹ️ BAJO | Cromosoma |
| **oqxAB** | Quinolonas | ℹ️ BAJO | Cromosoma |

---

### 6.2 Abricate (Múltiples Bases de Datos)

```bash
conda activate bact_amr

mkdir -p 06_amr_screening/02_abricate

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"

echo "========================================"
echo "Detección AMR - Abricate"
echo "Múltiples bases de datos"
echo "========================================"

# Lista de bases de datos a usar
DATABASES=("card" "resfinder" "ncbi" "argannot" "megares")

for DB in "${DATABASES[@]}"; do
    echo "[Ejecutando contra: $DB]"
    abricate --db $DB \
      ${ASSEMBLY} > \
      06_amr_screening/02_abricate/${SAMPLE}_${DB}_results.tsv
done

# Generar resumen consolidado
echo ""
echo "Generando resumen consolidado..."
abricate --summary 06_amr_screening/02_abricate/${SAMPLE}_*_results.tsv > \
  06_amr_screening/02_abricate/${SAMPLE}_abricate_summary.tsv

echo "✓ Abricate completado"
echo ""

# Mostrar resumen
echo "=== RESUMEN POR BASE DE DATOS ==="
for DB in "${DATABASES[@]}"; do
    COUNT=$(grep -v "^#" 06_amr_screening/02_abricate/${SAMPLE}_${DB}_results.tsv | wc -l)
    echo "$DB: $COUNT genes detectados"
done
```

**📊 Comparación de Bases de Datos**:

| Base de Datos | Enfoque | Ventajas | Uso Recomendado |
|---------------|---------|----------|-----------------|
| **CARD** | Completo, mecanismos | Anotaciones detalladas | Primera opción |
| **ResFinder** | Clínico | Validado experimentalmente | Confirmación |
| **NCBI** | Amplio | Actualizado regularmente | Screening general |
| **ARG-ANNOT** | Histórico | Cobertura amplia | Genes raros |
| **MEGARes** | Metagenomas | Diversidad alta | Ambiental |

---

### 6.3 RGI (CARD - Análisis Avanzado)

```bash
conda activate bact_rgi

mkdir -p 06_amr_screening/03_rgi

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"
THREADS=8

echo "========================================"
echo "Detección AMR - RGI (CARD)"
echo "========================================"

# Verificar base de datos CARD
echo "[1/3] Verificando base de datos CARD..."
rgi database --version --local

# Ejecutar análisis RGI
echo "[2/3] Ejecutando RGI..."
rgi main \
  --input_sequence ${ASSEMBLY} \
  --output_file 06_amr_screening/03_rgi/${SAMPLE}_rgi \
  --input_type contig \
  --local \
  --clean \
  --alignment_tool BLAST \
  --include_loose \
  --num_threads ${THREADS}

# Generar heatmap
echo "[3/3] Generando heatmap..."
rgi heatmap \
  --input 06_amr_screening/03_rgi/${SAMPLE}_rgi.txt \
  --output 06_amr_screening/03_rgi/${SAMPLE}_rgi_heatmap \
  --category drug_class \
  --cluster both

echo ""
echo "✓ RGI completado"
echo "  Resultados: 06_amr_screening/03_rgi/${SAMPLE}_rgi.txt"
echo "  Heatmap: 06_amr_screening/03_rgi/${SAMPLE}_rgi_heatmap.png"

# Resumen de genes
echo ""
echo "=== RESUMEN RGI ==="
echo "Genes AMR detectados:"
grep -v "^ORF" 06_amr_screening/03_rgi/${SAMPLE}_rgi.txt | wc -l

echo ""
echo "Por categoría de detección:"
tail -n +2 06_amr_screening/03_rgi/${SAMPLE}_rgi.txt | \
  cut -f6 | sort | uniq -c
```

**🔍 Categorías de Detección RGI**:

| Categoría | Criterios | Interpretación |
|-----------|-----------|----------------|
| **Perfect** | 100% identidad, 100% cobertura | Alta confianza |
| **Strict** | >95% identidad, >95% cobertura | Confianza alta |
| **Loose** | >60% identidad, >60% cobertura | Revisar manualmente |

---

### 6.4 Consolidación de Resultados AMR

```bash
conda activate bact_main

SAMPLE="URO5550422"

echo "========================================"
echo "Consolidando Resultados AMR"
echo "========================================"

# Crear script Python para consolidar
cat > 06_amr_screening/consolidate_amr.py << 'EOFPYTHON'
#!/usr/bin/env python3
import pandas as pd
import sys

sample = sys.argv[1]

print(f"Consolidando resultados AMR para {sample}")

# Leer AMRFinderPlus
amrf = pd.read_csv(f'06_amr_screening/01_amrfinder/{sample}_amrfinder_protein.tsv', 
                   sep='\t', comment='#')
amrf_genes = set(amrf['Gene symbol'].dropna())

# Leer Abricate CARD
abr = pd.read_csv(f'06_amr_screening/02_abricate/{sample}_card_results.tsv', 
                  sep='\t')
abr_genes = set(abr['GENE'].dropna())

# Leer RGI
rgi = pd.read_csv(f'06_amr_screening/03_rgi/{sample}_rgi.txt', sep='\t')
rgi_genes = set(rgi['Best_Hit_ARO'].dropna())

# Genes consenso (detectados por ≥2 herramientas)
all_genes = amrf_genes | abr_genes | rgi_genes
consensus = set()

for gene in all_genes:
    count = 0
    if gene in amrf_genes: count += 1
    if gene in abr_genes: count += 1
    if gene in rgi_genes: count += 1
    
    if count >= 2:
        consensus.add(gene)

print(f"\n=== RESUMEN DE DETECCIÓN ===")
print(f"AMRFinderPlus: {len(amrf_genes)} genes")
print(f"Abricate (CARD): {len(abr_genes)} genes")
print(f"RGI: {len(rgi_genes)} genes")
print(f"\nGenes de ALTA CONFIANZA (≥2 herramientas): {len(consensus)}")
print("\nGenes consenso:")
for gene in sorted(consensus):
    print(f"  - {gene}")

# Guardar resultados
with open(f'06_amr_screening/{sample}_amr_consensus.txt', 'w') as f:
    f.write(f"# Genes AMR de Alta Confianza - {sample}\n")
    f.write(f"# Detectados por ≥2 herramientas\n\n")
    for gene in sorted(consensus):
        f.write(f"{gene}\n")

print(f"\n✓ Resultados guardados en: 06_amr_screening/{sample}_amr_consensus.txt")
EOFPYTHON

# Ejecutar consolidación
python3 06_amr_screening/consolidate_amr.py ${SAMPLE}
```

---

## Fase 7: Tipificación Molecular

### 7.1 MLST (Multi-Locus Sequence Typing)

```bash
conda activate bact_main

mkdir -p 07_typing/mlst

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"

echo "========================================"
echo "MLST Typing"
echo "Muestra: ${SAMPLE}"
echo "========================================"

# Ejecutar MLST
mlst --scheme kpneumoniae ${ASSEMBLY} > 07_typing/mlst/${SAMPLE}_mlst.txt

echo "✓ MLST completado"
echo ""

# Mostrar resultado
cat 07_typing/mlst/${SAMPLE}_mlst.txt

# Extraer ST
ST=$(awk '{print $3}' 07_typing/mlst/${SAMPLE}_mlst.txt)
echo ""
echo "=== SEQUENCE TYPE (ST) ==="
echo "ST: ${ST}"

# Información adicional del ST (buscar en base de datos)
echo ""
echo "Para más información sobre este ST, visita:"
echo "https://bigsdb.pasteur.fr/klebsiella/klebsiella.html"
```

**📊 STs Comunes en K. pneumoniae**:

| ST | Características | Relevancia Clínica |
|----|-----------------|-------------------|
| **ST258** | Productor de KPC | Alta mortalidad, brotes hospitalarios |
| **ST11** | MDR, productor de carbapenemasas | Pandémico |
| **ST15** | Productor de CTX-M | Altamente virulento |
| **ST23** | Hipervirulento (hvKp) | Infecciones invasivas |
| **ST101** | Productor de NDM | Emergente |

---

### 7.2 Detección de Plásmidos

```bash
conda activate bact_main

mkdir -p 07_typing/plasmids

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"

echo "========================================"
echo "Detección de Plásmidos"
echo "========================================"

# Usar Abricate con base de datos PlasmidFinder
conda activate bact_amr

abricate --db plasmidfinder \
  ${ASSEMBLY} > \
  07_typing/plasmids/${SAMPLE}_plasmidfinder.tsv

echo "✓ PlasmidFinder completado"
echo ""

# Mostrar resultados
echo "=== PLÁSMIDOS DETECTADOS ==="
grep -v "^#" 07_typing/plasmids/${SAMPLE}_plasmidfinder.tsv | \
  awk -F'\t' '{printf "%-30s %-15s %s%%\n", $6, $13, $10}'
```

**🧬 Análisis de Plásmidos en el Ensamblaje Nanopore**:

```bash
SAMPLE="URO5550422"

echo "=== ANÁLISIS DE CONTIGS CIRCULARES (Posibles Plásmidos) ==="

# Buscar contigs circulares en assembly_info.txt de Flye
if [ -f "03_assembly/02_nanopore_only/assembly_info.txt" ]; then
    echo ""
    echo "Contigs circulares en ensamblaje Nanopore:"
    grep "Y" 03_assembly/02_nanopore_only/assembly_info.txt | \
      awk '$2 < 500000 {print $1, $2" bp", "Circular"}'
fi

# Para ensamblaje híbrido
if [ -f "03_assembly/03_hybrid/assembly.gfa" ]; then
    echo ""
    echo "Analizando circularidad en ensamblaje híbrido..."
    # Bandage puede detectar plásmidos circulares
fi
```

---

### 7.3 Factores de Virulencia

```bash
conda activate bact_amr

mkdir -p 07_typing/virulence

SAMPLE="URO5550422"
ASSEMBLY="03_assembly/BEST_ASSEMBLY.fasta"

echo "========================================"
echo "Detección de Factores de Virulencia"
echo "========================================"

# Usar Abricate con base de datos VFDB
abricate --db vfdb \
  ${ASSEMBLY} > \
  07_typing/virulence/${SAMPLE}_vfdb.tsv

echo "✓ VFDB completado"
echo ""

# Resumen
echo "=== FACTORES DE VIRULENCIA DETECTADOS ==="
echo "Total de genes:"
grep -v "^#" 07_typing/virulence/${SAMPLE}_vfdb.tsv | wc -l

echo ""
echo "Genes de alta confianza (>90% identidad):"
awk -F'\t' '$10 > 90' 07_typing/virul
