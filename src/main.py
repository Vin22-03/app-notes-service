from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Gauge
import random

app = FastAPI()

# ✅ Templates & Static (for HTML form)
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")

# ✅ Prometheus instrumentation
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

REQUEST_COUNTER = Counter(
    "app_requests_total", "Total number of requests", ["endpoint"]
)

RANDOM_NUMBER_GAUGE = Gauge(
    "app_random_number", "Current value of the random number"
)

# 📝 In-memory Notes DB
class Note(BaseModel):
    title: str
    content: str

notes_db: List[Note] = []

# 🌐 Landing Page with HTML UI
@app.get("/", response_class=HTMLResponse)
def landing_page(request: Request):
    REQUEST_COUNTER.labels(endpoint="/").inc()
    return templates.TemplateResponse("index.html", {"request": request})

# ✅ API Endpoints
@app.get("/health")
def health_check():
    REQUEST_COUNTER.labels(endpoint="/health").inc()
    return {"status": "ok"}

@app.get("/random", response_class=JSONResponse)
def get_random_number():
    REQUEST_COUNTER.labels(endpoint="/random").inc()
    num = random.randint(0, 100)
    RANDOM_NUMBER_GAUGE.set(num)
    return {"status": "ok", "random_number": num}

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

# 👇 Local dev only
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
