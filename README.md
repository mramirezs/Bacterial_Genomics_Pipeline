# 🧬 Pipeline de Vigilancia Genómica y Análisis de Resistencia Antimicrobiana en Bacterias

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bioinformatics](https://img.shields.io/badge/Bioinformatics-Pipeline-blue.svg)]()

Este repositorio documenta un flujo de trabajo bioinformático completo para el análisis de genomas bacterianos clínicos utilizando datos de secuenciación de nueva generación (NGS). El pipeline integra tres estrategias de análisis complementarias: **Ensamblaje con Illumina**, **Ensamblaje con Nanopore** y **Ensamblaje Híbrido (Illumina + Nanopore)**, junto con detección exhaustiva de genes de resistencia a antimicrobianos (AMR) y análisis de variantes genómicas.

---

## 📋 Tabla de Contenidos

- [Características del Pipeline](#-características-del-pipeline)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Flujo de Trabajo](#-flujo-de-trabajo)
- [Resultados Esperados](#-resultados-esperados)
- [Interpretación de Resultados](#-interpretación-de-resultados)
- [Solución de Problemas](#-solución-de-problemas)
- [Referencias](#-referencias)

---

## 🎯 Características del Pipeline

### Tecnologías Soportadas
- **Illumina** (lecturas cortas, paired-end): Alta precisión, ideal para SNPs/INDELs
- **Oxford Nanopore** (lecturas largas): Ensamblajes contiguos, detección de variantes estructurales
- **Híbrido** (Illumina + Nanopore): Combina precisión y continuidad

### Análisis Incluidos
- ✅ Control de calidad exhaustivo (raw y trimmed reads)
- ✅ Tres estrategias de ensamblaje independientes
- ✅ Mapeo contra genoma de referencia y llamado de variantes
- ✅ Detección de genes AMR con múltiples bases de datos
- ✅ Anotación funcional de genomas
- ✅ Evaluación de calidad de ensamblajes
- ✅ Visualización y reportes integrados

---

## 📂 Estructura del Proyecto

```text
Bacterial_Genomics_Project/
├── 00_raw_data/                    # Datos crudos de secuenciación
│   ├── illumina/                   # Lecturas paired-end (R1, R2)
│   │   ├── sample_R1.fastq.gz
│   │   └── sample_R2.fastq.gz
│   └── nanopore/                   # Lecturas largas ONT
│       └── sample_ont.fastq.gz
│
├── 01_reference/                   # Genomas de referencia (opcional)
│   ├── reference.fasta
│   └── reference.gff
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
│   └── 03_variants/                # BCFtools variant calling
│       ├── illumina_variants.vcf
│       ├── nanopore_variants.vcf
│       └── consensus.fasta
│
├── 05_annotation/                  # Anotación funcional
│   ├── 01_prokka/                  # Anotación Prokka
│   │   ├── genome.gff
│   │   ├── genome.gbk
│   │   ├── genome.faa
│   │   └── genome.ffn
│   └── 02_bakta/                   # Anotación Bakta (alternativa)
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
├── 07_results/                     # Resultados consolidados y figuras
│   ├── assembly_comparison.png
│   ├── amr_summary.xlsx
│   └── final_report.html
│
├── envs/                           # Archivos YAML de ambientes Conda
│   ├── bact_main.yml
│   ├── bact_amr.yml
│   └── bact_rgi.yml
│
├── scripts/                        # Scripts de automatización
│   ├── 01_qc_illumina.sh
│   ├── 02_qc_nanopore.sh
│   ├── 03_assembly_illumina.sh
│   ├── 04_assembly_nanopore.sh
│   ├── 05_assembly_hybrid.sh
│   ├── 06_mapping.sh
│   ├── 07_annotation.sh
│   ├── 08_amr_screening.sh
│   └── run_full_pipeline.sh
│
├── logs/                           # Logs de ejecución
│   └── [timestamp]_pipeline.log
│
├── README.md                       # Este archivo
└── LICENSE                         # Licencia MIT

```

---

## 💻 Requisitos del Sistema

### Hardware Recomendado
- **CPU**: Mínimo 8 cores (16+ cores recomendado para ensamblaje híbrido)
- **RAM**: Mínimo 16 GB (32+ GB recomendado)
- **Almacenamiento**: 50-100 GB libres por muestra (dependiendo de la cobertura)

### Software Base
- Linux/Unix (Ubuntu 20.04+, CentOS 7+, o similar)
- Bash shell
- Git
- Conexión a internet (para instalación de herramientas)

---

## 🛠️ Instalación y Configuración

### Paso 1: Instalar Miniforge (Gestor de Paquetes)

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
```

### Paso 2: Configurar Canales de Bioconda

```bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

### Paso 3: Crear los Tres Ambientes Especializados

Debido a conflictos de dependencias entre herramientas bioinformáticas, el pipeline utiliza **tres ambientes Conda separados** para garantizar compatibilidad y reproducibilidad.

#### 🧬 Ambiente 1: `bact_main` (Pipeline Principal)

Contiene herramientas para QC, mapeo, ensamblaje y detección básica de AMR.

```bash
# Crear ambiente base
conda create -n bact_main -c conda-forge -c bioconda -c defaults \
  python=3.10 pip pigz openjdk=11 -y

# Activar
conda activate bact_main

# Instalar herramientas de control de calidad
conda install fastqc multiqc fastp nanoplot filtlong -y

# Instalar herramientas de mapeo y análisis de variantes
conda install bwa minimap2 samtools bcftools bedtools blast -y

# Instalar ensambladores
conda install unicycler flye spades quast bandage -y

# Instalar herramientas AMR
conda install ncbi-amrfinderplus barrnap -y

# Configurar base de datos AMRFinderPlus (primera vez)
mkdir -p 06_amr_screening/amrfinder_db
amrfinder_update --database 06_amr_screening/amrfinder_db
```

**⏱️ Tiempo de instalación**: ~15 minutos  
**📦 Descarga de base de datos**: ~500 MB adicionales

#### 🦠 Ambiente 2: `bact_amr` (Anotación y AMR)

Dedicado a Prokka y Abricate, que requieren versiones específicas de Perl.

```bash
# Crear ambiente
mamba create -n bact_amr -c conda-forge -c bioconda -c defaults \
  python=3.9 prokka abricate -y

# Activar y configurar bases de datos
mamba activate bact_amr
abricate --setupdb
```

**⏱️ Tiempo de instalación**: ~10 minutos  
**📦 Descarga de bases de datos**: ~100 MB adicionales

#### 🧪 Ambiente 3: `bact_rgi` (AMR Avanzado)

Para RGI (Resistance Gene Identifier) con base de datos CARD.

```bash
# Crear ambiente
mamba create -n bact_rgi -c conda-forge -c bioconda -c defaults \
  python=3.11 rgi -y

# Activar
mamba activate bact_rgi

# Descargar y cargar base de datos CARD
mkdir -p 06_amr_screening/rgi
cd 06_amr_screening/rgi
wget https://card.mcmaster.ca/latest/data
tar -xvf data
rgi load --card_json card.json --local
cd ../..
```

**⏱️ Tiempo de instalación**: ~10 minutos  
**📦 Descarga de base de datos CARD**: ~50 MB

### Paso 4: Verificar Instalaciones

```bash
# Verificar bact_main
conda activate bact_main
fastqc --version
bwa 2>&1 | head -3
samtools --version
unicycler --version
spades.py --version
flye --version
quast --version
amrfinder --version

# Verificar bact_amr
conda activate bact_amr
prokka --version
abricate --version
abricate --list

# Verificar bact_rgi
conda activate bact_rgi
rgi main --version
rgi database --version --local
```

### Paso 5: Exportar Ambientes (Reproducibilidad)

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
```

### Paso 6: Clonar o Replicar en Otro Servidor

```bash
# Opción A: Clonar repositorio
git clone https://github.com/tu-usuario/Bacterial_Genomics_Project.git
cd Bacterial_Genomics_Project

# Opción B: Copiar archivos YML
scp envs/*.yml usuario@servidor:/ruta/proyecto/envs/

# Crear ambientes desde YML
mamba env create -f envs/bact_main.yml
mamba env create -f envs/bact_amr.yml
mamba env create -f envs/bact_rgi.yml

# Configurar bases de datos
conda activate bact_main
amrfinder_update --database 06_amr_screening/amrfinder_db

conda activate bact_amr
abricate --setupdb

conda activate bact_rgi
# Descargar CARD y ejecutar: rgi load --card_json card.json --local
```

---

## 🔬 Flujo de Trabajo

### Fase 1: Preparación de Datos

#### 1.1 Crear Enlaces Simbólicos a Datos Crudos

```bash
# Crear directorio de datos crudos
mkdir -p 00_raw_data/illumina 00_raw_data/nanopore

# Crear enlaces simbólicos (evita duplicar datos)
ln -s /ruta/absoluta/datos/sample_R1.fastq.gz 00_raw_data/illumina/
ln -s /ruta/absoluta/datos/sample_R2.fastq.gz 00_raw_data/illumina/
ln -s /ruta/absoluta/datos/sample_ont.fastq.gz 00_raw_data/nanopore/
```

#### 1.2 Descargar Genoma de Referencia (Opcional)

Para análisis de mapeo y detección de variantes:

```bash
mkdir -p 01_reference

# Ejemplo: Descargar E. coli K-12 MG1655 desde NCBI
# Para otras bacterias, buscar en NCBI Genome: https://www.ncbi.nlm.nih.gov/genome/
wget -O 01_reference/reference.fasta.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"

gunzip 01_reference/reference.fasta.gz
```

---

### Fase 2: Control de Calidad (QC)

#### 2.1 QC de Lecturas Illumina

```bash
conda activate bact_main

# Crear directorios
mkdir -p 02_qc/01_illumina_raw 02_qc/02_illumina_trimmed

# FastQC en datos crudos
fastqc 00_raw_data/illumina/*.fastq.gz \
  -o 02_qc/01_illumina_raw/ \
  -t 8

# Limpieza y recorte con fastp
fastp \
  -i 00_raw_data/illumina/sample_R1.fastq.gz \
  -I 00_raw_data/illumina/sample_R2.fastq.gz \
  -o 02_qc/02_illumina_trimmed/sample_R1_trimmed.fastq.gz \
  -O 02_qc/02_illumina_trimmed/sample_R2_trimmed.fastq.gz \
  --detect_adapter_for_pe \
  --cut_front --cut_tail \
  --trim_poly_g \
  --qualified_quality_phred 20 \
  --unqualified_percent_limit 40 \
  --n_base_limit 5 \
  --length_required 50 \
  --thread 8 \
  --html 02_qc/02_illumina_trimmed/fastp_report.html \
  --json 02_qc/02_illumina_trimmed/fastp_report.json

# FastQC en datos limpios
fastqc 02_qc/02_illumina_trimmed/*_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ \
  -t 8
```

**📊 Resultados QC Illumina**

_[Incluir aquí capturas de pantalla o estadísticas clave]_

| Métrica | Raw Reads | Trimmed Reads |
|---------|-----------|---------------|
| Total Reads | | |
| % Bases ≥Q30 | | |
| GC Content (%) | | |
| Duplicación (%) | | |
| Adaptadores Detectados | | |

---

#### 2.2 QC de Lecturas Nanopore

```bash
conda activate bact_main

# Crear directorios
mkdir -p 02_qc/03_nanopore_raw 02_qc/04_nanopore_filtered

# NanoPlot en datos crudos
NanoPlot \
  --fastq 00_raw_data/nanopore/sample_ont.fastq.gz \
  -o 02_qc/03_nanopore_raw/ \
  -t 8 \
  --plots kde

# Filtrado con Filtlong
filtlong \
  --min_length 1000 \
  --keep_percent 90 \
  --target_bases 500000000 \
  00_raw_data/nanopore/sample_ont.fastq.gz | \
  pigz > 02_qc/04_nanopore_filtered/sample_ont_filtered.fastq.gz

# NanoPlot en datos filtrados
NanoPlot \
  --fastq 02_qc/04_nanopore_filtered/sample_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ \
  -t 8 \
  --plots kde
```

**📊 Resultados QC Nanopore**

_[Incluir aquí gráficos de distribución de longitud y calidad]_

| Métrica | Raw Reads | Filtered Reads |
|---------|-----------|----------------|
| Total Reads | | |
| Mean Read Length (bp) | | |
| Median Read Length (bp) | | |
| Mean Quality Score | | |
| N50 (bp) | | |
| Total Bases (Gb) | | |

---

#### 2.3 Reporte Consolidado con MultiQC

```bash
conda activate bact_main

mkdir -p 02_qc/05_multiqc

# Generar reporte integrado
multiqc 02_qc/ \
  -o 02_qc/05_multiqc/ \
  --filename multiqc_report_complete
```

**📊 Reporte MultiQC**

_[Enlace a reporte HTML o capturas de pantalla clave]_

---

### Fase 3: Estrategias de Ensamblaje

#### 3.1 Ensamblaje Solo Illumina (SPAdes)

```bash
conda activate bact_main

mkdir -p 03_assembly/01_illumina_only

# Ensamblaje con SPAdes
spades.py \
  -1 02_qc/02_illumina_trimmed/sample_R1_trimmed.fastq.gz \
  -2 02_qc/02_illumina_trimmed/sample_R2_trimmed.fastq.gz \
  -o 03_assembly/01_illumina_only/ \
  --careful \
  -t 8 -m 16

# Copiar contigs finales
cp 03_assembly/01_illumina_only/contigs.fasta \
   03_assembly/01_illumina_only/assembly_illumina.fasta
```

**📊 Estadísticas Ensamblaje Illumina**

| Métrica | Valor |
|---------|-------|
| Número de Contigs | |
| Tamaño Total del Ensamblaje (bp) | |
| Contig Más Largo (bp) | |
| N50 (bp) | |
| L50 | |
| GC Content (%) | |

---

#### 3.2 Ensamblaje Solo Nanopore (Flye)

```bash
conda activate bact_main

mkdir -p 03_assembly/02_nanopore_only

# Ensamblaje con Flye
flye \
  --nano-raw 02_qc/04_nanopore_filtered/sample_ont_filtered.fastq.gz \
  --out-dir 03_assembly/02_nanopore_only/ \
  --threads 8 \
  --genome-size 5m

# Copiar ensamblaje final
cp 03_assembly/02_nanopore_only/assembly.fasta \
   03_assembly/02_nanopore_only/assembly_nanopore.fasta
```

**📊 Estadísticas Ensamblaje Nanopore**

| Métrica | Valor |
|---------|-------|
| Número de Contigs | |
| Tamaño Total del Ensamblaje (bp) | |
| Contig Más Largo (bp) | |
| N50 (bp) | |
| L50 | |
| GC Content (%) | |
| Circularidad Detectada | |

---

#### 3.3 Ensamblaje Híbrido (Unicycler)

```bash
conda activate bact_main

mkdir -p 03_assembly/03_hybrid

# Ensamblaje híbrido con Unicycler
unicycler \
  -1 02_qc/02_illumina_trimmed/sample_R1_trimmed.fastq.gz \
  -2 02_qc/02_illumina_trimmed/sample_R2_trimmed.fastq.gz \
  -l 02_qc/04_nanopore_filtered/sample_ont_filtered.fastq.gz \
  -o 03_assembly/03_hybrid/ \
  -t 8

# Copiar ensamblaje final
cp 03_assembly/03_hybrid/assembly.fasta \
   03_assembly/03_hybrid/assembly_hybrid.fasta
```

**📊 Estadísticas Ensamblaje Híbrido**

| Métrica | Valor |
|---------|-------|
| Número de Contigs | |
| Tamaño Total del Ensamblaje (bp) | |
| Contig Más Largo (bp) | |
| N50 (bp) | |
| L50 | |
| GC Content (%) | |
| Circularidad Detectada | |

---

#### 3.4 Evaluación Comparativa de Ensamblajes (QUAST)

```bash
conda activate bact_main

mkdir -p 03_assembly/04_quast_evaluation

# Evaluación con QUAST (con referencia)
quast.py \
  03_assembly/01_illumina_only/assembly_illumina.fasta \
  03_assembly/02_nanopore_only/assembly_nanopore.fasta \
  03_assembly/03_hybrid/assembly_hybrid.fasta \
  -r 01_reference/reference.fasta \
  -o 03_assembly/04_quast_evaluation/ \
  --threads 8 \
  --labels "Illumina,Nanopore,Hybrid"

# Si no tienes referencia, omite el parámetro -r
```

**📊 Comparación de Ensamblajes (QUAST)**

_[Incluir tabla comparativa generada por QUAST]_

| Métrica | Illumina | Nanopore | Híbrido |
|---------|----------|----------|---------|
| Contigs (≥500 bp) | | | |
| Tamaño Total (bp) | | | |
| Contig Más Largo (bp) | | | |
| N50 (bp) | | | |
| L50 | | | |
| GC (%) | | | |
| Genes Predichos | | | |
| % Genoma Cubierto | | | |
| Mismatches por 100 kb | | | |

**🎯 Recomendación de Ensamblaje:**

_[Seleccionar el mejor ensamblaje basado en métricas QUAST]_

---

### Fase 4: Mapeo y Análisis de Variantes

#### 4.1 Mapeo de Lecturas Illumina

```bash
conda activate bact_main

mkdir -p 04_mapping/01_illumina

# Indexar referencia (solo primera vez)
bwa index 01_reference/reference.fasta

# Mapeo con BWA-MEM
bwa mem -t 8 \
  01_reference/reference.fasta \
  02_qc/02_illumina_trimmed/sample_R1_trimmed.fastq.gz \
  02_qc/02_illumina_trimmed/sample_R2_trimmed.fastq.gz | \
  samtools view -Sb - | \
  samtools sort -@ 8 -o 04_mapping/01_illumina/aligned_sorted.bam

# Indexar BAM
samtools index 04_mapping/01_illumina/aligned_sorted.bam

# Estadísticas de mapeo
samtools flagstat 04_mapping/01_illumina/aligned_sorted.bam > \
  04_mapping/01_illumina/flagstat.txt

samtools coverage 04_mapping/01_illumina/aligned_sorted.bam > \
  04_mapping/01_illumina/coverage.txt

samtools depth 04_mapping/01_illumina/aligned_sorted.bam | \
  awk '{sum+=$3} END {print "Mean Depth:", sum/NR}' > \
  04_mapping/01_illumina/mean_depth.txt
```

**📊 Estadísticas de Mapeo Illumina**

| Métrica | Valor |
|---------|-------|
| Total Reads | |
| Reads Mapeadas (%) | |
| Reads Paired (%) | |
| Cobertura Media | |
| Duplicados (%) | |

---

#### 4.2 Mapeo de Lecturas Nanopore

```bash
conda activate bact_main

mkdir -p 04_mapping/02_nanopore

# Mapeo con Minimap2
minimap2 -ax map-ont -t 8 \
  01_reference/reference.fasta \
  02_qc/04_nanopore_filtered/sample_ont_filtered.fastq.gz | \
  samtools view -Sb - | \
  samtools sort -@ 8 -o 04_mapping/02_nanopore/aligned_sorted.bam

# Indexar BAM
samtools index 04_mapping/02_nanopore/aligned_sorted.bam

# Estadísticas
samtools flagstat 04_mapping/02_nanopore/aligned_sorted.bam > \
  04_mapping/02_nanopore/flagstat.txt

samtools coverage 04_mapping/02_nanopore/aligned_sorted.bam > \
  04_mapping/02_nanopore/coverage.txt
```

**📊 Estadísticas de Mapeo Nanopore**

| Métrica | Valor |
|---------|-------|
| Total Reads | |
| Reads Mapeadas (%) | |
| Cobertura Media | |

---

#### 4.3 Llamado de Variantes y Consenso

```bash
conda activate bact_main

mkdir -p 04_mapping/03_variants

# Llamado de variantes Illumina
bcftools mpileup -Ou -f 01_reference/reference.fasta \
  04_mapping/01_illumina/aligned_sorted.bam | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/illumina_variants.vcf.gz

bcftools index 04_mapping/03_variants/illumina_variants.vcf.gz

# Llamado de variantes Nanopore
bcftools mpileup -Ou -f 01_reference/reference.fasta \
  04_mapping/02_nanopore/aligned_sorted.bam | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/nanopore_variants.vcf.gz

bcftools index 04_mapping/03_variants/nanopore_variants.vcf.gz

# Generar secuencia consenso (Illumina)
bcftools consensus -f 01_reference/reference.fasta \
  04_mapping/03_variants/illumina_variants.vcf.gz > \
  04_mapping/03_variants/consensus_illumina.fasta

# Estadísticas de variantes
bcftools stats 04_mapping/03_variants/illumina_variants.vcf.gz > \
  04_mapping/03_variants/illumina_variants_stats.txt

bcftools stats 04_mapping/03_variants/nanopore_variants.vcf.gz > \
  04_mapping/03_variants/nanopore_variants_stats.txt
```

**📊 Variantes Detectadas**

| Tipo de Variante | Illumina | Nanopore |
|------------------|----------|----------|
| SNPs | | |
| INDELs | | |
| Variantes en Genes | | |

---

### Fase 5: Anotación Funcional

#### 5.1 Anotación con Prok
