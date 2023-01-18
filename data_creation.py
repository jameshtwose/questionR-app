# %%
import pandas as pd
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
question_df.to_csv("data/questions.csv")
# %%
