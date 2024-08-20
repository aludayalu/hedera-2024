from flask import request, redirect
from monster import render, tokeniser, parser, Flask
import sys, json

app = Flask(__name__)

tailwindcss="<script>"+open("public/tailwind.js").read()+"</script>"

@app.get("/")
def home():
    signals=open("public/signals.js").read()
    maincss=open("public/main.css").read()
    return render("index", locals()|globals())

@app.get("/pricing")
def pricing():
    signals=open("public/signals.js").read()
    maincss=open("public/main.css").read()
    return render("pricing", locals()|globals())

@app.get("/dashboard")
def dashboard():
    signals=open("public/signals.js").read()
    maincss=open("public/main.css").read()
    return render("dashboard", locals()|globals())

app.run(host="0.0.0.0", port=int(sys.argv[1]))