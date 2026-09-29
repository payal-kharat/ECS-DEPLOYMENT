import os
from flask import Flask
import mysql.connector


class DBManager:
    def __init__(
        self,
        database=os.getenv("DB_NAME", "example"),
        host=os.getenv("DB_HOST", "db"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD")
    ):
        self.connection = mysql.connector.connect(
            user=user,
            password=password,
            host=host,
            database=database,
            port=int(os.getenv("DB_PORT", "3306")),
            auth_plugin='mysql_native_password'
        )
        self.cursor = self.connection.cursor()
    
    def populate_db(self):
        self.cursor.execute('DROP TABLE IF EXISTS blog')
        self.cursor.execute('CREATE TABLE blog (id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255))')
        self.cursor.executemany('INSERT INTO blog (id, title) VALUES (%s, %s);', [(i, 'Blog post #%d'% i) for i in range (1,5)])
        self.connection.commit()
    
    def query_titles(self):
        self.cursor.execute('SELECT title FROM blog')
        rec = []
        for c in self.cursor:
            rec.append(c[0])
        return rec


server = Flask(__name__)
conn = None
@server.route('/health')
def health():
    return "OK", 200
@server.route('/')
def listBlog():
    global conn
    if not conn:
        conn = DBManager(password_file='/run/secrets/db-password')
        conn.populate_db()
    rec = conn.query_titles()

    response = ''
    for c in rec:
        response = response  + '<div>   Hello  ' + c + '</div>'
    return response


if __name__ == '__main__':
    server.run()
