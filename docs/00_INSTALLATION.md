# 🛠️ Guía de Instalación y Configuración
### Bacterial Genomics Pipeline - Versión 4.1

---

## 📋 Tabla de Contenidos

1. [**Configuración de la Estructura del Proyecto**](#-paso-0-configuración-de-la-estructura-del-proyecto) ⭐ NUEVO
2. [Requisitos Previos](#-requisitos-previos)
3. [Instalación de Miniforge/Mamba](#-instalación-de-miniforgemamba)
4. [Configuración de Canales Bioconda](#-configuración-de-canales-bioconda)
5. [Creación de Ambientes Conda](#-creación-de-ambientes-conda)
6. [Descarga de Bases de Datos](#-descarga-de-bases-de-datos)
7. [Verificación de Instalación](#-verificación-de-instalación)
8. [Exportar e Importar Ambientes](#-exportar-e-importar-ambientes)
9. [Actualización del Sistema](#-actualización-del-sistema)
10. [Solución de Problemas](#-solución-de-problemas)
11. [Comandos de Referencia](#-comandos-de-referencia)

---

## 🏗️ Paso 0: Configuración de la Estructura del Proyecto

**⭐ IMPORTANTE: Ejecuta este paso PRIMERO, antes de instalar los ambientes conda.**

### ¿Qué hace este paso?

Crea automáticamente toda la estructura de directorios necesaria para el proyecto:
- ✅ 14 directorios principales
- ✅ 40+ subdirectorios organizados
- ✅ Descarga el genoma de referencia
- ✅ Archivos de metadata y configuración
- ✅ Scripts auxiliares
- ✅ Archivo .gitignore configurado

### Ejecución Rápida

```bash
# Opción 1: Desde el repositorio clonado
cd Bacterial_Genomics_Pipeline
bash setup_project_structure.sh

# Opción 2: Descargar script directamente
wget https://raw.githubusercontent.com/TU-USUARIO/Bacterial_Genomics_Pipeline/main/setup_project_structure.sh
chmod +x setup_project_structure.sh
bash setup_project_structure.sh

# Opción 3: Personalizar nombre del proyecto
bash setup_project_structure.sh mi_proyecto URO5550422
```

### Estructura Creada

```
~/bacterial_genomics/
├── 00_raw_data/          # Tus datos FASTQ (Illumina + Nanopore)
├── 01_reference/         # Genoma de referencia K. pneumoniae
├── 02_qc/                # Control de calidad
├── 03_assembly/          # Ensamblajes
├── 04_mapping/           # Mapeos y variantes
├── 05_annotation/        # Anotación funcional
├── 06_amr_screening/     # Genes AMR
├── 07_typing/            # MLST, plásmidos
├── 08_results/           # Resultados finales
├── databases/            # AMRFinder, CARD, etc.
├── envs/                 # Archivos YAML
├── scripts/              # Scripts de análisis
└── logs/                 # Logs de ejecución
```

### Verificar Estructura

```bash
# Ir al directorio del proyecto
cd ~/bacterial_genomics

# Verificar que todo se creó correctamente
bash scripts/verify_structure.sh

# Salida esperada:
# ✓ 00_raw_data/illumina
# ✓ 00_raw_data/nanopore
# ✓ 01_reference
# ... (todos los directorios)
# ✓ Estructura completa
```

### Archivos Importantes Creados

| Archivo | Descripción |
|---------|-------------|
| `sample_metadata.txt` | Metadata de la muestra |
| `reference_sequences.txt` | Índice de secuencias del genoma de referencia |
| `README_PROJECT.md` | README específico del proyecto |
| `PROJECT_CONFIG.sh` | Variables de configuración |
| `.gitignore` | Configurado para genómica |
| `scripts/link_raw_data.sh` | Script para enlazar datos |
| `scripts/verify_structure.sh` | Verificación de estructura |

### 📚 Documentación Completa

Para más detalles sobre la configuración del proyecto, ver:
**[SETUP_PROJECT_GUIDE.md](SETUP_PROJECT_GUIDE.md)**

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

# Medaka (polishing Nanopore - opcional pero recomendado)
mamba install -c bioconda medaka -y

# Tiempo estimado: 3-5 minutos
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

**⚠️ IMPORTANTE:** Ejecutar DESPUÉS de crear la estructura del proyecto con `setup_project_structure.sh`.

### Base de Datos AMRFinderPlus

```bash
# El directorio ya fue creado por setup_project_structure.sh
# Si no lo ejecutaste, créalo manualmente:
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
# El directorio ya fue creado por setup_project_structure.sh
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

El script `verify_structure.sh` ya fue creado por `setup_project_structure.sh`. Ahora necesitamos el script de verificación de ambientes:

```bash
# Ir al directorio del proyecto
cd ~/bacterial_genomics

# Crear script de verificación de ambientes
cat > scripts/verify_installation.sh << 'EOF'
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
chmod +x scripts/verify_installation.sh

# Ejecutar verificación
bash scripts/verify_installation.sh
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

## 💾 Exportar e Importar Ambientes

[El resto del contenido de 00_INSTALLATION.md permanece igual...]

### Exportar los 3 Ambientes

```bash
# Ir al directorio del proyecto
cd ~/bacterial_genomics

# Exportar bact_main
conda activate bact_main
conda env export --no-builds > envs/bact_main.yml
conda deactivate

# Exportar bact_amr
conda activate bact_amr
conda env export --no-builds > envs/bact_amr.yml
conda deactivate

# Exportar bact_rgi
conda activate bact_rgi
conda env export --no-builds > envs/bact_rgi.yml
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

[El resto del documento 00_INSTALLATION.md se mantiene igual desde "Actualización del Sistema" en adelante...]

---

## ✅ Checklist Final de Instalación

Antes de proceder a los pipelines, verifica que tengas:

- [ ] ✅ Estructura del proyecto creada (`setup_project_structure.sh`)
- [ ] ✅ Genoma de referencia descargado en `01_reference/`
- [ ] ✅ Miniforge/Mamba instalado correctamente
- [ ] ✅ Canales de Bioconda configurados
- [ ] ✅ Ambiente `bact_main` creado y funcional
- [ ] ✅ Ambiente `bact_amr` creado y funcional
- [ ] ✅ Ambiente `bact_rgi` creado y funcional
- [ ] ✅ Base de datos AMRFinderPlus descargada
- [ ] ✅ Bases de datos Abricate configuradas (9 bases)
- [ ] ✅ Base de datos CARD descargada
- [ ] ✅ Ambientes exportados a YAML en `envs/`
- [ ] ✅ Script de verificación ejecutado sin errores
- [ ] ✅ Scripts auxiliares creados y funcionales

---

## 🎓 Siguiente Paso

Una vez completada la instalación y configuración, puedes proceder a:

### 📘 Si tienes datos Illumina
→ [01_ILLUMINA_PIPELINE.md](01_ILLUMINA_PIPELINE.md)

### 📗 Si tienes datos Nanopore
→ [02_NANOPORE_PIPELINE.md](02_NANOPORE_PIPELINE.md)

### 📕 Si tienes ambos (Recomendado)
→ [03_HYBRID_PIPELINE.md](03_HYBRID_PIPELINE.md)

---

<div align="center">

**✨ ¡Instalación y Configuración Completadas! ✨**

---

**Tiempo total invertido:** ~60-90 minutos  
**Espacio utilizado:** ~5-6 GB (ambientes + bases de datos)  
**Herramientas instaladas:** 50+  
**Bases de datos:** 12+  
**Estructura completa:** 54+ directorios

---

### Navegación

[⬅️ Volver al Índice Principal](../README.md) | [🏗️ Configuración del Proyecto](SETUP_PROJECT_GUIDE.md)

**Siguiente →**  
[📘 Pipeline Illumina](01_ILLUMINA_PIPELINE.md) | [📗 Pipeline Nanopore](02_NANOPORE_PIPELINE.md) | [📕 Pipeline Híbrido](03_HYBRID_PIPELINE.md)

---

*Última actualización: Enero 2025*  
*Versión: 4.1*  
*Incluye configuración automática del proyecto*

</div>
