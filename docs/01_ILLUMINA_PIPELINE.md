# 📘 Pipeline Solo Illumina
### Análisis de Genomas Bacterianos con Lecturas Cortas

---

## 📋 Tabla de Contenidos

1. [Introducción](#-introducción)
2. [Prerrequisitos](#-prerrequisitos)
3. [Visión General del Pipeline](#-visión-general-del-pipeline)
4. [Fase 1: Control de Calidad](#-fase-1-control-de-calidad)
5. [Fase 2: Ensamblaje de Novo](#-fase-2-ensamblaje-de-novo)
6. [Fase 3: Evaluación del Ensamblaje](#-fase-3-evaluación-del-ensamblaje)
7. [Fase 4: Mapeo Contra Referencia](#-fase-4-mapeo-contra-referencia)
8. [Fase 5: Llamado de Variantes](#-fase-5-llamado-de-variantes)
9. [Fase 6: Análisis de Cobertura](#-fase-6-análisis-de-cobertura)
10. [Interpretación de Resultados](#-interpretación-de-resultados)
11. [Solución de Problemas](#-solución-de-problemas)

---

## 🎯 Introducción

### ¿Cuándo Usar Este Pipeline?

✅ **Ideal para:**
- Detección precisa de SNPs e INDELs
- Análisis de variantes de alta confianza
- Cuando solo dispones de datos Illumina paired-end
- Estudios de epidemiología molecular
- Identificación de genes de resistencia antimicrobiana

⚠️ **Limitaciones:**
- Ensamblajes fragmentados (50-200 contigs)
- Dificultad para cerrar cromosomas completos
- Problemas con regiones repetitivas largas
- Plásmidos pueden quedar incompletos

### Características de Datos Illumina

| Característica | Valor Típico |
|----------------|--------------|
| Longitud de reads | 150-300 bp |
| Química | Paired-end |
| Tasa de error | <0.1% (muy baja) |
| Cobertura recomendada | 50-100x |
| Ventaja principal | Alta precisión |
| Desventaja principal | Lecturas cortas |

---

## ✅ Prerrequisitos

### Antes de Empezar

- [ ] Instalación completa según [00_INSTALLATION.md](00_INSTALLATION.md)
- [ ] Ambiente `bact_main` activado
- [ ] Datos Illumina paired-end en formato FASTQ
- [ ] Al menos 50x cobertura del genoma
- [ ] ~50-100 GB de espacio libre en disco

### Verificar Instalación

```bash
# Activar ambiente
conda activate bact_main

# Verificar herramientas críticas
fastqc --version
fastp --version
spades.py --version
bwa
samtools --version
bcftools --version

# Si todo está bien, continuar
```

### Estructura de Datos Esperada

```
00_raw_data/illumina/
├── SAMPLE_1.fastq.gz    # Forward reads (R1)
└── SAMPLE_2.fastq.gz    # Reverse reads (R2)
```

---

## 🔄 Visión General del Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    PIPELINE ILLUMINA                        │
└─────────────────────────────────────────────────────────────┘

1. DATOS CRUDOS (FASTQ)
   ├─ SAMPLE_1.fastq.gz (R1)
   └─ SAMPLE_2.fastq.gz (R2)
   │
   ▼
2. CONTROL DE CALIDAD
   ├─ FastQC (raw data)
   ├─ fastp (trimming + QC)
   └─ FastQC (clean data)
   │
   ▼
3. ENSAMBLAJE DE NOVO
   ├─ SPAdes
   └─ Contigs ensamblados
   │
   ▼
4. EVALUACIÓN DE CALIDAD
   ├─ QUAST
   └─ Métricas (N50, L50, etc.)
   │
   ▼
5. MAPEO CONTRA REFERENCIA
   ├─ BWA-MEM
   ├─ Samtools (sort, index)
   └─ BAM file
   │
   ▼
6. LLAMADO DE VARIANTES
   ├─ BCFtools mpileup
   ├─ BCFtools call
   └─ VCF file
   │
   ▼
7. ANÁLISIS DE COBERTURA
   ├─ Por cromosoma
   ├─ Por plásmidos
   └─ Estadísticas
   │
   ▼
8. RESULTADOS FINALES
   ├─ Ensamblaje (contigs)
   ├─ Variantes (VCF)
   ├─ Cobertura
   └─ Reportes QC
```

**⏱️ Tiempo estimado total:** 3-5 horas  
**💾 Espacio requerido:** ~50-100 GB por muestra

---

## 🔬 Fase 1: Control de Calidad

### Objetivo

Evaluar la calidad de las lecturas crudas, eliminar adaptadores, recortar bases de baja calidad y generar reportes de QC.

### Paso 1.1: FastQC en Datos Crudos

```bash
# Activar ambiente
conda activate bact_main

# Variables (CAMBIAR SEGÚN TU MUESTRA)
SAMPLE="URO5550422"
R1="00_raw_data/illumina/${SAMPLE}_1.fastq.gz"
R2="00_raw_data/illumina/${SAMPLE}_2.fastq.gz"
THREADS=8

echo "========================================"
echo "FastQC - Datos Crudos"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Crear directorio de salida
mkdir -p 02_qc/01_illumina_raw

# Ejecutar FastQC
fastqc ${R1} ${R2} \
  -o 02_qc/01_illumina_raw/ \
  -t ${THREADS} \
  --quiet

echo "✓ FastQC completado"
echo "  Reportes en: 02_qc/01_illumina_raw/"
```

**📊 Archivos generados:**
- `SAMPLE_1_fastqc.html` - Reporte visual R1
- `SAMPLE_2_fastqc.html` - Reporte visual R2
- `SAMPLE_1_fastqc.zip` - Datos R1
- `SAMPLE_2_fastqc.zip` - Datos R2

**🔍 Qué revisar en FastQC:**

```bash
# Abrir reportes HTML
firefox 02_qc/01_illumina_raw/${SAMPLE}_1_fastqc.html &
firefox 02_qc/01_illumina_raw/${SAMPLE}_2_fastqc.html &
```

| Módulo FastQC | ✅ PASS | ⚠️ WARN | ❌ FAIL |
|---------------|---------|---------|---------|
| Per base quality | Q30+ en mayoría | Q20-Q30 algunas bases | <Q20 muchas bases |
| Per sequence quality | Pico en Q35-Q40 | Pico en Q25-Q30 | Pico <Q25 |
| Adapter content | <5% | 5-10% | >10% |
| Duplication level | <20% | 20-40% | >40% |
| Overrepresented seqs | Ninguna | Pocas | Muchas |

### Paso 1.2: Limpieza con fastp

```bash
echo "========================================"
echo "fastp - Limpieza y Filtrado"
echo "========================================"

# Crear directorio de salida
mkdir -p 02_qc/02_illumina_trimmed

# Ejecutar fastp (herramienta todo-en-uno)
fastp \
  --in1 ${R1} \
  --in2 ${R2} \
  --out1 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz \
  --out2 02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz \
  --detect_adapter_for_pe \
  --cut_front \
  --cut_tail \
  --cut_window_size 4 \
  --cut_mean_quality 20 \
  --trim_poly_g \
  --qualified_quality_phred 20 \
  --unqualified_percent_limit 40 \
  --n_base_limit 5 \
  --length_required 50 \
  --thread ${THREADS} \
  --html 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html \
  --json 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json \
  2> 02_qc/02_illumina_trimmed/${SAMPLE}_fastp.log

echo "✓ fastp completado"
echo "  Reporte: 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html"
```

**⚙️ Parámetros de fastp explicados:**

| Parámetro | Función |
|-----------|---------|
| `--detect_adapter_for_pe` | Detecta y elimina adaptadores automáticamente |
| `--cut_front --cut_tail` | Recorta extremos de baja calidad |
| `--cut_window_size 4` | Ventana deslizante de 4 bases |
| `--cut_mean_quality 20` | Calidad promedio mínima Q20 |
| `--trim_poly_g` | Elimina homopolímeros de G (artefacto NovaSeq) |
| `--qualified_quality_phred 20` | Base válida si Q≥20 |
| `--length_required 50` | Descartar reads <50 bp |

**📈 Revisar reporte fastp:**

```bash
# Abrir reporte HTML
firefox 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html &

# Métricas clave en terminal
echo "=== RESUMEN FASTP ==="
grep -A 5 "summary" 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json
```

**🎯 Métricas esperadas después de fastp:**

| Métrica | Valor Ideal | Valor Aceptable | ⚠️ Revisar si |
|---------|-------------|-----------------|--------------|
| % reads passed | >95% | >90% | <90% |
| % bases Q30 | >90% | >80% | <80% |
| % duplication | <20% | <30% | >40% |
| GC content | 55-58% | 52-62% | <50% o >65% |
| Adaptadores después | <1% | <2% | >5% |

### Paso 1.3: FastQC en Datos Limpios

```bash
echo "========================================"
echo "FastQC - Datos Limpios"
echo "========================================"

# Ejecutar FastQC en datos trimmed
fastqc 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz \
       02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ \
  -t ${THREADS} \
  --quiet

echo "✓ FastQC post-trimming completado"
```

### Paso 1.4: Reporte Consolidado con MultiQC

```bash
echo "========================================"
echo "MultiQC - Reporte Consolidado"
echo "========================================"

# Crear directorio
mkdir -p 02_qc/05_multiqc

# Generar reporte integrado
multiqc 02_qc/ \
  -o 02_qc/05_multiqc/ \
  --filename ${SAMPLE}_multiqc_report \
  --title "QC Report - ${SAMPLE}" \
  --comment "Klebsiella pneumoniae - Illumina" \
  --force

echo "✓ MultiQC completado"
echo "  Reporte: 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html"

# Abrir reporte
firefox 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html &
```

**📊 MultiQC integra:**
- FastQC antes y después
- Estadísticas fastp
- Gráficos comparativos
- Resumen general de calidad

---

## 🧬 Fase 2: Ensamblaje de Novo

### Objetivo

Ensamblar las lecturas limpias en contigs usando SPAdes, optimizado para genomas bacterianos.

### Paso 2.1: Ensamblaje con SPAdes

```bash
echo "========================================"
echo "Ensamblaje con SPAdes"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
THREADS=8
MEMORY=16  # GB

# Crear directorio de salida
mkdir -p 03_assembly/01_illumina_only

# Ejecutar SPAdes
spades.py \
  -1 ${R1_TRIM} \
  -2 ${R2_TRIM} \
  -o 03_assembly/01_illumina_only/ \
  --isolate \
  --careful \
  -t ${THREADS} \
  -m ${MEMORY} \
  --cov-cutoff auto

echo "✓ Ensamblaje completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de SPAdes:**

| Parámetro | Función |
|-----------|---------|
| `--isolate` | Modo para genomas bacterianos aislados (recomendado) |
| `--careful` | Minimiza mismatches y pequeños indels |
| `--cov-cutoff auto` | Elimina contigs de baja cobertura automáticamente |
| `-m 16` | Límite de memoria RAM (GB) |
| `-t 8` | Número de threads |

**📁 Archivos generados por SPAdes:**

```
03_assembly/01_illumina_only/
├── contigs.fasta              # Ensamblaje final (usar este)
├── scaffolds.fasta            # Scaffolds (contigs unidos)
├── assembly_graph.fastg       # Grafo de ensamblaje
├── assembly_graph_with_scaffolds.gfa  # Grafo GFA
├── spades.log                 # Log del proceso
└── params.txt                 # Parámetros usados
```

### Paso 2.2: Estadísticas Básicas del Ensamblaje

```bash
echo "========================================"
echo "Estadísticas del Ensamblaje"
echo "========================================"

# Copiar contigs finales con nombre estándar
cp 03_assembly/01_illumina_only/contigs.fasta \
   03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta

# Calcular estadísticas
echo "Archivo: ${SAMPLE}_illumina_assembly.fasta"
echo ""

# Número total de contigs
echo -n "Número de contigs: "
grep -c ">" 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta

# Tamaño total del ensamblaje
echo -n "Tamaño total: "
grep -v ">" 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta | \
  tr -d '\n' | wc -c | \
  awk '{printf "%'"'"'d bp\n", $1}'

# Contig más largo
echo -n "Contig más largo: "
cat 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta | \
  awk '/^>/ {if (seqlen){print seqlen}; seqlen=0; next} {seqlen += length($0)} END {print seqlen}' | \
  sort -rn | head -1 | \
  awk '{printf "%'"'"'d bp\n", $1}'

# Contig más corto
echo -n "Contig más corto: "
cat 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta | \
  awk '/^>/ {if (seqlen){print seqlen}; seqlen=0; next} {seqlen += length($0)} END {print seqlen}' | \
  sort -n | head -1 | \
  awk '{printf "%'"'"'d bp\n", $1}'

# Longitud promedio
echo -n "Longitud promedio: "
cat 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta | \
  awk '/^>/ {if (seqlen){print seqlen}; seqlen=0; next} {seqlen += length($0)} END {print seqlen}' | \
  awk '{sum+=$1; n++} END {printf "%'"'"'d bp\n", sum/n}'
```

---

## 📊 Fase 3: Evaluación del Ensamblaje

### Objetivo

Evaluar la calidad del ensamblaje usando QUAST y comparar contra el genoma de referencia.

### Paso 3.1: Evaluación con QUAST

```bash
echo "========================================"
echo "Evaluación con QUAST"
echo "========================================"

# Variables
ASSEMBLY="03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
REFERENCE="01_reference/reference.fasta"

# Crear directorio
mkdir -p 03_assembly/04_quast_evaluation

# Ejecutar QUAST
quast.py \
  ${ASSEMBLY} \
  -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads ${THREADS} \
  --labels "Illumina_${SAMPLE}" \
  --glimmer \
  --min-contig 200 \
  --plots-format png

echo "✓ QUAST completado"
echo "  Reporte: 03_assembly/04_quast_evaluation/report.html"

# Abrir reporte
firefox 03_assembly/04_quast_evaluation/report.html &
```

### Paso 3.2: Interpretar Resultados QUAST

```bash
# Ver resumen en terminal
cat 03_assembly/04_quast_evaluation/report.txt

# Extraer métricas clave
echo "=== MÉTRICAS CLAVE QUAST ==="
grep "# contigs (>= 0 bp)" 03_assembly/04_quast_evaluation/report.txt
grep "Total length (>= 0 bp)" 03_assembly/04_quast_evaluation/report.txt
grep "Largest contig" 03_assembly/04_quast_evaluation/report.txt
grep "N50" 03_assembly/04_quast_evaluation/report.txt
grep "L50" 03_assembly/04_quast_evaluation/report.txt
grep "GC (%)" 03_assembly/04_quast_evaluation/report.txt
grep "# genes" 03_assembly/04_quast_evaluation/report.txt
grep "Genome fraction (%)" 03_assembly/04_quast_evaluation/report.txt
```

**📊 Valores esperados para K. pneumoniae (Illumina):**

| Métrica | Valor Esperado | Interpretación |
|---------|----------------|----------------|
| **# contigs** | 50-150 | Normal para Illumina |
| **Tamaño total** | 5.3-5.9 Mb | Cercano a referencia (5.7 Mb) |
| **Largest contig** | 200-800 kb | Buena continuidad |
| **N50** | 100-300 kb | Calidad aceptable |
| **L50** | 10-30 | Fragmentación moderada |
| **GC%** | 56-58% | Típico de K. pneumoniae |
| **# genes** | 5,000-5,500 | Genoma completo |
| **Genome fraction** | >98% | Casi completo |

**🔍 Métricas Explicadas:**

- **N50**: Longitud del contig donde 50% del genoma está en contigs ≥ esa longitud (↑ mejor)
- **L50**: Número mínimo de contigs que contienen 50% del genoma (↓ mejor)
- **Genome fraction**: % del genoma de referencia cubierto por el ensamblaje (↑ mejor)

---

## 🗺️ Fase 4: Mapeo Contra Referencia

### Objetivo

Mapear las lecturas limpias contra el genoma de referencia para análisis de variantes y cobertura.

### Paso 4.1: Indexar Genoma de Referencia

```bash
echo "========================================"
echo "Indexando Genoma de Referencia"
echo "========================================"

REFERENCE="01_reference/reference.fasta"

# Índice para BWA (si no existe)
if [ ! -f "${REFERENCE}.bwt" ]; then
    echo "Creando índice BWA..."
    bwa index ${REFERENCE}
fi

# Índice para Samtools (si no existe)
if [ ! -f "${REFERENCE}.fai" ]; then
    echo "Creando índice FAI..."
    samtools faidx ${REFERENCE}
fi

echo "✓ Índices creados"
ls -lh 01_reference/
```

### Paso 4.2: Mapeo con BWA-MEM

```bash
echo "========================================"
echo "Mapeo con BWA-MEM"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
REFERENCE="01_reference/reference.fasta"
THREADS=8

# Crear directorio
mkdir -p 04_mapping/01_illumina

# Mapeo y conversión a BAM en un solo paso
bwa mem -t ${THREADS} \
  -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1" \
  ${REFERENCE} \
  ${R1_TRIM} \
  ${R2_TRIM} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/01_illumina/${SAMPLE}_sorted.bam

echo "✓ Mapeo completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de BWA-MEM:**

- `-t 8`: Usar 8 threads
- `-R`: Read Group (metadatos importantes para variant calling)
  - `ID`: Identificador del run
  - `SM`: Nombre de la muestra
  - `PL`: Plataforma (ILLUMINA)
  - `LB`: Librería

### Paso 4.3: Indexar BAM

```bash
echo "Indexando BAM..."
samtools index 04_mapping/01_illumina/${SAMPLE}_sorted.bam

echo "✓ BAM indexado"
ls -lh 04_mapping/01_illumina/
```

### Paso 4.4: Estadísticas de Mapeo

```bash
echo "========================================"
echo "Estadísticas de Mapeo"
echo "========================================"

# Flagstat (estadísticas generales)
samtools flagstat 04_mapping/01_illumina/${SAMPLE}_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_flagstat.txt

# Mostrar flagstat
cat 04_mapping/01_illumina/${SAMPLE}_flagstat.txt

# Cobertura por secuencia
samtools coverage 04_mapping/01_illumina/${SAMPLE}_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_coverage.txt

# Mostrar cobertura
cat 04_mapping/01_illumina/${SAMPLE}_coverage.txt

# Profundidad promedio
samtools depth 04_mapping/01_illumina/${SAMPLE}_sorted.bam | \
  awk '{sum+=$3; count++} END {print "Profundidad promedio:", sum/count"x"}' > \
  04_mapping/01_illumina/${SAMPLE}_mean_depth.txt

cat 04_mapping/01_illumina/${SAMPLE}_mean_depth.txt
```

**📊 Interpretar flagstat:**

```
100000 + 0 in total (QC-passed reads + QC-failed reads)
98500 + 0 mapped (98.50% : N/A)            ← % mapeado (≥95% es bueno)
100000 + 0 paired in sequencing
50000 + 0 read1
50000 + 0 read2
97000 + 0 properly paired (97.00% : N/A)   ← Pares correctos (≥95% bueno)
98000 + 0 with itself and mate mapped
500 + 0 singletons (0.50% : N/A)          ← Singles (<2% bueno)
```

**🎯 Valores esperados:**

| Métrica | Valor Ideal | Aceptable | ⚠️ Revisar si |
|---------|-------------|-----------|--------------|
| % mapeado | >98% | >95% | <95% |
| % properly paired | >97% | >94% | <94% |
| % singletons | <2% | <5% | >5% |
| Cobertura promedio | 50-100x | 30-150x | <30x o >200x |

---

## 🧬 Fase 5: Llamado de Variantes

### Objetivo

Identificar SNPs e INDELs comparando las lecturas mapeadas contra la referencia.

### Paso 5.1: Variant Calling con BCFtools

```bash
echo "========================================"
echo "Llamado de Variantes"
echo "Muestra: ${SAMPLE}"
echo "========================================"

# Variables
BAM="04_mapping/01_illumina/${SAMPLE}_sorted.bam"
REFERENCE="01_reference/reference.fasta"

# Crear directorio
mkdir -p 04_mapping/04_coverage_analysis

# Cobertura por secuencia
samtools coverage ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_coverage_summary.txt

# Mostrar resumen
echo "=== COBERTURA POR SECUENCIA ==="
cat 04_mapping/04_coverage_analysis/${SAMPLE}_coverage_summary.txt

# Profundidad por posición (para gráficos)
samtools depth -a ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_depth.txt

echo "✓ Análisis de cobertura completado"
```

### Paso 6.2: Cobertura por Cromosoma y Plásmidos

```bash
echo "========================================"
echo "Cobertura por Elemento Genómico"
echo "========================================"

# Leer secuencias del genoma de referencia
while read -r seqid rest; do
    # Saltar líneas de comentario
    [[ $seqid == \#* ]] && continue
    
    echo "Procesando: $seqid"
    
    # Extraer reads mapeados a esta secuencia
    samtools view -b ${BAM} "$seqid" > \
      04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam
    
    # Indexar
    samtools index 04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam
    
    # Estadísticas de esta secuencia
    samtools coverage 04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam > \
      04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}_coverage.txt
    
    # Profundidad promedio
    samtools depth 04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam | \
      awk -v seq="$seqid" '{sum+=$3; count++} END {
        if (count>0) printf "%s\t%.2fx\n", seq, sum/count
        else printf "%s\t0x\n", seq
      }' >> 04_mapping/04_coverage_analysis/${SAMPLE}_depth_per_sequence.txt

done < 01_reference/reference_sequences.txt

echo "✓ Análisis por secuencia completado"
```

### Paso 6.3: Resumen de Cobertura

```bash
# Crear resumen consolidado
cat > 04_mapping/04_coverage_analysis/${SAMPLE}_coverage_report.txt << EOF
# Reporte de Cobertura - ${SAMPLE}
# Generado: $(date)
# Genoma de referencia: K. pneumoniae HS11286

========================================
COBERTURA POR ELEMENTO GENÓMICO
========================================

EOF

# Agregar profundidad por secuencia
cat 04_mapping/04_coverage_analysis/${SAMPLE}_depth_per_sequence.txt >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_coverage_report.txt

echo ""
echo "=== REPORTE DE COBERTURA ==="
cat 04_mapping/04_coverage_analysis/${SAMPLE}_coverage_report.txt
```

### Paso 6.4: Identificar Regiones de Baja Cobertura

```bash
echo "========================================"
echo "Identificando Regiones de Baja Cobertura"
echo "========================================"

# Regiones con cobertura <10x
samtools depth ${BAM} | \
  awk '$3 < 10 {print $1"\t"$2"\t"$3}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_low_coverage_regions.txt

# Contar posiciones con baja cobertura
LOW_COV_COUNT=$(wc -l < 04_mapping/04_coverage_analysis/${SAMPLE}_low_coverage_regions.txt)
echo "Posiciones con cobertura <10x: $LOW_COV_COUNT"

if [ $LOW_COV_COUNT -gt 0 ]; then
    echo "⚠️  Revisar regiones de baja cobertura"
    head -20 04_mapping/04_coverage_analysis/${SAMPLE}_low_coverage_regions.txt
else
    echo "✓ Cobertura uniforme en todo el genoma"
fi
```

---

## 📊 Interpretación de Resultados

### Resumen del Pipeline

```bash
echo "========================================"
echo "RESUMEN FINAL - Pipeline Illumina"
echo "Muestra: ${SAMPLE}"
echo "========================================"
echo ""

# 1. Control de Calidad
echo "=== 1. CONTROL DE CALIDAD ==="
echo "Reads iniciales:"
zcat ${R1} | wc -l | awk '{printf "  R1: %'"'"'d reads\n", $1/4}'
zcat ${R2} | wc -l | awk '{printf "  R2: %'"'"'d reads\n", $1/4}'

echo "Reads después de trimming:"
zcat ${R1_TRIM} | wc -l | awk '{printf "  R1: %'"'"'d reads\n", $1/4}'
zcat ${R2_TRIM} | wc -l | awk '{printf "  R2: %'"'"'d reads\n", $1/4}'

echo ""

# 2. Ensamblaje
echo "=== 2. ENSAMBLAJE ==="
ASSEMBLY="03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
echo "Archivo: ${SAMPLE}_illumina_assembly.fasta"
echo -n "  Contigs: "
grep -c ">" ${ASSEMBLY}
echo -n "  Tamaño total: "
grep -v ">" ${ASSEMBLY} | tr -d '\n' | wc -c | awk '{printf "%'"'"'d bp\n", $1}'
echo -n "  N50: "
grep "N50" 03_assembly/04_quast_evaluation/report.txt | awk '{print $2" bp"}'

echo ""

# 3. Mapeo
echo "=== 3. MAPEO ==="
echo "Reads mapeados:"
grep "mapped (" 04_mapping/01_illumina/${SAMPLE}_flagstat.txt | head -1
echo "Cobertura promedio:"
cat 04_mapping/01_illumina/${SAMPLE}_mean_depth.txt

echo ""

# 4. Variantes
echo "=== 4. VARIANTES ==="
TOTAL_VARS=$(bcftools view -H 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz | wc -l)
FILTERED_VARS=$(bcftools view -H 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz | wc -l)
echo "  Total de variantes: $TOTAL_VARS"
echo "  Variantes de alta calidad: $FILTERED_VARS"

# SNPs vs INDELs
bcftools stats 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz | \
  grep "^SN" | grep -E "SNPs|indels" | sed 's/SN\t[0-9]*\t/  /'

echo ""
echo "========================================"
echo "✓ Pipeline Illumina Completado"
echo "========================================"
```

### Archivos Importantes Generados

```bash
echo "=== ARCHIVOS IMPORTANTES ==="
echo ""
echo "Control de Calidad:"
echo "  - 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html"
echo "  - 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html"
echo ""
echo "Ensamblaje:"
echo "  - 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
echo "  - 03_assembly/04_quast_evaluation/report.html"
echo ""
echo "Mapeo y Variantes:"
echo "  - 04_mapping/01_illumina/${SAMPLE}_sorted.bam"
echo "  - 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz"
echo "  - 04_mapping/03_variants/${SAMPLE}_consensus.fasta"
echo ""
echo "Cobertura:"
echo "  - 04_mapping/04_coverage_analysis/${SAMPLE}_coverage_report.txt"
```

---

## 🎯 Criterios de Calidad

### ✅ Ensamblaje Exitoso

| Criterio | Valor Mínimo | Valor Óptimo |
|----------|--------------|--------------|
| **Número de contigs** | <200 | <100 |
| **N50** | >50 kb | >150 kb |
| **Tamaño total** | 5.0-6.0 Mb | 5.5-5.8 Mb |
| **Genome fraction** | >95% | >98% |
| **% Reads mapeados** | >90% | >95% |
| **Cobertura promedio** | >30x | >50x |

### ⚠️ Señales de Alerta

| Problema | Posible Causa | Solución |
|----------|---------------|----------|
| N50 <30 kb | Cobertura baja | Aumentar profundidad de secuenciación |
| >300 contigs | Contaminación o mala calidad | Revisar FastQC, limpiar mejor |
| Cobertura <20x | Poca cantidad de datos | Resecuenciar o pooling |
| % mapeado <85% | Referencia incorrecta | Verificar especie/cepa |
| Muchos gaps en cobertura | Sesgo GC o PCR | Revisar librería |

---

## 🔧 Solución de Problemas

### Problema 1: SPAdes se Queda Sin Memoria

**Síntoma:**
```
== Error ==  system call for: "[bash, -c, bwa mem ... ]" finished abnormally, err code: -9
```

**Solución:**
```bash
# Reducir uso de memoria
spades.py \
  -1 ${R1_TRIM} \
  -2 ${R2_TRIM} \
  -o 03_assembly/01_illumina_only/ \
  --isolate \
  --careful \
  -t 4 \
  -m 8 \  # Reducir de 16 a 8 GB
  --cov-cutoff auto

# O ensamblar con menos threads y más memoria
spades.py ... -t 2 -m 24
```

### Problema 2: BWA Muy Lento

**Síntoma:**
Mapeo toma más de 4 horas.

**Solución:**
```bash
# Aumentar threads
bwa mem -t 16 ...  # En lugar de -t 8

# Usar menos threads si el sistema está saturado
# y asegurarse que tiene suficiente RAM disponible
free -h
```

### Problema 3: Cobertura Desigual

**Síntoma:**
Algunas regiones con cobertura <10x, otras con >200x.

**Causas posibles:**
- Sesgo de amplificación PCR
- Sesgo GC
- Contaminación

**Diagnóstico:**
```bash
# Revisar distribución de cobertura
samtools depth ${BAM} | \
  awk '{print $3}' | \
  sort -n | \
  uniq -c > coverage_distribution.txt

# Graficar con R o Python
# O verificar en IGV visualmente
```

### Problema 4: Muchas Variantes (>5000)

**Síntoma:**
Miles de variantes comparado con la referencia.

**Causa probable:**
Referencia incorrecta o cepa muy divergente.

**Solución:**
```bash
# Verificar identidad con la referencia
# Buscar mejor referencia o usar el ensamblaje de novo
# para análisis downstream

# Comparar con base de datos
conda activate bact_main
blastn -query ${ASSEMBLY} -db nt -remote -outfmt 6 -max_target_seqs 5
```

### Problema 5: Ensamblaje Muy Fragmentado (>200 contigs)

**Síntoma:**
```
Number of contigs: 387
N50: 25 kb
```

**Causas posibles:**
- Cobertura insuficiente (<30x)
- Mala calidad de reads
- Contaminación
- Genoma complejo

**Diagnóstico:**
```bash
# 1. Revisar cobertura
cat 04_mapping/01_illumina/${SAMPLE}_mean_depth.txt

# 2. Revisar calidad FastQC
firefox 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html

# 3. Buscar contaminación con Kraken2 (si instalado)
kraken2 --db /path/to/db \
  --paired ${R1_TRIM} ${R2_TRIM} \
  --report ${SAMPLE}_kraken_report.txt
```

**Soluciones:**
```bash
# Si cobertura <30x: resecuenciar o pooling

# Si calidad baja: ajustar parámetros fastp más estrictos
fastp ... --qualified_quality_phred 25 --length_required 100

# Si contaminación: filtrar reads con Kraken2

# Si genoma complejo: considerar obtener datos Nanopore para híbrido
```

---

## 🚀 Script Completo del Pipeline

Para automatizar todo el proceso:

```bash
cat > scripts/run_illumina_pipeline.sh << 'EOF'
#!/bin/bash

# Script completo del Pipeline Illumina
# Uso: bash scripts/run_illumina_pipeline.sh SAMPLE_NAME

set -e  # Salir si hay error

SAMPLE=$1
THREADS=8
MEMORY=16

if [ -z "$SAMPLE" ]; then
    echo "Uso: bash $0 SAMPLE_NAME"
    exit 1
fi

echo "========================================"
echo "Pipeline Illumina Completo"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Activar ambiente
conda activate bact_main

# Variables
R1="00_raw_data/illumina/${SAMPLE}_1.fastq.gz"
R2="00_raw_data/illumina/${SAMPLE}_2.fastq.gz"
REFERENCE="01_reference/reference.fasta"

# Verificar archivos
if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
    echo "❌ Error: Archivos FASTQ no encontrados"
    exit 1
fi

###############################
# FASE 1: CONTROL DE CALIDAD
###############################
echo ""
echo "=== FASE 1: Control de Calidad ==="

# FastQC raw
mkdir -p 02_qc/01_illumina_raw
fastqc ${R1} ${R2} -o 02_qc/01_illumina_raw/ -t ${THREADS} -q

# fastp
mkdir -p 02_qc/02_illumina_trimmed
fastp \
  -i ${R1} -I ${R2} \
  -o 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz \
  -O 02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz \
  --detect_adapter_for_pe --cut_front --cut_tail \
  --cut_window_size 4 --cut_mean_quality 20 --trim_poly_g \
  --qualified_quality_phred 20 --unqualified_percent_limit 40 \
  --n_base_limit 5 --length_required 50 --thread ${THREADS} \
  --html 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html \
  --json 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json \
  2> 02_qc/02_illumina_trimmed/${SAMPLE}_fastp.log

# FastQC trimmed
fastqc 02_qc/02_illumina_trimmed/${SAMPLE}_R*_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ -t ${THREADS} -q

# MultiQC
mkdir -p 02_qc/05_multiqc
multiqc 02_qc/ -o 02_qc/05_multiqc/ \
  --filename ${SAMPLE}_multiqc_report \
  --title "QC Report - ${SAMPLE}" -f -q

echo "✓ Control de calidad completado"

###############################
# FASE 2: ENSAMBLAJE
###############################
echo ""
echo "=== FASE 2: Ensamblaje ==="

R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"

mkdir -p 03_assembly/01_illumina_only

spades.py \
  -1 ${R1_TRIM} -2 ${R2_TRIM} \
  -o 03_assembly/01_illumina_only/ \
  --isolate --careful -t ${THREADS} -m ${MEMORY} \
  --cov-cutoff auto

cp 03_assembly/01_illumina_only/contigs.fasta \
   03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta

echo "✓ Ensamblaje completado"

###############################
# FASE 3: EVALUACIÓN
###############################
echo ""
echo "=== FASE 3: Evaluación ==="

ASSEMBLY="03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
mkdir -p 03_assembly/04_quast_evaluation

quast.py ${ASSEMBLY} -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads ${THREADS} --labels "Illumina_${SAMPLE}" \
  --glimmer --min-contig 200 -q

echo "✓ Evaluación completada"

###############################
# FASE 4: MAPEO
###############################
echo ""
echo "=== FASE 4: Mapeo ==="

# Indexar referencia si no existe
[ ! -f "${REFERENCE}.bwt" ] && bwa index ${REFERENCE}
[ ! -f "${REFERENCE}.fai" ] && samtools faidx ${REFERENCE}

mkdir -p 04_mapping/01_illumina

# Mapeo
bwa mem -t ${THREADS} \
  -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1" \
  ${REFERENCE} ${R1_TRIM} ${R2_TRIM} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/01_illumina/${SAMPLE}_sorted.bam

# Indexar BAM
samtools index 04_mapping/01_illumina/${SAMPLE}_sorted.bam

# Estadísticas
samtools flagstat 04_mapping/01_illumina/${SAMPLE}_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_flagstat.txt
samtools coverage 04_mapping/01_illumina/${SAMPLE}_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_coverage.txt
samtools depth 04_mapping/01_illumina/${SAMPLE}_sorted.bam | \
  awk '{sum+=$3; count++} END {print "Profundidad promedio:", sum/count"x"}' > \
  04_mapping/01_illumina/${SAMPLE}_mean_depth.txt

echo "✓ Mapeo completado"

###############################
# FASE 5: VARIANTES
###############################
echo ""
echo "=== FASE 5: Llamado de Variantes ==="

BAM="04_mapping/01_illumina/${SAMPLE}_sorted.bam"
mkdir -p 04_mapping/03_variants

# Variant calling
bcftools mpileup -Ou -f ${REFERENCE} ${BAM} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz

# Estadísticas
bcftools stats 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_variants_stats.txt

# Filtrar
bcftools view -i 'QUAL>=30 && DP>=10' \
  04_mapping/03_variants/${SAMPLE}_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz

# Consenso
bcftools consensus -f ${REFERENCE} \
  04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_consensus.fasta

echo "✓ Variantes completadas"

###############################
# FASE 6: COBERTURA
###############################
echo ""
echo "=== FASE 6: Análisis de Cobertura ==="

mkdir -p 04_mapping/04_coverage_analysis

samtools coverage ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_coverage_summary.txt

samtools depth -a ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_depth.txt

# Por secuencia
while read -r seqid rest; do
    [[ $seqid == \#* ]] && continue
    samtools view -b ${BAM} "$seqid" > \
      04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam
    samtools index 04_mapping/04_coverage_analysis/${SAMPLE}_${seqid}.bam
done < 01_reference/reference_sequences.txt

echo "✓ Análisis de cobertura completado"

###############################
# RESUMEN FINAL
###############################
echo ""
echo "========================================"
echo "✓ Pipeline Illumina Completado"
echo "Muestra: ${SAMPLE}"
echo "Fin: $(date)"
echo "========================================"
echo ""
echo "Archivos importantes:"
echo "  QC: 02_qc/05_multiqc/${SAMPLE}_multiqc_report.html"
echo "  Ensamblaje: 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
echo "  QUAST: 03_assembly/04_quast_evaluation/report.html"
echo "  BAM: 04_mapping/01_illumina/${SAMPLE}_sorted.bam"
echo "  Variantes: 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz"
echo "  Consenso: 04_mapping/03_variants/${SAMPLE}_consensus.fasta"
echo ""

# Generar resumen
bash scripts/generate_summary_illumina.sh ${SAMPLE}

EOF

chmod +x scripts/run_illumina_pipeline.sh
```

### Uso del Script Automatizado

```bash
# Ejecutar pipeline completo
bash scripts/run_illumina_pipeline.sh URO5550422

# Tiempo estimado: 3-5 horas
# Monitorear progreso en terminal
```

---

## 📝 Checklist Final

Antes de continuar con análisis downstream, verifica:

- [ ] ✅ FastQC muestra buena calidad (Q30 >80%)
- [ ] ✅ fastp eliminó adaptadores (<1% restante)
- [ ] ✅ Ensamblaje tiene N50 >50 kb
- [ ] ✅ Número de contigs <200
- [ ] ✅ Genome fraction >95%
- [ ] ✅ % reads mapeados >90%
- [ ] ✅ Cobertura promedio >30x
- [ ] ✅ Variantes filtradas generadas
- [ ] ✅ Sin grandes gaps en cobertura

---

## 🎓 Próximos Pasos

### Continuar con Análisis Downstream

Una vez completado el pipeline Illumina:

**→ [04_AMR_TYPING.md](04_AMR_TYPING.md)** - Detección de genes AMR y tipificación molecular

Este incluye:
- Anotación funcional (Prokka)
- Detección de genes AMR (AMRFinderPlus, Abricate, RGI)
- MLST typing
- Detección de plásmidos
- Factores de virulencia

---

<div align="center">

**✅ Pipeline Illumina Completado**

---

[⬅️ Volver a Instalación](00_INSTALLATION.md) | [🏠 Índice Principal](../README.md) | [➡️ Siguiente: Pipeline Nanopore](02_NANOPORE_PIPELINE.md)

---

*Última actualización: Enero 2025*  
*Versión: 1.0*

</div>="04_mapping/01_illumina/${SAMPLE}_sorted.bam"
REFERENCE="01_reference/reference.fasta"

# Crear directorio
mkdir -p 04_mapping/03_variants

# Pileup + Call en un paso
bcftools mpileup -Ou -f ${REFERENCE} ${BAM} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz

echo "✓ Variantes llamadas"
```

### Paso 5.2: Indexar VCF

```bash
# Indexar VCF
bcftools index 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz

echo "✓ VCF indexado"
```

### Paso 5.3: Estadísticas de Variantes

```bash
echo "========================================"
echo "Estadísticas de Variantes"
echo "========================================"

# Generar estadísticas
bcftools stats 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_variants_stats.txt

# Resumen de variantes
echo "=== RESUMEN DE VARIANTES ==="
grep "^SN" 04_mapping/03_variants/${SAMPLE}_variants_stats.txt | \
  grep -E "SNPs|indels|MNPs"

# Número total de variantes
echo -n "Total de variantes: "
bcftools view -H 04_mapping/03_variants/${SAMPLE}_variants.vcf.gz | wc -l
```

### Paso 5.4: Filtrar Variantes de Alta Calidad

```bash
echo "========================================"
echo "Filtrando Variantes de Alta Calidad"
echo "========================================"

# Filtrar por calidad y profundidad
bcftools view -i 'QUAL>=30 && DP>=10' \
  04_mapping/03_variants/${SAMPLE}_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz

# Indexar variantes filtradas
bcftools index 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz

# Contar variantes filtradas
echo -n "Variantes de alta calidad: "
bcftools view -H 04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz | wc -l

echo "✓ Variantes filtradas"
```

**🔍 Criterios de Filtrado:**

- `QUAL>=30`: Calidad Phred ≥30 (99.9% confianza)
- `DP>=10`: Profundidad (depth) ≥10 reads

### Paso 5.5: Generar Secuencia Consenso

```bash
echo "========================================"
echo "Generando Secuencia Consenso"
echo "========================================"

# Crear secuencia consenso aplicando variantes
bcftools consensus -f ${REFERENCE} \
  04_mapping/03_variants/${SAMPLE}_variants_filtered.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_consensus.fasta

echo "✓ Secuencia consenso generada"
echo "  Archivo: 04_mapping/03_variants/${SAMPLE}_consensus.fasta"
```

---

## 📈 Fase 6: Análisis de Cobertura

### Objetivo

Analizar la cobertura de secuenciación por cada elemento del genoma (cromosoma y plásmidos).

### Paso 6.1: Cobertura Global

```bash
echo "========================================"
echo "Análisis de Cobertura"
echo "========================================"

# Variables
BAM
