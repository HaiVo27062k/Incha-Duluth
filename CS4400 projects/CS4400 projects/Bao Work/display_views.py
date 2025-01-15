from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)
 
# THIS METHOD IS FOR VIEWING OWNER
def displayOwner(): 
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_owner_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_owner.html', data=data)


# THIS METHOD IS FOR VIEWING EMPLOYEE
def displayEmployee(): 
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_employee_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_employee.html', data=data)


# THIS METHOD IS FOR VIEWING PILOT
def displayPilot():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_pilot_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_pilot.html', data=data)


# THIS METHOD IS FOR VIEWING LOCATION
def displayLocation():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_location_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_location.html', data=data)


# THIS METHOD IS FOR VIEWING INGREDIENT
def displayIngredient():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_ingredient_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_ingredient.html', data=data)


# THIS METHOD IS FOR VIEWING SERVICE
def displayService():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_service_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_service.html', data=data)