# %%
import pandas as pd
from dotenv import load_dotenv, find_dotenv
import os
from sqlalchemy import create_engine
# %%
# question_df.to_csv("data/questions.csv")

# %%
question_df = (pd.read_csv("data/data_for_votes.csv")
               .reset_index()
               .dropna(subset=["narrative", "narrativeTitle"])
               )

# %%
question_df.shape

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
latest_df = (pd.read_sql_table(table_name, sql_engine)
             .sort_values(by="index")
             .reset_index(drop=True)
             )
# %%
latest_df.to_csv("data/latest_sql.csv")
# %%
latest_df.shape
# %%
latest_df.assign(
    **{"votes": lambda d: d["importance"] - question_df["importance"]})
# %%
tmp_df = question_df.rename(columns={"importance": "importance_old"})[
    ["index", "importance_old"]]
df = (pd.merge(latest_df.rename(columns={"importance": "importance_new"}),
               tmp_df,
               how="outer", on="index").assign(
    **{"votes": lambda d: (d["importance_new"].astype(float) - d["importance_old"].astype(float)).astype(int)})
    .drop(columns=["importance_new"])
    .rename(columns={"importance_old": "importance"})
)
# %%
df[question_df.columns.tolist()+["votes"]].to_sql(name=table_name,
                   con=sql_engine,
                   if_exists="append")
# %%
