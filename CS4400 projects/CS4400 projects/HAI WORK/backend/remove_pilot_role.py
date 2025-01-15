from flask import Flask, render_template, request
from flask_mysqldb import MySQL


app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 

def remove_pilot_role():
    if request.method == "POST":
        details = request.form

        userName = details['ip_username']
        cur = mysql.connection.cursor()

        if (userName == "" or len(userName) > 40):
            return "INVALID userName input!"

        query1 = "SELECT flown_by FROM drones"
        cur.execute(query1)
        for item1 in cur:
            if (userName == item1[0]):
                return "The Pilot is CONTROLLING at least one drone"

        query3 = "SELECT username FROM pilots"
        cur.execute(query3)
        for item3 in cur:
            if (userName == item3[0]):
                cur.callproc('remove_pilot_role', [userName])
                mysql.connection.commit()
                cur.close()
                return ("REMOVE: Succesfully removed!")
        
        return "USERNAME is NOT in PILOTS!"

    return render_template('remove_pilot_role.html')