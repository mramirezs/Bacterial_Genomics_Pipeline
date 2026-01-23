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
|---------|-------|
