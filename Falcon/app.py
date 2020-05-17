import falcon, json
from waitress import serve
from falcon_multipart.middleware import MultipartMiddleware
import cgi
import base64

user_accounts = {'Csacsi': 'mypass'} # Test user/password pairs

class Authorize (object): # 'Before' wrappers. Runs before on_get, on_put, on_post, etc. If raises no exception or HTTP error, then method (on_get, on_put, etc.) runs
    def __init__ (self, roles): # Test roles. Should come from DB
        self.roles = roles

    def auth_basic (self, username, password): # Authenticates user and password
        if username in user_accounts and user_accounts[username] == password:
            print ('You are logged on!')
        else:
            print ('Unauthorized, access denied!')
            raise falcon.HTTPUnauthorized ('Unauthorized', 'Access denied!')

    def __call__ (self, req, resp, resource, params): # 'Before' wrapper must be callable. This function is called for the object
        if 'Admin' in self.roles:
            req.user_id = 5
        else:
            print ('Only the Admin is authorized to execute this!')
            raise falcon.HTTPBadRequest ('Bad request', 'Only Admin can execute this!')
        if req.auth is not None:
            auth_exp = req.auth.split (' ') # Splits into auth type such as 'basic' and the encoded user:password
        else:
            auth_exp = (None, None,)

        if auth_exp[0] is not None and auth_exp[0].lower () == 'basic':
             auth = base64.b64decode(auth_exp[1]).decode ('utf-8').split (':') # Decode user:password
             username = auth[0]
             password = auth[1]
             self.auth_basic (username, password) # Check if both username and password match to any test user/password pairs
        else:
            print ("Wrong authentication method. Should be 'basic'!")
            raise falcon.HTTPNotImplemented ('Not implemented', 'Wrong authentication method!')

class ObjRequestClass: # Resource. Attached to a route (URI)
    json_content = {}
    def validate_json (self, req):  # Checks if payload is a valid JSON or not
        try:
            self.json_content = json.loads (req.stream.read (req.content_length or 0))  # Avoid blocking if no content
            return True
        except ValueError:
            return False ;

    @falcon.before (Authorize (['Admin', 'User', 'Other'])) # Wrapper. Checks authentication before running GET handler
    def on_get (self, req, resp):
        print ("*** GET ***")
        resp.status = falcon.HTTP_200 # Default response status
        content = { # JSON response content
            'name': 'Csacsi',
            'age': '51',
            'country': 'Hun'}
        #resp.body = json.dumps (content)

        # Print some request attributes
        print ('URL: %s', req.url)
        print ('Content type: %s' % req.content_type)
        print ('Query string: %s' % req.query_string)
        print ('Content length: %d' % req.content_length)
        print ('Method: %s' % req.method)
        print ('Host: %s' % req.host)
        print ('Headers: %s' % req.headers)
        print ('Parameters: %s' % req._params)

        output = {}
        if req.headers['CONTENT-TYPE'][:20] == 'multipart/form-data;': # If the payload was form data
            env = req.env
            env.setdefault('QUERY_STRING', '')

            data = req.stream.read (req.content_length or 0) # Reads the form data. Or supposed to do at least
            print ('Data: %s' % data)

            form = cgi.FieldStorage(fp = req.stream, environ = env) # Does not work
            output ['value'] = 'Form handled'

        elif req.headers['CONTENT-TYPE'][:16] == 'application/json': # IF the payload is JSON
            if self.validate_json (req): # Validate the JSON firt
                if 'method' not in self.json_content: # JSON should contain method keyword
                    resp.status = falcon.HTTP_501
                    output ['value'] = 'Error: no method found'
                else:
                    if self.json_content['method'] == 'get-name': # If it is get-name than get the name value from the JSON response content
                        output ['value'] = content['name'] # Constructs response output
                    else:
                        resp.status = falcon.HTTP_404
                        output['value'] = None
            else:
                output['status'] = 404
                output['msg'] = 'JSON input not valid'
        else:
            output['value'] = None

        valid_params = True
        if 'love' not in req.params: # Checks the existence of the URI parameters. The bit that starts with ? and & separates the param/value pairs
            valid_params = False
        if 'home' not in req.params:
            valid_params = False
        if valid_params:
            output['love'] = req.params['love'] # Constructs (adds to) response output
            output['home'] = req.params['home']

        resp.body = json.dumps (output)

    @falcon.before (Authorize (['User', 'Other']))
    def on_post (self, req, resp):
        print ("*** POST ***")
        resp.status = falcon.HTTP_200 # Default response status
        output = {}
        data = json.loads (req.stream.read (req.content_length or 0)) # Avoid blocking if no content
        equal = int (data['x']) + int (data['y']) # From the JSON payload, get the value of x and y and add them together

        output = {'Result:': '{0} + {1} = {2}'.format (data['x'], data['y'], equal)} # Constructs response output
        resp.body = json.dumps (output)

    @falcon.before (Authorize (['User', 'Other']))
    def on_put (self, req, resp):
        print ("*** PUT ***")
        resp.status = falcon.HTTP_200 # Default response status
        
        output = {'Message': 'Not implemented yet'}
        route_path = str (req.path) 
        if route_path.startswith ("/test/v1/"):
            # Logic for /api/v1/
            resp.res.status = falcon.HTTP_200
            res.body = json.dumps({'status': True, 'message': '/test/v1 handled'})
        elif route_path.startswith("/test/v2/"):
            resp.res.status = falcon.HTTP_200
            res.body = json.dumps({'status': True, 'message': '/test/v2 handled'})
        else:
            resp.body = json.dumps (output)

    @falcon.before (Authorize (['Admin', 'User', 'Other']))
    def on_put_getit (self, req, resp, name):
        print ('*** PUT getit ***')
        print ("Name:" + name)
        resp.status = falcon.HTTP_200
        resp.body = json.dumps({'status': True, 'message': '/test/getit handled'})

api = falcon.API (middleware=MultipartMiddleware()) # Instantiates a falcon API object
api.req_options.auto_parse_form_urlencoded = True # No use. Does not work for form parameters
myResource = ObjRequestClass ()
api.add_route ('/test', myResource) # Assigns route to resource (main class). Requirese an instance of that class
api.add_route ('/test/getit/{name}', myResource, suffix='getit') # With a name field

serve (api, listen='*:8080') # Runs the 'waitress' server. It is a python module. WSGI server (Web Server Gateway Interface)
# URI: localhost:8080/test?love=Zsur&home=Leanyfalu Payload: {"method":"get-name", "x": "5", "y": "6"}
# Alternatively: waitress-serve --port=8000 look.app:api

