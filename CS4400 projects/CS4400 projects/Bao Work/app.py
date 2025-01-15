from flask import Flask, render_template, request
from flask_mysqldb import MySQL
from back_end.display_views import displayOwner, displayPilot, displayLocation, displayEmployee, displayIngredient, displayService
from back_end.ingredient_management import addIngredient
from back_end.service_management import addService
from back_end.add_employee import add_employee
from back_end.add_restaurant import add_restaurant
app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '4400phase4'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)

# ROUTE FOR MAIN PAGE
@app.route('/', methods=['GET', 'POST'])
def main(): 
    return render_template('main_page.html')


# ROUTE FOR DISPLAY OWNER
@app.route('/view-owner/', methods=['GET'])
def be_displayOwner():
    return displayOwner()


# ROUTE FOR DISPLAY EMPLOYEE
@app.route('/view-employee/', methods=['GET'])
def be_displayEmployee():
    return displayEmployee()


# ROUTE FOR DISPLAY PILOT
@app.route('/view-pilot/', methods=['GET'])
def be_displayPilot(): 
    return displayPilot()


# ROUTE FOR DISPLAY LOCATION
@app.route('/view-location/', methods=['GET'])
def be_displayLocation(): 
    return displayLocation()


# ROUTE FOR DISPLAY INGREDIENT
@app.route('/view-ingredient/', methods=['GET'])
def be_displayIngredient(): 
    return displayIngredient()


# ROUTE FOR DISPLAY SERVICE
@app.route('/view-service/', methods=['GET'])
def be_displayService(): 
    return displayService()


# ROUTE FOR DISPLAY INGREDIENT MANAGEMENT 
@app.route('/ingredient-management/', methods=['GET'])
def be_ingredient_management():
    return render_template('ingredient_main_page.html')


# ROUTE FOR ADD INGREDIENT 
@app.route('/add-ingredient/', methods=['GET', 'POST'])
def be_add_ingredient():
    return addIngredient()



# ROUTE FOR DISPLAY SERVICE MANAGEMENT 
@app.route('/service-management/', methods=['GET'])
def be_service_management():
    return render_template('service_main_page.html')



# ROUTE FOR ADD SERVICE
@app.route('/add-service/', methods=['GET', 'POST'])
def be_add_service():
    return addService()


# ROUTE FOR DISPLAY USER MANAGEMENT 
@app.route('/user-management/', methods=['GET'])
def be_user_management():
    return render_template('user_main_page.html')      


# ROUTE FOR ADD EMPLOYEE
@app.route('/add-employee/', methods=['GET', 'POST'])
def be_add_employee():
    return add_employee()



# ROUTE FOR DISPLAY ADD RESTAURANT
@app.route('/add-restaurant/', methods=['GET', 'POST'])
def be_add_restaurant():
    return add_restaurant()

if __name__ == '__main__':
    app.debug = True
    app.run()