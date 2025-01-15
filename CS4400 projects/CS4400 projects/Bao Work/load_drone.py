from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# THIS METHOD IS TO LOAD DRONE
def load_drone():
    if request.method == "POST":
        details = request.form
        id = details['ip_id']
        tag = details['ip_tag']
        barcode = details['ip_barcode']
        more = details['ip_more_packages']
        price = details['ip_price']        
        
        
        if id == '' or len(id) > 40:
            return 'Invalid ID Input!'
        try: 
            tag = int(tag)
        except: 
            return 'Invalid Tag Input!'
        if barcode == '' or len(barcode) > 40:
            return 'Invalid Barcode Input!'
        try: 
            more = int(more)
        except: 
            return 'Invalid More Input!'
        try: 
            price = int(price)
        except: 
            return 'Invalid Price Input!'

        cur = mysql.connection.cursor()

        cur.execute("SELECT id FROM delivery_services WHERE id = '%s'" % id); 
        res = cur.fetchall()
        if (len(res) != 1):
            return ('Input ID Does Not Exist!')


        cur.execute("SELECT id, tag FROM drones WHERE id = '%s' and tag = '%s'" % (id, tag))
        res = cur.fetchall()
        if (len(res) != 1):
            return ('Input Drone Does Not Exist!')


        cur.execute("SELECT hover FROM drones WHERE id = '%s' and tag = '%s'" % (id, tag))
        hover = cur.fetchall()

        cur.execute("SELECT barcode FROM ingredients WHERE barcode = '%s'" % barcode)
        res = cur.fetchall()
        if (len(res) != 1):
            return ('Input Barcode Does Not Exist!')
        
        cur.callproc('load_drone', [id, tag, barcode, more, price])
        mysql.connection.commit()
        cur.close()
        return 'Sucessfully Loaded!'
    return render_template('load_drone.html')
