# 📗 Pipeline Solo Nanopore
### Análisis de Genomas Bacterianos con Lecturas Largas

---

## 📋 Tabla de Contenidos

1. [Introducción](#-introducción)
2. [Prerrequisitos](#-prerrequisitos)
3. [Visión General del Pipeline](#-visión-general-del-pipeline)
4. [Fase 1: Control de Calidad](#-fase-1-control-de-calidad)
5. [Fase 2: Ensamblaje de Novo](#-fase-2-ensamblaje-de-novo)
6. [Fase 3: Evaluación del Ensamblaje](#-fase-3-evaluación-del-ensamblaje)
7. [Fase 4: Polishing (Pulido)](#-fase-4-polishing-pulido)
8. [Fase 5: Mapeo Contra Referencia](#-fase-5-mapeo-contra-referencia)
9. [Fase 6: Análisis de Cobertura](#-fase-6-análisis-de-cobertura)
10. [Fase 7: Identificación de Elementos Circulares](#-fase-7-identificación-de-elementos-circulares)
11. [Interpretación de Resultados](#-interpretación-de-resultados)
12. [Solución de Problemas](#-solución-de-problemas)

---

## 🎯 Introducción

### ¿Cuándo Usar Este Pipeline?

✅ **Ideal para:**
- Obtener genomas altamente contiguos (2-10 contigs)
- Cerrar cromosomas y plásmidos completos
- Resolver regiones repetitivas complejas
- Cuando solo dispones de datos Nanopore
- Reconstruir estructura genómica completa

⚠️ **Limitaciones:**
- Mayor tasa de errores (especialmente indels)
- Menos preciso para SNP calling
- Requiere mayor cobertura (>50x recomendado)
- Puede necesitar polishing adicional

### Características de Datos Nanopore

| Característica | Valor Típico |
|----------------|--------------|
| Longitud de reads | 1-50 kb (promedio 5-15 kb) |
| Química | Single-end (lecturas largas) |
| Tasa de error | 5-10% (principalmente indels) |
| Cobertura recomendada | 50-100x |
| Ventaja principal | Resolución de estructura |
| Desventaja principal | Mayor tasa de errores |

### Ventajas de Nanopore sobre Illumina

| Aspecto | Nanopore | Illumina |
|---------|----------|----------|
| **Continuidad** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐ Fragmentado |
| **Precisión** | ⭐⭐⭐ Buena | ⭐⭐⭐⭐⭐ Excelente |
| **Plásmidos cerrados** | ✅ Sí | ❌ Difícil |
| **Regiones repetitivas** | ✅ Resuelve | ❌ Problemático |
| **Costo por Gb** | Medio | Bajo |
| **Tiempo de run** | Horas-días | Días |

---

## ✅ Prerrequisitos

### Antes de Empezar

- [ ] Instalación completa según [00_INSTALLATION.md](00_INSTALLATION.md)
- [ ] Ambiente `bact_main` activado
- [ ] Datos Nanopore en formato FASTQ
- [ ] Al menos 50x cobertura del genoma
- [ ] ~50-100 GB de espacio libre en disco

### Verificar Instalación

```bash
# Activar ambiente
conda activate bact_main

# Verificar herramientas críticas
NanoPlot --version
filtlong --version
flye --version
minimap2 --version
samtools --version

# Si todo está bien, continuar
```

### Estructura de Datos Esperada

```
00_raw_data/nanopore/
└── SAMPLE_1.fastq.gz    # Long reads (ONT)
```

**⚠️ IMPORTANTE**: El archivo puede tener el mismo nombre que R1 de Illumina, pero debe estar en directorio separado (`nanopore/` vs `illumina/`).

---

## 🔄 Visión General del Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    PIPELINE NANOPORE                        │
└─────────────────────────────────────────────────────────────┘

1. DATOS CRUDOS (FASTQ)
   └─ SAMPLE_1.fastq.gz (long reads)
   │
   ▼
2. CONTROL DE CALIDAD
   ├─ NanoPlot (raw data)
   ├─ Filtlong (filtrado por calidad/longitud)
   └─ NanoPlot (filtered data)
   │
   ▼
3. ENSAMBLAJE DE NOVO
   ├─ Flye (ensamblador para long reads)
   └─ Assembly graph (contigs circulares)
   │
   ▼
4. EVALUACIÓN DE CALIDAD
   ├─ QUAST
   └─ Métricas (N50, circularidad, etc.)
   │
   ▼
5. POLISHING (Opcional pero recomendado)
   ├─ Medaka (corrección con Nanopore)
   └─ Genoma pulido
   │
   ▼
6. MAPEO CONTRA REFERENCIA
   ├─ Minimap2
   ├─ Samtools (sort, index)
   └─ BAM file
   │
   ▼
7. ANÁLISIS DE COBERTURA
   ├─ Por cromosoma
   ├─ Por plásmidos
   └─ Estadísticas
   │
   ▼
8. IDENTIFICACIÓN DE ELEMENTOS CIRCULARES
   ├─ Cromosoma (circular)
   ├─ Plásmidos (circulares)
   └─ Assembly graph analysis
   │
   ▼
9. RESULTADOS FINALES
   ├─ Ensamblaje (contigs largos)
   ├─ Elementos circulares
   ├─ Cobertura
   └─ Reportes QC
```

**⏱️ Tiempo estimado total:** 2-4 horas  
**💾 Espacio requerido:** ~50-100 GB por muestra

---

## 🔬 Fase 1: Control de Calidad

### Objetivo

Evaluar la calidad de las lecturas Nanopore, filtrar por longitud y calidad, y generar reportes de QC.

### Paso 1.1: NanoPlot en Datos Crudos

```bash
# Activar ambiente
conda activate bact_main

# Variables (CAMBIAR SEGÚN TU MUESTRA)
SAMPLE="URO5550422"
NANOPORE="00_raw_data/nanopore/${SAMPLE}_1.fastq.gz"
THREADS=8

echo "========================================"
echo "NanoPlot - Datos Crudos"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Crear directorio de salida
mkdir -p 02_qc/03_nanopore_raw

# Ejecutar NanoPlot
NanoPlot \
  --fastq ${NANOPORE} \
  -o 02_qc/03_nanopore_raw/ \
  -t ${THREADS} \
  --plots kde dot \
  --N50 \
  --title "${SAMPLE} - Raw Nanopore Data" \
  --color darkslategrey

echo "✓ NanoPlot completado"
echo "  Reportes en: 02_qc/03_nanopore_raw/"
```

**📊 Archivos generados por NanoPlot:**
- `NanoPlot-report.html` - Reporte visual interactivo
- `NanoStats.txt` - Estadísticas textuales
- `LengthvsQualityScatterPlot_kde.png` - Longitud vs Calidad
- `LengthvsQualityScatterPlot_dot.png` - Dispersión
- `Non_weightedHistogramReadlength.png` - Distribución de longitudes
- `WeightedHistogramReadlength.png` - Histograma ponderado

**🔍 Revisar Reporte NanoPlot:**

```bash
# Abrir reporte HTML
firefox 02_qc/03_nanopore_raw/NanoPlot-report.html &

# Ver estadísticas en terminal
cat 02_qc/03_nanopore_raw/NanoStats.txt
```

**📈 Métricas Clave a Revisar:**

| Métrica | Valor Ideal | Valor Aceptable | ⚠️ Revisar si |
|---------|-------------|-----------------|--------------|
| Total reads | 50K-200K | 30K-300K | <30K |
| Total bases | 300M-1G | 200M-1.5G | <200M |
| Mean read length | 5-15 kb | 3-20 kb | <2 kb |
| Median read length | 4-12 kb | 2-15 kb | <1.5 kb |
| Read length N50 | 8-20 kb | 5-25 kb | <4 kb |
| Mean quality score | 11-14 | 10-15 | <10 |
| Median quality score | 12-14 | 10-15 | <10 |

**📊 Interpretar Estadísticas:**

```bash
echo "=== RESUMEN ESTADÍSTICAS RAW ==="
grep -E "Number of reads|Total bases|Mean read length|Read length N50|Mean read quality" \
  02_qc/03_nanopore_raw/NanoStats.txt
```

### Paso 1.2: Filtrado con Filtlong

```bash
echo "========================================"
echo "Filtlong - Filtrado de Calidad"
echo "========================================"

# Crear directorio de salida
mkdir -p 02_qc/04_nanopore_filtered

# Filtrar con Filtlong
filtlong \
  --min_length 1000 \
  --keep_percent 90 \
  --target_bases 500000000 \
  ${NANOPORE} | \
  pigz -p ${THREADS} > 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz

echo "✓ Filtrado completado"
echo "  Archivo: 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
```

**⚙️ Parámetros de Filtlong explicados:**

| Parámetro | Función |
|-----------|---------|
| `--min_length 1000` | Descartar reads <1 kb (muy cortos, poco útiles) |
| `--keep_percent 90` | Mantener 90% de datos de mejor calidad |
| `--target_bases 500000000` | ~500 Mb de datos finales (~88x para 5.7 Mb genoma) |

**💡 Ajustar según tu genoma:**

```bash
# Para genoma de 5.7 Mb, calcular target_bases para cobertura deseada
GENOME_SIZE=5700000
DESIRED_COV=80
TARGET_BASES=$((GENOME_SIZE * DESIRED_COV))

echo "Target bases para ${DESIRED_COV}x cobertura: $TARGET_BASES"
# Use este valor en --target_bases
```

### Paso 1.3: NanoPlot en Datos Filtrados

```bash
echo "========================================"
echo "NanoPlot - Datos Filtrados"
echo "========================================"

# Ejecutar NanoPlot en datos filtrados
NanoPlot \
  --fastq 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ \
  -t ${THREADS} \
  --plots kde dot \
  --N50 \
  --title "${SAMPLE} - Filtered Nanopore Data" \
  --color darkcyan

echo "✓ NanoPlot post-filtrado completado"
```

### Paso 1.4: Comparar Antes/Después del Filtrado

```bash
echo "========================================"
echo "Comparación Raw vs Filtered"
echo "========================================"

# Función para extraer métrica
get_stat() {
    local file=$1
    local pattern=$2
    grep "$pattern" "$file" | awk '{print $NF}'
}

RAW_STATS="02_qc/03_nanopore_raw/NanoStats.txt"
FILT_STATS="02_qc/04_nanopore_filtered/NanoStats.txt"

echo "Métrica                    | Raw          | Filtered     | Cambio"
echo "---------------------------|--------------|--------------|--------"

# Total reads
RAW_READS=$(get_stat "$RAW_STATS" "Number of reads:")
FILT_READS=$(get_stat "$FILT_STATS" "Number of reads:")
printf "%-26s | %-12s | %-12s | %.1f%%\n" "Number of reads" "$RAW_READS" "$FILT_READS" \
  $(echo "scale=1; ($FILT_READS/$RAW_READS)*100" | bc)

# Total bases
RAW_BASES=$(get_stat "$RAW_STATS" "Total bases:")
FILT_BASES=$(get_stat "$FILT_STATS" "Total bases:")
printf "%-26s | %-12s | %-12s | %.1f%%\n" "Total bases" "$RAW_BASES" "$FILT_BASES" \
  $(echo "scale=1; ($FILT_BASES/$RAW_BASES)*100" | bc)

# Mean length
RAW_MEAN=$(get_stat "$RAW_STATS" "Mean read length:")
FILT_MEAN=$(get_stat "$FILT_STATS" "Mean read length:")
printf "%-26s | %-12s | %-12s | +%.1f%%\n" "Mean read length" "$RAW_MEAN" "$FILT_MEAN" \
  $(echo "scale=1; (($FILT_MEAN-$RAW_MEAN)/$RAW_MEAN)*100" | bc)

# N50
RAW_N50=$(get_stat "$RAW_STATS" "Read length N50:")
FILT_N50=$(get_stat "$FILT_STATS" "Read length N50:")
printf "%-26s | %-12s | %-12s | +%.1f%%\n" "Read length N50" "$RAW_N50" "$FILT_N50" \
  $(echo "scale=1; (($FILT_N50-$RAW_N50)/$RAW_N50)*100" | bc)

# Quality
RAW_QUAL=$(get_stat "$RAW_STATS" "Mean read quality:")
FILT_QUAL=$(get_stat "$FILT_STATS" "Mean read quality:")
printf "%-26s | %-12s | %-12s | +%.1f%%\n" "Mean quality" "$RAW_QUAL" "$FILT_QUAL" \
  $(echo "scale=1; (($FILT_QUAL-$RAW_QUAL)/$RAW_QUAL)*100" | bc)

echo ""
echo "✓ Comparación completada"
```

**🎯 Resultados Esperados del Filtrado:**

- ✅ Retención de ~85-95% de reads
- ✅ Retención de ~90-95% de bases
- ✅ Incremento en mean length (10-30%)
- ✅ Incremento en N50 (15-40%)
- ✅ Incremento en calidad promedio (5-15%)

---

## 🧬 Fase 2: Ensamblaje de Novo

### Objetivo

Ensamblar las lecturas filtradas en contigs usando Flye, optimizado para lecturas largas de Nanopore.

### Paso 2.1: Ensamblaje con Flye

```bash
echo "========================================"
echo "Ensamblaje con Flye"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8
GENOME_SIZE="5.7m"  # Para K. pneumoniae

# Crear directorio de salida
mkdir -p 03_assembly/02_nanopore_only

# Ejecutar Flye
flye \
  --nano-raw ${NANOPORE_FILT} \
  --out-dir 03_assembly/02_nanopore_only/ \
  --genome-size ${GENOME_SIZE} \
  --threads ${THREADS} \
  --iterations 3 \
  --meta

echo "✓ Ensamblaje completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de Flye:**

| Parámetro | Función |
|-----------|---------|
| `--nano-raw` | Lecturas Nanopore sin corregir (basecalling directo) |
| `--genome-size 5.7m` | Tamaño esperado del genoma (ayuda a optimización) |
| `--threads 8` | Número de threads paralelos |
| `--iterations 3` | Número de rondas de polishing (↑ calidad) |
| `--meta` | Modo metagenoma (útil para detectar múltiples replicons) |

**📁 Archivos generados por Flye:**

```
03_assembly/02_nanopore_only/
├── assembly.fasta              # Ensamblaje final (USAR ESTE)
├── assembly_info.txt           # Info de contigs (longitud, circularidad)
├── assembly_graph.gfa          # Grafo de ensamblaje (visualizar con Bandage)
├── assembly_graph.gv           # Grafo en formato GraphViz
├── flye.log                    # Log detallado del proceso
└── params.json                 # Parámetros usados
```

### Paso 2.2: Analizar assembly_info.txt

```bash
echo "========================================"
echo "Información del Ensamblaje"
echo "========================================"

# Copiar ensamblaje con nombre estándar
cp 03_assembly/02_nanopore_only/assembly.fasta \
   03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta

# Mostrar información de contigs
echo "=== CONTIGS ENSAMBLADOS ==="
cat 03_assembly/02_nanopore_only/assembly_info.txt

echo ""
echo "=== RESUMEN ==="
echo -n "Número total de contigs: "
grep -v "^#" 03_assembly/02_nanopore_only/assembly_info.txt | wc -l

echo -n "Contigs circulares: "
grep -c "circular=Y" 03_assembly/02_nanopore_only/assembly_info.txt || echo "0"

echo -n "Tamaño total del ensamblaje: "
awk 'NR>1 {sum+=$2} END {printf "%'"'"'d bp\n", sum}' \
  03_assembly/02_nanopore_only/assembly_info.txt
```

**🔍 Interpretar assembly_info.txt:**

```
#seq_name       length  cov.    circ.   repeat  mult.   alt_group       graph_path
contig_1        5334567 67      Y       N       1       *       1
contig_2        122799  54      Y       N       1       *       2
contig_3        111195  48      Y       N       1       *       3
contig_4        105974  51      Y       N       1       *       4
contig_5        3751    89      Y       N       1       *       5
contig_6        3353    76      Y       N       1       *       6
contig_7        1308    112     Y       N       1       *       7
```

**Columnas importantes:**
- `length`: Longitud del contig en bp
- `cov.`: Cobertura promedio
- `circ.`: Y = circular (cromosoma/plásmido cerrado)
- `repeat`: Y = región repetitiva
- `mult.`: Multiplicidad (copias del elemento)

### Paso 2.3: Identificar Cromosoma y Plásmidos

```bash
echo "========================================"
echo "Identificación de Elementos Genómicos"
echo "========================================"

# Identificar posible cromosoma (contig más largo)
echo "=== POSIBLE CROMOSOMA ==="
awk 'NR>1 && $2 > 5000000 {printf "%-15s %10d bp  Cobertura: %dx  Circular: %s\n", $1, $2, $3, $4}' \
  03_assembly/02_nanopore_only/assembly_info.txt

# Identificar posibles plásmidos (contigs circulares pequeños)
echo ""
echo "=== POSIBLES PLÁSMIDOS ==="
awk 'NR>1 && $2 < 500000 && $4 == "Y" {printf "%-15s %10d bp  Cobertura: %dx  Circular: %s\n", $1, $2, $3, $4}' \
  03_assembly/02_nanopore_only/assembly_info.txt

# Elementos NO circulares (posibles problemas)
echo ""
NONCIRCULAR=$(awk 'NR>1 && $4 == "N"' 03_assembly/02_nanopore_only/assembly_info.txt | wc -l)
if [ $NONCIRCULAR -gt 0 ]; then
    echo "⚠️  Elementos NO circulares detectados: $NONCIRCULAR"
    echo "    Estos pueden representar:"
    echo "    - Contaminación"
    echo "    - Plásmidos incompletos"
    echo "    - Artefactos de ensamblaje"
    awk 'NR>1 && $4 == "N" {printf "    %-15s %10d bp  Cobertura: %dx\n", $1, $2, $3}' \
      03_assembly/02_nanopore_only/assembly_info.txt
else
    echo "✓ Todos los elementos son circulares (excelente)"
fi
```

---

## 📊 Fase 3: Evaluación del Ensamblaje

### Objetivo

Evaluar la calidad del ensamblaje Nanopore usando QUAST y comparar contra el genoma de referencia.

### Paso 3.1: Evaluación con QUAST

```bash
echo "========================================"
echo "Evaluación con QUAST"
echo "========================================"

# Variables
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta"
REFERENCE="01_reference/reference.fasta"

# Crear directorio
mkdir -p 03_assembly/04_quast_evaluation

# Ejecutar QUAST
quast.py \
  ${ASSEMBLY} \
  -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads ${THREADS} \
  --labels "Nanopore_${SAMPLE}" \
  --glimmer \
  --min-contig 200 \
  --plots-format png \
  --circos

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
grep "Largest contig" 03_assembly/04_quast_evaluation/report.txt
grep "Total length" 03_assembly/04_quast_evaluation/report.txt
grep "N50" 03_assembly/04_quast_evaluation/report.txt
grep "L50" 03_assembly/04_quast_evaluation/report.txt
grep "# mismatches per 100 kbp" 03_assembly/04_quast_evaluation/report.txt
grep "# indels per 100 kbp" 03_assembly/04_quast_evaluation/report.txt
```

**📊 Valores esperados para K. pneumoniae (Nanopore):**

| Métrica | Valor Esperado | Interpretación |
|---------|----------------|----------------|
| **# contigs** | 2-10 | Excelente continuidad |
| **Largest contig** | 5.0-5.5 Mb | Probablemente cromosoma completo |
| **Tamaño total** | 5.5-6.0 Mb | Cromosoma + plásmidos |
| **N50** | >5 Mb | Altísima continuidad |
| **L50** | 1-2 | Muy pocos contigs necesarios |
| **GC%** | 56-58% | Normal para K. pneumoniae |
| **Genome fraction** | >99% | Casi completo |
| **Mismatches/100kb** | 50-200 | Normal para Nanopore |
| **Indels/100kb** | 200-500 | Típico, mejorable con polishing |

**🎯 Ventaja sobre Illumina:**

```
NANOPORE:
  # contigs: 7
  N50: 5.33 Mb
  L50: 1

ILLUMINA:
  # contigs: 98
  N50: 145 kb
  L50: 12

→ Nanopore produce ensamblajes 10-50x más contiguos
```

---

## 🔧 Fase 4: Polishing (Pulido)

### Objetivo

Mejorar la precisión del ensamblaje usando Medaka para corregir errores de basecalling.

### Paso 4.1: Polishing con Medaka

```bash
echo "========================================"
echo "Polishing con Medaka"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta"
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
THREADS=8

# Crear directorio
mkdir -p 03_assembly/02_nanopore_only/medaka_polish

# Ejecutar Medaka
medaka_consensus \
  -i ${NANOPORE_FILT} \
  -d ${ASSEMBLY} \
  -o 03_assembly/02_nanopore_only/medaka_polish \
  -t ${THREADS} \
  -m r941_min_high_g360

echo "✓ Polishing completado"
echo "  Fin: $(date)"
```

**⚙️ Modelos de Medaka:**

El parámetro `-m` depende de tu flowcell y basecaller:

| Flowcell | Basecaller | Modelo Medaka |
|----------|------------|---------------|
| MinION R9.4.1 | Guppy ≥3.6.0 (high accuracy) | `r941_min_high_g360` |
| MinION R9.4.1 | Guppy <3.6.0 | `r941_min_high_g303` |
| MinION R9.4.1 | Fast mode | `r941_min_fast` |
| MinION R10.4 | Guppy ≥5.0.0 | `r104_e81_fast_g5015` |
| PromethION R9.4.1 | Guppy high acc | `r941_prom_high_g360` |

**💡 Cómo saber qué modelo usar:**

```bash
# Revisar metadata de basecalling
# Usualmente está en el header del FASTQ original
zcat ${NANOPORE} | head -1

# O listar modelos disponibles
medaka tools list_models
```

### Paso 4.2: Copiar Ensamblaje Pulido

```bash
# Copiar ensamblaje pulido
cp 03_assembly/02_nanopore_only/medaka_polish/consensus.fasta \
   03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta

echo "✓ Ensamblaje pulido: ${SAMPLE}_nanopore_polished.fasta"
```

### Paso 4.3: Comparar Antes/Después del Polishing

```bash
echo "========================================"
echo "Comparación Pre vs Post Polishing"
echo "========================================"

# Evaluar con QUAST (comparar ambos)
quast.py \
  03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta \
  03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta \
  -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/polishing_comparison \
  --threads ${THREADS} \
  --labels "Before_polish,After_polish" \
  --min-contig 200

echo "✓ Comparación completada"
echo "  Reporte: 03_assembly/04_quast_evaluation/polishing_comparison/report.html"

# Ver diferencia en errores
echo ""
echo "=== REDUCCIÓN DE ERRORES ==="
grep "# mismatches per 100 kbp" \
  03_assembly/04_quast_evaluation/polishing_comparison/report.txt

grep "# indels per 100 kbp" \
  03_assembly/04_quast_evaluation/polishing_comparison/report.txt
```

**🎯 Mejora Esperada con Medaka:**

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| Mismatches/100kb | 150-200 | 50-100 | ~50-60% |
| Indels/100kb | 400-500 | 150-250 | ~50-60% |
| Precisión general | ~95% | ~98% | +3% |

---

## 🗺️ Fase 5: Mapeo Contra Referencia

### Objetivo

Mapear las lecturas filtradas contra el genoma de referencia para análisis de cobertura y validación.

### Paso 5.1: Indexar Genoma de Referencia

```bash
echo "========================================"
echo "Preparando Referencia para Minimap2"
echo "========================================"

REFERENCE="01_reference/reference.fasta"

# Índice para Samtools (si no existe)
if [ ! -f "${REFERENCE}.fai" ]; then
    echo "Creando índice FAI..."
    samtools faidx ${REFERENCE}
fi

# Índice para Minimap2 (opcional, acelera mapeo)
if [ ! -f "${REFERENCE}.mmi" ]; then
    echo "Creando índice Minimap2..."
    minimap2 -d ${REFERENCE}.mmi ${REFERENCE}
fi

echo "✓ Índices creados"
```

### Paso 5.2: Mapeo con Minimap2

```bash
echo "========================================"
echo "Mapeo con Minimap2"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Variables
NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
REFERENCE="01_reference/reference.fasta"
THREADS=8

# Crear directorio
mkdir -p 04_mapping/02_nanopore

# Mapeo con Minimap2 y conversión a BAM
minimap2 -ax map-ont -t ${THREADS} \
  ${REFERENCE} \
  ${NANOPORE_FILT} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/02_nanopore/${SAMPLE}_sorted.bam

echo "✓ Mapeo completado"
echo "  Fin: $(date)"
```

**⚙️ Parámetros de Minimap2:**

- `-ax map-ont`: Preset para Nanopore vs referencia
- `-t 8`: Usar 8 threads
- Salida en formato SAM (pipe a samtools)

### Paso 5.3: Indexar BAM

```bash
echo "Indexando BAM..."
samtools index 04_mapping/02_nanopore/${SAMPLE}_sorted.bam

echo "✓ BAM indexado"
ls -lh 04_mapping/02_nanopore/
```

### Paso 5.4: Estadísticas de Mapeo

```bash
echo "========================================"
echo "Estadísticas de Mapeo"
echo "========================================"

BAM="04_mapping/02_nanopore/${SAMPLE}_sorted.bam"

# Flagstat (estadísticas generales)
samtools flagstat ${BAM} > \
  04_mapping/02_nanopore/${SAMPLE}_flagstat.txt

# Mostrar flagstat
cat 04_mapping/02_nanopore/${SAMPLE}_flagstat.txt

# Cobertura por secuencia
samtools coverage ${BAM} > \
  04_mapping/02_nanopore/${SAMPLE}_coverage.txt

# Mostrar cobertura
echo ""
echo "=== COBERTURA POR SECUENCIA ==="
cat 04_mapping/02_nanopore/${SAMPLE}_coverage.txt

# Profundidad promedio
samtools depth ${BAM} | \
  awk '{sum+=$3; count++} END {print "Profundidad promedio:", sum/count"x"}' > \
  04_mapping/02_nanopore/${SAMPLE}_mean_depth.txt

cat 04_mapping/02_nanopore/${SAMPLE}_mean_depth.txt
```

**📊 Valores esperados:**

| Métrica | Valor Ideal | Aceptable | ⚠️ Revisar si |
|---------|-------------|-----------|--------------|
| % mapeado | >95% | >90% | <90% |
| Cobertura promedio | 50-100x | 30-150x | <30x |
| Reads primarios | >90% | >85% | <85% |

---

## 📈 Fase 6: Análisis de Cobertura

### Objetivo

Analizar la cobertura detallada por cada elemento genómico (cromosoma y plásmidos).

### Paso 6.1: Cobertura Global

```bash
echo "========================================"
echo "Análisis de Cobertura"
echo "========================================"

BAM="04_mapping/02_nanopore/${SAMPLE}_sorted.bam"

# Crear directorio
mkdir -p 04_mapping/04_coverage_analysis

# Cobertura por secuencia
samtools coverage ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage_summary.txt

# Mostrar resumen
echo "=== COBERTURA POR SECUENCIA ==="
cat 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage_summary.txt
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
      04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_${seqid}.bam
    
    # Indexar
    samtools index 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_${seqid}.bam
    
    # Profundidad promedio
    samtools depth 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_${seqid}.bam | \
      awk -v seq="$seqid" '{sum+=$3; count++} END {
        if (count>0) printf "%s\t%.2fx\n", seq, sum/count
        else printf "%s\t0x\n", seq
      }' >> 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_depth_per_sequence.txt

done < 01_reference/reference_sequences.txt

echo "✓ Análisis por secuencia completado"
```

### Paso 6.3: Uniformidad de Cobertura

```bash
echo "========================================"
echo "Análisis de Uniformidad"
echo "========================================"

# Calcular estadísticas de profundidad
samtools depth ${BAM} | \
  awk '{print $3}' | \
  sort -n | \
  awk '
    BEGIN {count=0; sum=0}
    {
      depth[count++] = $1
      sum += $1
    }
    END {
      mean = sum/count
      median = depth[int(count/2)]
      
      # Percentiles
      p25 = depth[int(count*0.25)]
      p75 = depth[int(count*0.75)]
      
      printf "Mean depth: %.2fx\n", mean
      printf "Median depth: %.2fx\n", median
      printf "25th percentile: %.2fx\n", p25
      printf "75th percentile: %.2fx\n", p75
      printf "IQR: %.2fx\n", p75-p25
    }
  ' > 04_mapping/04_coverage_analysis/${SAMPLE}_depth_stats.txt

cat 04_mapping/04_coverage_analysis/${SAMPLE}_depth_stats.txt
```

**🎯 Cobertura Ideal:**
- Media y mediana muy cercanas (distribución simétrica)
- IQR (rango intercuartílico) pequeño
- Sin regiones grandes con 0x cobertura

---

## 🔄 Fase 7: Identificación de Elementos Circulares

### Objetivo

Confirmar qué elementos son circulares (cromosoma, plásmidos) y extraerlos individualmente.

### Paso 7.1: Lista de Elementos Circulares

```bash
echo "========================================"
echo "Elementos Circulares Identificados"
echo "========================================"

# Extraer elementos circulares del assembly_info.txt
grep "circular=Y" 03_assembly/02_nanopore_only/assembly_info.txt > \
  03_assembly/02_nanopore_only/circular_elements.txt

# Mostrar
echo "=== ELEMENTOS CIRCULARES ==="
cat 03_assembly/02_nanopore_only/circular_elements.txt

# Contar
CIRCULAR_COUNT=$(wc -l < 03_assembly/02_nanopore_only/circular_elements.txt)
echo ""
echo "Total de elementos circulares: $CIRCULAR_COUNT"
```

### Paso 7.2: Extraer Secuencias Circulares

```bash
echo "========================================"
echo "Extrayendo Secuencias Circulares"
echo "========================================"

# Crear directorio
mkdir -p 03_assembly/02_nanopore_only/circular_sequences

# Archivo de ensamblaje
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"

# Extraer cada elemento circular
while read -r contig_name length cov circ rest; do
    echo "Extrayendo: $contig_name (${length} bp)"
    
    # Extraer secuencia con samtools
    samtools faidx ${ASSEMBLY} ${contig_name} > \
      03_assembly/02_nanopore_only/circular_sequences/${contig_name}.fasta
    
done < 03_assembly/02_nanopore_only/circular_elements.txt

echo "✓ Secuencias circulares extraídas"
ls -lh 03_assembly/02_nanopore_only/circular_sequences/
```

### Paso 7.3: Clasificar Cromosoma vs Plásmidos

```bash
echo "========================================"
echo "Clasificación: Cromosoma vs Plásmidos"
echo "========================================"

# Crear directorio
mkdir -p 03_assembly/02_nanopore_only/classified

# Clasificar por tamaño
while read -r contig_name length rest; do
    if [ $length -gt 4000000 ]; then
        # Cromosoma (>4 Mb)
        echo "$contig_name ($length bp) → CROMOSOMA"
        cp 03_assembly/02_nanopore_only/circular_sequences/${contig_name}.fasta \
           03_assembly/02_nanopore_only/classified/chromosome.fasta
    else
        # Plásmido (<4 Mb)
        echo "$contig_name ($length bp) → PLÁSMIDO"
        cp 03_assembly/02_nanopore_only/circular_sequences/${contig_name}.fasta \
           03_assembly/02_nanopore_only/classified/plasmid_${contig_name}.fasta
    fi
done < 03_assembly/02_nanopore_only/circular_elements.txt

echo ""
echo "✓ Elementos clasificados en: 03_assembly/02_nanopore_only/classified/"
ls -lh 03_assembly/02_nanopore_only/classified/
```

---

## 📊 Interpretación de Resultados

### Resumen del Pipeline

```bash
echo "========================================"
echo "RESUMEN FINAL - Pipeline Nanopore"
echo "Muestra: ${SAMPLE}"
echo "========================================"
echo ""

# 1. Control de Calidad
echo "=== 1. CONTROL DE CALIDAD ==="
echo "Datos crudos:"
grep "Number of reads:" 02_qc/03_nanopore_raw/NanoStats.txt
grep "Total bases:" 02_qc/03_nanopore_raw/NanoStats.txt
grep "Read length N50:" 02_qc/03_nanopore_raw/NanoStats.txt

echo ""
echo "Datos filtrados:"
grep "Number of reads:" 02_qc/04_nanopore_filtered/NanoStats.txt
grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt
grep "Read length N50:" 02_qc/04_nanopore_filtered/NanoStats.txt

echo ""

# 2. Ensamblaje
echo "=== 2. ENSAMBLAJE ==="
ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta"
echo "Archivo: ${SAMPLE}_nanopore_polished.fasta"
echo -n "  Contigs totales: "
grep -c ">" ${ASSEMBLY}
echo -n "  Elementos circulares: "
grep -c "circular=Y" 03_assembly/02_nanopore_only/assembly_info.txt || echo "0"
echo -n "  Tamaño total: "
grep -v ">" ${ASSEMBLY} | tr -d '\n' | wc -c | awk '{printf "%'"'"'d bp\n", $1}'

# Identificar cromosoma
echo -n "  Cromosoma: "
awk '$2 > 4000000 {printf "%s (%d bp)\n", $1, $2}' \
  03_assembly/02_nanopore_only/assembly_info.txt

# Contar plásmidos
PLASMID_COUNT=$(awk '$2 < 4000000 && $4 == "Y"' \
  03_assembly/02_nanopore_only/assembly_info.txt | wc -l)
echo "  Plásmidos: $PLASMID_COUNT"

echo ""

# 3. Calidad (QUAST)
echo "=== 3. CALIDAD DEL ENSAMBLAJE ==="
if [ -f "03_assembly/04_quast_evaluation/report.txt" ]; then
    grep "N50" 03_assembly/04_quast_evaluation/report.txt | head -1
    grep "L50" 03_assembly/04_quast_evaluation/report.txt | head -1
    grep "# mismatches per 100 kbp" 03_assembly/04_quast_evaluation/report.txt
    grep "# indels per 100 kbp" 03_assembly/04_quast_evaluation/report.txt
fi

echo ""

# 4. Mapeo
echo "=== 4. MAPEO ==="
echo "Reads mapeados:"
grep "mapped (" 04_mapping/02_nanopore/${SAMPLE}_flagstat.txt | head -1
echo "Cobertura promedio:"
cat 04_mapping/02_nanopore/${SAMPLE}_mean_depth.txt

echo ""
echo "========================================"
echo "✓ Pipeline Nanopore Completado"
echo "========================================"
```

### Archivos Importantes Generados

```bash
echo "=== ARCHIVOS IMPORTANTES ==="
echo ""
echo "Control de Calidad:"
echo "  - 02_qc/03_nanopore_raw/NanoPlot-report.html"
echo "  - 02_qc/04_nanopore_filtered/NanoPlot-report.html"
echo ""
echo "Ensamblaje:"
echo "  - 03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta"
echo "  - 03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta (USAR ESTE)"
echo "  - 03_assembly/02_nanopore_only/assembly_info.txt"
echo "  - 03_assembly/04_quast_evaluation/report.html"
echo ""
echo "Elementos Circulares:"
echo "  - 03_assembly/02_nanopore_only/classified/chromosome.fasta"
echo "  - 03_assembly/02_nanopore_only/classified/plasmid_*.fasta"
echo ""
echo "Mapeo:"
echo "  - 04_mapping/02_nanopore/${SAMPLE}_sorted.bam"
echo "  - 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage_summary.txt"
```

---

## 🎯 Criterios de Calidad

### ✅ Ensamblaje Exitoso

| Criterio | Valor Mínimo | Valor Óptimo |
|----------|--------------|--------------|
| **Número de contigs** | <15 | <10 |
| **Elementos circulares** | ≥1 (cromosoma) | 5-8 (cromosoma + plásmidos) |
| **N50** | >1 Mb | >5 Mb |
| **L50** | <5 | 1-2 |
| **Tamaño total** | 5.0-6.0 Mb | 5.5-5.8 Mb |
| **% Reads mapeados** | >85% | >90% |
| **Cobertura promedio** | >40x | >60x |
| **Cromosoma circular** | Sí | Sí |

### ⚠️ Señales de Alerta

| Problema | Posible Causa | Solución |
|----------|---------------|----------|
| >20 contigs | Cobertura baja o mala calidad | Aumentar cobertura, mejorar filtrado |
| Cromosoma NO circular | Cobertura insuficiente | Obtener más datos, verificar calidad |
| Muchos plásmidos NO circulares | Plásmidos de bajo copy number | Aumentar cobertura |
| Cobertura <30x | Datos insuficientes | Re-secuenciar |
| N50 <500 kb | Problema de ensamblaje | Revisar parámetros Flye |
| Alta tasa de indels (>500/100kb) | Falta polishing | Ejecutar Medaka |

---

## 🔧 Solución de Problemas

### Problema 1: Flye Falla con "Not Enough Data"

**Síntoma:**
```
[ERROR] Alignment error: not enough reads
```

**Causas:**
- Cobertura <20x
- Reads muy cortos (<1 kb promedio)
- Genoma muy pequeño para `--genome-size`

**Solución:**
```bash
# Verificar cobertura
TOTAL_BASES=$(grep "Total bases:" 02_qc/04_nanopore_filtered/NanoStats.txt | awk '{print $NF}')
GENOME_SIZE=5700000
COVERAGE=$(echo "$TOTAL_BASES / $GENOME_SIZE" | bc)
echo "Cobertura estimada: ${COVERAGE}x"

# Si <20x, necesitas más datos o reducir --target_bases en Filtlong
# Si reads muy cortos, reducir --min_length en Filtlong

# Ajustar --genome-size si es necesario
flye --nano-raw ... --genome-size 6m  # Aumentar si tienes muchos plásmidos
```

### Problema 2: Cromosoma NO Sale Circular

**Síntoma:**
```
contig_1    5334567    67    N    ...
```
(circ. = N en lugar de Y)

**Causas:**
- Cobertura insuficiente en extremos
- Reads no suficientemente largos
- Región repetitiva en extremos

**Solución:**
```bash
# 1. Verificar cobertura en extremos
samtools depth 04_mapping/02_nanopore/${SAMPLE}_sorted.bam | \
  head -1000 | awk '{print $3}' | \
  awk '{sum+=$1; n++} END {print "Cobertura inicio:", sum/n"x"}'

samtools depth 04_mapping/02_nanopore/${SAMPLE}_sorted.bam | \
  tail -1000 | awk '{print $3}' | \
  awk '{sum+=$1; n++} END {print "Cobertura final:", sum/n"x"}'

# 2. Si cobertura baja (<20x), necesitas más datos

# 3. Intentar forzar circularidad manualmente (avanzado)
# Usar herramientas como Circlator o inspeccionar grafo con Bandage
```

### Problema 3: Muchos Contigs Pequeños (Basura)

**Síntoma:**
```
# contigs: 45
Muchos contigs <10 kb
```

**Causas:**
- Contaminación
- Artefactos de secuenciación
- Phage, plásmidos pequeños

**Diagnóstico:**
```bash
# Listar contigs pequeños
awk '$2 < 10000' 03_assembly/02_nanopore_only/assembly_info.txt

# Verificar cobertura (contaminación suele tener baja cobertura)
awk '$2 < 10000 && $3 < 10' 03_assembly/02_nanopore_only/assembly_info.txt
```

**Solución:**
```bash
# Filtrar contigs pequeños y de baja cobertura
# Crear ensamblaje limpio
seqtk seq -L 1000 ${ASSEMBLY} > ${SAMPLE}_nanopore_filtered.fasta

# O usar solo elementos circulares (más confiable)
cat 03_assembly/02_nanopore_only/classified/*.fasta > \
  ${SAMPLE}_circular_only.fasta
```

### Problema 4: Medaka Muy Lento

**Síntoma:**
Medaka toma >8 horas.

**Solución:**
```bash
# Usar GPU si disponible
medaka_consensus ... --device cuda

# Reducir threads si causa problemas de memoria
medaka_consensus ... -t 4

# Alternativamente, omitir Medaka si la precisión es aceptable
# (revisar QUAST: si indels <300/100kb, puede ser suficiente)
```

### Problema 5: Alta Tasa de Errores Después de Polishing

**Síntoma:**
```
# indels per 100 kbp: 450 (esperado <250)
```

**Causas:**
- Modelo Medaka incorrecto
- Datos de mala calidad
- Necesita más rondas de polishing

**Solución:**
```bash
# 1. Verificar modelo Medaka correcto
medaka tools list_models

# 2. Ejecutar ronda adicional de Medaka
medaka_consensus \
  -i ${NANOPORE_FILT} \
  -d 03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta \
  -o 03_assembly/02_nanopore_only/medaka_polish_round2 \
  -t 8 -m r941_min_high_g360

# 3. Si tienes datos Illumina, usa pipeline híbrido para mejor precisión
```

---

## 🚀 Script Completo del Pipeline

```bash
cat > scripts/run_nanopore_pipeline.sh << 'EOF'
#!/bin/bash

# Script completo del Pipeline Nanopore
# Uso: bash scripts/run_nanopore_pipeline.sh SAMPLE_NAME

set -e  # Salir si hay error

SAMPLE=$1
THREADS=8
GENOME_SIZE="5.7m"
MEDAKA_MODEL="r941_min_high_g360"  # AJUSTAR SEGÚN TU FLOWCELL

if [ -z "$SAMPLE" ]; then
    echo "Uso: bash $0 SAMPLE_NAME"
    exit 1
fi

echo "========================================"
echo "Pipeline Nanopore Completo"
echo "Muestra: ${SAMPLE}"
echo "Inicio: $(date)"
echo "========================================"

# Activar ambiente
conda activate bact_main

# Variables
NANOPORE="00_raw_data/nanopore/${SAMPLE}_1.fastq.gz"
REFERENCE="01_reference/reference.fasta"

# Verificar archivo
if [ ! -f "$NANOPORE" ]; then
    echo "❌ Error: Archivo FASTQ no encontrado: $NANOPORE"
    exit 1
fi

###############################
# FASE 1: CONTROL DE CALIDAD
###############################
echo ""
echo "=== FASE 1: Control de Calidad ==="

# NanoPlot raw
mkdir -p 02_qc/03_nanopore_raw
NanoPlot --fastq ${NANOPORE} \
  -o 02_qc/03_nanopore_raw/ -t ${THREADS} \
  --plots kde dot --N50 \
  --title "${SAMPLE} - Raw Nanopore Data"

# Filtlong
mkdir -p 02_qc/04_nanopore_filtered
filtlong --min_length 1000 --keep_percent 90 --target_bases 500000000 \
  ${NANOPORE} | \
  pigz -p ${THREADS} > 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz

# NanoPlot filtered
NanoPlot --fastq 02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz \
  -o 02_qc/04_nanopore_filtered/ -t ${THREADS} \
  --plots kde dot --N50 \
  --title "${SAMPLE} - Filtered Nanopore Data"

echo "✓ Control de calidad completado"

###############################
# FASE 2: ENSAMBLAJE
###############################
echo ""
echo "=== FASE 2: Ensamblaje con Flye ==="

NANOPORE_FILT="02_qc/04_nanopore_filtered/${SAMPLE}_ont_filtered.fastq.gz"
mkdir -p 03_assembly/02_nanopore_only

flye --nano-raw ${NANOPORE_FILT} \
  --out-dir 03_assembly/02_nanopore_only/ \
  --genome-size ${GENOME_SIZE} \
  --threads ${THREADS} \
  --iterations 3 --meta

cp 03_assembly/02_nanopore_only/assembly.fasta \
   03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta

echo "✓ Ensamblaje completado"

###############################
# FASE 3: EVALUACIÓN
###############################
echo ""
echo "=== FASE 3: Evaluación con QUAST ==="

ASSEMBLY="03_assembly/02_nanopore_only/${SAMPLE}_nanopore_assembly.fasta"
mkdir -p 03_assembly/04_quast_evaluation

quast.py ${ASSEMBLY} -r ${REFERENCE} \
  -o 03_assembly/04_quast_evaluation/ \
  --threads ${THREADS} --labels "Nanopore_${SAMPLE}" \
  --glimmer --min-contig 200 -q

echo "✓ Evaluación completada"

###############################
# FASE 4: POLISHING
###############################
echo ""
echo "=== FASE 4: Polishing con Medaka ==="

mkdir -p 03_assembly/02_nanopore_only/medaka_polish

medaka_consensus \
  -i ${NANOPORE_FILT} -d ${ASSEMBLY} \
  -o 03_assembly/02_nanopore_only/medaka_polish \
  -t ${THREADS} -m ${MEDAKA_MODEL}

cp 03_assembly/02_nanopore_only/medaka_polish/consensus.fasta \
   03_assembly/02_nanopore_only/${SAMPLE}_nanopore_polished.fasta

echo "✓ Polishing completado"

###############################
# FASE 5: MAPEO
###############################
echo ""
echo "=== FASE 5: Mapeo con Minimap2 ==="

[ ! -f "${REFERENCE}.fai" ] && samtools faidx ${REFERENCE}

mkdir -p 04_mapping/02_nanopore

minimap2 -ax map-ont -t ${THREADS} ${REFERENCE} ${NANOPORE_FILT} | \
  samtools view -Sb - | \
  samtools sort -@ ${THREADS} -o 04_mapping/02_nanopore/${SAMPLE}_sorted.bam

samtools index 04_mapping/02_nanopore/${SAMPLE}_sorted.bam

# Estadísticas
samtools flagstat 04_mapping/02_nanopore/${SAMPLE}_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_flagstat.txt
samtools coverage 04_mapping/02_nanopore/${SAMPLE}_sorted.bam > \
  04_mapping/02_nanopore/${SAMPLE}_coverage.txt
samtools depth 04_mapping/02_nanopore/${SAMPLE}_sorted.bam | \
  awk '{sum+=$3; count++} END {print "Profundidad promedio:", sum/count"x"}' > \
  04_mapping/02_nanopore/${SAMPLE}_mean_depth.txt

echo "✓ Mapeo completado"

###############################
# FASE 6: COBERTURA
###############################
echo ""
echo "=== FASE 6: Análisis de Cobertura ==="

BAM="04_mapping/02_nanopore/${SAMPLE}_sorted.bam"
mkdir -p 04_mapping/04_coverage_analysis

samtools coverage ${BAM} > \
  04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_coverage_summary.txt

# Por secuencia
while read -r seqid rest; do
    [[ $seqid == \#* ]] && continue
    samtools view -b ${BAM} "$seqid" > \
      04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_${seqid}.bam
    samtools index 04_mapping/04_coverage_analysis/${SAMPLE}_nanopore_${seqid}.bam
done < 01_reference/reference_sequences.txt

echo "✓ Análisis de cobertura completado"

###############################
# FASE 7: ELEMENTOS CIRCULARES
###############################
echo ""
echo "=== FASE 7: Identificación de Elementos Circulares ==="

grep "circular=Y" 03_assembly/02_nanopore_only/assembly_info.txt > \
  03_assembly/02_nanopore_only/circular_elements.txt || true

mkdir -p 03_assembly/02_nanopore_only/circular_sequences
