from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# THIS METHOD IS TO REMOVE INGREDIENT
def manage_service():
    if request.method == "POST":
        details = request.form
        username = details['ip_username']
        id = details['ip_id']
        
        
        if username == '' or len(username) > 40:
            return 'Invalid Username Input!'
        
        if id == '' or len(id) > 40:
            return 'Invalid ID Input!'

        cur = mysql.connection.cursor()

        cur.execute("SELECT username FROM employees")
        flag = False
        for item in cur: 
            if (item[0] == username):
                flag = True
                break
        if (flag == False):
            return ('Username Is Not An Employee!')


        cur.execute("SELECT id FROM delivery_services")
        flag = False 
        for item in cur: 
            if (item[0] == id):
                flag = True
                break
        if (flag == False):
            return ('Input ID Does Not Exist!')
        
        
        cur.execute("SELECT id, username FROM work_for")
        flag = False
        for item in cur: 
            if (item[0] == id and item[1] == username):
                flag = True
                break
        if (flag == False):
            return ('Input Employee Is Not Working For Input Service')

        
        cur.execute("SELECT flown_by FROM drones")
        for item in cur: 
            if (item[0] == username):
                return ('This Employee Is Flying A Drone!')

        
        cur.execute("SELECT id, username FROM work_for")
        for item in cur: 
            if (item[0] != id):
                if (item[1] == username):
                    return ('Input Employee Is Also Working For Another Service!')

        
        cur.callproc('manage_service', [username, id])
        mysql.connection.commit()
        cur.close()
        return 'Sucessfully Updated!'
    return render_template('manage_service.html')
