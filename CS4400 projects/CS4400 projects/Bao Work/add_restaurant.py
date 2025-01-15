from flask import Flask, render_template,request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)


def add_restaurant():
    if request.method == "POST":
        details = request.form
        cur = mysql.connection.cursor()

        long_name = details['ip_long_name']
        rating = details['ip_rating']
        spent = details['ip_spent']
        location = details['ip_location']
        if long_name == '' or len(long_name) > 100:
            return 'Invalid Restaurant Name Input!'
        try: 
            rating = int(rating)
        except: 
            return 'Invalid Rating Input!'
        try: 
            spent = int(spent)
        except: 
            return 'Invalid Spent Input!'
        
        if int(rating) > 5 or int(rating) < 1:
            return 'Invalid Rating Input!'
        query1 = "SELECT long_name FROM restaurants"
        cur.execute(query1)
        for item1 in cur:
            if long_name == item1[0]:
                return 'Restaurant Name Already Existed!'
        query2 = "SELECT label FROM locations"
        cur.execute(query2)
        for item2 in cur:
            if location != item2[0]:
                return 'Location does not exit!'
        cur.callproc('add_restaurant', [long_name, rating, spent, location])
        mysql.connection.commit()
        cur.close()
        return 'successfully added a new restaurant'
    return render_template('add_restaurant.html')