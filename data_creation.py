# %%
import pandas as pd
from dotenv import load_dotenv, find_dotenv
import os
from sqlalchemy import create_engine
# %%
question_df = pd.DataFrame({"question": ["What is your favourite food?",
                           "What makes you happy?",
                           "Why do you get up in the morning?",
                           "How can you live with yourself?",
                           "What is the best flavour of ice cream?"],
              "question_importance": [1, 10, 7, 9, 2],
              "question_type": ["happy", "existential", "existential", "existential", "happy"]}).reset_index()
question_df
# %%
# question_df.to_csv("data/questions.csv")
# %%
_ = load_dotenv(find_dotenv())

connection_string = os.getenv("POSTGRESQL_ADDON_URI")
# %%
sql_engine = create_engine(connection_string)
# %%
table_name = "questions_db"
# %%
question_df.to_sql(name=table_name,
    con=sql_engine,
    if_exists="append")
# %%
