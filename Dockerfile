# Use official Python image
FROM python:3.10-slim

# Set working directory inside container
ARG CACHEBUST=1
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire src folder to /app/src
COPY ./src /app


# Expose port (should match FastAPI/uvicorn)
EXPOSE 8000

# Run the app (main.py should be inside /app/src)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
