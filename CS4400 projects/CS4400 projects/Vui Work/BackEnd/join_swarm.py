from flask import Flask, render_template,request
from flask_mysqldb import MySQL

app = Flask(__name__)
 
 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Mrokey123@'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
 
mysql = MySQL(app)


def join_swarm():
    if request.method == "POST":
        details = request.form
        id = details['ip_id']
        tag = details['ip_tag']
        swarm_leader_tag = details['ip_swarm_leader_tag']

        cur = mysql.connection.cursor()

        if id == '' or len(id) > 40:
            return 'Invalid ID Input!'
        try: 
            tag = int(tag)
        except: 
            return 'Invalid Tag Input!'
        try: 
            swarm_leader_tag = int(swarm_leader_tag)
        except: 
            return 'Invalid Swarm Leader Tag Input!'


        cur.execute("SELECT swarm_tag FROM drones WHERE tag = '%s' and id = '%s' "%(tag, id))
        for item6 in cur:
            if item6[0] == swarm_leader_tag:
                return 'The swarm leader is has to be different drone!'
        
        cur.execute('SELECT id FROM delivery_services')
        flag = False
        for item in cur: 
            if (item[0] == id):
                flag = True
                break
        if (flag == False):
            return 'ID Does Not Exist!'

        cur.execute("SELECT tag FROM drones WHERE tag = '%s' and id = '%s' "%(tag, id))
        flag = cur.fetchall()
        if len(flag) != 1:
            return 'Tag does not exist!'

        cur.execute("SELECT tag FROM drones WHERE tag = '%s' and id = '%s' "%(swarm_leader_tag, id))
        flag = cur.fetchall()
        if len(flag) != 1:
            return 'Swarm Leader Tag does not exist!'

        #ERROR HEREEEEE
        cur.execute("SELECT flown_by FROM drones WHERE tag = '%s' and id = '%s' "%(tag, id))
        flag1 = cur.fetchall()
        if None in flag1:
            return "This drone is not currently controlled by a pilot"
        

        cur.execute('SELECT swarm_id, swarm_tag FROM drones')
        flag2 = False
        for item1 in cur:
            if item1[0] == id and item1[1] == tag:
                flag2 = True
                break
        if (flag2 == True):
            return 'Drone is currently leading swarms'

        cur.execute("SELECT flown_by FROM drones WHERE tag = '%s' and id = '%s' "%(swarm_leader_tag, id))
        flag3 = False
        if flag3 == None:
            return 'the swarm leader drone is not directly controlled!'


        cur.execute("SELECT hover FROM drones WHERE tag = '%s' and id = '%s' "%(tag, id))
        droneLoc = cur.fetchall()
        cur.execute("SELECT hover FROM drones WHERE tag = '%s' and id = '%s' "%(swarm_leader_tag, id))
        swarmLoc = cur.fetchall()
        if droneLoc != swarmLoc:
            return 'two drones are not at the same location!'

    

        cur.callproc('join_swarm', [id, tag, swarm_leader_tag])
        mysql.connection.commit()
        cur.close()
        return 'Successfully Updated!'
    return render_template('join_swarm.html')