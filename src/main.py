from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from fastapi.responses import HTMLResponse
import uvicorn
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

# 📊 Prometheus monitoring
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# 🚑 Health check endpoint for ALB
@app.get("/healthz")
def health_check():
    return {"status": "ok"}

# 🎨 Beautiful landing page
@app.get("/", response_class=HTMLResponse)
def root():
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
                .button {
                    background-color: #2980b9;
                    border: none;
                    color: white;
                    padding: 15px 32px;
                    text-align: center;
                    text-decoration: none;
                    font-size: 16px;
                    margin: 20px;
                    border-radius: 8px;
                    cursor: pointer;
                }
                .button:hover {
                    background-color: #3498db;
                }
            </style>
        </head>
        <body>
            <h1>Welcome to Vin's Notes App 🎉</h1>
            <p>Create, view, and manage your notes with ease using FastAPI ⚡</p>
            <a href="/docs" class="button">📚 API Docs</a>
            <a href="/metrics" class="button">📈 Prometheus Metrics</a>
            <a href="/notes" class="button">📝 View Notes</a>
        </body>
    </html>
    """

# 📝 Notes data model
class Note(BaseModel):
    title: str
    content: str

# 🧠 In-memory notes store
notes_db: List[Note] = []

# ➕ Add new note
@app.post("/notes")
def create_note(note: Note):
    notes_db.append(note)
    return {"message": "Note added successfully!", "note": note}

# 📋 Get all notes
@app.get("/notes")
def get_notes():
    return notes_db

# 🗑️ Delete all notes
@app.delete("/notes")
def delete_notes():
    notes_db.clear()
    return {"message": "All notes deleted."}

# 🚀 Run app
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
