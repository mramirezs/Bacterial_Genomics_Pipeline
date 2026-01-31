# 📕 Pipeline Híbrido (Illumina + Nanopore)
### Análisis de Genomas Bacterianos con Ensamblaje Híbrido

---

## 📋 Tabla de Contenidos

1. [Introducción](#-introducción)
2. [Prerrequisitos](#-prerrequisitos)
3. [Visión General del Pipeline](#-visión-general-del-pipeline)
4. [Fase 1: Control de Calidad](#-fase-1-control-de-calidad)
5. [Fase 2: Ensamblaje Híbrido](#-fase-2-ensamblaje-híbrido)
6. [Fase 3: Evaluación Comparativa](#-fase-3-evaluación-comparativa)
7. [Fase 4: Mapeo y Validación](#-fase-4-mapeo-y-validación)
8. [Fase 5: Consenso de Alta Calidad](#-fase-5-consenso-de-alta-calidad)
9. [Fase 6: Análisis de Cobertura](#-fase-6-análisis-de-cobertura)
10. [Comparación de Estrategias](#-comparación-de-estrategias)
11. [Interpretación de Resultados](#-interpretación-de-resultados)
12. [Solución de Problemas](#-solución-de-problemas)

---

## 🎯 Introducción

### ¿Por Qué Usar Ensamblaje Híbrido?

El pipeline híbrido combina **lecturas cortas de Illumina** (alta precisión) con **lecturas largas de Nanopore** (alta continuidad) para producir ensamblajes de **calidad excepcional**.

### ⭐ Lo Mejor de Ambos Mundos

| Característica | Illumina Solo | Nanopore Solo | **Híbrido** |
|----------------|---------------|---------------|-------------|
| **Continuidad** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Precisión** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Cromosoma cerrado** | ❌ | ✅ | ✅ |
| **Plásmidos cerrados** | ❌ | ✅ | ✅ |
| **SNP calling confiable** | ✅ | ⚠️ | ✅ |
| **Regiones repetitivas** | ❌ | ✅ | ✅ |
| **# Contigs** | 50-200 | 2-10 | 1-5 |
| **Tasa de errores** | <0.01% | ~2% | <0.01% |

### ✅ Cuándo Usar Este Pipeline

**Ideal para:**
- ✅ Genomas de referencia de alta calidad
- ✅ Publicaciones científicas
- ✅ Caracterización completa de estructura genómica
- ✅ Tipificación precisa de plásmidos
- ✅ Estudios de epidemiología molecular avanzada
- ✅ Cuando necesitas **lo mejor posible**

**Requisitos:**
- Datos Illumina paired-end (≥50x cobertura)
- Datos Nanopore (≥50x cobertura)
- Tiempo de cómputo mayor (5-8 horas)
- Mayor espacio en disco (~150-200 GB)

### 🎯 Resultados Esperados

Con un ensamblaje híbrido bien ejecutado obtendrás:
- **1-5 contigs** (cromosoma + plásmidos principales)
- **N50 >5 Mb** (cromosoma completo)
- **Precisión >99.99%** (corregido con Illumina)
- **Elementos circulares cerrados** (cromosoma + plásmidos)
- **SNPs confiables** (validados por ambas tecnologías)

---

## ✅ Prerrequisitos

### Antes de Empezar

- [ ] Instalación completa según [00_INSTALLATION.md](00_INSTALLATION.md)
- [ ] Ambiente `bact_main` activado
- [ ] **Datos Illumina** paired-end (≥50x cobertura)
- [ ] **Datos Nanopore** (≥50x cobertura)
- [ ] ~150-200 GB de espacio libre en disco
- [ ] Opcional pero recomendado: haber ejecutado pipelines individuales primero

### Verificar Instalación

```bash
# Activar ambiente
conda activate bact_main

# Verificar herramientas críticas para híbrido
unicycler --version
fastqc --version
NanoPlot --version
bwa
minimap2 --version
samtools --version

# Si todo está bien, continuar
```

### Estructura de Datos Esperada

```
00_raw_data/
├── illumina/
│   ├── SAMPLE_1.fastq.gz    # R1 (forward)
│   └── SAMPLE_2.fastq.gz    # R2 (reverse)
└── nanopore/
    └── SAMPLE_1.fastq.gz    # Long reads
```

**⚠️ IMPORTANTE**: Aunque los archivos pueden tener nombres similares, deben estar en directorios separados.

---

## 🔄 Visión General del Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│                    PIPELINE HÍBRIDO                          │
└──────────────────────────────────────────────────────────────┘

1. DATOS CRUDOS
   ├─ Illumina R1/R2 (paired-end)
   └─ Nanopore (long reads)
   │
   ▼
2. CONTROL DE CALIDAD (PARALELO)
   ├─ Illumina: FastQC → fastp → FastQC
   └─ Nanopore: NanoPlot → Filtlong → NanoPlot
   │
   ▼
3. ENSAMBLAJE HÍBRIDO CON UNICYCLER
   ├─ Entrada: Illumina trimmed + Nanopore filtered
   ├─ Proceso: SPAdes + Miniasm + Racon + Pilon
   └─ Salida: Assembly híbrido de alta calidad
   │
   ▼
4. EVALUACIÓN COMPARATIVA (3-WAY)
   ├─ QUAST: Illumina vs Nanopore vs Híbrido
   └─ Identificar mejor ensamblaje
   │
   ▼
5. MAPEO CRUZADO
   ├─ Illumina → Ensamblaje híbrido
   ├─ Nanopore → Ensamblaje híbrido
   └─ Validación de ambas tecnologías
   │
   ▼
6. CONSENSO DE ALTA CALIDAD
   ├─ Variant calling con ambas tecnologías
   ├─ Validación cruzada de variantes
   └─ Secuencia consenso final
   │
   ▼
7. ANÁLISIS DE COBERTURA
   ├─ Cobertura Illumina por secuencia
   ├─ Cobertura Nanopore por secuencia
   └─ Validación de estructura
   │
   ▼
8. RESULTADOS FINALES
   ├─ Ensamblaje híbrido (1-5 contigs)
   ├─ Elementos circulares identificados
   ├─ Variantes validadas
   └─ Reportes integrados
```

**⏱️ Tiempo estimado total:** 5-8 horas  
**💾 Espacio requerido:** ~150-200 GB por muestra

---

## 🔬 Fase 1: Control de Calidad

### Objetivo

Realizar QC completo de ambas tecnologías antes del ensamblaje híbrido.

### Paso 1.1: QC de Datos Illumina

Si ya ejecutaste el pipeline Illumina ([01_ILLUMINA_PIPELINE.md](01_ILLUMINA_PIPELINE.md)), puedes reutilizar los datos limpios. Si no:

```bash
# Activar ambiente
conda activate bact_main

# Variables
SAMPLE="URO5550422"
R1="00_raw_data/illumina/${SAMPLE}_1.fastq.gz"
R2="00_raw_data/illumina/${SAMPLE}_2.fastq.gz"
THREADS=8

echo "========================================"
echo "QC Illumina - Pipeline Híbrido"
echo "Muestra: ${SAMPLE}"
echo "========================================"

# FastQC raw
mkdir -p 02_qc/01_illumina_raw
fastqc ${R1} ${R2} -o 02_qc/01_illumina_raw/ -t ${THREADS} -q

# Limpieza con fastp
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
  --json 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json

# FastQC trimmed
fastqc 02_qc/02_illumina_trimmed/${SAMPLE}_R*_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ -t ${THREADS} -q

echo "✓ QC Illumina completado"
```

### Paso 1.2: QC de Datos Nanopore

Si ya ejecutaste el pipeline Nanopore ([02_NANOPORE_PIPELINE.md](02_NANOPORE_PIPELINE.md)), puedes reutilizar los datos filtrados. Si no:

```bash
# Variables
NANOPORE="00_raw_data/nanopore/${SAMPLE}_1.fastq.gz"

echo "========================================"
echo "QC Nanopore - Pipeline Híbrido"
echo "========================================"

# NanoPlot raw
mkdir -p 02_qc/03_nanopore_raw
NanoPlot --fastq ${NANOPORE} \
  -o 02_qc/03_nanopore_raw/ -t ${THREADS} \
  --plots kde dot --N50 \
  --title "${SAMPLE} - Raw Nanopore"

# Filtlong
mkdir -p 02_qc/04_nanopore_filtered
filtlong --min_length 1000 --keep_percent 90 --target_bases 500000000 \
  ${NANOPORE} | \
  pigz -p ${THREADS} > 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz

# NanoPlot filtered
NanoPlot --fastq 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ -t ${THREADS} \
  --plots kde dot --N50 \
  --title "${SAMPLE} - Filtered Nanopore"

echo "✓ QC Nanopore completado"
```

### Paso 1.3: Verificar Cobertura de Ambas Tecnologías

```bash
echo "========================================"
echo "Verificación de Cobertura"
echo "========================================"

GENOME_SIZE=5700000  # K. pneumoniae

# Cobertura Illumina
ILLUMINA_BASES=$(zcat 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz | \
  paste - - - - | cut -f2 | tr -d '\n' | wc -c)
ILLUMINA_BASES=$((ILLUMINA_BASES * 2))  # x2 porque es paired-end
ILLUMINA_COV=$(echo "$ILLUMINA_BASES / $GENOME_SIZE" | bc)

echo "Illumina:"
echo "  Total bases: $(printf "%'d" $ILLUMINA_BASES)"
echo "  Cobertura estimada: ${ILLUMINA_COV}x"

# Cobertura Nanopore
NANOPORE_BASES=$(grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt | \
  awk '{print $NF}' | tr -d ',')
NANOPORE_COV=$(echo "$NANOPORE_BASES / $GENOME_SIZE" | bc)

echo ""
echo "Nanopore:"
echo "  Total bases: $(printf "%'d" $NANOPORE_BASES)"
echo "  Cobertura estimada: ${NANOPORE_COV}x"

echo ""
echo "=== EVALUACIÓN ==="
if [ $ILLUMINA_COV -ge 50 ] && [ $NANOPORE_COV -ge 50 ]; then
    echo "✓ Coberturas adecuadas para ensamblaje híbrido"
else
    echo "⚠️  Advertencia: cobertura baja detectada"
    [ $ILLUMINA_COV -lt 50 ] && echo "  - Illumina: ${ILLUMINA_COV}x (recomendado ≥50x)"
    [ $NANOPORE_COV -lt 50 ] && echo "  - Nanopore: ${NANOPORE_COV}x (recomendado ≥50x)"
fi
```

### Paso 1.4: Reporte MultiQC Integrado

```bash
echo "========================================"
echo "Reporte MultiQC Integrado"
echo "========================================"

mkdir -p 02_qc/05_multiqc

multiqc 02_qc/ \
  -o 02_qc/05_multiqc/ \
  --filename ${SAMPLE}_hybrid_multiqc_report \
  --title "Hybrid QC Report - ${SAMPLE}" \
  --comment "Illumina + Nanopore for hybrid assembly" \
  --force

echo "✓ Reporte MultiQC generado"
firefox 02_qc/05_multiqc/${SAMPLE}_hybrid_multiqc_report.html &
```

---

## 🧬 Fase 2: Ensamblaje Híbrido

### Objetivo

Ensamblar el genoma usando Unicycler, que integra inteligentemente lecturas cortas y largas.

### ¿Cómo Funciona Unicycler?

Unicycler ejecuta varios pasos automáticamente:

1. **Ensamblaje inicial con SPAdes** (usando Illumina)
2. **Bridging con lecturas largas** (Nanopore cierra gaps)
3. **Polishing con Racon** (corrige errores Nanopore)
4. **Polishing final con Pilon** (usa Illumina para máxima precisión)

### Paso 2.1: Ensamblaje Híbrido con Unicycler

```bash
echo "========================================"
echo "Ensamblaje Híbrido con Unicycler"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8

# Crear directorio
mkdir -p 03_assembly/03_hybrid

# Ejecutar Unicycler
unicycler \
  -1 ${R1_TRIM} \
  -2 ${R2_TRIM} \
  -l ${NANOPORE_FILT} \
  -o 03_assembly/03_hybrid/ \
  --threads ${THREADS} \
  --mode normal \
  --min_fasta_length 200 \
  --keep 2

echo "✓ Ensamblaje híbrido completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de Unicycler:**

| Parámetro | Función |
|-----------|---------|
| `-1 / -2` | Lecturas Illumina paired-end |
| `-l` | Lecturas largas (Nanopore) |
| `--mode normal` | Balance entre velocidad y calidad |
| `--min_fasta_length 200` | Descartar contigs <200 bp |
| `--keep 2` | Guardar archivos intermedios (nivel medio) |

**🎯 Modos de Unicycler:**

- `--mode conservative`: Más lento, máxima calidad (usar para publicaciones)
- `--mode normal`: Balance (recomendado para mayoría)
- `--mode bold`: Más rápido, puede ser menos preciso

### Paso 2.2: Archivos Generados por Unicycler

```bash
echo "========================================"
echo "Archivos Generados"
echo "========================================"

ls -lh 03_assembly/03_hybrid/

# Archivos principales:
# assembly.fasta - Ensamblaje final (USAR ESTE)
# assembly.gfa - Grafo de ensamblaje
# unicycler.log - Log detallado
```

**📁 Archivos importantes:**

```
03_assembly/03_hybrid/
├── assembly.fasta           # ⭐ ENSAMBLAJE FINAL
├── assembly.gfa             # Grafo (visualizar con Bandage)
├── unicycler.log            # Log del proceso
└── [varios archivos SAM/BAM de polishing]
```

### Paso 2.3: Renombrar y Analizar Ensamblaje

```bash
# Copiar con nombre estándar
cp 03_assembly/03_hybrid/assembly.fasta \
   03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta

echo "========================================"
echo "Estadísticas del Ensamblaje Híbrido"
echo "========================================"

ASSEMBLY="03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"

# Número de contigs
echo -n "Número de contigs: "
grep -c ">" ${ASSEMBLY}

# Tamaño total
echo -n "Tamaño total: "
grep -v ">" ${ASSEMBLY} | tr -d '\n' | wc -c | awk '{printf "%'"'"'d bp\n", $1}'

# Contigs y longitudes
echo ""
echo "=== CONTIGS ENSAMBLADOS ==="
grep ">" ${ASSEMBLY} | while read header; do
    contig_name=$(echo $header | sed 's/>//' | awk '{print $1}')
    length=$(echo $header | grep -oP 'length=\K[0-9]+')
    depth=$(echo $header | grep -oP 'depth=\K[0-9.]+')
    circular=$(echo $header | grep -o 'circular=true' || echo "linear")
    
    printf "%-15s %12s bp  Depth: %6sx  %s\n" \
      "$contig_name" "$(printf "%'d" $length)" "$depth" "$circular"
done
```

**📊 Salida Esperada:**

```
Número de contigs: 4

=== CONTIGS ENSAMBLADOS ===
1              5,334,567 bp  Depth:   65.2x  circular=true
2                122,799 bp  Depth:   54.1x  circular=true
3                111,195 bp  Depth:   48.7x  circular=true
4                105,974 bp  Depth:   51.3x  circular=true
```

---

## 📊 Fase 3: Evaluación Comparativa

### Objetivo

Comparar el ensamblaje híbrido contra los ensamblajes individuales (Illumina y Nanopore) para validar la mejora.

### Paso 3.1: Preparar Ensamblajes para Comparación

```bash
echo "========================================"
echo "Preparando Comparación 3-Way"
echo "========================================"

# Si NO tienes los ensamblajes individuales, crearlos
# (omitir si ya los ejecutaste)

# Ensamblaje Illumina (si no existe)
if [ ! -f "03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta" ]; then
    echo "Ejecutando ensamblaje Illumina..."
    bash scripts/run_illumina_assembly_only.sh ${SAMPLE}
fi

# Ensamblaje Nanopore (si no existe)
if [ ! -f "03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta" ]; then
    echo "Ejecutando ensamblaje Nanopore..."
    bash scripts/run_nanopore_assembly_only.sh ${SAMPLE}
fi
```

### Paso 3.2: Evaluación con QUAST (3-Way)

```bash
echo "========================================"
echo "Evaluación QUAST - Comparación 3-Way"
echo "========================================"

ILLUMINA_ASM="03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta"
NANOPORE_ASM="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
HYBRID_ASM="03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"
REFERENCE="01_reference/reference.fasta"

mkdir -p 03_assembly/04_quast_evaluation/hybrid_comparison

quast.py \
  ${ILLUMINA_ASM} \
  ${NANOPORE_ASM} \
  ${HYBRID_ASM} \
  -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/hybrid_comparison/ \
  --threads ${THREADS} \
  --labels "Illumina,Nanopore,Hybrid" \
  --glimmer \
  --min-contig 200 \
  --plots-format png \
  --circos

echo "✓ Evaluación QUAST completada"
firefox 03_assembly/04_quast_evaluation/hybrid_comparison/report.html &
```

### Paso 3.3: Tabla Comparativa

```bash
echo "========================================"
echo "Tabla Comparativa - 3 Estrategias"
echo "========================================"

# Mostrar reporte en terminal
cat 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt

# Generar tabla resumida
cat > 03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt << EOF
# Comparación de Estrategias de Ensamblaje
# Muestra: ${SAMPLE}
# Fecha: $(date)

EOF

echo "Métrica                         | Illumina  | Nanopore | Híbrido  | Mejor" >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt
echo "--------------------------------|-----------|----------|----------|-------" >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

# Extraer métricas clave
grep "# contigs (>= 0 bp)" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | \
  awk '{printf "%-31s | %9s | %8s | %8s |\n", "# contigs", $4, $5, $6}' >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

grep "Largest contig" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | \
  awk '{printf "%-31s | %9s | %8s | %8s |\n", "Largest contig", $3, $4, $5}' >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

grep "Total length" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | head -1 | \
  awk '{printf "%-31s | %9s | %8s | %8s |\n", "Total length", $3, $4, $5}' >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

grep "N50" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | head -1 | \
  awk '{printf "%-31s | %9s | %8s | %8s |\n", "N50", $2, $3, $4}' >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

grep "L50" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | head -1 | \
  awk '{printf "%-31s | %9s | %8s | %8s |\n", "L50", $2, $3, $4}' >> \
  03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt

# Mostrar tabla
cat 03_assembly/04_quast_evaluation/hybrid_comparison/summary_table.txt
```

**📊 Ejemplo de Tabla Comparativa:**

```
Métrica                         | Illumina  | Nanopore | Híbrido  | Mejor
--------------------------------|-----------|----------|----------|-------
# contigs                       |        98 |        7 |        4 | Híbrido
Largest contig                  |   387,234 | 5,334,567| 5,334,567| Híbrido
Total length                    | 5,612,345 | 5,723,892| 5,689,234| Híbrido
N50                             |   145,678 | 5,334,567| 5,334,567| Híbrido
L50                             |        12 |        1 |        1 | Híbrido
```

---

## 🗺️ Fase 4: Mapeo y Validación

### Objetivo

Mapear AMBAS tecnologías contra el ensamblaje híbrido para validación cruzada.

### Paso 4.1: Preparar Ensamblaje Híbrido como Referencia

```bash
echo "========================================"
echo "Preparando Ensamblaje Híbrido"
echo "========================================"

HYBRID_ASM="03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"

# Índices para mapeo
bwa index ${HYBRID_ASM}
samtools faidx ${HYBRID_ASM}

echo "✓ Índices creados"
```

### Paso 4.2: Mapeo de Lecturas Illumina

```bash
echo "========================================"
echo "Mapeo Illumina → Ensamblaje Híbrido"
echo "========================================"

R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"

mkdir -p 04_mapping/01_illumina

# Mapeo
bwa mem -t ${THREADS} \
  -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
  ${HYBRID_ASM} ${R1_TRIM} ${R2_TRIM} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam

# Indexar
samtools index 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam

# Estadísticas
samtools flagstat 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_hybrid_flagstat.txt

samtools coverage 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_hybrid_coverage.txt

echo "✓ Mapeo Illumina completado"
cat 04_mapping/01_illumina/${SAMPLE}_hybrid_flagstat.txt
```

### Paso 4.3: Mapeo de Lecturas Nanopore

```bash
echo "========================================"
echo "Mapeo Nanopore → Ensamblaje Híbrido"
echo "========================================"

NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"

mkdir -p 04_mapping/02_nanopore

# Mapeo
minimap2 -ax map-ont -t ${THREADS} \
  ${HYBRID_ASM} ${NANOPORE_FILT} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam

# Indexar
samtools index 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam

# Estadísticas
samtools flagstat 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_hybrid_flagstat.txt

samtools coverage 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_hybrid_coverage.txt

echo "✓ Mapeo Nanopore completado"
cat 04_mapping/02_nanopore/${SAMPLE}_hybrid_flagstat.txt
```

---

## 🎯 Fase 5: Consenso de Alta Calidad

### Objetivo

Generar secuencia consenso validada por ambas tecnologías.

### Paso 5.1: Variant Calling con Illumina

```bash
echo "========================================"
echo "Variant Calling - Illumina"
echo "========================================"

BAM_ILLUMINA="04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam"

mkdir -p 04_mapping/03_variants

# Call variants
bcftools mpileup -Ou -f ${HYBRID_ASM} ${BAM_ILLUMINA} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz

# Filtrar variantes de alta calidad
bcftools view -i 'QUAL>=30 && DP>=10' \
  04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz

echo "✓ Variantes Illumina detectadas"
```

### Paso 5.2: Variant Calling con Nanopore

```bash
echo "========================================"
echo "Variant Calling - Nanopore"
echo "========================================"

BAM_NANOPORE="04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam"

# Call variants
bcftools mpileup -Ou -f ${HYBRID_ASM} ${BAM_NANOPORE} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz

# Filtrar variantes
bcftools view -i 'QUAL>=20 && DP>=5' \
  04_mapping/03_variants/${SAMPLE}_nanopore_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_nanopore_variants_filtered.vcf.gz

bcftools index 04_mapping/03_variants/${SAMPLE}_nanopore_variants_filtered.vcf.gz

echo "✓ Variantes Nanopore detectadas"
```

### Paso 5.3: Validación Cruzada de Variantes

```bash
echo "========================================"
echo "Validación Cruzada de Variantes"
echo "========================================"

# Encontrar variantes consenso (detectadas por ambas tecnologías)
bcftools isec \
  04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz \
  04_mapping/03_variants/${SAMPLE}_nanopore_variants_filtered.vcf.gz \
  -p 04_mapping/03_variants/isec_output

# Variantes comunes están en isec_output/0002.vcf (Illumina) y 0003.vcf (Nanopore)
# Estas son las más confiables

echo "=== RESUMEN DE VARIANTES ==="
echo "Variantes Illumina únicamente:"
bcftools view -H 04_mapping/03_variants/isec_output/0000.vcf.gz | wc -l

echo "Variantes Nanopore únicamente:"
bcftools view -H 04_mapping/03_variants/isec_output/0001.vcf.gz | wc -l

echo "Variantes CONSENSO (ambas tecnologías):"
bcftools view -H 04_mapping/03_variants/isec_output/0002.vcf.gz | wc -l

# Usar variantes consenso para generar secuencia final
bcftools consensus -f ${HYBRID_ASM} \
  04_mapping/03_variants/isec_output/0002.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_hybrid_consensus.fasta

echo "✓ Secuencia consenso de alta calidad generada"
```

---

## 📈 Fase 6: Análisis de Cobertura

### Objetivo

Analizar la cobertura de ambas tecnologías sobre el ensamblaje híbrido.

### Paso 6.1: Cobertura por Tecnología

```bash
echo "========================================"
echo "Análisis de Cobertura - Ambas Tecnologías"
echo "========================================"

mkdir -p 04_mapping/04_coverage_analysis

# Cobertura Illumina
echo "=== COBERTURA ILLUMINA ==="
samtools coverage ${BAM_ILLUMINA} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_illumina_coverage.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_coverage.txt

# Profundidad promedio Illumina
samtools depth ${BAM_ILLUMINA} | \
  awk '{sum+=$3; count++} END {printf "Profundidad promedio Illumina: %.2fx\n", sum/count}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_illumina_mean_depth.txt

echo ""
echo "=== COBERTURA NANOPORE ==="
samtools coverage ${BAM_NANOPORE} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage.txt

# Profundidad promedio Nanopore
samtools depth ${BAM_NANOPORE} | \
  awk '{sum+=$3; count++} END {printf "Profundidad promedio Nanopore: %.2fx\n", sum/count}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_mean_depth.txt

cat 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_mean_depth.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_mean_depth.txt
```

### Paso 6.2: Cobertura Combinada

```bash
echo "========================================"
echo "Cobertura Combinada"
echo "========================================"

# Crear reporte combinado
cat > 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt << EOF
# Reporte de Cobertura Combinada - Pipeline Híbrido
# Muestra: ${SAMPLE}
# Fecha: $(date)

========================================
COBERTURA POR TECNOLOGÍA
========================================

EOF

echo "ILLUMINA:" >> 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_coverage.txt >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt

echo "" >> 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
echo "NANOPORE:" >> 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage.txt >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt

echo "" >> 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
echo "========================================" >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
echo "PROFUNDIDAD PROMEDIO" >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
echo "========================================" >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_mean_depth.txt >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_mean_depth.txt >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt

echo "✓ Reporte de cobertura combinada generado"
cat 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt
```

### Paso 6.3: Identificar Regiones con Cobertura Desigual

```bash
echo "========================================"
echo "Análisis de Regiones con Cobertura Desigual"
echo "========================================"

# Regiones con baja cobertura en Illumina pero buena en Nanopore
# (típicamente regiones repetitivas o con sesgo GC)
samtools depth ${BAM_ILLUMINA} ${BAM_NANOPORE} | \
  awk '$3 < 20 && $4 > 40 {print $1"\t"$2"\t"$3"\t"$4}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_illumina_low_nanopore_high.txt

# Regiones con baja cobertura en Nanopore pero buena en Illumina
# (posibles regiones problemáticas para Nanopore)
samtools depth ${BAM_ILLUMINA} ${BAM_NANOPORE} | \
  awk '$3 > 40 && $4 < 20 {print $1"\t"$2"\t"$3"\t"$4}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_low_illumina_high.txt

# Resumen
echo "Regiones con problemas de cobertura:"
echo "  Illumina baja, Nanopore alta: $(wc -l < 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_low_nanopore_high.txt) posiciones"
echo "  Nanopore baja, Illumina alta: $(wc -l < 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_low_illumina_high.txt) posiciones"
```

---

## 📊 Comparación de Estrategias

### Tabla Comparativa Final

```bash
echo "========================================"
echo "COMPARACIÓN FINAL - 3 ESTRATEGIAS"
echo "========================================"

cat > 08_results/comparison_table.txt << EOF
# Comparación de Estrategias de Ensamblaje
# Muestra: ${SAMPLE}
# Fecha: $(date)

========================================
MÉTRICAS DE ENSAMBLAJE
========================================

Métrica                    | Illumina    | Nanopore    | Híbrido     | Mejor
---------------------------|-------------|-------------|-------------|----------
Número de contigs          | $(grep -c ">" 03_assembly/01_illumina_only/${SAMPLE}_illumina_assembly.fasta) | $(grep -c ">" 03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta) | $(grep -c ">" 03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta) | Híbrido
Cromosoma cerrado          | No          | Sí          | Sí          | Híbrido
Plásmidos cerrados         | No          | Sí          | Sí          | Híbrido
Continuidad (N50)          | ~150 kb     | >5 Mb       | >5 Mb       | Híbrido
Precisión                  | >99.9%      | ~98%        | >99.99%     | Híbrido
Tiempo de análisis         | 3-5 h       | 2-4 h       | 5-8 h       | Nanopore

========================================
VENTAJAS POR ESTRATEGIA
========================================

ILLUMINA:
  ✓ Alta precisión en SNPs
  ✓ Bajo costo por base
  ✓ Análisis más rápido
  ✗ Ensamblaje fragmentado
  ✗ Plásmidos incompletos

NANOPORE:
  ✓ Alta continuidad
  ✓ Cromosoma cerrado
  ✓ Plásmidos completos
  ✗ Mayor tasa de errores
  ✗ SNP calling menos preciso

HÍBRIDO:
  ✓ Continuidad de Nanopore
  ✓ Precisión de Illumina
  ✓ Cromosoma y plásmidos cerrados
  ✓ SNPs altamente confiables
  ✓ MEJOR CALIDAD GENERAL
  ✗ Mayor tiempo de cómputo
  ✗ Requiere ambos tipos de datos

========================================
RECOMENDACIÓN
========================================

Para caracterización completa y publicación:
→ USAR ENSAMBLAJE HÍBRIDO

Para vigilancia epidemiológica rutinaria:
→ Illumina puede ser suficiente

Para tipificación de plásmidos:
→ Nanopore o Híbrido

EOF

cat 08_results/comparison_table.txt
```

---

## 📊 Interpretación de Resultados

### Resumen del Pipeline Híbrido

```bash
echo "========================================"
echo "RESUMEN FINAL - Pipeline Híbrido"
echo "Muestra: ${SAMPLE}"
echo "========================================"
echo ""

# 1. Datos de entrada
echo "=== 1. DATOS DE ENTRADA ==="
echo "Illumina:"
grep "Total reads:" 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json | head -1
echo "Nanopore:"
grep "Number of reads:" 02_qc/04_nanopore_filtered/NanoStats.txt

echo ""

# 2. Ensamblaje híbrido
echo "=== 2. ENSAMBLAJE HÍBRIDO ==="
HYBRID_ASM="03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"
echo "Archivo: ${SAMPLE}_hybrid_assembly.fasta"
echo -n "  Contigs: "
grep -c ">" ${HYBRID_ASM}
echo -n "  Tamaño total: "
grep -v ">" ${HYBRID_ASM} | tr -d '\n' | wc -c | awk '{printf "%'"'"'d bp\n", $1}'

# Elementos circulares
CIRCULAR=$(grep "circular=true" ${HYBRID_ASM} | wc -l)
echo "  Elementos circulares: $CIRCULAR"

echo ""

# 3. Calidad (QUAST)
echo "=== 3. CALIDAD DEL ENSAMBLAJE ==="
if [ -f "03_assembly/04_quast_evaluation/hybrid_comparison/report.txt" ]; then
    grep "Hybrid" 03_assembly/04_quast_evaluation/hybrid_comparison/report.txt | head -10
fi

echo ""

# 4. Cobertura
echo "=== 4. COBERTURA ==="
cat 04_mapping/04_coverage_analysis/${SAMPLE}_illumina_mean_depth.txt
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_mean_depth.txt

echo ""

# 5. Variantes consenso
echo "=== 5. VARIANTES CONSENSO ==="
CONSENSUS_VARS=$(bcftools view -H 04_mapping/03_variants/isec_output/0002.vcf.gz 2>/dev/null | wc -l)
echo "Variantes validadas por ambas tecnologías: $CONSENSUS_VARS"

echo ""
echo "========================================"
echo "✓ Pipeline Híbrido Completado"
echo "========================================"
```

### Archivos Importantes Generados

```bash
echo "=== ARCHIVOS IMPORTANTES ==="
echo ""
echo "Control de Calidad:"
echo "  - 02_qc/05_multiqc/${SAMPLE}_hybrid_multiqc_report.html"
echo ""
echo "Ensamblaje Híbrido:"
echo "  - 03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta (⭐ PRINCIPAL)"
echo "  - 03_assembly/03_hybrid/assembly.gfa (grafo)"
echo ""
echo "Evaluación Comparativa:"
echo "  - 03_assembly/04_quast_evaluation/hybrid_comparison/report.html"
echo ""
echo "Mapeos:"
echo "  - 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam"
echo "  - 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam"
echo ""
echo "Variantes y Consenso:"
echo "  - 04_mapping/03_variants/${SAMPLE}_hybrid_consensus.fasta (⭐ SECUENCIA FINAL)"
echo "  - 04_mapping/03_variants/isec_output/ (variantes validadas)"
echo ""
echo "Cobertura:"
echo "  - 04_mapping/04_coverage_analysis/${SAMPLE}_combined_coverage_report.txt"
```

---

## 🎯 Criterios de Calidad

### ✅ Ensamblaje Híbrido Exitoso

| Criterio | Valor Mínimo | Valor Óptimo | Significado |
|----------|--------------|--------------|-------------|
| **# contigs** | <10 | 1-5 | Altamente contiguo |
| **N50** | >1 Mb | >5 Mb | Cromosoma completo |
| **L50** | <5 | 1-2 | Muy pocos contigs |
| **Cromosoma circular** | Sí | Sí | Estructura cerrada |
| **Plásmidos circulares** | ≥1 | 3-6 | Elementos móviles |
| **Cobertura Illumina** | >40x | >60x | Buena corrección |
| **Cobertura Nanopore** | >40x | >60x | Buena estructura |
| **Variantes consenso** | >80% | >90% | Alta concordancia |
| **% Genome fraction** | >99% | >99.5% | Casi completo |

### ⚠️ Señales de Alerta

| Problema | Posible Causa | Solución |
|----------|---------------|----------|
| >10 contigs | Cobertura insuficiente | Aumentar cobertura de ambas tecnologías |
| Cromosoma NO circular | Datos Nanopore insuficientes | Obtener más datos Nanopore (>60x) |
| Alta discordancia de variantes | Problema de calidad | Revisar QC, especialmente Nanopore |
| Cobertura muy desigual | Sesgo de amplificación | Mejorar preparación de librería |
| Contigs pequeños extra | Contaminación | Filtrar contigs <1 kb, verificar con BLAST |

---

## 🔧 Solución de Problemas

### Problema 1: Unicycler Falla en "Bridging"

**Síntoma:**
```
Error: Unable to bridge contigs with long reads
```

**Causas:**
- Cobertura Nanopore insuficiente (<30x)
- Lecturas Nanopore muy cortas (<5 kb promedio)
- Baja calidad de datos Nanopore

**Solución:**
```bash
# Verificar cobertura Nanopore
grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt
grep "Mean read length:" 02_qc/04_nanopore_filtered/NanoStats.txt

# Si cobertura <30x o mean length <5 kb:
# Opción 1: Ajustar filtlong para mantener más datos
filtlong --keep_percent 95 --target_bases 600000000 ...

# Opción 2: Usar modo bold (menos estricto)
unicycler ... --mode bold

# Opción 3: Si no funciona, usar ensamblaje Illumina pulido con Nanopore
# (ver pipeline alternativo en troubleshooting)
```

### Problema 2: Unicycler Muy Lento (>12 horas)

**Síntoma:**
Pipeline toma más de 12 horas.

**Causas:**
- Modo conservative (muy exhaustivo)
- Demasiados threads (overhead)
- Datos excesivos

**Solución:**
```bash
# Usar modo normal en lugar de conservative
unicycler ... --mode normal

# Usar número óptimo de threads (no siempre más es mejor)
unicycler ... --threads 8  # En lugar de 16+

# Reducir datos Illumina si cobertura >150x
seqtk sample -s100 R1.fastq.gz 0.5 | gzip > R1_sampled.fastq.gz
seqtk sample -s100 R2.fastq.gz 0.5 | gzip > R2_sampled.fastq.gz
```

### Problema 3: Muchas Variantes Discordantes

**Síntoma:**
```
Variantes Illumina únicamente: 5000+
Variantes consenso: <50%
```

**Causas:**
- Ensamblaje de referencia diferente a la muestra
- Problemas de calidad en una tecnología
- Errores sistemáticos en Nanopore

**Diagnóstico:**
```bash
# Verificar calidad de mapeo
grep "mapped (" 04_mapping/01_illumina/${SAMPLE}_hybrid_flagstat.txt
grep "mapped (" 04_mapping/02_nanopore/${SAMPLE}_hybrid_flagstat.txt

# Si % mapeado <90%, hay problema

# Verificar tipo de variantes
bcftools stats 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz | \
  grep "^SN"
```

**Solución:**
```bash
# Si es cepa muy divergente:
# 1. Usar el ensamblaje híbrido como "referencia"
# 2. No comparar contra genoma de referencia distante

# Si es problema de calidad Nanopore:
# 3. Ejecutar ronda adicional de polishing con Medaka
# 4. Usar solo variantes Illumina para consenso final
```

### Problema 4: Plásmidos No Salen Circulares

**Síntoma:**
Plásmidos quedan lineales (no circular=true).

**Causas:**
- Cobertura Nanopore insuficiente en plásmidos
- Plásmidos de bajo copy number
- Problemas de extracción de DNA

**Solución:**
```bash
# Verificar cobertura específica de plásmidos
samtools view -b ${BAM_NANOPORE} "nombre_plasmido" | \
  samtools depth - | \
  awk '{sum+=$3; n++} END {print "Cobertura plásmido:", sum/n"x"}'

# Si cobertura <40x en plásmidos:
# 1. Obtener más datos Nanopore enfocados
# 2. Usar kit de enriquecimiento de plásmidos
# 3. Aceptar que algunos plásmidos quedarán incompletos
```

### Problema 5: Contaminación Detectada

**Síntoma:**
Contigs extra pequeños con baja cobertura.

**Diagnóstico:**
```bash
# Identificar contigs sospechosos
grep ">" ${HYBRID_ASM} | while read header; do
    contig=$(echo $header | cut -d' ' -f1 | sed 's/>//')
    length=$(echo $header | grep -oP 'length=\K[0-9]+')
    depth=$(echo $header | grep -oP 'depth=\K[0-9.]+')
    
    if [ $length -lt 10000 ] && [ $(echo "$depth < 10" | bc -l) -eq 1 ]; then
        echo "Sospechoso: $contig - ${length}bp - ${depth}x"
    fi
done

# BLAST de contigs sospechosos
blastn -query contig_sospechoso.fasta \
       -db nt -remote -outfmt 6 -max_target_seqs 5
```

**Solución:**
```bash
# Filtrar contigs pequeños de baja cobertura
seqtk seq -L 1000 ${HYBRID_ASM} | \
  grep -A1 "depth=[5-9][0-9]\|depth=[1-9][0-9][0-9]" > \
  ${SAMPLE}_hybrid_filtered.fasta

# O usar solo elementos circulares
grep -A1 "circular=true" ${HYBRID_ASM} > \
  ${SAMPLE}_hybrid_circular_only.fasta
```

---

## 🚀 Script Completo del Pipeline

```bash
cat > scripts/run_hybrid_pipeline.sh << 'EOF'
#!/bin/bash

# Script completo del Pipeline Híbrido
# Uso: bash scripts/run_hybrid_pipeline.sh SAMPLE_NAME

set -e  # Salir si hay error

SAMPLE=$1
THREADS=8

if [ -z "$SAMPLE" ]; then
    echo "Uso: bash $0 SAMPLE_NAME"
    exit 1
fi

echo "========================================"
echo "Pipeline Híbrido Completo"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Activar ambiente
conda activate bact_main

# Variables
R1="00_raw_data/illumina/${SAMPLE}_1.fastq.gz"
R2="00_raw_data/illumina/${SAMPLE}_2.fastq.gz"
NANOPORE="00_raw_data/nanopore/${SAMPLE}_1.fastq.gz"
REFERENCE="01_reference/reference.fasta"

# Verificar archivos
if [ ! -f "$R1" ] || [ ! -f "$R2" ] || [ ! -f "$NANOPORE" ]; then
    echo "❌ Error: Archivos FASTQ no encontrados"
    exit 1
fi

###############################
# FASE 1: CONTROL DE CALIDAD
###############################
echo ""
echo "=== FASE 1: Control de Calidad ==="

# QC Illumina
mkdir -p 02_qc/01_illumina_raw 02_qc/02_illumina_trimmed
fastqc ${R1} ${R2} -o 02_qc/01_illumina_raw/ -t ${THREADS} -q

fastp -i ${R1} -I ${R2} \
  -o 02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz \
  -O 02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz \
  --detect_adapter_for_pe --cut_front --cut_tail \
  --cut_window_size 4 --cut_mean_quality 20 --trim_poly_g \
  --qualified_quality_phred 20 --unqualified_percent_limit 40 \
  --n_base_limit 5 --length_required 50 --thread ${THREADS} \
  --html 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.html \
  --json 02_qc/02_illumina_trimmed/${SAMPLE}_fastp_report.json

fastqc 02_qc/02_illumina_trimmed/${SAMPLE}_R*_trimmed.fastq.gz \
  -o 02_qc/02_illumina_trimmed/ -t ${THREADS} -q

# QC Nanopore
mkdir -p 02_qc/03_nanopore_raw 02_qc/04_nanopore_filtered
NanoPlot --fastq ${NANOPORE} -o 02_qc/03_nanopore_raw/ -t ${THREADS} \
  --plots kde dot --N50 --title "${SAMPLE} - Raw Nanopore"

filtlong --min_length 1000 --keep_percent 90 --target_bases 500000000 \
  ${NANOPORE} | pigz -p ${THREADS} > \
  02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz

NanoPlot --fastq 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ -t ${THREADS} \
  --plots kde dot --N50 --title "${SAMPLE} - Filtered Nanopore"

# MultiQC
mkdir -p 02_qc/05_multiqc
multiqc 02_qc/ -o 02_qc/05_multiqc/ \
  --filename ${SAMPLE}_hybrid_multiqc_report \
  --title "Hybrid QC - ${SAMPLE}" -f -q

echo "✓ Control de calidad completado"

###############################
# FASE 2: ENSAMBLAJE HÍBRIDO
###############################
echo ""
echo "=== FASE 2: Ensamblaje Híbrido con Unicycler ==="

R1_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R1_trimmed.fastq.gz"
R2_TRIM="02_qc/02_illumina_trimmed/${SAMPLE}_R2_trimmed.fastq.gz"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"

mkdir -p 03_assembly/03_hybrid

unicycler -1 ${R1_TRIM} -2 ${R2_TRIM} -l ${NANOPORE_FILT} \
  -o 03_assembly/03_hybrid/ --threads ${THREADS} \
  --mode normal --min_fasta_length 200 --keep 2

cp 03_assembly/03_hybrid/assembly.fasta \
   03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta

echo "✓ Ensamblaje híbrido completado"

###############################
# FASE 3: EVALUACIÓN
###############################
echo ""
echo "=== FASE 3: Evaluación con QUAST ==="

HYBRID_ASM="03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"
mkdir -p 03_assembly/04_quast_evaluation

quast.py ${HYBRID_ASM} -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads ${THREADS} --labels "Hybrid_${SAMPLE}" \
  --glimmer --min-contig 200 -q

echo "✓ Evaluación completada"

###############################
# FASE 4: MAPEO
###############################
echo ""
echo "=== FASE 4: Mapeo y Validación ==="

# Índices
bwa index ${HYBRID_ASM} 2>/dev/null || true
samtools faidx ${HYBRID_ASM}

# Mapeo Illumina
mkdir -p 04_mapping/01_illumina
bwa mem -t ${THREADS} -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
  ${HYBRID_ASM} ${R1_TRIM} ${R2_TRIM} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam

samtools index 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam
samtools flagstat 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_hybrid_flagstat.txt
samtools coverage 04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/01_illumina/${SAMPLE}_hybrid_coverage.txt

# Mapeo Nanopore
mkdir -p 04_mapping/02_nanopore
minimap2 -ax map-ont -t ${THREADS} ${HYBRID_ASM} ${NANOPORE_FILT} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam

samtools index 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam
samtools flagstat 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_hybrid_flagstat.txt
samtools coverage 04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_hybrid_coverage.txt

echo "✓ Mapeo completado"

###############################
# FASE 5: VARIANTES
###############################
echo ""
echo "=== FASE 5: Variantes y Consenso ==="

BAM_ILLUMINA="04_mapping/01_illumina/${SAMPLE}_hybrid_sorted.bam"
BAM_NANOPORE="04_mapping/02_nanopore/${SAMPLE}_hybrid_sorted.bam"

mkdir -p 04_mapping/03_variants

# Variantes Illumina
bcftools mpileup -Ou -f ${HYBRID_ASM} ${BAM_ILLUMINA} | \
  bcftools call -mv -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz
bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz

bcftools view -i 'QUAL>=30 && DP>=10' \
  04_mapping/03_variants/${SAMPLE}_illumina_variants.vcf.gz | \
  bcftools view -Oz -o 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz
bcftools index 04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz

# Consenso
bcftools consensus -f ${HYBRID_ASM} \
  04_mapping/03_variants/${SAMPLE}_illumina_variants_filtered.vcf.gz > \
  04_mapping/03_variants/${SAMPLE}_hybrid_consensus.fasta

echo "✓ Consenso generado"

###############################
# FASE 6: COBERTURA
###############################
echo ""
echo "=== FASE 6: Análisis de Cobertura ==="

mkdir -p 04_mapping/04_coverage_analysis

samtools coverage ${BAM_ILLUMINA} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_illumina_coverage.txt
samtools coverage ${BAM_NANOPORE} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage.txt

samtools depth ${BAM_ILLUMINA} | \
  awk '{sum+=$3; count++} END {printf "Profundidad Illumina: %.2fx\n", sum/count}' > \
  04_mapping/04_coverage_analysis/${SAMPLE}_mean_depth.txt
samtools depth ${BAM_NANOPORE} | \
  awk '{sum+=$3; count++} END {printf "Profundidad Nanopore: %.2fx\n", sum/count}' >> \
  04_mapping/04_coverage_analysis/${SAMPLE}_mean_depth.txt

echo "✓ Análisis de cobertura completado"

###############################
# RESUMEN FINAL
###############################
echo ""
echo "========================================"
echo "✓ Pipeline Híbrido Completado"
echo "Muestra: ${SAMPLE}"
echo "Fin: $(date)"
echo "========================================"
echo ""
echo "Archivos principales:"
echo "  QC: 02_qc/05_multiqc/${SAMPLE}_hybrid_multiqc_report.html"
echo "  Ensamblaje: 03_assembly/03_hybrid/${SAMPLE}_hybrid_assembly.fasta"
echo "  QUAST: 03_assembly/04_quast_evaluation/report.html"
echo "  Consenso: 04_mapping/03_variants/${SAMPLE}_hybrid_consensus.fasta"
echo ""

EOF

chmod +x scripts/run_hybrid_pipeline.sh
```

### Uso del Script Automatizado

```bash
# Ejecutar pipeline híbrido completo
bash scripts/run_hybrid_pipeline.sh URO5550422

# Tiempo estimado: 5-8 horas
# Monitorear progreso en terminal
```

---

## 📝 Checklist Final

Antes de continuar con análisis downstream, verifica:

- [ ] ✅ QC muestra buena calidad en ambas tecnologías
- [ ] ✅ Cobertura Illumina >50x
- [ ] ✅ Cobertura Nanopore >50x
- [ ] ✅ Ensamblaje tiene <10 contigs
- [ ] ✅ N50 >1 Mb
- [ ] ✅ Cromosoma está cerrado (circular)
- [ ] ✅ Plásmidos principales están cerrados
- [ ] ✅ % reads mapeados >90% (ambas tecnologías)
- [ ] ✅ Variantes consenso generadas
- [ ] ✅ Sin grandes regiones con cobertura desigual

---

## 🎓 Próximos Pasos

### Continuar con Análisis Downstream

El ensamblaje híbrido es el **mejor punto de partida** para:

**→ [04_AMR_TYPING.md](04_AMR_TYPING.md)** - Detección de genes AMR y tipificación molecular

Este incluye:
- Anotación funcional (Prokka/Bakta)
- Detección exhaustiva de genes AMR
- MLST typing de alta confianza
- Caracterización completa de plásmidos
- Factores de virulencia
- Reportes integrados

---

## 📖 Referencias

### Herramientas Utilizadas

- **Unicycler**: Wick et al. (2017) - PLOS Computational Biology
  - "Unicycler: Resolving bacterial genome assemblies from short and long sequencing reads"
  
- **fastp**: Chen et al. (2018) - Bioinformatics
  
- **Filtlong**: https://github.com/rrwick/Filtlong
  
- **SPAdes**: Bankevich et al. (2012) - Journal of Computational Biology
  
- **Minimap2**: Li (2018) - Bioinformatics

### Lecturas Recomendadas

1. **Ensamblaje híbrido**:
   - Wick & Holt (2019) "Benchmarking of long-read assemblers for prokaryote whole genome sequencing"
   
2. **Comparación de estrategias**:
   - Goldstein et al. (2019) "Advantages of hybrid long-read assembly of bacterial genomes"
   
3. **Mejores prácticas**:
   - Wick et al. (2017) "Completing bacterial genome assemblies with multiplex MinION sequencing"

---

## 💡 Tips y Mejores Prácticas

### 1. Proporción Óptima Illumina:Nanopore

```bash
# Recomendación general:
# Illumina: 50-100x
# Nanopore: 50-80x

# No es necesario exceder estas coberturas
# Más no siempre es mejor (aumenta tiempo sin mejora significativa)
```

### 2. Cuándo NO Usar Pipeline Híbrido

```bash
# Si solo tienes uno de los dos tipos de datos
# Si el costo/tiempo no justifica la mejora marginal
# Si solo necesitas detección de genes AMR (Illumina suficiente)
# Si cobertura de alguna tecnología es <30x
```

### 3. Verificar Calidad del Híbrido

```bash
# El ensamblaje híbrido DEBE ser mejor que individuales
# Si no es así, revisar:

# 1. Comparar N50
# Si híbrido no mejora N50, problema con datos Nanopore

# 2. Comparar precisión  
# Si híbrido tiene más errores, problema con integración

# 3. Si híbrido es peor, usar mejor individual
```

### 4. Optimización de Recursos

```bash
# Ejecutar en paralelo si tienes múltiples muestras
# Usar SSD para archivos temporales
# Limitar memoria de SPAdes si necesario
# Considerar cluster computing para >10 muestras
```

---

<div align="center">

**✅ Pipeline Híbrido Completado**

---

**Resultado: Ensamblaje de Máxima Calidad**
- Continuidad de Nanopore
- Precisión de Illumina  
- Cromosoma y plásmidos cerrados
- SNPs altamente confiables

---

### Navegación

[⬅️ Pipeline Nanopore](02_NANOPORE_PIPELINE.md) | [🏠 Índice Principal](../README.md) | [➡️ Detección AMR](04_AMR_TYPING.md)

---

*Última actualización: Enero 2025*  
*Versión: 1.0*  
*Pipeline Híbrido - Calidad Premium*

</div>
