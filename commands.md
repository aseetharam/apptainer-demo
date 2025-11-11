### **Part 1. Pull and explore containers**

Goal: introduce pulling and inspecting images.

```bash
# Move to scratch for all demos
cd $SCRATCH

# Pull an image as SIF
apptainer pull fastqc.sif docker://biocontainers/fastqc:v0.11.9_cv8

# Pull an image as writable sandbox
apptainer pull --sandbox ubuntu_sandbox docker://ubuntu:22.04

# Inspect metadata
apptainer inspect fastqc.sif
```

---

### **Part 2. Shell into and run programs**

Goal: show difference between `exec`, `run`, and `shell`.

```bash
# Open an interactive shell
apptainer shell fastqc.sif

# Inside shell
fastqc --version
exit

# Or run one command directly
apptainer exec fastqc.sif fastqc --help

# Run the image’s default command (if defined)
apptainer run fastqc.sif
```

---

### **Part 3. Using bind mounts**

Goal: demonstrate how data in scratch becomes visible inside the container.

```bash
# Define path to FASTQ files
DATA=$SCRATCH/20251021_AirwayStudy_RNAseq/01_data/raw

# Bind mount scratch data to /data inside container
apptainer exec --bind $DATA:/data fastqc.sif fastqc /data/SRR1039508.fastq.gz

# Mount current directory (best practice for project-local work)
apptainer exec --bind $PWD fastqc.sif fastqc sample.fastq.gz
```

---

### **Part 4. Using writable overlays**

Goal: show how to use overlays with Trinity for temporary writable space.

```bash
# Pull Trinity image
apptainer pull trinity.sif docker://biocontainers/trinity:2.15.1--pl5321hdfd78af_1

# Create writable overlay file (5GB)
apptainer overlay create --size 5000 trinity_overlay.img

# Run Trinity using overlay for intermediate files
apptainer exec --overlay trinity_overlay.img trinity.sif Trinity \
    --seqType fq \
    --max_memory 4G \
    --left $DATA/SRR1039508.fastq.gz \
    --CPU 4 \
    --output /tmp/trinity_out_dir
```

---

### **Part 5. Using clean environments**

Goal: illustrate isolation 

```bash
# Run with clean environment
apptainer exec --cleanenv fastqc.sif fastqc /data/SRR1039508.fastq.gz


```

---

### **Part 6. Building custom container (short version)**

Goal: explain `.def` file usage.

```bash
# Create def file (fastqc.def) in current directory

# Build a sif image (if local fakeroot allowed)
apptainer build --fakeroot fastqc.sif fastqc.def
```

---

### **Part 7. Running with SLURM**

Goal: demonstrate integrating Apptainer commands in a job script.

**`trinity_job.slurm`**

```bash
#!/bin/bash
#SBATCH -A rcac
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -t 01:00:00
#SBATCH --mem=64G
#SBATCH -J trinity_assembly
#SBATCH -o trinity_%j.out
#SBATCH -e trinity_%j.err

module --force purge

DATA=$SCRATCH/20251021_AirwayStudy_RNAseq/01_data/raw
OUTDIR=$SCRATCH/trinity_out
OVERLAY=$SCRATCH/trinity_overlay.img

apptainer exec --overlay $OVERLAY trinity.sif Trinity \
    --seqType fq \
    --max_memory 60G \
    --CPU 16 \
    --left $DATA/SRR1039508.fastq.gz \
    --output $OUTDIR
```

Submit job:

```bash
sbatch trinity_job.slurm
```

