from pathlib import Path

configfile: "config/config.yaml"

# rule extract_samples: SCREW THIS SHIT
#     input:
#         variant=config['variant_file']
#     output:
#         '{input.variant}'.split('.')[0] + '_samples.txt'
#     log:
#         err=expand('logs/{dude}.err', dude=config['run_name']),
#         log=expand('logs/{dude}.log', dude=config['run_name'])
#     shell:
#         "bcftools query -l {input} > {output}"

# # Get all the sample names

def get_sample_names(wildcards):

    filepath = Path(config['variant_file'])
    sample_file_name = filepath.stem.split('.')[0] + '_samples.txt'

    # print(f'Variant File: {filepath}')
    # print(f'Sample File: {filepath.parent / sample_file_name}' )

    with open(filepath.parent / sample_file_name, 'r') as f:
        sample_names = [i.strip() for i in f.readlines()]
    return sample_names

# use the following command and make your life easier: bcftools query -l /path/to/vcf > vcfname_samples.txt

rule all:
        input:
            expand("output/R64_{sample_name}.fasta", sample_name=get_sample_names)
        default_target: True

ruleorder: index_variant >  consensus

rule index_variant:
    input:
        sequence=config['variant_file'],
        variant=config['variant_file'],
    log:
        err=expand('logs/{dude}.err', dude=config['run_name']),
        log=expand('logs/{dude}.log', dude=config['run_name'])
    output:
        expand('{variant_file}.csi', variant_file=config['variant_file'])
    shell:
        "bcftools index {input.variant} > {log.log} 2> {log.err}"

rule consensus:
    input:
        sample_name=expand('{sample_name}', sample_name=get_sample_names),
        variant_index=expand('{variant_file}.csi', variant_file=config['variant_file']),
    params:
    #     sample_name=config["sample_name"],
        fasta=config["sequence_file"],
        variant=config["variant_file"],
    # output:
    #     "output/R64_{params.sample_name}.fasta"
    output:
        "output/R64_{params.sample_name}.fasta",
    log:
        err=expand('logs/{dude}.err', dude=config['run_name']),
        log=expand('logs/{dude}.log', dude=config['run_name'])
    shell:
        "bcftools consensus -s {input.sample_name} -f {params.fasta} {params.variant} -o {output} > {log.log} 2> {log.err}"
