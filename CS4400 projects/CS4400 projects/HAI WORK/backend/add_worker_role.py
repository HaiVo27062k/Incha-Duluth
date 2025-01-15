from flask import Flask, render_template, request
from flask_mysqldb import MySQL


app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 



###### LOGIC ERROR
def add_worker_role():
    if request.method == "POST":
        cur = mysql.connection.cursor()
        details = request.form
        userName = details['ip_username']

        if (userName == "" or len(userName) > 40):
            return "INVALID userName input!"

        query1 = "SELECT username FROM workers"
        cur.execute(query1)
        for item1 in cur:
            if userName == item1[0]:
                return 'USERNAME already existed in WORKERS!'

        query2 = "SELECT username FROM restaurant_owners"
        cur.execute(query2)
        for item2 in cur:
            if userName == item2[0]:
                return 'USERNAME already existed in  OWNERS!'

        query3 = "SELECT username FROM employees"
        cur.execute(query3)
        for item3 in cur:
            if (userName == item3[0]):
                cur.callproc('add_worker_role',[userName])
                mysql.connection.commit()
                cur.close()
                return ("Add: Succesfully Added!")

        return "USERNAME is NOT in EMPLOYEES!"
    return render_template('add_worker_role.html')