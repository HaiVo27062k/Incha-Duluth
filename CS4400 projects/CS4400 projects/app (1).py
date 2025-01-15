from flask import Flask, render_template, request
from flask_mysqldb import MySQL
app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)
 
 
@app.route('/', methods=['GET', 'POST'])
def main(): 
    return render_template('main_page.html')


@app.route('/add-owner/', methods=['GET', 'POST'])
def addOwner():
    if request.method == "POST":
        details = request.form
        userName = details['ip_username']
        firstName = details['ip_first_name']
        lastName = details['ip_last_name']
        address = details['ip_address']
        birthDate = details['ip_birthdate']
        cur = mysql.connection.cursor()
        cur.callproc('add_owner', [userName, firstName, lastName, address, birthDate])
        mysql.connection.commit()
        cur.close()
        return 'successfully added a new owner'
    return render_template('add_owner.html')

@app.route('/view-owner/', methods=['GET'])
def displayOwner():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM display_owner_view')
        data = cur.fetchall()
        mysql.connection.commit()
        cur.close()
        return render_template('view_owner.html', data=data)
        
 

if __name__ == '__main__':
    app.debug = True
    app.run()