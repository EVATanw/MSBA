from flask import Flask
from flask import render_template,request

app = Flask(__name__)

@app.route("/",methods=["GET","POST"])
def HWagenda():
    return(render_template("HWagenda.html"))

@app.route("/HWq1", methods=["GET", "POST"])
def HWq1():
    return render_template("HWq1.html")

@app.route("/HWq2", methods=["GET", "POST"])
def HWq2():
    return render_template("HWq2.html")

@app.route("/HWq3", methods=["GET", "POST"])
def HWq3():
    return render_template("HWq3.html")

@app.route("/HWq4", methods=["GET", "POST"])
def HWq4():
    return render_template("HWq4.html")

@app.route("/HWq5", methods=["GET", "POST"])
def HWq5():
    return render_template("HWq5.html")

if __name__ == "__main__":
    app.run()
