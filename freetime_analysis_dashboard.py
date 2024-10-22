# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col, avg as avg_, udf
import pandas as pd
import plotly.graph_objects as go

# GLOBAL VARIABLES
color_mapping = {
    "TV and Video": 'MidnightBlue',
    "Socializing": 'SteelBlue',
    "Other Free Time Activities": 'CornflowerBlue',
    "Hobbies and Games": 'DodgerBlue',
    "Sport": 'DarkSkyBlue',
    "Reading": 'LightSkyBlue',
    "Volunteer Work and Help": 'AliceBlue'
}

# HELPER FUNCTIONS
# Return subset of table based on country, sex, and year
def get_subset(full_df, country, sex, year, total=False):
    filtered_df = full_df.filter(
        (col('Country Name') == country) &
        (col('Sex Name') == sex) &
        (col('"Date"') == f"{str(year)}-01-01")
    )
    if total:
        return filtered_df.filter((col('Activity Name') == 'Total Free Time Activities'))
    else:
        return filtered_df.filter((col('Activity Name') != 'Total Free Time Activities'))

# Get list of available years for a particular country
def get_available_years(full_df, country):
    filtered_df = full_df.filter(col('"Country Name"') == country).drop_duplicates('"Date"')
    return [int(d.year) for d in filtered_df.to_pandas()["Date"].tolist()]

# Draw pie chart describing free time breakup for a particular identity group
def draw_subset_pie_graph(full_df, country, sex, year):
    # ADD HEADER LINE
    st.write(f"Free time breakup of {country} {sex} ({year})")
    sp_subset_df = get_subset(full_df, country, sex, year)
    pd_subset_df = sp_subset_df.to_pandas()
    plotly_pie_chart = draw_plotly_pie_chart(pd_subset_df, "Activity Name", "Hours", color_mapping)
    return plotly_pie_chart

def draw_plotly_pie_chart(df, label_col, value_col, color_map):
    value_list = df[value_col].values.tolist()
    label_list = df[label_col].values.tolist()
    fig = go.Figure(data=[go.Pie(labels=label_list, values=value_list, marker=dict(colors=df[label_col].map(color_map)))])
    return fig

### SETUP ###
# Get the current credentials
session = get_active_session()

# Pull original dataframe from Snowflake
full_df = session.table("ARTS_MEDIA_AND_ENTERTAINMENT_DATA_ATLAS.ARTS_MEDIA_ENTERTAINMENT.UNECE_GELB_FREETIMEUSE").rename(col('"Value"'), '"Hours"')

# Pull our modified table from Snowflake
corr_df = session.table("SUMMIT_HOL.PUBLIC.COUNTRY_FREETIME_VALUES").filter(col("Sex Name") != "Both sexes")
pd_corr_df = corr_df.to_pandas()
pd_corr_df["Year"] = pd_corr_df["Date"].apply(lambda d: d.year)

# Create table to enable proportional comparison in the "Country Comparison" tab
snow_df_totals = full_df.filter((col('Activity Name') == "Total Free Time Activities") & (col('Sex Name') == 'Both sexes'))
snow_df_avgd_totals = snow_df_totals.group_by('Country Name').agg(avg_(col('"Hours"')).alias('Total')).sort(col('Total'))
pd_df_avgd_totals = snow_df_avgd_totals.to_pandas()

# Create table for sex comparison
snow_df_sex_comp = full_df.filter((col('Sex Name') != "Both sexes")) \
    .group_by('Sex Name', "Country Name", "Activity Name") \
    .agg(avg_(col('"Hours"')).alias("country avg")) \
    .group_by('Sex Name', "Activity Name") \
    .agg(avg_(col('country avg')).alias("Average hours spent on activity (daily)")) \
    .sort(col("Average hours spent on activity (daily)"))

# Prepare totals for proportions
totals = {r[0]: r[2] for r in snow_df_sex_comp.filter(col("Activity Name") == "Total Free Time Activities").collect()}

@udf
def prop_udf(avg: float, sex: str) -> float:
    return avg / totals[sex]

# Add proportions to the sex comparison dataframe
snow_df_sex_comp = snow_df_sex_comp.with_column("Proportion of total free time",
                                                 prop_udf(snow_df_sex_comp["Average hours spent on activity (daily)"], 
                                                          snow_df_sex_comp["Sex Name"]))

# Create table for average activity distribution
filtered_df = full_df.filter((col('Activity Name') != 'Total Free Time Activities') & (col('Sex Name') == 'Both sexes'))
filtered_df = filtered_df.to_pandas()
sorted_df = filtered_df.sort_values(by=['Country Name', 'Activity Name', 'Date'], ascending=[True, True, False])
final_df = sorted_df.drop_duplicates(subset=['Country Name', 'Activity Name'], keep='first')
avg_dist_df = final_df.groupby('Activity Name')['Hours'].mean().reset_index()

# Make lists for use in dropdown menus
activity_names = [
    "Total Free Time Activities", 
    "TV and Video", 
    "Sport", 
    "Reading", 
    "Socializing",
    "Hobbies and Games", 
    "Volunteer Work and Help", 
    "Other Free Time Activities"
]
country_names = sorted(full_df.drop_duplicates("Country Name").to_pandas()["Country Name"].to_list())
sex_names = sorted(full_df.drop_duplicates("Sex Name").to_pandas()["Sex Name"].to_list())

# Create sample rows for info tab
sample_data = pd.DataFrame([
    {"Country Name": "Albania", "Activity Name": "TV and Video", "Sex Name": "Both Sexes", "Date": "2010-01-01", "Value": 1.71},
    {"Country Name": "United States", "Activity Name": "Sport", "Sex Name": "Female", "Date": "2014-01-01", "Value": 0.2},
    {"Country Name": "Greece", "Activity Name": "Total Free Time Activities", "Sex Name": "Male", "Date": "2013-01-01", "Value": 6.27}
])
