FROM python:3.11-slim
WORKDIR /app

# Install Python ML dependencies
COPY workers/inference-worker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python worker script
COPY workers/inference-worker/inference_worker.py .

# Run the worker
CMD ["python", "inference_worker.py"]
