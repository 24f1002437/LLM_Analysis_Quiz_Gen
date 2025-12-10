FROM python:3.12-slim

# --- System deps required by Playwright browsers ---
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates curl unzip \
    # Playwright dependencies
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 libxrandr2 \
    libxfixes3 libpango-1.0-0 libcairo2 \
    # Tesseract OCR engine
    tesseract-ocr \
    # FFmpeg for audio processing (pydub)
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*


# --- Install Playwright + Chromium ---
RUN pip install playwright && playwright install --with-deps chromium

# --- Install uv package manager ---
RUN pip install uv

# --- Copy app to container ---
WORKDIR /app
COPY . .

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

# --- Install dependencies from pyproject.toml ---
RUN uv sync --frozen

# Expose port
EXPOSE 7860

# --- Run FastAPI inside uv environment ---
CMD uv run uvicorn main:app --host 0.0.0.0 --port $PORT
