from flask import Flask, Response, make_response
from pymongo import MongoClient
import json

mongodb_url = "mongodb+srv://admin:admin@vroumscluster.geh4g.mongodb.net/VroumsCluster?retryWrites=true&w=majority"

app = Flask(__name__)
app.config["DEBUG"] = True

client = MongoClient(mongodb_url)
database = client.VroumsDatabase


@app.route('/404')
def page_non_trouvee():
    reponse = make_response("Cette page devrait vous avoir renvoyé une erreur 404")
    reponse.status_code = 404
    return reponse


@app.route('/highways', methods=['GET'])
def get_highways():
    highways_collection = database.highways
    highways_cursor = highways_collection.find({}, {'_id': False})

    highways = list(highways_cursor)
    data_as_str = json.dumps(highways)

    return Response(response=data_as_str, mimetype="application/json")


if __name__ == '__main__':
    app.run()
