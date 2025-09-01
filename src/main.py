from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import uvicorn

app = FastAPI()

# 🚑 Health check endpoint for ALB
@app.get("/healthz")
def health_check():
    return {"status": "ok"}

# 🏠 Root path (access via ALB DNS)
@app.get("/")
def root():
    return {"message": "Hello from Vin's Notes App via FastAPI 🎉"}

# 📝 Notes data model
class Note(BaseModel):
    title: str
    content: str

# 🧠 In-memory list to store notes (temporary, not DB)
notes_db: List[Note] = []

# ➕ Create a new note
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

# 🚀 Optional: Run locally
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
