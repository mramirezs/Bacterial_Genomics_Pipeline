# 🛠️ Guía de Instalación y Configuración
### Bacterial Genomics Pipeline - Versión 4.0

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#-requisitos-previos)
2. [Instalación de Miniforge/Mamba](#-instalación-de-miniforgemamba)
3. [Configuración de Canales Bioconda](#-configuración-de-canales-bioconda)
4. [Creación de Ambientes Conda](#-creación-de-ambientes-conda)
5. [Descarga de Bases de Datos](#-descarga-de-bases-de-datos)
6. [Verificación de Instalación](#-verificación-de-instalación)
7. [Configuración del Proyecto](#-configuración-del-proyecto)
8. [Exportar e Importar Ambientes](#-exportar-e-importar-ambientes)
9. [Actualización del Sistema](#-actualización-del-sistema)
10. [Solución de Problemas](#-solución-de-problemas)
11. [Comandos de Referencia](#-comandos-de-referencia)

---

## ⚙️ Requisitos Previos

### Sistema Operativo

✅ **Sistemas Soportados:**
- Ubuntu 20.04 LTS o superior
- Debian 10+
- CentOS 7+
- Rocky Linux 8+
- Cualquier distribución Linux moderna

❌ **No Soportado:**
- Windows (usar WSL2)
- macOS (algunas herramientas bioinformáticas no disponibles)

### Hardware Recomendado

| Componente | Mínimo | Recomendado | Óptimo |
|------------|--------|-------------|--------|
| **CPU** | 4 cores | 8 cores | 16+ cores |
| **RAM** | 16 GB | 32 GB | 64+ GB |
| **Almacenamiento** | 100 GB libres | 200 GB libres | SSD 500 GB |
| **Red** | 10 Mbps | 100 Mbps | 1 Gbps |

### Software Base Requerido

```bash
# Verificar bash
bash --version
# Requerido: bash 4.0+

# Verificar git
git --version
# Requerido: git 2.0+

# Verificar wget o curl
wget --version
curl --version
# Al menos uno de los dos

# Verificar permisos de escritura
cd ~
mkdir -p test_dir && rm -rf test_dir && echo "✓ Permisos OK"
```

---

## 📥 Instalación de Miniforge/Mamba

### ¿Por qué Miniforge y no Anaconda?

- ✅ **Más rápido:** Mamba resuelve dependencias 10-20x más rápido
- ✅ **Gratis y libre:** No requiere licencia comercial
- ✅ **Bioconda por defecto:** Canal principal para bioinformática
- ✅ **Menor tamaño:** Solo paquetes esenciales

### Paso 1: Descargar Miniforge

```bash
# Ir al directorio home
cd ~

# Descargar instalador para Linux x86_64
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

# Verificar descarga
ls -lh Miniforge3-Linux-x86_64.sh
# Debe mostrar archivo de ~70-80 MB
```

### Paso 2: Instalar Miniforge

```bash
# Dar permisos de ejecución
chmod +x Miniforge3-Linux-x86_64.sh

# Instalar en modo batch (sin preguntas interactivas)
bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3

# Nota: 
# -b = batch mode (sin confirmaciones)
# -p = path de instalación
```

### Paso 3: Inicializar Conda

```bash
# Inicializar conda para bash
$HOME/miniforge3/bin/conda init bash

# Recargar configuración de bash
source ~/.bashrc

# Verificar instalación
conda --version
mamba --version

# Salida esperada:
# conda 24.x.x
# mamba 1.x.x
```

### Paso 4: Configuración Inicial de Conda

```bash
# Desactivar activación automática del ambiente base
conda config --set auto_activate_base false

# Configurar mamba como solver por defecto
conda config --set solver libmamba

# Verificar configuración
conda config --show-sources
```

**🎯 Verificación:**
```bash
# Después de reiniciar terminal, NO debería aparecer (base)
# antes del prompt

# Si aparece (base), ejecutar:
conda deactivate
```

---

## 🔧 Configuración de Canales Bioconda

### ¿Qué son los Canales?

Los canales son repositorios de paquetes. Para bioinformática necesitamos:
- **conda-forge:** Paquetes científicos generales
- **bioconda:** Herramientas bioinformáticas
- **defaults:** Paquetes base de conda

### Configurar Prioridad de Canales

```bash
# Agregar canales en orden de prioridad
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# Establecer prioridad estricta (IMPORTANTE)
conda config --set channel_priority strict

# Verificar configuración
conda config --show channels
```

**Salida esperada:**
```yaml
channels:
  - conda-forge
  - bioconda
  - defaults
```

---

## 🐍 Creación de Ambientes Conda

### ¿Por qué 3 Ambientes Separados?

Algunas herramientas bioinformáticas tienen **conflictos de dependencias** entre sí:
- **Prokka** requiere versiones específicas de Perl
- **RGI** necesita Python 3.11
- **SPAdes/Unicycler** funcionan mejor con Python 3.10

Por eso creamos 3 ambientes especializados:

| Ambiente | Propósito | Herramientas Principales |
|----------|-----------|-------------------------|
| `bact_main` | Pipeline principal | FastQC, SPAdes, BWA, Flye, Unicycler, AMRFinder |
| `bact_amr` | Anotación y AMR | Prokka, Abricate |
| `bact_rgi` | AMR avanzado | RGI (CARD database) |

---

### 🧬 Ambiente 1: `bact_main` (Principal)

Este ambiente contiene todas las herramientas para QC, ensamblaje, mapeo y detección básica de AMR.

#### Crear Ambiente Base

```bash
# Crear ambiente con Python 3.10
mamba create -n bact_main -c conda-forge -c bioconda \
  python=3.10 pip pigz openjdk=11 -y

# Tiempo estimado: 2-3 minutos
# Tamaño: ~500 MB
```

#### Activar Ambiente

```bash
conda activate bact_main

# El prompt debe cambiar a:
# (bact_main) usuario@host:~$
```

#### Instalar Herramientas de Control de Calidad

```bash
# FastQC, MultiQC, fastp (Illumina)
mamba install -c bioconda fastqc multiqc fastp -y

# NanoPlot, Filtlong (Nanopore)
mamba install -c bioconda nanoplot filtlong -y

# Tiempo estimado: 3-5 minutos
```

**Verificar instalación:**
```bash
fastqc --version    # v0.12.1
multiqc --version   # v1.14
fastp --version     # 0.23.4
NanoPlot --version  # 1.41.0
filtlong --version  # v0.2.1
```

#### Instalar Herramientas de Mapeo y Análisis de Variantes

```bash
# BWA (Illumina), Minimap2 (Nanopore)
mamba install -c bioconda bwa minimap2 -y

# Samtools, BCFtools, BEDtools
mamba install -c bioconda samtools bcftools bedtools -y

# BLAST (para búsquedas de homología)
mamba install -c bioconda blast -y

# Tiempo estimado: 3-5 minutos
```

**Verificar instalación:**
```bash
bwa 2>&1 | head -3           # BWA para mapeo Illumina
minimap2 --version           # 2.24-r1122
samtools --version           # 1.17
bcftools --version           # 1.17
```

#### Instalar Ensambladores

```bash
# SPAdes (Illumina)
mamba install -c bioconda spades -y

# Flye (Nanopore)
mamba install -c bioconda flye -y

# Unicycler (Híbrido)
mamba install -c bioconda unicycler -y

# QUAST (Evaluación de calidad)
mamba install -c bioconda quast -y

# Bandage (Visualización de gráficos)
mamba install -c bioconda bandage -y

# Tiempo estimado: 5-8 minutos
```

**Verificar instalación:**
```bash
spades.py --version        # 3.15.5
flye --version             # 2.9.1
unicycler --version        # 0.5.0
quast.py --version         # 5.2.0
Bandage --version          # 0.8.1
```

#### Instalar Herramientas AMR y Typing

```bash
# AMRFinderPlus (NCBI)
mamba install -c bioconda ncbi-amrfinderplus -y

# Barrnap (rRNA prediction)
mamba install -c bioconda barrnap -y

# MLST (Multi-Locus Sequence Typing)
mamba install -c bioconda mlst -y

# Tiempo estimado: 2-3 minutos
```

**Verificar instalación:**
```bash
amrfinder --version        # 3.11.4
barrnap --version          # 0.9
mlst --version             # 2.23.0
```

#### Instalar Herramientas Adicionales

```bash
# seqtk (manipulación de secuencias)
mamba install -c bioconda seqtk -y

# Kraken2 (clasificación taxonómica - opcional)
mamba install -c bioconda kraken2 -y

# Tiempo estimado: 2-3 minutos
```

**✅ Ambiente `bact_main` completo**

```bash
echo "=== VERIFICACIÓN BACT_MAIN ==="
which fastqc
which spades.py
which bwa
which amrfinder
echo "✓ Ambiente bact_main instalado correctamente"

# Desactivar ambiente
conda deactivate
```

---

### 🦠 Ambiente 2: `bact_amr` (Anotación y AMR)

Este ambiente está dedicado a **Prokka** y **Abricate**, que requieren versiones específicas de Perl.

#### Crear Ambiente

```bash
# Crear ambiente con Python 3.9 y herramientas Perl
mamba create -n bact_amr -c conda-forge -c bioconda \
  python=3.9 prokka abricate -y

# Tiempo estimado: 5-7 minutos
# Tamaño: ~800 MB (incluye dependencias Perl)
```

#### Activar y Configurar

```bash
# Activar ambiente
conda activate bact_amr

# Configurar bases de datos de Abricate
abricate --setupdb

# Tiempo estimado: 3-5 minutos
# Descarga: ~150 MB
```

#### Verificar Bases de Datos Disponibles

```bash
# Listar bases de datos
abricate --list

# Salida esperada:
# DATABASE       SEQUENCES  DBTYPE  DATE
# argannot       2223       nucl    2023-Apr-17
# card           3094       nucl    2023-Aug-22
# ecoh           597        nucl    2023-Apr-17
# ecoli_vf       2701       nucl    2023-Apr-17
# megares        7635       nucl    2023-Apr-17
# ncbi           5386       nucl    2023-Jul-13
# plasmidfinder  460        nucl    2023-Apr-17
# resfinder      3077       nucl    2023-Apr-17
# vfdb           2597       nucl    2023-Apr-17
```

#### Verificar Prokka

```bash
# Verificar instalación
prokka --version

# Salida esperada:
# prokka 1.14.6

# Ver opciones disponibles
prokka --listdb
```

**✅ Ambiente `bact_amr` completo**

```bash
echo "=== VERIFICACIÓN BACT_AMR ==="
prokka --version
abricate --version
abricate --list | wc -l  # Debe mostrar ~9 bases de datos
echo "✓ Ambiente bact_amr instalado correctamente"

# Desactivar ambiente
conda deactivate
```

---

### 🧪 Ambiente 3: `bact_rgi` (AMR Avanzado)

Este ambiente está dedicado a **RGI** (Resistance Gene Identifier) con la base de datos **CARD**.

#### Crear Ambiente

```bash
# Crear ambiente con Python 3.11 (requerido por RGI)
mamba create -n bact_rgi -c conda-forge -c bioconda \
  python=3.11 rgi -y

# Tiempo estimado: 3-4 minutos
# Tamaño: ~400 MB
```

#### Activar Ambiente

```bash
conda activate bact_rgi

# Verificar instalación
rgi main --version

# Salida esperada:
# 6.0.2
```

**✅ Ambiente `bact_rgi` completo**

```bash
echo "=== VERIFICACIÓN BACT_RGI ==="
rgi main --version
echo "✓ Ambiente bact_rgi instalado correctamente"

# Desactivar ambiente
conda deactivate
```

---

## 📊 Descarga de Bases de Datos

### Base de Datos AMRFinderPlus

```bash
# Crear directorio
mkdir -p ~/bacterial_genomics/databases/amrfinder_db

# Activar ambiente
conda activate bact_main

# Descargar base de datos
amrfinder_update --database ~/bacterial_genomics/databases/amrfinder_db

# Tiempo estimado: 5-10 minutos
# Tamaño: ~700 MB

# Verificar
amrfinder --database ~/bacterial_genomics/databases/amrfinder_db --version

# Desactivar
conda deactivate
```

### Base de Datos MLST

```bash
conda activate bact_main

# Actualizar esquemas MLST
mlst --list

# Esto descarga esquemas para ~150 especies
# Tiempo estimado: 2-3 minutos

# Verificar que Klebsiella pneumoniae está disponible
mlst --list | grep pneumoniae

conda deactivate
```

### Base de Datos CARD (para RGI)

```bash
# Crear directorio
mkdir -p ~/bacterial_genomics/databases/card

# Activar ambiente
conda activate bact_rgi

# Ir al directorio
cd ~/bacterial_genomics/databases/card

# Descargar base de datos CARD
wget https://card.mcmaster.ca/latest/data

# Descomprimir
tar -xvf data

# Cargar base de datos en RGI (modo local)
rgi load --card_json card.json --local

# Tiempo estimado: 2-3 minutos
# Tamaño: ~50 MB

# Verificar
rgi database --version --local

# Volver al directorio inicial
cd ~

# Desactivar
conda deactivate
```

---

## ✅ Verificación de Instalación

### Script de Verificación Automatizada

```bash
# Crear directorio de scripts
mkdir -p ~/bacterial_genomics/scripts

# Crear script de verificación
cat > ~/bacterial_genomics/scripts/verify_installation.sh << 'EOF'
#!/bin/bash

echo "========================================"
echo "Verificación de Instalación"
echo "Bacterial Genomics Pipeline"
echo "========================================"
echo ""

# Función para verificar comando
check_tool() {
    local env=$1
    local tool=$2
    local cmd=$3
    
    conda activate $env 2>/dev/null
    if command -v $tool &> /dev/null; then
        version=$($cmd 2>&1 | head -1)
        echo "  ✓ $tool: OK"
        status=0
    else
        echo "  ❌ $tool: NO ENCONTRADO"
        status=1
    fi
    conda deactivate 2>/dev/null
    return $status
}

errors=0

# Verificar ambiente bact_main
echo "[Ambiente: bact_main]"
check_tool bact_main fastqc "fastqc --version" || ((errors++))
check_tool bact_main fastp "fastp --version" || ((errors++))
check_tool bact_main bwa "bwa 2>&1 | head -1" || ((errors++))
check_tool bact_main samtools "samtools --version" || ((errors++))
check_tool bact_main spades.py "spades.py --version" || ((errors++))
check_tool bact_main flye "flye --version" || ((errors++))
check_tool bact_main unicycler "unicycler --version" || ((errors++))
check_tool bact_main quast.py "quast.py --version" || ((errors++))
check_tool bact_main amrfinder "amrfinder --version" || ((errors++))
check_tool bact_main mlst "mlst --version" || ((errors++))
echo ""

# Verificar ambiente bact_amr
echo "[Ambiente: bact_amr]"
check_tool bact_amr prokka "prokka --version" || ((errors++))
check_tool bact_amr abricate "abricate --version" || ((errors++))
echo ""

# Verificar ambiente bact_rgi
echo "[Ambiente: bact_rgi]"
check_tool bact_rgi rgi "rgi main --version" || ((errors++))
echo ""

# Verificar bases de datos
echo "[Bases de Datos]"
if [ -d ~/bacterial_genomics/databases/amrfinder_db ]; then
    echo "  ✓ AMRFinderPlus DB: Instalada"
else
    echo "  ❌ AMRFinderPlus DB: NO ENCONTRADA"
    ((errors++))
fi

conda activate bact_amr 2>/dev/null
db_count=$(abricate --list 2>/dev/null | wc -l)
if [ $db_count -gt 5 ]; then
    echo "  ✓ Abricate DBs: $db_count bases disponibles"
else
    echo "  ❌ Abricate DBs: Incompletas"
    ((errors++))
fi
conda deactivate 2>/dev/null

if [ -f ~/bacterial_genomics/databases/card/card.json ]; then
    echo "  ✓ CARD DB: Instalada"
else
    echo "  ❌ CARD DB: NO ENCONTRADA"
    ((errors++))
fi
echo ""

# Resumen final
echo "========================================"
if [ $errors -eq 0 ]; then
    echo "✓ TODAS LAS VERIFICACIONES PASARON"
    echo "El sistema está listo para usar"
else
    echo "❌ SE ENCONTRARON $errors ERRORES"
    echo "Revisa los mensajes arriba"
fi
echo "========================================"
echo ""

exit $errors
EOF

# Dar permisos de ejecución
chmod +x ~/bacterial_genomics/scripts/verify_installation.sh

# Ejecutar verificación
bash ~/bacterial_genomics/scripts/verify_installation.sh
```

**Salida esperada si todo está bien:**
```
========================================
Verificación de Instalación
Bacterial Genomics Pipeline
========================================

[Ambiente: bact_main]
  ✓ fastqc: OK
  ✓ fastp: OK
  ✓ bwa: OK
  ✓ samtools: OK
  ✓ spades.py: OK
  ✓ flye: OK
  ✓ unicycler: OK
  ✓ quast.py: OK
  ✓ amrfinder: OK
  ✓ mlst: OK

[Ambiente: bact_amr]
  ✓ prokka: OK
  ✓ abricate: OK

[Ambiente: bact_rgi]
  ✓ rgi: OK

[Bases de Datos]
  ✓ AMRFinderPlus DB: Instalada
  ✓ Abricate DBs: 9 bases disponibles
  ✓ CARD DB: Instalada

========================================
✓ TODAS LAS VERIFICACIONES PASARON
El sistema está listo para usar
========================================
```

---

## 📁 Configuración del Proyecto

### Crear Estructura de Directorios

```bash
# Crear estructura completa
mkdir -p ~/bacterial_genomics/{00_raw_data/{illumina,nanopore},01_reference,02_qc/{01_illumina_raw,02_illumina_trimmed,03_nanopore_raw,04_nanopore_filtered,05_multiqc},03_assembly/{01_illumina_only,02_nanopore_only,03_hybrid,04_quast_evaluation},04_mapping/{01_illumina,02_nanopore,03_variants,04_coverage_analysis},05_annotation/{01_prokka,02_bakta},06_amr_screening/{01_amrfinder,02_abricate,03_rgi},07_typing/{mlst,plasmids,virulence},08_results/{figures,tables,reports},logs}

echo "✓ Estructura de directorios creada"
```

### Descargar Genoma de Referencia

```bash
# Ir al directorio de referencia
cd ~/bacterial_genomics/01_reference

# Descargar genoma de referencia K. pneumoniae
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/240/185/GCF_000240185.1_ASM24018v2/GCF_000240185.1_ASM24018v2_genomic.fna.gz

# Descomprimir
gunzip GCF_000240185.1_ASM24018v2_genomic.fna.gz

# Crear enlace simbólico
ln -s GCF_000240185.1_ASM24018v2_genomic.fna reference.fasta

# Crear índice de secuencias
grep ">" reference.fasta | sed 's/>//' | awk '{print $1}' > reference_sequences.txt

# Volver al directorio principal
cd ~/bacterial_genomics

echo "✓ Genoma de referencia descargado"
```

### Crear Archivo de Metadata

```bash
cat > ~/bacterial_genomics/00_raw_data/sample_metadata.txt << 'EOF'
# Metadata de la Muestra
Sample_ID: URO5550422
Organism: Klebsiella pneumoniae
Source: Clinical isolate (urinary)
Sequencing_Date: 2024-01-01
Reference: K. pneumoniae HS11286 (GCF_000240185.1)

# Datos de Secuenciación
Illumina_Platform: MiSeq/NextSeq
Illumina_Chemistry: Paired-end
Nanopore_Platform: MinION/GridION
EOF

echo "✓ Metadata creada"
```

---

## 💾 Exportar e Importar Ambientes

### Exportar los 3 Ambientes

```bash
# Crear directorio para archivos YAML
mkdir -p ~/bacterial_genomics/envs

# Exportar bact_main
conda activate bact_main
conda env export --no-builds > ~/bacterial_genomics/envs/bact_main.yml
conda deactivate

# Exportar bact_amr
conda activate bact_amr
conda env export --no-builds > ~/bacterial_genomics/envs/bact_amr.yml
conda deactivate

# Exportar bact_rgi
conda activate bact_rgi
conda env export --no-builds > ~/bacterial_genomics/envs/bact_rgi.yml
conda deactivate

echo "✓ Ambientes exportados en: ~/bacterial_genomics/envs/"
ls -lh ~/bacterial_genomics/envs/
```

### Recrear Ambientes desde YAML (En otro servidor)

#### Opción 1: Copiar Archivos YAML por SCP

```bash
# En el servidor original, copiar archivos al servidor nuevo
scp ~/bacterial_genomics/envs/*.yml usuario@servidor_nuevo:~/

# En el servidor nuevo, recrear ambientes
cd ~
mamba env create -f bact_main.yml
mamba env create -f bact_amr.yml
mamba env create -f bact_rgi.yml

# Tiempo estimado: 30-45 minutos
```

#### Opción 2: Descargar desde GitHub

```bash
# En el servidor nuevo, descargar desde tu repositorio
cd ~
mkdir -p bacterial_genomics/envs

# Descargar archivos YAML
wget https://raw.githubusercontent.com/TU-USUARIO/Bacterial_Genomics_Pipeline/main/envs/bact_main.yml
wget https://raw.githubusercontent.com/TU-USUARIO/Bacterial_Genomics_Pipeline/main/envs/bact_amr.yml
wget https://raw.githubusercontent.com/TU-USUARIO/Bacterial_Genomics_Pipeline/main/envs/bact_rgi.yml

# Recrear ambientes
mamba env create -f bact_main.yml
mamba env create -f bact_amr.yml
mamba env create -f bact_rgi.yml
```

### Configurar Bases de Datos en el Servidor Nuevo

```bash
# Crear script para configurar bases de datos
cat > ~/bacterial_genomics/scripts/setup_databases.sh << 'EOF'
#!/bin/bash

echo "========================================"
echo "Configuración de Bases de Datos"
echo "========================================"

# Crear directorio de bases de datos
mkdir -p ~/bacterial_genomics/databases/{amrfinder_db,card}

# AMRFinderPlus
echo "[1/3] Descargando base de datos AMRFinderPlus..."
conda activate bact_main
amrfinder_update --database ~/bacterial_genomics/databases/amrfinder_db
conda deactivate

# Abricate
echo "[2/3] Configurando bases de datos Abricate..."
conda activate bact_amr
abricate --setupdb
conda deactivate

# CARD
echo "[3/3] Descargando base de datos CARD..."
conda activate bact_rgi
cd ~/bacterial_genomics/databases/card
wget https://card.mcmaster.ca/latest/data
tar -xf data
rgi load --card_json card.json --local
cd ~
conda deactivate

echo ""
echo "✓ Bases de datos configuradas"
EOF

chmod +x ~/bacterial_genomics/scripts/setup_databases.sh

# Ejecutar configuración
bash ~/bacterial_genomics/scripts/setup_databases.sh
```

### Verificar Reproducibilidad

```bash
# Verificar que los ambientes sean idénticos
conda activate bact_main
conda list > ~/ambiente_nuevo_main.txt
conda deactivate

# Comparar con lista original (si la tienes)
diff ambiente_original_main.txt ambiente_nuevo_main.txt

# Si hay diferencias menores en versiones build, es normal
# Lo importante es que las versiones principales coincidan
```

---

## 🔄 Actualización del Sistema

### Actualizar Todas las Herramientas

```bash
# Actualizar ambiente bact_main
conda activate bact_main
mamba update --all -y
conda deactivate

# Actualizar ambiente bact_amr
conda activate bact_amr
mamba update --all -y
conda deactivate

# Actualizar ambiente bact_rgi
conda activate bact_rgi
mamba update --all -y
conda deactivate

echo "✓ Todos los ambientes actualizados"
```

### Actualizar Bases de Datos

```bash
# Actualizar AMRFinderPlus
conda activate bact_main
amrfinder_update --database ~/bacterial_genomics/databases/amrfinder_db --force_update
conda deactivate

# Actualizar Abricate
conda activate bact_amr
abricate --setupdb
conda deactivate

# Actualizar CARD
conda activate bact_rgi
cd ~/bacterial_genomics/databases/card
wget -O data_new https://card.mcmaster.ca/latest/data
tar -xf data_new
rgi load --card_json card.json --local
conda deactivate

echo "✓ Bases de datos actualizadas"
```

### Script de Actualización Automática

```bash
cat > ~/bacterial_genomics/scripts/update_all.sh << 'EOF'
#!/bin/bash

echo "========================================"
echo "Actualización del Sistema"
echo "Bacterial Genomics Pipeline"
echo "========================================"
echo ""

# Actualizar ambientes
echo "[1/3] Actualizando ambientes conda..."
for env in bact_main bact_amr bact_rgi; do
    echo "  Actualizando $env..."
    conda activate $env
    mamba update --all -y -q
    conda deactivate
done

# Actualizar bases de datos
echo "[2/3] Actualizando bases de datos..."
conda activate bact_main
amrfinder_update --database ~/bacterial_genomics/databases/amrfinder_db -q
conda deactivate

conda activate bact_amr
abricate --setupdb > /dev/null 2>&1
conda deactivate

# Verificar
echo "[3/3] Verificando instalación..."
bash ~/bacterial_genomics/scripts/verify_installation.sh

echo ""
echo "✓ Actualización completada"
EOF

chmod +x ~/bacterial_genomics/scripts/update_all.sh
```

---

## 🛠️ Solución de Problemas Comunes

### Problema 1: Conflictos de Canales

**Síntoma:**
```
PackagesNotFoundError: The following packages are not available from current channels
```

**Solución:**
```bash
# Verificar canales
conda config --show channels

# Reconfigurar canales en orden correcto
conda config --remove-key channels
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# Actualizar índice
conda update --all
```

### Problema 2: Mamba Lento o Colgado

**Síntoma:**
Mamba se queda "pensando" en "Solving environment" por más de 10 minutos.

**Solución:**
```bash
# Limpiar caché
mamba clean --all -y

# Actualizar mamba
conda update -n base mamba -y

# Intentar crear ambiente de nuevo
mamba create -n bact_main python=3.10 -y --force
```

### Problema 3: Error de Espacio en Disco

**Síntoma:**
```
OSError: [Errno 28] No space left on device
```

**Solución:**
```bash
# Verificar espacio
df -h

# Limpiar paquetes descargados
conda clean --all -y

# Mover directorio de conda a partición con más espacio
mv ~/miniforge3 /ruta/con/mas/espacio/miniforge3
ln -s /ruta/con/mas/espacio/miniforge3 ~/miniforge3
```

### Problema 4: Perl Dependencies (Prokka)

**Síntoma:**
```
Can't locate Bio/Perl/...
```

**Solución:**
```bash
# Reinstalar ambiente bact_amr
conda deactivate
conda env remove -n bact_amr
mamba create -n bact_amr -c conda-forge -c bioconda prokka abricate -y

# Verificar
conda activate bact_amr
prokka --version
```

### Problema 5: Bases de Datos no se Descargan

**Síntoma:**
AMRFinder o CARD no se descargan correctamente.

**Solución:**
```bash
# AMRFinder - descarga manual
conda activate bact_main
mkdir -p ~/bacterial_genomics/databases/amrfinder_db
amrfinder_update \
  --database ~/bacterial_genomics/databases/amrfinder_db \
  --force_update

# CARD - descarga manual con curl
conda activate bact_rgi
cd ~/bacterial_genomics/databases/card
curl -O https://card.mcmaster.ca/latest/data
tar -xf data
rgi load --card_json card.json --local
```

### Problema 6: Permisos Denegados

**Síntoma:**
```
Permission denied
```

**Solución:**
```bash
# Dar permisos a scripts
chmod +x ~/bacterial_genomics/scripts/*.sh

# Dar permisos a directorios
chmod -R u+w ~/bacterial_genomics/

# Verificar propiedad
ls -la ~/bacterial_genomics/
```

---

## 📚 Comandos de Referencia Rápida

### Gestión de Ambientes

```bash
# Listar todos los ambientes
conda env list

# Activar ambiente
conda activate bact_main

# Desactivar ambiente actual
conda deactivate

# Ver paquetes instalados en ambiente actual
conda list

# Buscar versiones de un paquete
mamba search spades

# Instalar paquete adicional
mamba install -c bioconda nombre_paquete

# Actualizar paquete específico
mamba update nombre_paquete

# Eliminar paquete
mamba remove nombre_paquete
```

### Exportar e Importar Ambientes

```bash
# Exportar ambiente actual
conda env export > mi_ambiente.yml

# Exportar sin builds (recomendado para portabilidad)
conda env export --no-builds > mi_ambiente.yml

# Crear ambiente desde archivo YAML
mamba env create -f mi_ambiente.yml

# Actualizar ambiente existente desde YAML
mamba env update -f mi_ambiente.yml --prune
```

### Limpieza y Mantenimiento

```bash
# Limpiar paquetes descargados
conda clean --packages -y

# Limpiar caché
conda clean --all -y

# Ver espacio usado por conda
du -sh ~/miniforge3/

# Ver espacio usado por bases de datos
du -sh ~/bacterial_genomics/databases/
```

---

## 🎯 Mejores Prácticas

### 1. Usar Ambientes Virtuales

✅ **CORRECTO:**
```bash
conda activate bact_main
spades.py --version
```

❌ **INCORRECTO:**
```bash
# Nunca instalar en ambiente base
conda install -n base spades
```

### 2. Documentar Versiones

```bash
# Siempre exportar ambientes después de cambios
conda activate bact_main
conda env export --no-builds > envs/bact_main_$(date +%Y%m%d).yml
```

### 3. Mantener Bases de Datos Actualizadas

```bash
# Crear recordatorio mensual
# Agregar a crontab:
# 0 0 1 * * /home/usuario/bacterial_genomics/scripts/update_all.sh
```

### 4. Verificar Después de Actualizar

```bash
# Siempre verificar después de cambios
bash ~/bacterial_genomics/scripts/verify_installation.sh
```

### 5. Respaldar Configuración

```bash
# Respaldar archivos YAML periódicamente
tar -czf bacterial_genomics_envs_$(date +%Y%m%d).tar.gz \
  ~/bacterial_genomics/envs/

# Mover a ubicación segura
mv bacterial_genomics_envs_*.tar.gz /ruta/respaldo/
```

---

## 📊 Resumen de Instalación

### Tamaños de Descarga

| Componente | Tamaño Aproximado |
|------------|------------------|
| Miniforge3 | 70-80 MB |
| bact_main | 3-4 GB |
| bact_amr | 800 MB |
| bact_rgi | 400 MB |
| Base de datos AMRFinder | 700 MB |
| Base de datos CARD | 50 MB |
| Bases de datos Abricate | 150 MB |
| Genoma referencia | 5-10 MB |
| **TOTAL** | **~5-6 GB** |

### Tiempos Estimados

| Paso | Tiempo (Internet Rápido) | Tiempo (Internet Lento) |
|------|-------------------------|------------------------|
| Instalación Miniforge | 2-3 min | 5-10 min |
| Ambiente bact_main | 15-20 min | 30-45 min |
| Ambiente bact_amr | 5-7 min | 10-15 min |
| Ambiente bact_rgi | 3-4 min | 7-10 min |
| Bases de datos | 10-15 min | 20-30 min |
| **TOTAL** | **35-50 min** | **70-110 min** |

---

## 🚀 Script de Instalación Completo (Todo en Uno)

Para facilitar la instalación, puedes usar este script que configura TODO automáticamente:

```bash
# Crear directorio principal
mkdir -p ~/bacterial_genomics/scripts
cd ~/bacterial_genomics

# Crear script de instalación completo
cat > scripts/setup_complete_installation.sh << 'EOF'
#!/bin/bash

set -e  # Salir si hay errores

echo "========================================"
echo "Instalación Completa"
echo "Bacterial Genomics Pipeline"
echo "========================================"
echo ""

# Verificar que conda/mamba estén instalados
if ! command -v mamba &> /dev/null; then
    echo "❌ ERROR: mamba no está instalado"
    echo "Por favor instala Miniforge primero"
    exit 1
fi

echo "✓ mamba encontrado: $(mamba --version)"
echo ""

# Crear directorios
echo "[Paso 1/6] Creando estructura de directorios..."
mkdir -p ~/bacterial_genomics/{00_raw_data/{illumina,nanopore},01_reference,02_qc/{01_illumina_raw,02_illumina_trimmed,03_nanopore_raw,04_nanopore_filtered,05_multiqc},03_assembly/{01_illumina_only,02_nanopore_only,03_hybrid,04_quast_evaluation},04_mapping/{01_illumina,02_nanopore,03_variants,04_coverage_analysis},05_annotation/{01_prokka,02_bakta},06_amr_screening/{01_amrfinder,02_abricate,03_rgi},07_typing/{mlst,plasmids,virulence},08_results/{figures,tables,reports},databases/{amrfinder_db,card},envs,scripts,logs}

# Crear ambientes
echo "[Paso 2/6] Creando ambientes conda..."

# bact_main
echo "  [2.1] Creando bact_main..."
mamba create -n bact_main -c conda-forge -c bioconda python=3.10 pip pigz openjdk=11 -y
conda activate bact_main
mamba install -c bioconda fastqc multiqc fastp nanoplot filtlong -y
mamba install -c bioconda bwa minimap2 samtools bcftools bedtools blast -y
mamba install -c bioconda spades flye unicycler quast bandage -y
mamba install -c bioconda ncbi-amrfinderplus barrnap mlst -y
mamba install -c bioconda seqtk kraken2 -y
conda deactivate

# bact_amr
echo "  [2.2] Creando bact_amr..."
mamba create -n bact_amr -c conda-forge -c bioconda python=3.9 prokka abricate -y

# bact_rgi
echo "  [2.3] Creando bact_rgi..."
mamba create -n bact_rgi -c conda-forge -c bioconda python=3.11 rgi -y

# Descargar bases de datos
echo "[Paso 3/6] Descargando bases de datos..."

# AMRFinderPlus
conda activate bact_main
amrfinder_update --database ~/bacterial_genomics/databases/amrfinder_db
mlst --list > /dev/null 2>&1
conda deactivate

# Abricate
conda activate bact_amr
abricate --setupdb
conda deactivate

# CARD
conda activate bact_rgi
cd ~/bacterial_genomics/databases/card
wget -q https://card.mcmaster.ca/latest/data
tar -xf data
rgi load --card_json card.json --local
cd ~/bacterial_genomics
conda deactivate

# Descargar genoma de referencia
echo "[Paso 4/6] Descargando genoma de referencia..."
cd ~/bacterial_genomics/01_reference
wget -q https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/240/185/GCF_000240185.1_ASM24018v2/GCF_000240185.1_ASM24018v2_genomic.fna.gz
gunzip GCF_000240185.1_ASM24018v2_genomic.fna.gz
ln -s GCF_000240185.1_ASM24018v2_genomic.fna reference.fasta
grep ">" reference.fasta | sed 's/>//' | awk '{print $1}' > reference_sequences.txt
cd ~/bacterial_genomics

# Exportar ambientes
echo "[Paso 5/6] Exportando ambientes..."
conda activate bact_main
conda env export --no-builds > ~/bacterial_genomics/envs/bact_main.yml
conda deactivate

conda activate bact_amr
conda env export --no-builds > ~/bacterial_genomics/envs/bact_amr.yml
conda deactivate

conda activate bact_rgi
conda env export --no-builds > ~/bacterial_genomics/envs/bact_rgi.yml
conda deactivate

# Verificación
echo "[Paso 6/6] Verificando instalación..."
bash ~/bacterial_genomics/scripts/verify_installation.sh

echo ""
echo "========================================"
echo "✓ INSTALACIÓN COMPLETADA"
echo "========================================"
echo ""
echo "Tiempo total: ~45-60 minutos"
echo "Espacio usado: ~5-6 GB"
echo ""
echo "Ambientes creados:"
echo "  1. bact_main  - Pipeline principal"
echo "  2. bact_amr   - Anotación y AMR"
echo "  3. bact_rgi   - AMR avanzado (CARD)"
echo ""
echo "Archivos YAML exportados en:"
echo "  ~/bacterial_genomics/envs/"
echo ""
echo "Siguiente paso:"
echo "  Elegir tu pipeline según tus datos"
echo ""
EOF

chmod +x scripts/setup_complete_installation.sh

# Ejecutar instalación completa
bash scripts/setup_complete_installation.sh
```

---

## ✅ Checklist Final

Antes de proceder a los pipelines, verifica que tengas:

- [ ] ✅ Miniforge/Mamba instalado correctamente
- [ ] ✅ Canales de Bioconda configurados
- [ ] ✅ Ambiente `bact_main` creado y funcional
- [ ] ✅ Ambiente `bact_amr` creado y funcional
- [ ] ✅ Ambiente `bact_rgi` creado y funcional
- [ ] ✅ Base de datos AMRFinderPlus descargada
- [ ] ✅ Bases de datos Abricate configuradas (9 bases)
- [ ] ✅ Base de datos CARD descargada
- [ ] ✅ Genoma de referencia descargado
- [ ] ✅ Estructura de directorios creada
- [ ] ✅ Ambientes exportados a YAML
- [ ] ✅ Script de verificación ejecutado sin errores

---

## 🎓 Siguiente Paso

Una vez completada la instalación, puedes proceder a:

### 📘 Si tienes datos Illumina
→ [01_ILLUMINA_PIPELINE.md](01_ILLUMINA_PIPELINE.md)

### 📗 Si tienes datos Nanopore
→ [02_NANOPORE_PIPELINE.md](02_NANOPORE_PIPELINE.md)

### 📕 Si tienes ambos (Recomendado)
→ [03_HYBRID_PIPELINE.md](03_HYBRID_PIPELINE.md)

---

## 📞 Ayuda y Soporte

### Recursos Online
- **Bioconda:** https://bioconda.github.io/
- **Conda cheatsheet:** https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html
- **GitHub Issues:** https://github.com/TU-USUARIO/Bacterial_Genomics_Pipeline/issues

### Comandos Útiles de Diagnóstico

```bash
# Ver estado del sistema
conda info

# Ver ambientes instalados
conda env list

# Ver paquetes en ambiente actual
conda list

# Ver espacio usado
du -sh ~/miniforge3/
du -sh ~/bacterial_genomics/

# Ver versión de herramientas críticas
conda activate bact_main
spades.py --version
amrfinder --version
conda deactivate
```

---

## 📚 Referencias

### Documentación Oficial

- **Conda:** https://docs.conda.io/
- **Mamba:** https://mamba.readthedocs.io/
- **Bioconda:** https://bioconda.github.io/
- **conda-forge:** https://conda-forge.org/

### Herramientas Instaladas

- **FastQC:** https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
- **SPAdes:** https://cab.spbu.ru/software/spades/
- **Flye:** https://github.com/fenderglass/Flye
- **Unicycler:** https://github.com/rrwick/Unicycler
- **AMRFinderPlus:** https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/
- **Prokka:** https://github.com/tseemann/prokka
- **RGI:** https://github.com/arpcard/rgi

---

<div align="center">

**✨ ¡Instalación Completada con Éxito! ✨**

---

**Tiempo total invertido:** ~45-60 minutos  
**Espacio utilizado:** ~5-6 GB  
**Herramientas instaladas:** 50+  
**Bases de datos:** 12+

---

### Navegación

[⬅️ Volver al Índice Principal](../README.md)

**Siguiente →**  
[📘 Pipeline Illumina](01_ILLUMINA_PIPELINE.md) | [📗 Pipeline Nanopore](02_NANOPORE_PIPELINE.md) | [📕 Pipeline Híbrido](03_HYBRID_PIPELINE.md)

---

*Última actualización: Enero 2025*  
*Versión: 4.0*  
*Documento completo y verificado*

</div>
