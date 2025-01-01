configfile: "config/config.yaml"



rule all:
        input:
            expand("output/R64_{sample_name}.fasta", sample_name=config['sample_name'])

ruleorder: index_variant > consensus

rule index_variant:
    input:
        variant='data/variant/small.vcf.gz'
    log:
        err=expand('logs/{dude}.err', dude=config['sample_name']),
        log=expand('logs/{dude}.log', dude=config['sample_name'])
    output:
        expand('logs/{dude}.err', dude=config['sample_name'])
    shell:
        "bcftools index {input} > {log.log} 2> {log.err}"

rule consensus:
    input:
        fasta=config["sequence_file"],
        variant=config["variant_file"],
    params:
        sample_name=config["sample_name"],
    # output:
    #     "output/R64_{params.sample_name}.fasta"
    output:
        expand("output/R64_{sample_name}.fasta", sample_name=config['sample_name']),
    log:
        err=expand('logs/{dude}.err', dude=config['sample_name']),
        log=expand('logs/{dude}.log', dude=config['sample_name'])
    shell:
        "bcftools consensus -s {params.sample_name} -f {input.fasta} {input.variant} -o {output} > {log.log} 2> {log.err}"
