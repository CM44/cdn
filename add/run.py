# encoding: utf-8

from flask import Flask
from flask import request
from flask import render_template_string
from werkzeug.contrib.fixers import ProxyFix
import os, sys, subprocess, tempfile, time, signal


def check_output(*popenargs, **kwargs):
    if 'stdout' in kwargs:
        raise ValueError('stdout argument not allowed, it will be overridden.')
    t = 0
    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output = ''
    while (t<30) and (process.poll() is None):
        t +=1
        time.sleep(1)
        output += process.stdout.readline()
    output += process.stdout.read()
    if t==30:
        os.kill(process.pid, signal.SIGKILL)
        os.waitpid(-1, os.WNOHANG)
        output += '\nreturen code: timeout'
        return output
    output += '\nreturen code: ' + str(process.returncode)
    return output

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
    return '<html><head><title>Learning Python</title></head><body><form method="post" action="/py2"><textarea name="code" style="width:90%;height: 600px"></textarea><p><button type="submit">Run</button></p></form></body></html>'

@app.route('/py2', methods=['POST'])
def py2():
    code = request.form['code']
    fpath = ''
    ret = ''
    try:
        fpath = write_py(code)
        ret += decode(check_output([sys.executable, fpath], stderr=subprocess.STDOUT))

    except subprocess.CalledProcessError as e:
        ret += 'Error: CalledProcessError\n' + decode(e.output)
    finally:
        os.remove(fpath)
    return '<PRE>'+ret.replace('\n','<br>')+'</PRE>'


app.wsgi_app = ProxyFix(app.wsgi_app)
if __name__ == '__main__':
    app.run()





