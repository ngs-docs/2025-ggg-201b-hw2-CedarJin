SAMPLES = ["SRR2584403","SRR2584404","SRR2584405"]

rule all:
    input:
        expand("{sample}_quast.4000000",sample=SAMPLES),
        expand("{sample}_annot.4000000",sample=SAMPLES)


rule subset_reads:
    input:
        "{sample}_1.fastq.gz",
    output:
        "{sample}_1.{subset,\d+}.fastq.gz"
    shell: """
        gunzip -c {input} | head -{wildcards.subset} | gzip -9c > {output} || true
    """

rule annotate:
    input:
        "{sample}-assembly.{subset}.fa"
    output:
        directory("{sample}_annot.{subset}")
    shell: """
       prokka --prefix {output} {input}                                       
    """

rule assemble:
    input:
        r1 = "{sample}_1.{subset}.fastq.gz"
    output:
        dir = directory("{sample}_assembly.{subset}"),
        assembly = "{sample}-assembly.{subset}.fa"
    shell: """
       megahit -r {input.r1} -f -m 10e9 -t 4 -o {output.dir}     
       cp {output.dir}/final.contigs.fa {output.assembly}                     
    """

rule quast:
    input:
        "{sample}-assembly.{subset}.fa"
    output:
        directory("{sample}_quast.{subset}")
    shell: """                                                                
       quast {input} -o {output}                                              
    """
