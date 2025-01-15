from flask import Flask, render_template,request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Password'
app.config['MYSQL_DB'] = 'figure_database'
 
mysql = MySQL(app)


def create_new_figure():
    if request.method == "POST":
        details = request.form
        cur = mysql.connection.cursor()

        ## Assigning Values
        figure_id = details['ip_figure_id']
        Details = details['ip_Details']
        Price = details['ip_Price']
        Quantity = details['ip_Quantity']

        ## Edge case checking
        if figure_id == '' or len(figure_id) > 4:
            return 'Invalid ID input!'
        try: 
            price = int(price)
        except: 
            return 'Invalid Price Input!'
        try: 
            Quantity = int(Quantity)
        except: 
            return 'Invalid Quantity Input!'
        
        if int(quantity) < 1:
            return 'Invalid Quantity Input!'

        # Check for unique ID
        query1 = "SELECT figure_id FROM figure_general"
        cur.execute(query1)
        for item1 in cur:
            if figure_id == item1[0]:
                return 'Figure_ID is already taken!'


        ## Passing the parameters to the procedures
        cur.callproc('create_new_figure', [figure_id, Details, Price, Quantity])
        mysql.connection.commit()
        cur.close()
        return "Figure Created Successfully!"
    return render_template('Create_New_Figure.html')