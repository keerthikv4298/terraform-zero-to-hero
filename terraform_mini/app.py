from flask import Flask

app = Flask(__name__)

@app.route('/')
def hellow():
    return "Hello keerthivasan, welcome to the world of hope"

if __name__ == "__main__":
    app.run(host = "0.0.0.0",port= 80)