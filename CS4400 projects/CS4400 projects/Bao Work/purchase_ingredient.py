from flask import Flask, render_template,request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)


def purchase_ingredient():
    if request.method == "POST":
        details = request.form
        cur = mysql.connection.cursor()

        resName = details['ip_long_name']
        droneID = details['ip_id']
        droneTag = details['ip_tag']
        inBarcode = details['ip_barcode']
        inQuant = details['ip_quantity']

        
        if resName == '' or len(resName) > 40:
            return 'Invalid Restaurant Name Input!'
        if droneID == '' or len(droneID) > 40:
            return 'Invalid Drone ID Input!'
        try: 
            droneTag = int(droneTag)
        except: 
            return 'Invalid Drone Tag Input!'
        if inBarcode == '' or len(inBarcode) > 40:
            return 'Invalid Ingredient Barcode Input!'
        try: 
            inQuant = int(inQuant)
        except: 
            return 'Invalid Desired Quantity Input!'
        
        
        cur.execute("SELECT long_name FROM restaurants")
        flag = False
        for item in cur: 
            if (item[0] == resName):
                flag = True
                break
        if (flag == False):
            return 'Restaurant Name Does Not Exist!'

        cur.execute("SELECT id, tag FROM drones")
        flag1 = False
        for item in cur: 
            if (item[0] == droneID and item[1] == droneTag):
                flag1 = True
                break
        if (flag1 == False):
            return 'Invalid Drone Input!'
        
        cur.execute("SELECT id, tag, hover FROM drones")
        for item in cur: 
            if (item[0] == droneID and item[1] == droneTag):
                hover = item[2]
                cur.execute("SELECT long_name, location FROM restaurants")
                for other in cur: 
                    if (other[0] == resName):
                        if (hover != other[1]):
                            return ('Drone Is Not At Restaurant Location!')
                        else: 
                            break; 
        
                break; 
        
        cur.execute("SELECT id, tag, barcode FROM payload")
        flag = False
        for item in cur: 
            if (item[0] == droneID and item[1] == droneTag and item[2] == inBarcode):
                flag = True
                break
        if (flag == False):
            return ('The Input Drone Does Not Carry The Desired Ingredient!')
        
        cur.execute("SELECT id, tag, barcode, quantity FROM payload")
        for item in cur: 
            if (item[0] == droneID and item[1] == droneTag and item[2] == inBarcode):
                if (item[3] < inQuant):
                    return ('Desired Quantity Exceeds Quantity On Drone!')
                else: 
                    break 
        
        cur.callproc('purchase_ingredient', [resName, droneID, droneTag, inBarcode, inQuant])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Purchased An Ingredient'
    return render_template('purchase_ingredient.html')