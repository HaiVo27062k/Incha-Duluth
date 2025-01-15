from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import datetime

app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 


##### INTERNAL SERVER ERROR
def add_employee():
    if request.method == "POST":

        cur = mysql.connection.cursor()
        details = request.form
        userName = details['ip_username']
        firstName = details['ip_first_name']
        lastName = details['ip_last_name']
        address = details['ip_address']
        birthDate = details['ip_birthdate']
        taxID = details['ip_taxID']
        hired = details['ip_hired']
        employee_experience = details['ip_employee_experience']
        salary = details['ip_salary']

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

        if (taxID == '' or len(taxID) > 100):
            return "invalid taxID input!"
        if (hired == ''):
            return "invalid hired input!"
        if (employee_experience == '' or len(employee_experience) > 100 or int(employee_experience) < 0):
            return "invalid employee_experience input!"
        if (salary == '' or len(salary) > 100):
            return "invalid salary input!"


        try: 
            employee_experience = int(employee_experience)
        except: 
            return 'invalid employee_experience input!'

        try: 
            salary = int(salary)
        except: 
            return 'invalid salary input!'

        try:
            date_format = '%Y-%m-%d'
            # formatting the date using strptime() function
            dateObject = datetime.datetime.strptime(birthDate, date_format)
            print(dateObject)
            # If the date validation goes wrong
        except:
            return "INVALID BIRTHDATE input!"

        try:
            date_format = '%Y-%m-%d'
            # formatting the date using strptime() function
            dateObject = datetime.datetime.strptime(hired, date_format)
            print(dateObject)
            # If the date validation goes wrong
        except:
            return "INVALID HIRED input!"
        
        query1 = "SELECT username FROM employees"
        cur.execute(query1)
        for item1 in cur:
            if userName == item1[0]:
                return 'USERNAME already existed!'

        query2 = "SELECT taxID FROM employees"
        cur.execute(query2)
        for item2 in cur:
            if taxID == item2[0]:
                return 'taxID already existed!'

        cur.callproc('add_employee', [userName, firstName, lastName, address, birthDate, taxID, hired, employee_experience, salary])
        mysql.connection.commit()
        cur.close()
        return ("Add: Succesfully Added!")
    return render_template('add_employee.html')