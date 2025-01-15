from flask import Flask, render_template, request
from flask_mysqldb import MySQL


app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 

def hire_employee():
    if request.method == "POST":
        details = request.form
        inEmployee = False
        deliveryExist = False

        be_userName = details['ip_username']
        be_id = details['ip_id']
        cur = mysql.connection.cursor()

        if (be_userName == "" or len(be_userName) > 40):
            return "INVALID userName input!"

        if (be_id == "" or len(be_id) > 5):
            return "INVALID id input!"

        query2 = "SELECT manager FROM delivery_services"
        cur.execute(query2)
        for item2 in cur:
            if (be_userName == item2[0]):
                return ("USERNAME is a MANAGER!!")

        query3 = "SELECT flown_by FROM drones"
        cur.execute(query3)
        for item3 in cur:
            if (be_userName == item3[0]):
                return ("USERNAME is currently flying a DRONE!!")

        query1 = "SELECT username, id FROM work_for where username = '%s' and id = '%s' " %(be_userName, be_id)
        cur.execute(query1)
        isMatch = cur.fetchone()
        if isMatch is not None:
            return "THE USER is already in work_for"


        query4 = "SELECT id FROM delivery_services"
        cur.execute(query4)
        for item4 in cur:
            if (be_id == item4[0]):
                deliveryExist = True
                break


        ## PLESAE CHECK ALREADY IN EMPLOYEES
        query5 = "SELECT username FROM employees"
        cur.execute(query5)
        for item5 in cur:
            if (be_userName == item5[0]):
                inEmployee = True
                break

        if(deliveryExist == False):
            return "The service does not EXIST"
        if(inEmployee == False):
            return "Username is NOT in the Employee"
        
        cur.callproc('hire_employee',[be_userName, be_id])
        mysql.connection.commit()
        cur.close()
        return ("HIRE: hire successfully")

    return render_template('hire_employee.html')