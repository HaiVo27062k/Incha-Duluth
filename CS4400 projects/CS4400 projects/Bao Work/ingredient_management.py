from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# THIS METHOD IS TO ADD NEW INGREDIENT 
def addIngredient():
    if request.method == "POST":
        details = request.form
        barcode = details['ip_barcode']
        name = details['ip_iname']
        weight = details['ip_weight']
        if barcode == '' or len(barcode) > 40:
            return 'Invalid Barcode Input!'
        if  name == '' or len(name) > 100:
            return 'Invalid Ingredient Name Input!'
        try: 
            weight = int(weight)
        except: 
            return 'Invalid Ingredient Weight Input!'
        
        cur = mysql.connection.cursor()
        cur.execute("SELECT barcode FROM ingredients")
        for item in cur: 
            if (item[0] == barcode):
                return 'Barcode Already Existed!'
        
        cur.callproc('add_ingredient', [barcode, name, weight])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Added!'
    return render_template('add_ingredient.html')
