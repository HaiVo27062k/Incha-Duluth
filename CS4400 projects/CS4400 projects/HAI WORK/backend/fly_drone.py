from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import math 

app = Flask(__name__) 
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Phamtram61020!'
app.config['MYSQL_DB'] = 'restaurant_supply_express'
mysql = MySQL(app) 

def fly_drone():
    if request.method == "POST":
        details = request.form

        validId = False
        validTag =  False
        validDestination = False
        sameLocation = True

        destination = details['ip_destination']
        be_id = details['ip_id']
        be_tag = details['ip_tag']
        cur = mysql.connection.cursor()

        if (be_id == "" or len(be_id) > 5):
            return "INVALID id input!"

        if (be_tag == "" or len(be_tag) > 4):
            return "INVALID tag input!"

        if (destination == "" or len(destination) > 40):
            return "INVALID destination input!"

        try:
            be_tag = int(be_tag)
        except:
            return "INVALID tag input!"

        ## CHECKING THE ID
        query1 = "SELECT id FROM delivery_services"
        cur.execute(query1)
        for item1 in cur:
            if (be_id == item1[0]):
                validId = True
                break
        if (validId == False):
            return "The ID is not in the service"

        ## CHECKING THE TAG
        query2 = "SELECT tag FROM drones"
        cur.execute(query2)
        for item2 in cur:
            if (be_tag == item2[0]):
                validTag = True
                break
        if (validTag == False):
            return "The Tag is not in the DRONES table!"

        ## CHECKING THE destination validity
        query3 = "SELECT label FROM locations"
        cur.execute(query3)
        for item3 in cur:
            if (destination == item3[0]):
                validDestination = True
                break
        if (validDestination == False):
            return "The DESTINATION does not exist"

         ## CHECKING MATCHIG ID & TAG
        query7 = "SELECT swarm_id, swarm_tag FROM drones where id = '%s' and tag = '%s'" %(be_id, be_tag)
        cur.execute(query7)
        isMatch = cur.fetchone()
        if  isMatch is None:
            return "Can NOT find the ID & TAG combination"

        ## Checking if being flown_by
        query5 = "SELECT drones.flown_by FROM drones where drones.id = '%s' and drones.tag = '%s' " %(be_id, be_tag)
        cur.execute(query5)
        flag = cur.fetchone()
        if  all(flag) == False:
            return "The drone is currently NOT being CONTROLLED"

        ## Checking to see if the destination is the same location as hover
        query4 = "SELECT hover FROM drones where id = '%s' and tag = '%s' and hover = '%s' " %(be_id, be_tag, destination)
        cur.execute(query4)
        isSame = cur.fetchone() 
        if  isSame == None:
            sameLocation = False
        if (sameLocation == True):
            return "The drone is currently at the SAME location, which is %s" %(isSame)
        

        ## CHECKING NOT IN SWARM
        query6 = "SELECT swarm_id, swarm_tag FROM drones where id = '%s' and tag = '%s'" %(be_id, be_tag)
        cur.execute(query6)
        isInSwarm = cur.fetchone()
        if  all(isInSwarm) == True:
            return "The drone is currently IN SWARM!!"

        cur.execute("SELECT hover FROM drones where id = '%s' and tag = '%s' " %(be_id, be_tag))
        currentLocation = cur.fetchone()

        cur.execute("SELECT hover FROM drones where id = '%s' and tag = '%s' " %(be_id, be_tag))
        home_base = cur.fetchone()

        
        cur.execute("SELECT fuel FROM drones where id = '%s' and tag = '%s'" %(be_id, be_tag))
        fuel = cur.fetchone()[0]

        ## DEPARTURE
        cur.execute("SELECT x_coord FROM locations where label = '%s' " %(currentLocation))
        x_cord1 = cur.fetchone()[0]
        cur.execute("SELECT y_coord FROM locations where label = '%s' " %(currentLocation))
        y_cord1 = cur.fetchone()[0]

        ## ARRIVAL
        cur.execute("SELECT x_coord FROM locations where label = '%s' " %(destination))
        x_cord2 = cur.fetchone()[0]
        cur.execute("SELECT y_coord FROM locations where label = '%s' " %(destination))
        y_cord2 = cur.fetchone()[0]
        fuelReq1 = math.trunc(math.sqrt( ((x_cord1 - x_cord2)*((x_cord1 - x_cord2))) + ( (y_cord1 - y_cord2)*((y_cord1 - y_cord2))))) + 1


        ## HOME BASE
        cur.execute("SELECT x_coord FROM locations where label = '%s' " %(home_base))
        x_cord3 = cur.fetchone()[0]
        cur.execute("SELECT y_coord FROM locations where label = '%s' " %(home_base))
        y_cord3 = cur.fetchone()[0]
        fuelReq2 = math.trunc(math.sqrt( ((x_cord2 - x_cord3)*((x_cord2 - x_cord3))) + ( (y_cord2 - y_cord3)*((y_cord2 - y_cord3))))) + 1

        ## CALCULATING
        if((fuelReq1 + fuelReq2) > fuel):
            return "The DRONE does NOT have enough FUEL!! as fuelReq1 = %s , fuelReq2 = %s and current fuel = %s " %(fuelReq1, fuelReq2,fuel)

        cur.execute("select count(hover) from drones where hover = '%s' " %(destination))
        count_drone = cur.fetchone()[0] + 1

        cur.execute("select space from locations where label = '%s' " %(destination))
        spaceAvailable = cur.fetchone()[0]

        if (spaceAvailable < count_drone):
            return "Not enough space at the home base!! as count_drone = %s and space_available = %s " %(count_drone, spaceAvailable)

        cur.callproc('fly_drone', [be_id,be_tag,destination])
        mysql.connection.commit()
        cur.close()
        return "Fly: fly successfully"

    return render_template('fly_drone.html')