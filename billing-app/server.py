import os
from sqlalchemy import create_engine
from app.consume_queue import consume_and_store_order
from app.orders import Base

if __name__ == "__main__":
    BILLING_DB_USER = os.getenv("BILLING_DB_USER", "default_user")
    BILLING_DB_PASSWORD = os.getenv("BILLING_DB_PASSWORD", "default_password")
    BILLING_DB_NAME = os.getenv("BILLING_DB_NAME", "billing_db")
    BILLING_DB_HOST = os.getenv("BILLING_DB_HOST", "localhost")
    BILLING_DB_PORT = os.getenv("BILLING_DB_PORT", "5432")

    DB_URI = f"postgresql://{BILLING_DB_USER}:{BILLING_DB_PASSWORD}@{BILLING_DB_HOST}:{BILLING_DB_PORT}/{BILLING_DB_NAME}"

    engine = create_engine(DB_URI)
    Base.metadata.create_all(engine)

    consume_and_store_order(engine)
