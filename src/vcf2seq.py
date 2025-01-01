import subprocess
from pathlib import Path
import hydra
from dotenv import load_dotenv
from omegaconf import DictConfig

load_dotenv()


def check_index_exists(config: DictConfig):
    """Checks if the index file for the variant file exists.

    If the index file with a '.csi' suffix does not exist for the specified
    variant file in the configuration, it runs the 'bcftools index' command
    to create it.

    Args:
        config (DictConfig): Configuration object containing the path to the
        variant file.
    """

    index_path = Path(config.variant_file + ".csi")  # Get path of variant file

    print(index_path)

    if not index_path.exists():
        subprocess.run(
            ["bcftools", "index", index_path],
            # stdout=config.log_fil
        )

    else:
        pass

    return None


def generate_consensus(config: DictConfig):
    """Runs the 'bcftools consensus' command to generate a consensus sequence given a variant file
    and a sequence file. The output is saved as a fasta file with the name
    <sequence_file_name><sample_name>.fasta.

    Args:
        config (DictConfig): Configuration object containing the paths to the
        variant and sequence files, as well as the sample name.
    """
    variant_path = config.variant_file
    sequence_path = Path(config.sequence_file)

    sample_name = config.sample_name

    output_name = sequence_path.stem + "_" + sample_name + ".fasta"
    output_path = Path(config.output.dir) / output_name
    print(output_path)

    command = [
        "bcftools",
        "consensus",
        "-f",
        sequence_path,
        "-s",
        sample_name,
        variant_path,
        "-o",
        output_path.as_posix(),
    ]

    subprocess.run(command)


@hydra.main(version_base="1.3", config_path="../configs/", config_name="config")
def main(config: DictConfig):
    """The main function for running the VCF to consensus sequence generation process.

    This function initializes the environment using Hydra, checks if the index file
    for the variant file exists and generates a consensus sequence. It uses the
    configuration specified in the Hydra config.

    Args:
        config (DictConfig): Configuration object containing the necessary paths and parameters
        for checking the index and generating the consensus sequence.
    """

    check_index_exists(config)

    generate_consensus(config)


if __name__ == "__main__":
    main()
