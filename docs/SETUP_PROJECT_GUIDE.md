# 📁 Configuración Automática de la Estructura del Proyecto

## 🎯 Descripción

El script `setup_project_structure.sh` crea automáticamente toda la estructura de directorios necesaria para el pipeline de análisis genómico bacteriano, incluyendo:

- ✅ 14 directorios principales
- ✅ 40+ subdirectorios organizados
- ✅ Descarga automática del genoma de referencia
- ✅ Archivos de metadata y configuración
- ✅ Scripts auxiliares
- ✅ Archivo .gitignore configurado

## 🚀 Uso Rápido

### Opción 1: Configuración por Defecto

```bash
# Descargar el script
wget https://raw.githubusercontent.com/TU-USUARIO/Bacterial_Genomics_Pipeline/main/setup_project_structure.sh

# Dar permisos de ejecución
chmod +x setup_project_structure.sh

# Ejecutar
bash setup_project_structure.sh
```

Esto creará:
- Directorio: `~/bacterial_genomics/`
- Muestra ejemplo: `SAMPLE`

### Opción 2: Personalizar Nombre

```bash
# Especificar nombre del proyecto y muestra
bash setup_project_structure.sh mi_proyecto URO5550422
```

Esto creará:
- Directorio: `~/mi_proyecto/`
- Muestra: `URO5550422`

## 📦 Lo que Hace el Script

### Paso 1: Crear Directorio Base
```
~/bacterial_genomics/
```

### Paso 2: Estructura de Directorios

```
bacterial_genomics/
├── 00_raw_data/
│   ├── illumina/           # FASTQ Illumina
│   └── nanopore/           # FASTQ Nanopore
├── 01_reference/           # Genoma de referencia
├── 02_qc/                  # Control de calidad
│   ├── 01_illumina_raw/
│   ├── 02_illumina_trimmed/
│   ├── 03_nanopore_raw/
│   ├── 04_nanopore_filtered/
│   └── 05_multiqc/
├── 03_assembly/            # Ensamblajes
│   ├── 01_illumina_only/
│   ├── 02_nanopore_only/
│   ├── 03_hybrid/
│   └── 04_quast_evaluation/
├── 04_mapping/             # Mapeos
│   ├── 01_illumina/
│   ├── 02_nanopore/
│   ├── 03_variants/
│   └── 04_coverage_analysis/
├── 05_annotation/          # Anotación
│   ├── 01_prokka/
│   └── 02_bakta/
├── 06_amr_screening/       # AMR
│   ├── 01_amrfinder/
│   ├── 02_abricate/
│   └── 03_rgi/
├── 07_typing/              # Tipificación
│   ├── mlst/
│   ├── plasmids/
│   └── virulence/
├── 08_results/             # Resultados
│   ├── figures/
│   ├── tables/
│   └── reports/
├── databases/              # Bases de datos
│   ├── amrfinder_db/
│   └── card/
├── envs/                   # Ambientes conda
├── scripts/                # Scripts
│   ├── illumina/
│   ├── nanopore/
│   ├── hybrid/
│   ├── common/
│   └── utils/
├── test_data/              # Datos de prueba
└── logs/                   # Logs
```

### Paso 3: Archivos Creados

1. **sample_metadata.txt** - Metadata de la muestra
2. **reference_sequences.txt** - Índice de secuencias de referencia
3. **README_PROJECT.md** - README del proyecto
4. **.gitignore** - Configurado para genómica
5. **PROJECT_CONFIG.sh** - Variables de configuración
6. **Scripts auxiliares:**
   - `link_raw_data.sh` - Enlazar datos
   - `verify_structure.sh` - Verificar estructura

### Paso 4: Descarga de Referencia

Descarga automáticamente:
- **Organismo:** *Klebsiella pneumoniae* HS11286
- **Accesión:** GCF_000240185.1
- **Tamaño:** ~5.7 Mb (1 cromosoma + 6 plásmidos)

## 🔍 Verificar Instalación

```bash
# Ir al directorio
cd ~/bacterial_genomics

# Verificar estructura
bash scripts/verify_structure.sh

# Salida esperada:
# ✓ 00_raw_data/illumina
# ✓ 00_raw_data/nanopore
# ✓ 01_reference
# ... (todos los directorios)
# ✓ Estructura completa
```

## 📥 Agregar tus Datos

### Opción 1: Copiar Archivos

```bash
# Illumina
cp /ruta/original/*.fastq.gz ~/bacterial_genomics/00_raw_data/illumina/

# Nanopore
cp /ruta/original/*.fastq.gz ~/bacterial_genomics/00_raw_data/nanopore/
```

### Opción 2: Crear Enlaces Simbólicos (Recomendado)

```bash
# Usar script auxiliar
cd ~/bacterial_genomics
bash scripts/link_raw_data.sh /ruta/illumina /ruta/nanopore

# O manualmente:
ln -s /ruta/illumina/*.fastq.gz 00_raw_data/illumina/
ln -s /ruta/nanopore/*.fastq.gz 00_raw_data/nanopore/
```

**Ventajas de enlaces simbólicos:**
- No duplica datos (ahorra espacio)
- Datos originales permanecen intactos
- Fácil de actualizar

## ⚙️ Configuración del Proyecto

El archivo `PROJECT_CONFIG.sh` contiene todas las variables del proyecto:

```bash
# Cargar configuración
source PROJECT_CONFIG.sh

# Usar variables
echo $PROJECT_NAME
echo $SAMPLE_ID
echo $BASE_DIR
echo $THREADS
```

**Variables disponibles:**
- Información del proyecto
- Rutas de directorios
- Parámetros por defecto
- Ambientes conda
- Rutas de bases de datos

## 🎯 Próximos Pasos Después de la Configuración

### 1. Instalar Ambientes Conda

Si aún no lo has hecho:

```bash
# Ver documentación de instalación
# docs/00_INSTALLATION.md

# O usar script automatizado
bash scripts/setup_environments.sh
```

### 2. Verificar Datos

```bash
# Listar datos Illumina
ls -lh 00_raw_data/illumina/

# Listar datos Nanopore  
ls -lh 00_raw_data/nanopore/

# Verificar genoma de referencia
ls -lh 01_reference/
```

### 3. Elegir Pipeline

Según tus datos disponibles:

| Datos Disponibles | Pipeline | Documentación |
|-------------------|----------|---------------|
| Solo Illumina | Pipeline Illumina | `docs/01_ILLUMINA_PIPELINE.md` |
| Solo Nanopore | Pipeline Nanopore | `docs/02_NANOPORE_PIPELINE.md` |
| Ambos | Pipeline Híbrido ⭐ | `docs/03_HYBRID_PIPELINE.md` |

### 4. Ejecutar Análisis

```bash
# Ejemplo: Pipeline híbrido
bash scripts/run_hybrid_pipeline.sh URO5550422
```

## 🔧 Personalización Avanzada

### Cambiar Organismo de Referencia

Si trabajas con otra especie:

```bash
# Editar script antes de ejecutar
nano setup_project_structure.sh

# Cambiar estas líneas:
ORGANISM="Tu_Organismo"
REFERENCE_STRAIN="Cepa"
REFERENCE_ACCESSION="GCF_XXXXXX"
REFERENCE_URL="https://..."
GENOME_SIZE="X.Xm"
```

### Agregar Directorios Personalizados

```bash
# Después de ejecutar el script
cd ~/bacterial_genomics

# Agregar tus propios directorios
mkdir -p 09_custom_analysis
mkdir -p 10_publication_figures
```

## 📝 Mantenimiento

### Limpiar Resultados Intermedios

```bash
# Eliminar archivos temporales
rm -rf 02_qc/*/tmp*
rm -rf 03_assembly/*/tmp*

# Mantener solo resultados finales
# Ver .gitignore para archivos que se pueden eliminar
```

### Respaldar Proyecto

```bash
# Respaldar estructura y scripts (sin datos)
tar -czf bacterial_genomics_structure.tar.gz \
  --exclude='00_raw_data' \
  --exclude='02_qc' \
  --exclude='03_assembly' \
  --exclude='04_mapping' \
  ~/bacterial_genomics/

# Respaldar solo resultados importantes
tar -czf results_$(date +%Y%m%d).tar.gz \
  ~/bacterial_genomics/08_results/
```

## ❓ Preguntas Frecuentes

### ¿Puedo ejecutar el script varias veces?

Sí. El script detecta si el directorio existe y pregunta si quieres sobrescribir.

### ¿Funciona en otros sistemas operativos?

El script está diseñado para Linux/Unix. Para Windows, usa WSL2.

### ¿Qué pasa si no tengo internet?

La descarga del genoma de referencia fallará. Puedes descargar manualmente:
```bash
# Descargar manualmente desde NCBI
# Luego copiar a 01_reference/
```

### ¿Puedo cambiar la ubicación del proyecto?

Sí, modifica la variable `BASE_DIR` en el script o ejecútalo con nombre personalizado.

## 🆘 Solución de Problemas

### Error: "Permission denied"

```bash
# Dar permisos de ejecución
chmod +x setup_project_structure.sh

# O ejecutar con bash explícitamente
bash setup_project_structure.sh
```

### Error al descargar referencia

```bash
# Verificar conexión a internet
ping ftp.ncbi.nlm.nih.gov

# Descargar manualmente
cd ~/bacterial_genomics/01_reference
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/240/185/GCF_000240185.1_ASM24018v2/GCF_000240185.1_ASM24018v2_genomic.fna.gz
```

### El directorio ya existe

El script preguntará si quieres sobrescribir. Si quieres mantener datos:
```bash
# Renombrar directorio existente
mv ~/bacterial_genomics ~/bacterial_genomics_backup

# Ejecutar script
bash setup_project_structure.sh
```

## 📖 Referencias

- Documentación completa: `docs/00_INSTALLATION.md`
- Pipeline Illumina: `docs/01_ILLUMINA_PIPELINE.md`
- Pipeline Nanopore: `docs/02_NANOPORE_PIPELINE.md`
- Pipeline Híbrido: `docs/03_HYBRID_PIPELINE.md`

---

**¿Listo para empezar?**

```bash
bash setup_project_structure.sh
```

¡Estructura creada en minutos! 🚀
