# 04. Análisis de Resistencia Antimicrobiana y Tipificación Molecular

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Anotación Funcional](#anotación-funcional)
3. [Detección de Resistencia Antimicrobiana](#detección-de-resistencia-antimicrobiana)
4. [Tipificación Molecular (MLST)](#tipificación-molecular-mlst)
5. [Detección de Plásmidos](#detección-de-plásmidos)
6. [Factores de Virulencia](#factores-de-virulencia)
7. [Reportes Consolidados](#reportes-consolidados)
8. [Interpretación de Resultados](#interpretación-de-resultados)

---

## Introducción

Este módulo describe los análisis **downstream** comunes a todos los pipelines (Illumina, Nanopore e Híbrido). Una vez que tengas un ensamblaje de alta calidad, estos análisis te permitirán:

- 🧬 Identificar genes y funciones (anotación)
- 💊 Detectar genes de resistencia antimicrobiana (AMR)
- 🔬 Tipificar molecularmente la cepa (MLST)
- 🧫 Identificar plásmidos
- ⚠️ Detectar factores de virulencia
- 📊 Generar reportes integrados

### Requisitos Previos

✅ Ensamblaje de alta calidad de **cualquier pipeline**:
- Illumina: `03_assembly/01_illumina_only/{SAMPLE}_illumina_assembly.fasta`
- Nanopore: `03_assembly/02_nanopore_only/{SAMPLE}_nanopore_polished.fasta`
- Híbrido: `03_assembly/03_hybrid/{SAMPLE}_hybrid_assembly.fasta`

✅ Ambientes conda configurados:
- `bact_main` - Herramientas principales
- `bact_amr` - AMRFinderPlus
- `bact_rgi` - RGI (Resistance Gene Identifier)

---

## Anotación Funcional

La anotación identifica genes, predice funciones y genera archivos para análisis posteriores.

### Opción 1: Prokka (Rápida, Recomendada)

**Ventajas:**
- ⚡ Rápida (5-10 minutos)
- 📦 Fácil de instalar
- ✅ Ideal para screening inicial

**Uso:**

```bash
# Activar ambiente
conda activate bact_main

# Variables
SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="05_annotation/01_prokka"

# Ejecutar Prokka
prokka \
    --outdir "${OUTPUT}" \
    --prefix "${SAMPLE}" \
    --kingdom Bacteria \
    --genus Neisseria \
    --species gonorrhoeae \
    --strain "${SAMPLE}" \
    --cpus 8 \
    --force \
    "${ASSEMBLY}"
```

**Archivos generados:**

```
05_annotation/01_prokka/
├── FRAN93.fna          # Secuencias nucleotídicas de genes
├── FRAN93.faa          # Secuencias proteicas
├── FRAN93.gff          # Anotación en formato GFF3
├── FRAN93.gbk          # GenBank format
├── FRAN93.tsv          # Tabla de genes
├── FRAN93.txt          # Estadísticas
└── FRAN93.log          # Log de ejecución
```

**Estadísticas típicas (N. gonorrhoeae):**

```
organism: Neisseria gonorrhoeae FRAN93
contigs: 1
bases: 2153920
CDS: 2045
rRNA: 12
tRNA: 50
tmRNA: 1
```

### Opción 2: Bakta (Más Completa)

**Ventajas:**
- 🎯 Base de datos actualizada
- 🔬 Anotación más detallada
- 📊 Mejor para publicaciones

**Desventajas:**
- ⏱️ Más lenta (20-30 minutos)
- 💾 Requiere base de datos (~30 GB)

**Instalación de base de datos:**

```bash
conda activate bact_main

# Descargar base de datos (solo una vez)
bakta_db download --output ~/bakta_db --type light
```

**Uso:**

```bash
bakta \
    --db ~/bakta_db/db-light \
    --output 05_annotation/02_bakta \
    --prefix "${SAMPLE}" \
    --genus Neisseria \
    --species gonorrhoeae \
    --strain "${SAMPLE}" \
    --threads 8 \
    --force \
    "${ASSEMBLY}"
```

**Recomendación:** Usa **Prokka** para análisis rutinarios y **Bakta** para publicaciones.

---

## Detección de Resistencia Antimicrobiana

Usaremos **tres herramientas complementarias** para maximizar la detección:

### 1. AMRFinderPlus (NCBI)

**Características:**
- 🏆 Base de datos oficial NCBI
- ✅ Actualizada regularmente
- 🎯 Alta especificidad

**Instalación:**

```bash
# Crear ambiente específico
conda create -n bact_amr -c conda-forge -c bioconda ncbi-amrfinderplus -y
conda activate bact_amr

# Actualizar base de datos
amrfinder --update
```

**Uso:**

```bash
conda activate bact_amr

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
PROTEINS="05_annotation/01_prokka/${SAMPLE}.faa"
OUTPUT="06_amr_typing/01_amrfinder"

mkdir -p "${OUTPUT}"

# Análisis con proteínas (más preciso)
amrfinder \
    --nucleotide "${ASSEMBLY}" \
    --protein "${PROTEINS}" \
    --organism Neisseria \
    --threads 8 \
    --plus \
    --output "${OUTPUT}/${SAMPLE}_amrfinder.tsv"
```

**Salida (ejemplo para N. gonorrhoeae):**

```
Gene symbol  Sequence name  Element type       Class               Subclass
penA         contig_1       AMR                Beta-lactam         Penicillin
mtrR         contig_1       POINT              Fluoroquinolone     Efflux
gyrA         contig_1       POINT              Fluoroquinolone     Target modification
parC         contig_1       POINT              Fluoroquinolone     Target modification
23S_rRNA     contig_1       POINT              Macrolide           Target modification
```

**Interpretación:**
- `AMR` - Gen de resistencia completo
- `POINT` - Mutación puntual asociada a resistencia
- `STRESS` - Gen de respuesta a estrés (puede conferir resistencia)

### 2. Abricate (Multi-base de datos)

**Características:**
- 🔄 Múltiples bases de datos
- ⚡ Muy rápida
- 📊 Fácil de comparar resultados

**Bases de datos disponibles:**
- `card` - CARD (Comprehensive Antibiotic Resistance Database)
- `resfinder` - ResFinder
- `ncbi` - NCBI AMRFinderPlus
- `argannot` - ARG-ANNOT
- `megares` - MEGARes
- `plasmidfinder` - PlasmidFinder
- `vfdb` - VFDB (Virulence factors)

**Uso:**

```bash
conda activate bact_main

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/02_abricate"

mkdir -p "${OUTPUT}"

# Ejecutar con múltiples bases de datos
for DB in card resfinder ncbi argannot; do
    echo "Ejecutando Abricate con base de datos: ${DB}"
    
    abricate \
        --db "${DB}" \
        --threads 8 \
        --minid 80 \
        --mincov 80 \
        "${ASSEMBLY}" \
        > "${OUTPUT}/${SAMPLE}_${DB}.tsv"
done

# Resumen consolidado
abricate --summary "${OUTPUT}"/*.tsv > "${OUTPUT}/${SAMPLE}_summary.tsv"
```

**Salida (ejemplo):**

```
FILE     SEQUENCE  START    END      STRAND  GENE    COVERAGE  IDENTITY  DATABASE
FRAN93   contig_1  145820   147124   +       penA    100.00    99.85     card
FRAN93   contig_1  892341   893123   +       mtrR    100.00    98.23     card
FRAN93   contig_1  1234567  1235432  +       tetM    95.23     89.45     resfinder
```

**Parámetros clave:**
- `--minid 80` - Identidad mínima 80% (ajustable)
- `--mincov 80` - Cobertura mínima 80% (ajustable)

### 3. RGI (CARD - Resistance Gene Identifier)

**Características:**
- 🎯 Análisis más detallado
- 🧬 Predice mecanismos de resistencia
- 📈 Categoriza por nivel de evidencia

**Instalación:**

```bash
# Crear ambiente específico
conda create -n bact_rgi -c conda-forge -c bioconda -c defaults rgi -y
conda activate bact_rgi

# Cargar base de datos CARD
rgi load --card_json ~/card_database/card.json --local
```

**Uso:**

```bash
conda activate bact_rgi

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/03_rgi"

mkdir -p "${OUTPUT}"

# Análisis principal
rgi main \
    --input_sequence "${ASSEMBLY}" \
    --output_file "${OUTPUT}/${SAMPLE}_rgi" \
    --input_type contig \
    --alignment_tool BLAST \
    --num_threads 8 \
    --clean \
    --low_quality

# Generar resumen visual
rgi heatmap \
    --input "${OUTPUT}/${SAMPLE}_rgi.txt" \
    --output "${OUTPUT}/${SAMPLE}_rgi_heatmap"
```

**Archivos generados:**

```
06_amr_typing/03_rgi/
├── FRAN93_rgi.txt              # Resultados principales
├── FRAN93_rgi.json             # Formato JSON
├── FRAN93_rgi_heatmap.png      # Visualización
└── FRAN93_rgi_heatmap.eps      # Para publicación
```

**Categorías de RGI:**

- **Perfect** - 100% identidad, cobertura completa
- **Strict** - >95% identidad, >95% cobertura
- **Loose** - <95% identidad pero significativo
- **Nudge** - Variantes homólogas

### Comparación de Herramientas AMR

| Herramienta | Velocidad | Cobertura | Especificidad | Uso Recomendado |
|-------------|-----------|-----------|---------------|-----------------|
| **AMRFinderPlus** | ⚡⚡ Rápida | 🎯 Alta | ⭐⭐⭐ Muy alta | Primera línea, NCBI oficial |
| **Abricate** | ⚡⚡⚡ Muy rápida | 🎯🎯 Muy alta | ⭐⭐ Moderada | Screening rápido |
| **RGI** | ⚡ Moderada | 🎯🎯🎯 Máxima | ⭐⭐⭐ Muy alta | Análisis detallado |

**Estrategia recomendada:**
1. Ejecutar **AMRFinderPlus** primero (oficial NCBI)
2. Complementar con **Abricate** (múltiples DBs)
3. Validar con **RGI** para análisis profundo

---

## Tipificación Molecular (MLST)

MLST (Multi-Locus Sequence Typing) identifica el tipo de secuencia de la cepa basándose en genes housekeeping.

### Instalación

```bash
conda activate bact_main

# Verificar que mlst está instalado
mlst --check

# Actualizar esquemas
mlst --list
```

### Uso Básico

```bash
SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/04_mlst"

mkdir -p "${OUTPUT}"

# Ejecutar MLST
mlst "${ASSEMBLY}" > "${OUTPUT}/${SAMPLE}_mlst.tsv"

# Ver resultado
cat "${OUTPUT}/${SAMPLE}_mlst.tsv"
```

**Salida esperada:**

```
FRAN93_assembly.fasta  neisseria  1901  abcZ(1)  adk(3)  aroE(2)  fumC(3)  gdh(8)  pdhC(3)  pgm(6)
```

**Interpretación:**
- **Esquema:** neisseria (PubMLST)
- **ST:** 1901
- **Alelos:** Números entre paréntesis son los alelos de cada gen

### MLST para Diferentes Esquemas

```bash
# Ver esquemas disponibles
mlst --schemes

# Especificar esquema manualmente
mlst --scheme neisseria "${ASSEMBLY}" > "${OUTPUT}/${SAMPLE}_mlst.tsv"

# Análisis de múltiples ensamblajes
mlst --threads 8 03_assembly/*/*.fasta > "${OUTPUT}/all_samples_mlst.tsv"
```

### Esquemas Comunes

| Bacteria | Esquema | ST típicos |
|----------|---------|------------|
| N. gonorrhoeae | `neisseria` | 1901, 7363, 9363 |
| K. pneumoniae | `klebsiella` | ST11, ST15, ST147, ST258 |
| E. coli | `ecoli` | ST131, ST38, ST10 |
| S. aureus | `saureus` | ST5, ST8, ST239 |

### Análisis de Nuevos Alelos

Si MLST reporta `~` o `?`:

```bash
# Alelo nuevo detectado (~)
# Alelo no encontrado (?)

# Extraer secuencias para enviar a PubMLST
mlst --novel "${ASSEMBLY}" > "${OUTPUT}/${SAMPLE}_novel_alleles.fasta"
```

---

## Detección de Plásmidos

Los plásmidos frecuentemente portan genes AMR y de virulencia.

### PlasmidFinder (con Abricate)

```bash
conda activate bact_main

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/05_plasmids"

mkdir -p "${OUTPUT}"

# Detectar plásmidos
abricate \
    --db plasmidfinder \
    --threads 8 \
    --minid 80 \
    --mincov 60 \
    "${ASSEMBLY}" \
    > "${OUTPUT}/${SAMPLE}_plasmids.tsv"
```

**Salida típica:**

```
FILE     SEQUENCE  START   END     STRAND  GENE       COVERAGE  IDENTITY  DATABASE
FRAN93   contig_2  1       45523   +       IncFII     98.45     99.12     plasmidfinder
FRAN93   contig_3  1       8234    +       Col(pHAD28) 100.00   98.76     plasmidfinder
```

### MOB-suite (Análisis Avanzado)

**Características:**
- 🔍 Reconstrucción de plásmidos
- 🧬 Tipificación de plásmidos
- 📊 Movilidad y transferencia

**Instalación:**

```bash
conda activate bact_main
mamba install -c bioconda mob_suite -y
```

**Uso:**

```bash
SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/05_plasmids/mob_suite"

mkdir -p "${OUTPUT}"

# Reconstruir plásmidos
mob_recon \
    --infile "${ASSEMBLY}" \
    --outdir "${OUTPUT}" \
    --num_threads 8

# Tipificar plásmidos
mob_typer \
    --infile "${ASSEMBLY}" \
    --outdir "${OUTPUT}" \
    --num_threads 8
```

**Archivos generados:**

```
mob_suite/
├── chromosome.fasta        # Secuencia cromosómica
├── plasmid_*.fasta        # Plásmidos individuales
├── contig_report.txt      # Clasificación de contigs
└── mobtyper_results.txt   # Tipificación
```

---

## Factores de Virulencia

### VFDB (Virulence Factor Database)

```bash
conda activate bact_main

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
OUTPUT="06_amr_typing/06_virulence"

mkdir -p "${OUTPUT}"

# Detectar factores de virulencia
abricate \
    --db vfdb \
    --threads 8 \
    --minid 75 \
    --mincov 75 \
    "${ASSEMBLY}" \
    > "${OUTPUT}/${SAMPLE}_virulence.tsv"
```

**Factores comunes en N. gonorrhoeae:**

| Gen/Sistema | Función | Importancia |
|-------------|---------|-------------|
| **pilE** | Pili tipo IV | Adhesión |
| **opa** | Proteínas de opacidad | Invasión celular |
| **por** | Porina | Resistencia suero |
| **lbpA/B** | Binding proteins | Adquisición hierro |
| **tbpA/B** | Transferrin binding | Adquisición hierro |
| **mtr** | Efflux pump | Resistencia |

### VFanalyzer (Opcional)

Para análisis más detallado:

```bash
# Instalar VFanalyzer
pip install vfanalyzer

# Ejecutar análisis
vfanalyzer \
    --input "${ASSEMBLY}" \
    --output "${OUTPUT}/vfanalyzer" \
    --threads 8
```

---

## Reportes Consolidados

### Script de Integración

Crear un script que integre todos los resultados:

```bash
#!/bin/bash

SAMPLE=$1
BASE_DIR="06_amr_typing"
REPORT_DIR="${BASE_DIR}/07_reports"
mkdir -p "${REPORT_DIR}"

# Archivo de reporte
REPORT="${REPORT_DIR}/${SAMPLE}_integrated_report.txt"

cat > "${REPORT}" << EOF
========================================
REPORTE CONSOLIDADO DE ANÁLISIS
========================================
Muestra: ${SAMPLE}
Fecha: $(date)
Pipeline: Bacterial Genomics

========================================
1. ANOTACIÓN FUNCIONAL
========================================
EOF

# Estadísticas de Prokka
if [ -f "05_annotation/01_prokka/${SAMPLE}.txt" ]; then
    cat "05_annotation/01_prokka/${SAMPLE}.txt" >> "${REPORT}"
fi

cat >> "${REPORT}" << EOF

========================================
2. RESISTENCIA ANTIMICROBIANA
========================================

2.1 AMRFinderPlus (NCBI):
EOF

if [ -f "${BASE_DIR}/01_amrfinder/${SAMPLE}_amrfinder.tsv" ]; then
    echo "Genes de resistencia detectados:" >> "${REPORT}"
    tail -n +2 "${BASE_DIR}/01_amrfinder/${SAMPLE}_amrfinder.tsv" | \
        awk '{print "  - " $1 " (" $5 ")"}' >> "${REPORT}"
fi

cat >> "${REPORT}" << EOF

2.2 Abricate (CARD):
EOF

if [ -f "${BASE_DIR}/02_abricate/${SAMPLE}_card.tsv" ]; then
    CARD_COUNT=$(tail -n +2 "${BASE_DIR}/02_abricate/${SAMPLE}_card.tsv" | wc -l)
    echo "Total de genes AMR (CARD): ${CARD_COUNT}" >> "${REPORT}"
fi

cat >> "${REPORT}" << EOF

========================================
3. TIPIFICACIÓN MOLECULAR
========================================
EOF

if [ -f "${BASE_DIR}/04_mlst/${SAMPLE}_mlst.tsv" ]; then
    cat "${BASE_DIR}/04_mlst/${SAMPLE}_mlst.tsv" >> "${REPORT}"
fi

cat >> "${REPORT}" << EOF

========================================
4. PLÁSMIDOS
========================================
EOF

if [ -f "${BASE_DIR}/05_plasmids/${SAMPLE}_plasmids.tsv" ]; then
    PLASMID_COUNT=$(tail -n +2 "${BASE_DIR}/05_plasmids/${SAMPLE}_plasmids.tsv" | wc -l)
    echo "Plásmidos detectados: ${PLASMID_COUNT}" >> "${REPORT}"
    tail -n +2 "${BASE_DIR}/05_plasmids/${SAMPLE}_plasmids.tsv" | \
        awk '{print "  - " $7}' >> "${REPORT}"
fi

cat >> "${REPORT}" << EOF

========================================
5. FACTORES DE VIRULENCIA
========================================
EOF

if [ -f "${BASE_DIR}/06_virulence/${SAMPLE}_virulence.tsv" ]; then
    VF_COUNT=$(tail -n +2 "${BASE_DIR}/06_virulence/${SAMPLE}_virulence.tsv" | wc -l)
    echo "Factores de virulencia: ${VF_COUNT}" >> "${REPORT}"
    tail -n +2 "${BASE_DIR}/06_virulence/${SAMPLE}_virulence.tsv" | \
        awk '{print "  - " $6}' | sort -u >> "${REPORT}"
fi

echo "" >> "${REPORT}"
echo "========================================" >> "${REPORT}"
echo "Reporte generado exitosamente" >> "${REPORT}"
echo "========================================" >> "${REPORT}"

# Mostrar reporte
cat "${REPORT}"
```

Guardar como `scripts/generate_amr_report.sh` y ejecutar:

```bash
bash scripts/generate_amr_report.sh FRAN93
```

---

## Interpretación de Resultados

### N. gonorrhoeae - Perfiles de Resistencia Comunes

#### 1. Resistencia a β-lactámicos

**Gen penA:**
- Mutaciones en PBP2 (Penicillin Binding Protein 2)
- Mosaico de penA → Resistencia a cefalosporinas
- Alelos comunes: penA-34.001, penA-60.001

**Interpretación:**
```
penA presente + Mosaico → Resistencia a ceftriaxona (preocupante)
penA wildtype → Susceptible a cefalosporinas
```

#### 2. Resistencia a Fluoroquinolonas

**Genes gyrA y parC:**
- Mutaciones en S91F, D95G/N (gyrA)
- Mutaciones en S87R, S88P (parC)

**Interpretación:**
```
gyrA S91 + parC S87 → Alta resistencia a ciprofloxacina
Solo gyrA → Resistencia moderada
Wildtype → Susceptible
```

#### 3. Resistencia a Macrólidos

**Gen 23S rRNA:**
- Mutaciones A2045G, C2611T
- Mutaciones en A2059G

**Interpretación:**
```
23S rRNA mutado → Resistencia a azitromicina
Wildtype → Susceptible
```

#### 4. Sistema MtrCDE (Efflux)

**Genes mtrR, mtrC, mtrD, mtrE:**
- Promotor mtrR con deleción → Sobreexpresión bomba efflux
- Mutaciones en mtrR

**Interpretación:**
```
mtrR mutado → Resistencia múltiple (azitromicina, detergentes)
Contribuye a resistencia cruzada
```

### Interpretación Clínica (N. gonorrhoeae)

| Perfil Genético | Interpretación Clínica | Tratamiento |
|-----------------|------------------------|-------------|
| penA mosaico + gyrA/parC mutados | MDR - Altamente resistente | Ceftriaxona IM dosis alta |
| penA wildtype + gyrA mutado | Resistente a FQ únicamente | Cefalosporina |
| 23S rRNA mutado | Resistente a azitromicina | No usar macrólidos |
| Todo wildtype | Pan-susceptible | Terapia estándar |

### K. pneumoniae - Perfiles AMR

#### Carbapenemasas (Crítico)

**Genes principales:**
- **blaKPC** (KPC-2, KPC-3) - Más común en América
- **blaNDM** (NDM-1) - Metalo-β-lactamasa
- **blaOXA-48** - Común en Europa/Medio Oriente
- **blaVIM** - Metalo-β-lactamasa

**Interpretación:**
```
KPC-2 presente → Resistencia a carbapenems
NDM-1 presente → Resistencia extrema (incluyendo aztreonam)
OXA-48 + CTX-M → Resistencia múltiple
```

#### BLEE (β-lactamasas de espectro extendido)

**Genes:**
- **blaCTX-M** (CTX-M-15 más común)
- **blaSHV** (SHV-11, SHV-12)
- **blaTEM**

#### ST de Alto Riesgo

| ST | Región | Característica |
|----|--------|----------------|
| **ST258** | USA | KPC-productor |
| **ST11** | Asia | KPC/NDM |
| **ST147** | Europa | OXA-48 |
| **ST15** | Global | Hipervirulento + MDR |

---

## Flujo de Trabajo Completo

### Secuencia de Comandos (N. gonorrhoeae)

```bash
#!/bin/bash
# AMR Typing Workflow - N. gonorrhoeae

SAMPLE="FRAN93"
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"

# 1. Anotación
conda activate bact_main
prokka --outdir 05_annotation/01_prokka --prefix ${SAMPLE} \
    --genus Neisseria --species gonorrhoeae \
    --cpus 8 ${ASSEMBLY}

# 2. AMR - AMRFinderPlus
conda activate bact_amr
mkdir -p 06_amr_typing/01_amrfinder
amrfinder --nucleotide ${ASSEMBLY} \
    --protein 05_annotation/01_prokka/${SAMPLE}.faa \
    --organism Neisseria --threads 8 --plus \
    --output 06_amr_typing/01_amrfinder/${SAMPLE}_amrfinder.tsv

# 3. AMR - Abricate
conda activate bact_main
mkdir -p 06_amr_typing/02_abricate
for DB in card resfinder ncbi; do
    abricate --db ${DB} --threads 8 ${ASSEMBLY} \
        > 06_amr_typing/02_abricate/${SAMPLE}_${DB}.tsv
done

# 4. MLST
mlst ${ASSEMBLY} > 06_amr_typing/04_mlst/${SAMPLE}_mlst.tsv

# 5. Plásmidos
abricate --db plasmidfinder --threads 8 ${ASSEMBLY} \
    > 06_amr_typing/05_plasmids/${SAMPLE}_plasmids.tsv

# 6. Virulencia
abricate --db vfdb --threads 8 ${ASSEMBLY} \
    > 06_amr_typing/06_virulence/${SAMPLE}_virulence.tsv

# 7. Reporte integrado
bash scripts/generate_amr_report.sh ${SAMPLE}

echo "Análisis AMR completado para ${SAMPLE}"
```

### Tiempo Estimado

| Paso | Herramienta | Tiempo (N. gonorrhoeae 2.2 Mb) |
|------|-------------|-------------------------------|
| Anotación | Prokka | 5-10 min |
| AMR | AMRFinderPlus | 2-5 min |
| AMR | Abricate (3 DBs) | 1-2 min |
| AMR | RGI | 10-15 min |
| MLST | mlst | <1 min |
| Plásmidos | Abricate | <1 min |
| Virulencia | Abricate | <1 min |
| **TOTAL** | | **20-35 minutos** |

---

## Resolución de Problemas

### Problema: AMRFinderPlus no encuentra organismo

**Error:**
```
Unknown organism: Neisseria
```

**Solución:**
```bash
# Listar organismos disponibles
amrfinder --list_organisms

# Usar "Neisseria" (con mayúscula)
# O usar análisis genérico:
amrfinder --nucleotide ${ASSEMBLY} --threads 8 --plus \
    --output output.tsv
```

### Problema: MLST no identifica esquema

**Error:**
```
FRAN93.fasta  -  -  abcZ(?)  adk(?)  ...
```

**Soluciones:**
1. **Especificar esquema manualmente:**
   ```bash
   mlst --scheme neisseria ${ASSEMBLY}
   ```

2. **Actualizar base de datos:**
   ```bash
   mlst --longlist  # Ver esquemas disponibles
   mlst --blastdb $(mlst --datadir)/neisseria/blast/mlst.fa
   ```

3. **Baja calidad de ensamblaje:**
   - Verificar N50 >50kb
   - Mejorar ensamblaje si es necesario

### Problema: Abricate no encuentra genes

**Causas:**
- Umbrales muy estrictos
- Base de datos desactualizada
- Ensamblaje fragmentado

**Soluciones:**
```bash
# Reducir umbrales
abricate --minid 70 --mincov 60 ${ASSEMBLY}

# Actualizar bases de datos
abricate --setupdb

# Verificar que la DB está disponible
abricate --list
```

### Problema: RGI muy lento

**Solución:**
```bash
# Usar DIAMOND en lugar de BLAST (más rápido)
rgi main --input_sequence ${ASSEMBLY} \
    --alignment_tool DIAMOND \
    --num_threads 8

# O usar modo contig estricto
rgi main --input_type contig --clean
```

---

## Referencias y Recursos

### Bases de Datos

| Base de Datos | URL | Actualización |
|---------------|-----|---------------|
| **NCBI AMRFinderPlus** | https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/ | Mensual |
| **CARD** | https://card.mcmaster.ca/ | Trimestral |
| **ResFinder** | https://cge.food.dtu.dk/services/ResFinder/ | Regular |
| **PubMLST** | https://pubmlst.org/ | Continua |
| **VFDB** | http://www.mgc.ac.cn/VFs/ | Anual |

### Documentación

- **AMRFinderPlus:** https://github.com/ncbi/amr/wiki
- **Abricate:** https://github.com/tseemann/abricate
- **RGI:** https://github.com/arpcard/rgi
- **Prokka:** https://github.com/tseemann/prokka
- **MLST:** https://github.com/tseemann/mlst

### Artículos Clave

1. Feldgarden M et al. (2021) "AMRFinderPlus and the Reference Gene Catalog facilitate examination of the genomic links among antimicrobial resistance, stress response, and virulence" *Scientific Reports*

2. Alcock BP et al. (2020) "CARD 2020: antibiotic resistome surveillance with the comprehensive antibiotic resistance database" *Nucleic Acids Research*

3. Jolley KA & Maiden MC (2010) "BIGSdb: Scalable analysis of bacterial genome variation at the population level" *BMC Bioinformatics*

---

## Checklist Final

Antes de finalizar el análisis AMR:

- [ ] Anotación funcional completada (Prokka/Bakta)
- [ ] AMR detectado con al menos 2 herramientas
- [ ] MLST ejecutado y ST identificado
- [ ] Plásmidos identificados
- [ ] Factores de virulencia analizados
- [ ] Reporte consolidado generado
- [ ] Resultados interpretados en contexto clínico
- [ ] Archivos organizados y respaldados

---

**Siguiente paso:** [05. Troubleshooting y Solución de Problemas](05_TROUBLESHOOTING.md)

**Última actualización:** Febrero 2026  
**Versión:** 1.0
