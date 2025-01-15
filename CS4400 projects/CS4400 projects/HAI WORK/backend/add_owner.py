from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import datetime

app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 


def add_owner():
    if request.method == "POST":
        cur = mysql.connection.cursor()
        details = request.form
        userName = details['ip_username']
        firstName = details['ip_first_name']
        lastName = details['ip_last_name']
        address = details['ip_address']
        birthDate = details['ip_birthdate']

        if (userName == '' or len(userName) > 40):
            return "invalid UserName input!"
        if (firstName == '' or len(firstName) > 100):
            return "invalid firstName input!"
        if (lastName == '' or len(lastName) > 100):
            return "invalid lastName input!"
        if (address == '' or len(address) > 500):
            return "invalid address input!"
        if (birthDate == ''):
            return "invalid birthDate input!"

            
        try:
            date_format = '%Y-%m-%d'
            # formatting the date using strptime() function
            dateObject = datetime.datetime.strptime(birthDate, date_format)
            print(dateObject)
            # If the date validation goes wrong
        except:
            return "INVALID BIRTHDATE input!"


        query1 = "SELECT username FROM restaurant_owners"
        cur.execute(query1)
        for item1 in cur:
            if userName == item1[0]:
                return 'USERNAME already existed!'


        cur.callproc('add_owner', [userName, firstName, lastName, address, birthDate])
        mysql.connection.commit()
        cur.close()
        return ("Add: Succesfully Added!")
    return render_template('add_owner.html')