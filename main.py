from flask import request, redirect
from monster import render, tokeniser, parser, Flask
import sys, json

app = Flask(__name__)

tailwindcss="<script>"+open("public/tailwind.js").read()+"</script>"

@app.get("/")
def home():
    signals=open("public/signals.js").read()
    print(tokeniser(open("components/index.html").read()))
    print(parser(tokeniser(open("components/index.html").read())))
    return render("index", locals()|globals())

app.run(host="0.0.0.0", port=int(sys.argv[1]))