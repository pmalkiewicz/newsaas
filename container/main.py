import subprocess
import os
from datetime import datetime

from flask import Flask, request
app = Flask(__name__)

def ebook_convert(recipe, filename):
    args = ["/usr/bin/ebook-convert",f"{recipe}.recipe", filename]

    return subprocess.run(args)

def ebook_send(recipe, filename, emails):
    username = os.environ["USERNAME"]
    password = os.environ["PASSWORD"]
    server = os.environ["SERVER"]
    port = os.environ["SMTP_PORT"]
    
    ret = []

    for email in emails:
        args = ["/usr/bin/calibre-smtp", "-v", f"--attachment={filename}", f"--subject={recipe}", 
                f"--username={username}", f"--password={password}", f"--relay={server}", f"--port={port}", 
                "--encryption-method=TLS", username, email, ""]
        ret.append(subprocess.run(args))

    return ret

@app.route('/status')
def healthcheck():
    return 'OK'

@app.route('/run', methods=['POST'])
def run():
    recipe = request.values.get('recipe')
    filename = recipe + '-' + datetime.today().strftime('%Y-%m-%d') + '.mobi'
    emails = request.values.getlist('email')

    print(f"Creating ebook from recipe {recipe} and sending it to {emails}")

    ret_convert = ebook_convert(recipe, filename)
    ret_send = ebook_send(recipe, filename, emails)
    
    ret = ''
    if (ret_convert.returncode == 0 and all(code == 0 for code in [el.returncode for el in ret_send])):
        ret = 'OK'
    else:
        ret = 'Error'
    return ret
