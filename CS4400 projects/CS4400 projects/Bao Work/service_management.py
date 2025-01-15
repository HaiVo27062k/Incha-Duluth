from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# THIS METHOD IS TO ADD NEW SERVICE
def addService():
    if request.method == "POST":
        details = request.form
        id = details['ip_id']
        name = details['ip_long_name']
        homeBase = details['ip_home_base']
        manager = details['ip_manager']
        if id == '' or len(id) > 40:
            return 'Invalid ID Input!'
        if  name == '' or len(name) > 100:
            return 'Invalid Service Name Input!'
        if  homeBase == '' or len(homeBase) > 40:
            return 'Invalid Home Base Input!'
        if  manager == '' or len(manager) > 40: 
            return 'Invalid Manager Input!'
        
        cur = mysql.connection.cursor()
        cur.execute("SELECT id FROM delivery_services")
        for item in cur: 
            if (item[0] == id):
                return 'ID Already Existed!'

        homeBaseValid = False
        cur.execute("SELECT label FROM locations")
        for item in cur: 
            if (item[0] == homeBase):
                homeBaseValid = True
                break
        if (homeBaseValid == False):
            return ("Home Base Does Not Exist!")
        

        managerValid = False
        cur.execute("SELECT username FROM workers")
        for item in cur: 
            if (item[0] == manager):
                managerValid = True
                break
        if (managerValid == False):
            return ("Manager Does Not Exist!")
        
        
        cur.execute("SELECT manager FROM delivery_services")
        for item in cur: 
            if (item[0] == manager):
                return 'Manager Already Managed A Service!'
        
        cur.callproc('add_service', [id, name, homeBase, manager])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Added!'
    return render_template('add_service.html')