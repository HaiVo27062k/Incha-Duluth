from flask import Flask, render_template, request
from flask_mysqldb import MySQL


app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 

def fire_employee():
    if request.method == "POST":
        details = request.form
        deliveryExist = False

        userName = details['ip_username']
        id = details['ip_id']
        cur = mysql.connection.cursor()

        if (userName == "" or len(userName) > 40):
            return "INVALID userName input!"

        if (id == "" or len(id) > 5):
            return "INVALID id input!"

        query2 = "SELECT manager FROM delivery_services"
        cur.execute(query2)
        for item2 in cur:
            if (userName == item2[0]):
                return ("USERNAME is a MANAGER!!")

        query3 = "SELECT flown_by FROM drones"
        cur.execute(query3)
        for item3 in cur:
            if (userName == item3[0]):
                return ("USERNAME is currently flying a DRONE!!")
        
        query4 = "SELECT id FROM delivery_services"
        cur.execute(query4)
        for item4 in cur:
            if (id == item4[0]):
                deliveryExist = True
                break;
        
        query1 = "SELECT username FROM work_for"
        cur.execute(query1)
        for item1 in cur:
            if (userName == item1[0]):
                cur.callproc('fire_employee', [userName,id])
                mysql.connection.commit()
                cur.close()
                return ("FIRE: fire successfully")

        if (deliveryExist == False):
            return "Delievery service does not exist!!"
        return "USER is not currently working!!"

    return render_template('fire_employee.html')