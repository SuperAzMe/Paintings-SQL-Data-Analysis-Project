import pandas as pd
from sqlalchemy import create_engine

sql_conn= 'postgresql://postgres:1234@localhost/postgres'
engine = create_engine(sql_conn)
conn = engine.connect()

# df = pd.read_csv(r'C:\Users\Asus\Downloads\Studies\Elite Technocrats\Day 7\archive\artist.csv')
files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size','subject', 'work']
for file in files:
   df = pd.read_csv(f'C:/Users/Asus/Downloads/Studies/Elite Technocrats/Day 7/archive/{file}.csv')
   df.to_sql(file, con=conn, if_exists='replace', index=False)
