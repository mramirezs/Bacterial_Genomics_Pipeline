# 🧬 Proyecto: Vigilancia Genómica y Análisis de Resistencia en *E. coli*

Este repositorio documenta el flujo de trabajo bioinformático para el análisis de una cepa clínica de *Escherichia coli*. El objetivo es detectar genes de resistencia a antimicrobianos (AMR) y variantes genéticas mediante dos estrategias complementarias: **Resecuenciamiento (Mapeo)** y **Ensamblaje De Novo (No Híbrido)**.

## 📂 Estructura del Proyecto

El proyecto sigue una organización estricta para garantizar la reproducibilidad en entornos HPC:

```text
Ecoli_Project/
├── 00_raw_data/              # Datos crudos (Enlaces simbólicos)
│   ├── illumina/             # URO5550422 (PE)
│   └── nanopore/             # FRAN93 (Long Reads)
├── 01_reference/             # Genoma de referencia (E. coli K-12 MG1655)
├── 02_qc/                    # Control de calidad (FastQC, NanoPlot)
├── 03_mapping/               # Análisis de Variantes (BWA, Minimap2)
├── 04_assembly/              # Ensamblaje De Novo (Separado)
│   ├── illumina_only/        # Spades
│   └── nanopore_only/        # Flye
├── 05_amr_screening/         # Detección de genes (Abricate, RGI, AMRFinder)
├── envs/                     # Archivos de ambientes exportados
└── scripts/                  # Scripts de automatización
```

## 🛠️ Instalación y Configuración del Entorno

Debido a conflictos de dependencias entre herramientas bioinformáticas (versiones incompatibles de Perl, Python y bibliotecas compartidas), utilizamos **tres ambientes Conda especializados** para garantizar la compatibilidad y reproducibilidad.

### 1. Pre-requisitos: Instalar Miniforge

Si aún no tienes un gestor de paquetes instalado en el servidor, recomendamos **Miniforge** por su velocidad y configuración nativa con `conda-forge`.

```bash
# Descargar e instalar Miniforge (Linux x86_64)
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3

# Inicializar y activar
$HOME/miniforge3/bin/conda init bash
source ~/.bashrc

# Verificar instalación de Mamba
mamba --version
```

### 2. Configurar canales de Bioconda

Configura los canales necesarios **una sola vez** antes de crear los ambientes:

```bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

### 3. Crear los ambientes especializados

#### 🧬 Ambiente 1: Pipeline Principal (`bact_main`)

Este ambiente contiene todas las herramientas para control de calidad, mapeo, ensamblaje y detección básica de AMR.

```bash
# Crear ambiente base
mamba create -n bact_main -c conda-forge -c bioconda -c defaults \
  python=3.10 pip pigz openjdk=11 -y

# Activar ambiente
mamba activate bact_main

# Instalar herramientas de control de calidad
mamba install fastqc multiqc fastp nanoplot filtlong -y

# Instalar herramientas de mapeo y análisis de variantes
mamba install bwa minimap2 samtools bcftools bedtools blast -y

# Instalar ensambladores
mamba install unicycler flye spades quast bandage -y

# Instalar herramientas AMR compatibles
mamba install ncbi-amrfinderplus barrnap -y

# Configurar base de datos de AMRFinderPlus (primera vez)
amrfinder_update --database 05_amr_screening/amrfinder_db
```

> ⏱️ **Tiempo estimado de instalación**: 10-15 minutos  
> 📦 **Descarga de base de datos AMRFinderPlus**: ~500 MB, 2-5 minutos adicionales

#### 🦠 Ambiente 2: Anotación y AMR (`bact_amr`)

Este ambiente está dedicado a Prokka y Abricate, que requieren versiones específicas de Perl incompatibles con el ambiente principal.

```bash
# Crear ambiente para Prokka y Abricate
mamba create -n bact_amr -c conda-forge -c bioconda -c defaults \
  python=3.9 prokka abricate -y

# Activar y configurar base de datos de Abricate (primera vez)
mamba activate bact_amr
abricate --setupdb
```

> ⏱️ **Tiempo estimado de instalación**: 5-10 minutos  
> 📦 **Descarga de bases de datos Abricate**: ~100 MB, 1-3 minutos adicionales

#### 🧪 Ambiente 3: RGI (`bact_rgi`)

RGI (Resistance Gene Identifier) requiere dependencias muy específicas que entran en conflicto con otras herramientas, por lo que se instala en un ambiente separado.

```bash
# Crear ambiente para RGI
mamba create -n bact_rgi -c conda-forge -c bioconda -c defaults \
  python=3.11 rgi -y
```

> ⏱️ **Tiempo estimado de instalación**: 5-10 minutos

### 4. Verificar las instalaciones

#### Verificar `bact_main`:

```bash
mamba activate bact_main

# Verificar herramientas clave
fastqc --version
bwa 2>&1 | head -3
samtools --version
unicycler --version
spades.py --version
quast --version

# Verificar AMRFinderPlus y base de datos
amrfinder --version
amrfinder --database 05_amr_screening/amrfinder_db --database_version
```

#### Verificar `bact_amr`:

```bash
mamba activate bact_amr

# Verificar herramientas
prokka --version
abricate --version
abricate --list  # Listar bases de datos disponibles
```

#### Verificar `bact_rgi`:

```bash
mamba activate bact_rgi

# Verificar RGI
rgi main --version
rgi load --help
```

### 5. Exportar ambientes para reproducibilidad

Una vez que todos los ambientes estén funcionando correctamente, expórtalos para garantizar la reproducibilidad en otros servidores o equipos:

```bash
# Crear directorio para almacenar archivos de ambientes
mkdir -p envs

# Exportar ambiente principal (con todas las versiones exactas)
mamba activate bact_main
mamba env export --no-builds > envs/bact_main.yml

# Exportar ambiente AMR
mamba activate bact_amr
mamba env export --no-builds > envs/bact_amr.yml

# Exportar ambiente RGI
mamba activate bact_rgi
mamba env export --no-builds > envs/bact_rgi.yml

# Opcional: Exportar solo paquetes principales (archivo más limpio)
mamba activate bact_main
mamba env export --from-history > envs/bact_main_minimal.yml
```

> 💡 **Nota**: `--no-builds` genera archivos YML más portables entre diferentes sistemas operativos. Los archivos `_minimal.yml` solo incluyen paquetes instalados explícitamente, sin dependencias.

### 6. Replicar ambientes en otro servidor

Para recrear exactamente los mismos ambientes en otra máquina:

#### Opción A: Copiar archivos YML y crear ambientes

```bash
# Desde tu máquina local, copiar archivos al servidor remoto
scp envs/*.yml usuario@servidor:/home/usuario/Ecoli_Project/envs/

# En el servidor remoto, crear los ambientes desde los archivos
cd /home/usuario/Ecoli_Project

mamba env create -f envs/bact_main.yml
mamba env create -f envs/bact_amr.yml
mamba env create -f envs/bact_rgi.yml

# Configurar bases de datos en el nuevo servidor
mamba activate bact_main
amrfinder_update --database 05_amr_screening/amrfinder_db

mamba activate bact_amr
abricate --setupdb

mamba activate bact_rgi
# Configurar CARD database si es necesario (ver sección RGI)
```

#### Opción B: Clonar el repositorio completo

```bash
# En el servidor remoto
git clone https://github.com/tu-usuario/Ecoli_Project.git
cd Ecoli_Project

# Crear ambientes desde los archivos YML versionados
mamba env create -f envs/bact_main.yml
mamba env create -f envs/bact_amr.yml
mamba env create -f envs/bact_rgi.yml

# Configurar bases de datos
mamba activate bact_main
amrfinder_update --database 05_amr_screening/amrfinder_db

mamba activate bact_amr
abricate --setupdb
```

### 7. Verificar bases de datos configuradas

Después de configurar los ambientes en un nuevo servidor, verifica que las bases de datos estén correctamente instaladas:

```bash
# Verificar base de datos AMRFinderPlus
mamba activate bact_main
amrfinder --list_organisms
amrfinder --database 05_amr_screening/amrfinder_db --database_version

# Verificar bases de datos Abricate
mamba activate bact_amr
abricate --list

# Salida esperada:
# DATABASE       SEQUENCES  DBTYPE  DATE
# argannot       2223       nucl    2023-Jun-19
# card           2631       nucl    2023-Jun-19
# ecoh           597        nucl    2023-Jun-19
# ecoli_vf       2701       nucl    2023-Jun-19
# megares        6635       nucl    2023-Jun-19
# ncbi           5386       nucl    2023-Jun-19
# plasmidfinder  460        nucl    2023-Jun-19
# resfinder      3077       nucl    2023-Jun-19
# vfdb           2597       nucl    2023-Jun-19
```

---

## 🚀 Uso de los ambientes en el pipeline

### Para control de calidad, mapeo y ensamblaje:

```bash
mamba activate bact_main

# Ejecutar análisis de calidad
fastqc 00_raw_data/illumina/*.fastq.gz -o 02_qc/illumina/
multiqc 02_qc/illumina/ -o 02_qc/illumina/

# Ejecutar mapeo
bwa mem 01_reference/ecoli_k12.fasta 00_raw_data/illumina/R1.fastq.gz 00_raw_data/illumina/R2.fastq.gz | samtools view -Sb - > 03_mapping/sample.bam

# Ejecutar ensamblaje
spades.py -1 00_raw_data/illumina/R1.fastq.gz -2 00_raw_data/illumina/R2.fastq.gz -o 04_assembly/illumina_only/
```

### Para anotación genómica:

```bash
mamba activate bact_amr

# Anotar genoma con Prokka
prokka --outdir 05_annotation/ --prefix ecoli_sample 04_assembly/illumina_only/contigs.fasta

# Detectar genes AMR con Abricate
abricate --db card 04_assembly/illumina_only/contigs.fasta > 05_amr_screening/abricate_card.tsv
abricate --db resfinder 04_assembly/illumina_only/contigs.fasta > 05_amr_screening/abricate_resfinder.tsv
```

### Para análisis AMR con RGI:

```bash
mamba activate bact_rgi

# Cargar base de datos CARD (primera vez)
rgi load --card_json /path/to/card.json --local

# Ejecutar análisis RGI
rgi main --input_sequence 04_assembly/illumina_only/contigs.fasta \
  --output_file 05_amr_screening/rgi_results \
  --local --clean
```

### Para detección AMR con AMRFinderPlus:

```bash
mamba activate bact_main

# Verificar que la base de datos esté configurada
amrfinder --database 05_amr_screening/amrfinder_db --list_organisms

# Ejecutar AMRFinderPlus con base de datos local
amrfinder --nucleotide 04_assembly/illumina_only/contigs.fasta \
  --database 05_amr_screening/amrfinder_db \
  --organism Escherichia \
  --output 05_amr_screening/amrfinder_results.tsv \
  --plus --threads 8

# Si necesitas actualizar la base de datos
amrfinder_update --database 05_amr_screening/amrfinder_db
```

---

## 🔧 Solución de Problemas Comunes

### Error: "Could not solve for environment specs"

**Causa**: Conflictos entre versiones de Perl, Python y bibliotecas compartidas (zlib, libzlib).

**Solución**: 
- ✅ Usar los tres ambientes separados como se describe arriba
- ✅ No intentar instalar prokka, abricate y rgi en el mismo ambiente
- ✅ Asegurarse de haber configurado los canales correctamente

### Instalación muy lenta

**Soluciones**:
- Usar `mamba` en lugar de `conda` (hasta 10x más rápido)
- Instalar herramientas en lotes pequeños como se muestra arriba
- Verificar conexión a internet y acceso a los repositorios de conda-forge/bioconda

### Conflictos al cambiar entre ambientes

**Solución**:
```bash
# Desactivar ambiente actual antes de cambiar
conda deactivate

# Activar nuevo ambiente
mamba activate <nombre_ambiente>
```

### Base de datos de RGI no encontrada

**Solución**:
```bash
mamba activate bact_rgi

# Descargar base de datos CARD (última versión)
wget https://card.mcmaster.ca/latest/data
tar -xvf data ./card.json

# Cargar base de datos local
rgi load --card_json ./card.json --local

# Verificar carga
rgi database --version --local
```

### Bases de datos desactualizadas

**Para AMRFinderPlus**:
```bash
mamba activate bact_main
amrfinder_update --database 05_amr_screening/amrfinder_db --force
```

**Para Abricate**:
```bash
mamba activate bact_amr
abricate-get_db --db resfinder --force  # Actualizar base específica
abricate --setupdb                       # Reindexar todas las bases
```

---

## 📊 Resumen de Herramientas por Ambiente

### 🧬 `bact_main` (Pipeline Principal)

| Categoría | Herramientas |
|-----------|--------------|
| **QC** | FastQC, MultiQC, Fastp, NanoPlot, Filtlong |
| **Mapeo** | BWA, Minimap2, Samtools, BCFtools, BEDtools |
| **Ensamblaje** | Unicycler, Flye, SPAdes, QUAST, Bandage |
| **AMR** | AMRFinderPlus, Barrnap, BLAST |
| **Utilidades** | Python 3.10, pigz, OpenJDK 11 |

### 🦠 `bact_amr` (Anotación y AMR)

| Categoría | Herramientas |
|-----------|--------------|
| **Anotación** | Prokka (con tbl2asn, barrnap, prodigal) |
| **AMR** | Abricate (CARD, ResFinder, NCBI, ARG-ANNOT, etc.) |
| **Utilidades** | Python 3.9, Perl con módulos específicos |

### 🧪 `bact_rgi` (AMR Avanzado)

| Categoría | Herramientas |
|-----------|--------------|
| **AMR** | RGI (Resistance Gene Identifier) + CARD database |
| **Utilidades** | Python 3.11, BLAST 2.16.0, KMA, Samtools 1.21 |

---

## 💡 Recomendaciones Adicionales

### Script wrapper para automatización

Puedes crear un script que cambie automáticamente entre ambientes según la tarea:

```bash
#!/bin/bash
# run_pipeline.sh

echo "🧬 Iniciando pipeline de análisis E. coli..."

# Paso 1: Control de Calidad
echo "📊 Paso 1: Control de Calidad"
mamba run -n bact_main bash scripts/01_qc.sh

# Paso 2: Ensamblaje
echo "🔧 Paso 2: Ensamblaje"
mamba run -n bact_main bash scripts/02_assembly.sh

# Paso 3: Anotación
echo "📝 Paso 3: Anotación con Prokka"
mamba run -n bact_amr bash scripts/03_annotation.sh

# Paso 4: Detección AMR
echo "🦠 Paso 4: Detección de genes AMR"
mamba run -n bact_main bash scripts/04_amrfinder.sh
mamba run -n bact_amr bash scripts/05_abricate.sh
mamba run -n bact_rgi bash scripts/06_rgi.sh

echo "✅ Pipeline completado exitosamente!"
```

### Alternativas a herramientas problemáticas

Si encuentras problemas persistentes, considera estas alternativas modernas:

| Herramienta | Alternativa | Ventaja |
|-------------|-------------|---------|
| Prokka | **Bakta** | Más rápido, mejor anotación, más actualizado |
| RGI | **AMRFinderPlus** | Oficial NCBI, más estable, ya instalado |
| Abricate | **AMRFinderPlus** | Integración nativa con NCBI, mejor curación |

---

## 📚 Referencias y Recursos

- **Conda/Mamba**: [https://mamba.readthedocs.io/](https://mamba.readthedocs.io/)
- **Bioconda**: [https://bioconda.github.io/](https://bioconda.github.io/)
- **Prokka**: [https://github.com/tseemann/prokka](https://github.com/tseemann/prokka)
- **Abricate**: [https://github.com/tseemann/abricate](https://github.com/tseemann/abricate)
- **RGI/CARD**: [https://card.mcmaster.ca/](https://card.mcmaster.ca/)
- **AMRFinderPlus**: [https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/](https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/)
- **SPAdes**: [https://github.com/ablab/spades](https://github.com/ablab/spades)
- **Unicycler**: [https://github.com/rrwick/Unicycler](https://github.com/rrwick/Unicycler)

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request para sugerencias o mejoras.

## ✉️ Contacto

Para preguntas o colaboraciones, contactar a [tu email/institución].
