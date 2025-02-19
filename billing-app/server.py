import os
from sqlalchemy import create_engine
from app.consume_queue import consume_and_store_order
from app.orders import Base

if __name__ == "__main__":
    # 1) Read environment variables
		db_host = os.getenv("DB_HOST")
		db_port = os.getenv("DB_PORT")
		db_user = os.getenv("DB_USER")
		db_password = os.getenv("DB_PASS")
		db_name = os.getenv("DB_NAME")


    # 2) Construct the DB URI with the Docker service name, not localhost
    DB_URI = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

    # 3) Create the engine
    engine = create_engine(DB_URI)

    # 4) Create tables, consume queue, etc.
    Base.metadata.create_all(engine)
    consume_and_store_order(engine)
