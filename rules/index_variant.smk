# Index the bgzipped VCF file
# No need to specify output as it is automatically handled by bcftools

rule index_variant:
    input:
        variant='data/variant/small.vcf.gz'
    log: "logs/index_variant.log"
    shell:
        "bcftools index {input} > {log} &> "
