from flask import Flask, render_template, request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# THIS METHOD IS TO REMOVE INGREDIENT
def remove_ingredient():
    if request.method == "POST":
        details = request.form
        barcode = details['ip_barcode']
        
        if barcode == '' or len(barcode) > 40:
            return 'Invalid Barcode Input!'

        cur = mysql.connection.cursor()
        cur.execute("SELECT barcode FROM ingredients")
        flag = False
        for item in cur: 
            if (item[0] == barcode):
                flag = True
                break
        if (flag == False):
            return ('Barcode Does Not Exist!')
        
        cur.execute("SELECT barcode FROM payload")
        for item in cur: 
            if (item[0] == barcode):
                return ('Cannot Remove Since Ingredient Is Carried By A Drone!')
        
        cur.callproc('remove_ingredient', [barcode])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Removed!'
    return render_template('remove_ingredient.html')
