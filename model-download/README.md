## Download model from huggingface to local filesystem

Example to download microsoft/phi-4

```bash
export HF_TOKEN=xxxxx
export MODEL="microsoft/phi-4"
python -m venv venv
source venv/bin/activate
pip install -r ./requirements.txt
python download.py --local_model_path="${HOME}/models"
```
