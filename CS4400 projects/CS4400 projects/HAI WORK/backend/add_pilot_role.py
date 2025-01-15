from flask import Flask, render_template, request
from flask_mysqldb import MySQL


app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 

def add_pilot_role():
    if request.method == "POST":
        details = request.form

        userName = details['ip_username']
        licenseID = details['ip_licenseID']
        pilot_experience = details['ip_pilot_experience']
        cur = mysql.connection.cursor()

        if (userName == "" or len(userName) > 40):
            return "INVALID userName input!"
        if (len(licenseID) != 6):
            return "INVALID licenseID input!"

        if (pilot_experience == "" or int(pilot_experience) < 1):
            return "INVALID pilot experiene input!"
        
        try:
            licenseID = int(licenseID)
        except: 
            return 'invalid licenseID input!'
        try: 
            pilot_experience = int(pilot_experience)
        except: 
            return 'invalid pilot_experience input!'


        query1 = "SELECT username FROM pilots"
        cur.execute(query1)
        for item1 in cur:
            if userName == item1[0]:
                return 'USERNAME already existed in Pilots!'

        query2 = "SELECT licenseID FROM pilots"
        cur.execute(query2)
        for item2 in cur:
            if int(licenseID) == int(item2[0]):
                return 'LicenseID already existed!'
        
        query3 = "SELECT username FROM employees"
        cur.execute(query3)
        for item3 in cur:
            if (userName == item3[0]):
                cur.callproc('add_pilot_role', [userName,licenseID,pilot_experience])
                mysql.connection.commit()
                cur.close()
                return ("Add: Succesfully Added!")
        
        return "USERNAME is NOT in EMPLOYEES!"

    return render_template('add_pilot_role.html')