#!/bin/bash

################################################################################
# Script de Configuración de Estructura del Proyecto
# Bacterial Genomics Pipeline
# 
# Descripción: Crea la estructura completa de directorios para el proyecto
#              de análisis genómico bacteriano
#
# Uso: bash setup_project_structure.sh [NOMBRE_PROYECTO] [MUESTRA_ID]
#
# Ejemplo: bash setup_project_structure.sh bacterial_genomics URO5550422
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

################################################################################
# CONFIGURACIÓN INICIAL
################################################################################

# Parámetros
PROJECT_NAME="${1:-bacterial_genomics}"
SAMPLE_ID="${2:-SAMPLE}"
ORGANISM="Klebsiella pneumoniae"
REFERENCE_STRAIN="HS11286"
REFERENCE_ACCESSION="GCF_000240185.1"

# Directorio base
BASE_DIR="$HOME/${PROJECT_NAME}"

echo ""
echo "========================================"
echo "  Configuración de Estructura del Proyecto"
echo "  Bacterial Genomics Pipeline"
echo "========================================"
echo ""
echo "Proyecto: ${PROJECT_NAME}"
echo "Muestra ejemplo: ${SAMPLE_ID}"
echo "Organismo: ${ORGANISM}"
echo "Referencia: ${REFERENCE_STRAIN} (${REFERENCE_ACCESSION})"
echo ""

# Confirmar con usuario
read -p "¿Deseas continuar con esta configuración? [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    print_warning "Configuración cancelada por el usuario"
    exit 0
fi

################################################################################
# PASO 1: CREAR DIRECTORIO BASE
################################################################################

print_info "[Paso 1/9] Creando directorio base del proyecto..."

if [ -d "$BASE_DIR" ]; then
    print_warning "El directorio $BASE_DIR ya existe"
    read -p "¿Deseas continuar y sobrescribir? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Abortado por el usuario"
        exit 1
    fi
else
    mkdir -p "$BASE_DIR"
    print_success "Directorio base creado: $BASE_DIR"
fi

cd "$BASE_DIR"

################################################################################
# PASO 2: CREAR ESTRUCTURA DE DIRECTORIOS
################################################################################

print_info "[Paso 2/9] Creando estructura de directorios..."

# Datos crudos
mkdir -p 00_raw_data/{illumina,nanopore}
print_success "Creado: 00_raw_data/"

# Referencia
mkdir -p 01_reference
print_success "Creado: 01_reference/"

# Control de calidad
mkdir -p 02_qc/{01_illumina_raw,02_illumina_trimmed,03_nanopore_raw,04_nanopore_filtered,05_multiqc}
print_success "Creado: 02_qc/"

# Ensamblaje
mkdir -p 03_assembly/{01_illumina_only,02_nanopore_only,03_hybrid,04_quast_evaluation}
print_success "Creado: 03_assembly/"

# Mapeo
mkdir -p 04_mapping/{01_illumina,02_nanopore,03_variants,04_coverage_analysis}
print_success "Creado: 04_mapping/"

# Anotación
mkdir -p 05_annotation/{01_prokka,02_bakta}
print_success "Creado: 05_annotation/"

# AMR screening
mkdir -p 06_amr_screening/{01_amrfinder,02_abricate,03_rgi}
print_success "Creado: 06_amr_screening/"

# Typing
mkdir -p 07_typing/{mlst,plasmids,virulence}
print_success "Creado: 07_typing/"

# Resultados
mkdir -p 08_results/{figures,tables,reports}
print_success "Creado: 08_results/"

# Bases de datos
mkdir -p databases/{amrfinder_db,card}
print_success "Creado: databases/"

# Ambientes conda
mkdir -p envs
print_success "Creado: envs/"

# Scripts
mkdir -p scripts/{illumina,nanopore,hybrid,common,utils}
print_success "Creado: scripts/"

# Test data
mkdir -p test_data
print_success "Creado: test_data/"

# Logs
mkdir -p logs
print_success "Creado: logs/"

################################################################################
# PASO 3: CREAR ARCHIVO DE METADATA
################################################################################

print_info "[Paso 3/9] Creando archivo de metadata..."

cat > 00_raw_data/sample_metadata.txt << EOF
# ========================================
# Metadata de la Muestra
# ========================================

# Información General
Sample_ID: ${SAMPLE_ID}
Organism: ${ORGANISM}
Source: Clinical isolate
Collection_Date: $(date +%Y-%m-%d)
Project: ${PROJECT_NAME}

# ========================================
# Datos de Secuenciación
# ========================================

# Illumina
Illumina_Platform: MiSeq/NextSeq/NovaSeq
Illumina_Chemistry: Paired-end
Illumina_Read_Length: 150-300 bp
Illumina_Expected_Coverage: 50-100x

# Nanopore
Nanopore_Platform: MinION/GridION/PromethION
Nanopore_Flowcell: R9.4.1/R10.4
Nanopore_Expected_Read_Length: 5-15 kb
Nanopore_Expected_Coverage: 50-100x

# ========================================
# Genoma de Referencia
# ========================================

Reference_Organism: ${ORGANISM} ${REFERENCE_STRAIN}
Reference_Accession: ${REFERENCE_ACCESSION}
Reference_Source: NCBI RefSeq
Genome_Size: ~5.7 Mb
Chromosomes: 1
Plasmids: 6

# ========================================
# Notas
# ========================================

Notes: Estructura creada automáticamente con setup_project_structure.sh
Created: $(date)
User: $(whoami)
Host: $(hostname)

EOF

print_success "Archivo de metadata creado"

################################################################################
# PASO 4: DESCARGAR GENOMA DE REFERENCIA
################################################################################

print_info "[Paso 4/9] Descargando genoma de referencia..."

cd 01_reference

REFERENCE_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/240/185/GCF_000240185.1_ASM24018v2/GCF_000240185.1_ASM24018v2_genomic.fna.gz"
REFERENCE_FILE="GCF_000240185.1_ASM24018v2_genomic.fna.gz"

if [ ! -f "$REFERENCE_FILE" ]; then
    print_info "Descargando desde NCBI..."
    wget -q --show-progress "$REFERENCE_URL" || {
        print_error "Error al descargar el genoma de referencia"
        print_warning "Puedes descargarlo manualmente desde: $REFERENCE_URL"
        cd "$BASE_DIR"
        exit 1
    }
    print_success "Genoma de referencia descargado"
else
    print_warning "Genoma de referencia ya existe, omitiendo descarga"
fi

# Descomprimir
if [ ! -f "GCF_000240185.1_ASM24018v2_genomic.fna" ]; then
    print_info "Descomprimiendo..."
    gunzip -k "$REFERENCE_FILE"
    print_success "Archivo descomprimido"
fi

# Crear enlace simbólico
ln -sf GCF_000240185.1_ASM24018v2_genomic.fna reference.fasta
print_success "Enlace simbólico creado: reference.fasta"

cd "$BASE_DIR"

################################################################################
# PASO 5: CREAR ÍNDICE DE SECUENCIAS DE REFERENCIA
################################################################################

print_info "[Paso 5/9] Creando índice de secuencias de referencia..."

cat > 01_reference/reference_sequences.txt << 'EOF'
# ========================================
# Secuencias del Genoma de Referencia
# Klebsiella pneumoniae HS11286
# Accession: GCF_000240185.1
# ========================================

# Formato: SeqID  Length  Type  Description

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
EOF

print_success "Índice de secuencias creado"

################################################################################
# PASO 6: CREAR README DEL PROYECTO
################################################################################

print_info "[Paso 6/9] Creando README del proyecto..."

cat > README_PROJECT.md << EOF
# ${PROJECT_NAME}

Proyecto de análisis genómico bacteriano usando el pipeline modular de Bacterial Genomics.

## 📋 Información del Proyecto

- **Muestra:** ${SAMPLE_ID}
- **Organismo:** ${ORGANISM}
- **Referencia:** ${REFERENCE_STRAIN} (${REFERENCE_ACCESSION})
- **Creado:** $(date)

## 📁 Estructura del Proyecto

\`\`\`
${PROJECT_NAME}/
├── 00_raw_data/          # Datos de secuenciación (FASTQ)
├── 01_reference/         # Genoma de referencia
├── 02_qc/                # Control de calidad
├── 03_assembly/          # Ensamblajes
├── 04_mapping/           # Mapeos y variantes
├── 05_annotation/        # Anotación funcional
├── 06_amr_screening/     # Genes AMR
├── 07_typing/            # Tipificación molecular
├── 08_results/           # Resultados finales
├── databases/            # Bases de datos locales
├── envs/                 # Ambientes conda
├── scripts/              # Scripts de análisis
└── logs/                 # Logs de ejecución
\`\`\`

## 🚀 Próximos Pasos

1. **Copiar datos de secuenciación:**
   \`\`\`bash
   # Illumina
   cp /ruta/a/datos/illumina/*fastq.gz 00_raw_data/illumina/
   
   # Nanopore
   cp /ruta/a/datos/nanopore/*fastq.gz 00_raw_data/nanopore/
   \`\`\`

2. **Elegir pipeline según tus datos:**
   - Solo Illumina → Ver \`docs/01_ILLUMINA_PIPELINE.md\`
   - Solo Nanopore → Ver \`docs/02_NANOPORE_PIPELINE.md\`
   - Ambos (Híbrido) → Ver \`docs/03_HYBRID_PIPELINE.md\`

3. **Ejecutar análisis:**
   \`\`\`bash
   # Ejemplo para pipeline híbrido
   bash scripts/run_hybrid_pipeline.sh ${SAMPLE_ID}
   \`\`\`

## 📚 Documentación

Ver la documentación completa del pipeline en:
- GitHub: https://github.com/tu-usuario/Bacterial_Genomics_Pipeline
- Documentación local: Si clonaste el repositorio, ver carpeta \`docs/\`

## 📞 Ayuda

Para problemas o preguntas:
- Revisar \`docs/05_TROUBLESHOOTING.md\`
- Abrir un issue en GitHub
- Contactar al administrador del proyecto

---

*Proyecto creado con Bacterial Genomics Pipeline*
EOF

print_success "README del proyecto creado"

################################################################################
# PASO 7: CREAR ARCHIVO .gitignore
################################################################################

print_info "[Paso 7/9] Creando archivo .gitignore..."

cat > .gitignore << 'EOF'
# Archivos de datos grandes (no subir a git)
00_raw_data/*.fastq
00_raw_data/*.fastq.gz
00_raw_data/*.fq
00_raw_data/*.fq.gz
01_reference/*.fna
01_reference/*.fna.gz
01_reference/*.fasta
01_reference/*.fa

# Resultados de análisis (muy grandes)
02_qc/
03_assembly/
04_mapping/
05_annotation/
06_amr_screening/
07_typing/
08_results/

# Bases de datos (descargar localmente)
databases/
*.db
*.sqlite
*.mmi
*.bwt
*.pac
*.ann
*.amb
*.sa

# Logs
logs/
*.log

# Archivos temporales
*.tmp
*.temp
.snakemake/

# Ambientes conda locales
.conda/
miniforge3/
*.yml.lock

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Archivos de respaldo
*.bak
*.backup
*~

# Archivos de sistema
Thumbs.db
.Spotlight-V100
.Trashes

# Excepciones (sí incluir estos)
!test_data/*.fastq.gz
!envs/*.yml
EOF

print_success "Archivo .gitignore creado"

################################################################################
# PASO 8: CREAR SCRIPTS AUXILIARES
################################################################################

print_info "[Paso 8/9] Creando scripts auxiliares..."

# Script para enlazar datos
cat > scripts/link_raw_data.sh << 'EOFSCRIPT'
#!/bin/bash

# Script para enlazar datos de secuenciación al proyecto
# Uso: bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore

ILLUMINA_DIR=$1
NANOPORE_DIR=$2

if [ -z "$ILLUMINA_DIR" ] || [ -z "$NANOPORE_DIR" ]; then
    echo "Uso: bash $0 /ruta/illumina /ruta/nanopore"
    exit 1
fi

echo "Enlazando datos Illumina..."
ln -sf ${ILLUMINA_DIR}/*.fastq.gz 00_raw_data/illumina/

echo "Enlazando datos Nanopore..."
ln -sf ${NANOPORE_DIR}/*.fastq.gz 00_raw_data/nanopore/

echo "✓ Datos enlazados"
ls -lh 00_raw_data/illumina/
ls -lh 00_raw_data/nanopore/
EOFSCRIPT

chmod +x scripts/link_raw_data.sh
print_success "Script link_raw_data.sh creado"

# Script para verificar estructura
cat > scripts/verify_structure.sh << 'EOFSCRIPT'
#!/bin/bash

# Verificar que la estructura del proyecto esté completa

echo "Verificando estructura del proyecto..."
echo ""

REQUIRED_DIRS=(
    "00_raw_data/illumina"
    "00_raw_data/nanopore"
    "01_reference"
    "02_qc"
    "03_assembly"
    "04_mapping"
    "05_annotation"
    "06_amr_screening"
    "07_typing"
    "08_results"
    "databases"
    "envs"
    "scripts"
    "logs"
)

missing=0

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ $dir"
    else
        echo "✗ $dir (FALTA)"
        ((missing++))
    fi
done

echo ""
if [ $missing -eq 0 ]; then
    echo "✓ Estructura completa"
    exit 0
else
    echo "✗ Faltan $missing directorios"
    exit 1
fi
EOFSCRIPT

chmod +x scripts/verify_structure.sh
print_success "Script verify_structure.sh creado"

################################################################################
# PASO 9: CREAR ARCHIVO DE CONFIGURACIÓN DEL PROYECTO
################################################################################

print_info "[Paso 9/9] Creando archivo de configuración..."

cat > PROJECT_CONFIG.sh << EOF
#!/bin/bash

# ========================================
# Configuración del Proyecto
# ========================================

# Información del proyecto
export PROJECT_NAME="${PROJECT_NAME}"
export SAMPLE_ID="${SAMPLE_ID}"
export ORGANISM="${ORGANISM}"
export REFERENCE_STRAIN="${REFERENCE_STRAIN}"
export REFERENCE_ACCESSION="${REFERENCE_ACCESSION}"

# Directorios
export BASE_DIR="${BASE_DIR}"
export RAW_DATA_DIR="\${BASE_DIR}/00_raw_data"
export REFERENCE_DIR="\${BASE_DIR}/01_reference"
export QC_DIR="\${BASE_DIR}/02_qc"
export ASSEMBLY_DIR="\${BASE_DIR}/03_assembly"
export MAPPING_DIR="\${BASE_DIR}/04_mapping"
export ANNOTATION_DIR="\${BASE_DIR}/05_annotation"
export AMR_DIR="\${BASE_DIR}/06_amr_screening"
export TYPING_DIR="\${BASE_DIR}/07_typing"
export RESULTS_DIR="\${BASE_DIR}/08_results"
export DB_DIR="\${BASE_DIR}/databases"
export SCRIPTS_DIR="\${BASE_DIR}/scripts"
export LOGS_DIR="\${BASE_DIR}/logs"

# Archivos de referencia
export REFERENCE_FASTA="\${REFERENCE_DIR}/reference.fasta"
export REFERENCE_SEQS="\${REFERENCE_DIR}/reference_sequences.txt"

# Parámetros por defecto
export THREADS=8
export MEMORY=16
export GENOME_SIZE="5.7m"

# Ambientes conda
export ENV_MAIN="bact_main"
export ENV_AMR="bact_amr"
export ENV_RGI="bact_rgi"

# Base de datos
export AMRFINDER_DB="\${DB_DIR}/amrfinder_db"
export CARD_DB="\${DB_DIR}/card"

echo "Configuración del proyecto cargada"
echo "Proyecto: \${PROJECT_NAME}"
echo "Muestra: \${SAMPLE_ID}"
echo "Base dir: \${BASE_DIR}"
EOF

chmod +x PROJECT_CONFIG.sh
print_success "Archivo de configuración creado"

################################################################################
# FINALIZACIÓN
################################################################################

echo ""
echo "========================================"
echo "  ✓ Configuración Completada"
echo "========================================"
echo ""
print_success "Estructura del proyecto creada exitosamente"
echo ""
echo "Ubicación: ${BASE_DIR}"
echo ""
echo "Resumen de lo creado:"
echo "  • 14 directorios principales"
echo "  • 40+ subdirectorios"
echo "  • Genoma de referencia K. pneumoniae"
echo "  • Archivos de metadata y configuración"
echo "  • Scripts auxiliares"
echo ""
echo "Próximos pasos:"
echo ""
echo "1. Ir al directorio del proyecto:"
echo "   cd ${BASE_DIR}"
echo ""
echo "2. Verificar estructura:"
echo "   bash scripts/verify_structure.sh"
echo ""
echo "3. Copiar o enlazar datos de secuenciación:"
echo "   bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore"
echo ""
echo "4. Instalar ambientes conda (si no lo has hecho):"
echo "   # Ver: docs/00_INSTALLATION.md"
echo ""
echo "5. Ejecutar pipeline según tus datos:"
echo "   # Solo Illumina: docs/01_ILLUMINA_PIPELINE.md"
echo "   # Solo Nanopore: docs/02_NANOPORE_PIPELINE.md"
echo "   # Híbrido: docs/03_HYBRID_PIPELINE.md"
echo ""
echo "========================================"
echo ""

# Mostrar estructura creada
print_info "Estructura de directorios:"
echo ""
tree -L 2 -d "$BASE_DIR" 2>/dev/null || find "$BASE_DIR" -maxdepth 2 -type d | sed 's|[^/]*/| |g'

echo ""
print_success "¡Proyecto listo para usar!"
echo ""
