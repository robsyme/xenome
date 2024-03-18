#!/usr/bin/env nextflow

workflow {
    mouse = Channel.fromPath(params.mouse)
    human = Channel.fromPath(params.human)
    reads = Channel.fromPath(params.reads) 
    
    reads | MakeFastq

    mouse
    | combine(human)
    | MakeIndex
    
    MakeIndex.out
    | map { [it] }
    | combine(MakeFastq.out)
    | Classify
    | view
}


process MakeIndex {
    publishDir params.outdir
    container 'robsyme/xenome:latest'

    cpus 12 
    memory '64G'

    input:
    tuple path(mouse), path(human)

    output:
    path("out*")

    script:
    """
    xenome index \\
        --graft ${human} \\
        --host ${mouse} \\
        --prefix out \\
        --kmer-size 25 \\
        --num-threads ${task.cpus - 2} \\
        --max-memory ${task.memory.toGiga() - 5} \\
        --verbose \\
        --log-file xenome.log
    """
}

process MakeFastq {
    cpus 8
    memory '8G'
    container 'wave.seqera.io/wt/e52681b5e0d2/wave/build:sra-tools--3018c98f5d3f2a24'

    input: path(sra)
    output: tuple path("*_1.fastq"), path("*_2.fastq")
    script: "fasterq-dump $sra --threads ${task.cpus}"
}

process Classify {
    cpus 8
    memory '64G'

    input: tuple path(index), path(fwd), path(rev)
    output: path("classify*")

    script:
    """
    xenome classify \\
        -l classify.xenome_log.txt \\
        -T $task.cpus \\
        --pairs \\
        --fastq-in ${fwd} \\
        --fastq-in ${rev} \\
        --prefix out \\
        --graft-name mouse \\
        --host-name human \\
        --max-memory ${task.memory.toGiga() - 2} \\
        --output-filename-prefix classify > classify.xenome_stats.txt
    """
}
