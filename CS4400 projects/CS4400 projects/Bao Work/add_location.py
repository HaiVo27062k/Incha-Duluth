from flask import Flask, render_template,request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)


def add_location():
    if request.method == "POST":
        details = request.form
        cur = mysql.connection.cursor()

        label = details['ip_label']
        x_coord = details['ip_x_coord']
        y_coord = details['ip_y_coord']
        space = details['ip_space']
        
        if label == '' or len(label) > 40:
            return 'Invalid Label Input!'
        try: 
            x_coord = int(x_coord)
        except: 
            return 'Invalid X Coord Input!'
        try: 
            y_coord = int(y_coord)
        except: 
            return 'Invalid Y Coord Input!'
        try: 
            space= int(space)
        except: 
            return 'Invalid Space Input!'
        
       
        cur.execute("SELECT label FROM locations")
        for item in cur: 
            if (item[0] == label):
                return ('Label Already Existed!')
        
        cur.execute("SELECT x_coord, y_coord FROM locations")
        for item in cur: 
            if (item[0] == x_coord and item[1] == y_coord): 
                return ('X, Y Combination Already Existed!')
        
        cur.callproc('add_location', [label, x_coord, y_coord, space])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Added A New Location'
    return render_template('add_location.html')