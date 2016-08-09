
from flask import Flask
from flask import render_template_string
from werkzeug.contrib.fixers import ProxyFix
import os, sys, subprocess, tempfile

def write_py(code):
    temp = tempfile.NamedTemporaryFile().name+'.py'
    f = open(temp, 'w')
    f.write(code)
    f.flush()
    f.close()
    print('Code wrote to: %s' % temp)
    return temp
def decode(s):
    try:
        return s.decode('utf-8')
    except UnicodeDecodeError:
        return s.decode('gbk')

app = Flask(__name__)
@app.route('/')
def index():
    return "Hi."
@app.route('/py')
def py():
    return '<html><head><title>Learning Python</title></head><body><form method="post" action="/run"><textarea name="code" style="width:90%;height: 600px"></textarea><p><button type="submit">Run</button></p></form></body></html>'
@app.route('/env')
def env():
    L = [b'<html><head><title>ENV</title></head><body>']
    for k, v in environ.items():
        p = '<p>%s = %s' % (k, str(v))
        L.append(p.encode('utf-8'))
    L.append(b'</html>')
    return L
@app.route('/run', methods=['POST'])
def run():
    code = request.form['code']
    fpath = '';
    ret = 'Execute done.\n';
    try:
        fpath = write_py(code)
        ret += decode(subprocess.check_output([sys.executable, fpath], stderr=subprocess.STDOUT))
    except subprocess.CalledProcessError as e:
        ret += 'Error: CalledProcessError\n' + decode(e.output)
    finally:
        os.remove(fpath)
    return ret;


app.wsgi_app = ProxyFix(app.wsgi_app)
if __name__ == '__main__':
    app.run()
