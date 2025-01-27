import argparse
import logging
import os
import shutil
from pathlib import Path

from dotenv import load_dotenv
from huggingface_hub import login, snapshot_download

load_dotenv()

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def download_model_locally(model_name: str, local_model_path: str, replace_if_exists: bool = True) -> str:
    """Download a Hugging Face model locally."""
    hf_token = os.getenv("HF_TOKEN")
    if not hf_token:
        raise EnvironmentError("HF_TOKEN is not defined. Please set it as an environment variable.")
    login(token=hf_token.strip(), add_to_git_credential=True)
    logger.info("Successfully logged in to Hugging Face.")

    # Build the final path for the model
    target_path = Path(local_model_path) / model_name.replace("/", "-")

    # Skip or remove existing directory if needed
    # Set to remove by default!! 
    if target_path.exists():
        if not replace_if_exists:
            logger.info(f"'{target_path}' already exists. Skipping download.")
            return str(target_path)
        shutil.rmtree(target_path)
        logger.info(f"Removed existing directory '{target_path}'.")

    snapshot_download(repo_id=model_name, local_dir=str(target_path))
    logger.info(f"Model '{model_name}' downloaded to '{target_path}'.")
    return str(target_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--local_model_path",
        default="./models",
        help="Local directory path to store the model."
    )
    args = parser.parse_args()

    downloaded_path = download_model_locally(
        model_name=os.getenv("MODEL"),  # e.g., "microsoft/phi-4"
        local_model_path=args.local_model_path,
        replace_if_exists=True, # might want to set this to False
    )
    logger.info(f"Model downloaded: {downloaded_path}")
