#!/usr/bin/env nextflow

process MakeIndex {
    publishDir params.outdir
    container 'robsyme/xenome:latest'

    cpus 12 
    memory '64G'

    input:
    tuple path(mouse), path(human)

    output:
    path("*")

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

workflow {
    mouse = Channel.fromPath(params.mouse)
    human = Channel.fromPath(params.human)

    mouse.combine(human)
    | MakeIndex
    | view
}
