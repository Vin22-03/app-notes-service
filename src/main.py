from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from typing import List
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Gauge
import random

app = FastAPI()

# ✅ Automatic FastAPI instrumentation
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# ✅ Manual Prometheus metrics
REQUEST_COUNTER = Counter(
    "app_requests_total",
    "Total number of requests to the app",
    ["endpoint"]
)

RANDOM_NUMBER_GAUGE = Gauge(
    "app_random_number",
    "Current value of the random number"
)

# 🎨 Beautiful landing page
@app.get("/", response_class=HTMLResponse)
def root():
    REQUEST_COUNTER.labels(endpoint="/").inc()
    return """
    <html>
        <head>
            <title>Vin's Notes App 📒</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background: linear-gradient(to right, #83a4d4, #b6fbff);
                    color: #333;
                    text-align: center;
                    padding: 50px;
                }
                h1 {
                    font-size: 3em;
                    color: #2c3e50;
                }
                p {
                    font-size: 1.2em;
                }
            </style>
        </head>
        <body>
            <h1>📒 Welcome to Vin's Notes App</h1>
            <p>Your notes live here on the cloud ☁️ – with Prometheus metrics enabled!</p>
            <p>Check <a href="/metrics">/metrics</a> for Prometheus scrape info</p>
        </body>
    </html>
    """

# 🚑 Health check endpoint
@app.get("/health")
def health_check():
    REQUEST_COUNTER.labels(endpoint="/health").inc()
    return {"status": "ok"}

# 🎲 Endpoint to trigger random gauge
@app.get("/random", response_class=JSONResponse)
def get_random_number():
    REQUEST_COUNTER.labels(endpoint="/random").inc()
    num = random.randint(0, 100)
    RANDOM_NUMBER_GAUGE.set(num)
    return {"status": "ok", "random_number": num}

# 📝 Notes model
class Note(BaseModel):
    title: str
    content: str

# 📚 In-memory storage
notes_db: List[Note] = []

@app.post("/notes")
def create_note(note: Note):
    REQUEST_COUNTER.labels(endpoint="/notes_post").inc()
    notes_db.append(note)
    return {"message": "Note added ✅", "note": note}

@app.get("/notes")
def get_notes():
    REQUEST_COUNTER.labels(endpoint="/notes_get").inc()
    return notes_db

@app.delete("/notes")
def delete_notes():
    REQUEST_COUNTER.labels(endpoint="/notes_delete").inc()
    notes_db.clear()
    return {"message": "All notes deleted."}

# 🔥 Local run only
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
