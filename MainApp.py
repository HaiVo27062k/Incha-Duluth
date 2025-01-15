from flask import Flask, render_template, request, redirect, render_template_string
from flask_mysqldb import MySQL
app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root'
app.config['MYSQL_DB'] = 'figure_database'
 
mysql = MySQL(app)
 
 
@app.route('/', methods=['GET', 'POST'])
def main(): 
    return render_template('Main_Page.html')

@app.route("/Create_New_Figure/success")
def Create_New_Figure_success():
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Success!</title>
        <script>
            setTimeout(() => {
                window.location.href = "{{ url_for('Create_New_Figure') }}";
            }, 2000); // Redirect after 2 seconds
        </script>
    </head>
    <body>
        <h1>Successfully added a new figure</h1>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/Create_New_Figure/', methods=['GET', 'POST'])
def Create_New_Figure():
    if request.method == "POST":
        details = request.form
        figure_id = details['ip_figure_id']
        Details = details['ip_Details']
        Price = details['ip_Price']
        Quantity = details['ip_Quantity']
        Quantity_Sold = details['ip_Quantity_Sold']
        cur = mysql.connection.cursor()
        cur.callproc('create_new_figure', [figure_id, Details, Price, Quantity, 0])
        mysql.connection.commit()
        cur.close()
        return redirect('/Create_New_Figure/success')
    return render_template('Create_New_Figure.html')

@app.route("/Sell_Figure/success")
def Sell_Figure_success():
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Success!</title>
        <script>
            setTimeout(() => {
                window.location.href = "{{ url_for('Sell_Figure') }}";
            }, 2000); // Redirect after 2 seconds
        </script>
    </head>
    <body>
        <h1>Successfully sold figures</h1>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/Sell_Figure/', methods=['GET', 'POST'])
def Sell_Figure():
    if request.method == "POST":
        details = request.form
        figure_id = details['sl_figure_id']
        Quantity = details['sl_Quantity']
        cur = mysql.connection.cursor()
        cur.callproc('sell_figure', [figure_id, Quantity])
        mysql.connection.commit()
        cur.close()
        return redirect('/Sell_Figure/success')
    return render_template('Sell_Figure.html')

@app.route('/Show_Figure/', methods=['GET'])
def Show_Figure():
    if request.method == "GET":
        cur = mysql.connection.cursor()
        cur.execute('SELECT * FROM figure_database.figure_general')
        data1 = cur.fetchall()
        mysql.connection.commit()

        cur.execute('SELECT * FROM figure_database.figure_accounting')
        data2 = cur.fetchall()
        mysql.connection.commit()
        cur.close()

        return render_template('Show_Figure.html', data=[data1, data2])

@app.route("/Restock_Figure/success")
def Restock_Figure_success():
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Success!</title>
        <script>
            setTimeout(() => {
                window.location.href = "{{ url_for('Restock_Figure') }}";
            }, 2000); // Redirect after 2 seconds
        </script>
    </head>
    <body>
        <h1>Successfully update figure quantity</h1>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/Restock_Figure/', methods=['POST', 'GET'])
def Restock_Figure():
    if request.method == "POST":
        details = request.form
        figure_id = details['sl_figure_id']
        Quantity = details['sl_Quantity']

        action = request.form.get('action')
        cur = mysql.connection.cursor()
        cur.callproc('restock_figure', [figure_id, Quantity, action])
        mysql.connection.commit()
        cur.close()
        return redirect('/Restock_Figure/success')
    return render_template('Restock_Figure.html')
        
 
if __name__ == '__main__':
    app.debug = True
    app.run(host = "10.0.0.106")