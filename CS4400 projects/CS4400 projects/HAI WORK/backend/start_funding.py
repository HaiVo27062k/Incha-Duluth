from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import datetime

app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 


def start_funding():
    if request.method == "POST":
        cur = mysql.connection.cursor()
        details = request.form
        userName = details['ip_owner']
        restaurant_name = details['ip_long_name']

        if (userName == '' or len(userName) > 40):
            return "invalid UserName input!"
        if (restaurant_name == "" or len(restaurant_name) > 100):
            return "INVALID restaurant name input!"

        query1 = "SELECT username FROM restaurant_owners"
        cur.execute(query1)
        for item1 in cur:
            if userName == item1[0]:
                break;
            else:
                return "The USER is not an OWNER!!"

        ########## CHECK TO SEE IF RESTAURANTS EXISTS #######################
        query2 = "SELECT long_name FROM restaurants"
        cur.execute(query2)
        found = False

        for item2 in cur:
            if(restaurant_name == "".join(item2)):
                found = True
                break;

        if(found == False):
            return "The restaurant does not EXIST!!"

        
        cur.callproc('start_funding',[userName, restaurant_name])
        mysql.connection.commit()
        cur.close()
        return ("START FUNDING: Succesfully MODIFIED!")
        


    return render_template('start_funding.html')
