### FRONT END ###
# Header
header = st.columns([1, 1, 2, 1, 1])
header[0].title(":art:")
header[1].title(":clapper:")
header[2].title("Free Time")
header[3].title(":basketball:")
header[4].title(":video_game:")

with st.expander("**INFO**"):
    st.write('**DATASET:** UNECE Time Spent on Free Time Activities by Sex (*from the Arts, Media, and Entertainment Data Atlas by Knoema*)')
    st.write('**DESCRIPTION:** The *UNECE Time Spent on Free Time Activities by Sex* dataset provides information about how various demographics choose to spend their free time. A demographic is made up of country, sex, and date, and each row in the dataset lists the average number of hours a specific demographic spends on a specific activity. From this data, we can pull insights about the activities that are most popular with people around the world, and how certain demographics differ from one another in how they choose to spend their free time.')

    st.write(
    """
    **RELEVANT VARIABLES**
    - *Country Name:* Country the entry was collected from
    - *Activity Name:* Name of activity for the recorded entry (Total Free Time Activities, TV and Video, Socializing, Reading, Sport, Hobbies and Games, Volunteer Work and Help, Other Free Time Activities)
    - *Sex Name:* Sex of recorded entry (Both sexes, Female, Male)
    - *Date:* Date recorded
    - *Value:* The average number of daily hours that the specified demographic (country, sex, and date) spent on a specific activity
    """
    )

st.write('**EXAMPLE DATA:**')
st.dataframe(sample_data)

tab1, tab2, tab3, tab4, tab5 = st.tabs(["Country Comparison", "Year Comparison", "Demographic Comparison", "Activity Correlation", "Sex Comparison"])

# Bar chart to compare total free time across countries
with tab1:
    st.subheader("The Average Time Spent per Activity Across All Countries :watch:")
    st.write("""Use the dropdown to choose an activity to see the average hours spent a day on each activity across all countries.""")

    # Interactive Elements
    col1, col2 = st.columns([2, 1], gap="medium")
    with col1:
        sel_activity = st.selectbox("Activity:", activity_names, index=0, key=0)
    with col2:
        st.write(" ")
        st.write(" ")
        proportional = st.checkbox("Proportional?", help="If selected, the chart will display times as a proportion of each country's total free time (instead of as hours)")

    # Calculations
    # filter full_df to selected activity and both sexes
    snow_df_filtered = full_df.filter((col('Activity Name') == sel_activity) & (col('Sex Name') == 'Both sexes'))
    # group by country and average values
    snow_df_avgd_times = snow_df_filtered.group_by('Country Name').agg(avg_(col('"Hours"')).alias('Average Time Spent (hours, daily)')).sort(col('Average Time Spent (hours, daily)'))
    # execute query and convert to pandas dataframe
    pd_df_avgd_times = snow_df_avgd_times.to_pandas()

    if proportional:
        prop_df = pd.merge(pd_df_avgd_times, pd_df_avgd_totals, on="Country Name", how="inner")
        prop_df["Proportion of total free time"] = prop_df["Average Time Spent (hours, daily)"] / prop_df["TOTAL"]
        prop_df = prop_df.sort_values("Proportion of total free time")
        altair_bar_chart = alt.Chart(prop_df, height=400).mark_bar().encode(
            x=alt.X('Country Name', sort=None),
            y='Proportion of total free time',
        )
    else:
        altair_bar_chart = alt.Chart(pd_df_avgd_times, height=400).mark_bar().encode(
            x=alt.X('Country Name', sort=None),
            y='Average Time Spent (hours, daily)',
        )

    # Plots/Output
    st.altair_chart(altair_bar_chart)

    with st.expander("**Analysis**"):
        st.write('Overall, the time spent on total free time activities does not vary much across all the countries, ranging from about 4 to 6 hours daily. TV and Video time also does not vary significantly, but other activities differ widely across countries, showing how various demographics spend their free time differently.')

# Line chart to compare activity values over time
with tab2:
    st.subheader("Time Spent on Each Activity by Country and Sex Over Time :chart:")
    st.write("""Use the dropdowns to see how daily time spent on each activity per specified sex and country changes over time.""")

    # Interactive Elements
    col1, col2, col3 = st.columns(3)
    sex = col1.selectbox(label="Sex", options=sex_names)
    country = col2.selectbox(label="Country", options=countries)
    area_or_line = col3.checkbox("Line chart")

    year_df = conn.query(f'SELECT * FROM ARTS_MEDIA_AND_ENTERTAINMENT_DATA_ATLAS.ARTS_MEDIA_ENTERTAINMENT.UNECE_GELB_FREE_TIMEUSE WHERE "Sex Name" = \'{sex}\' AND "Country Name" = \'{country}\' AND "Activity Name" != \'Total Free Time Activities\';', ttl=600)

    if area_or_line:
        chart = alt.Chart(year_df).mark_line(point=True).encode(
            x=alt.X("Date", axis=alt.Axis(title="Date")),
            y=alt.Y("Value", axis=alt.Axis(title="Time Spent Daily (in Hours)")),
            color="Activity Name"
        ).properties(width=850, height=450)
    else:
        chart = alt.Chart(year_df).mark_area().encode(
            x=alt.X("Date", axis=alt.Axis(title="Date")),
            y=alt.Y("Value", axis=alt.Axis(title="Time Spent Daily (in Hours)"), stack="normalize"),
            color="Activity Name"
        ).properties(width=850, height=450)

    st.altair_chart(chart, use_container_width=True)

    ### FRONT END ###
# Header
header = st.columns([1, 1, 2, 1, 1])
header[0].title(":art:")
header[1].title(":clapper:")
header[2].title("Free Time")
header[3].title(":basketball:")
header[4].title(":video_game:")

with st.expander("**INFO**"):
    st.write('**DATASET:** UNECE Time Spent on Free Time Activities by Sex (*from the Arts, Media, and Entertainment Data Atlas by Knoema*)')
    st.write('**DESCRIPTION:** The *UNECE Time Spent on Free Time Activities by Sex* dataset provides information about how various demographics choose to spend their free time. A demographic is made up of country, sex, and date, and each row in the dataset lists the average number of hours a specific demographic spends on a specific activity. From this data, we can pull insights about the activities that are most popular with people around the world, and how certain demographics differ from one another in how they choose to spend their free time.')

    st.write(
    """
    **RELEVANT VARIABLES**
    - *Country Name:* Country the entry was collected from
    - *Activity Name:* Name of activity for the recorded entry (Total Free Time Activities, TV and Video, Socializing, Reading, Sport, Hobbies and Games, Volunteer Work and Help, Other Free Time Activities)
    - *Sex Name:* Sex of recorded entry (Both sexes, Female, Male)
    - *Date:* Date recorded
    - *Value:* The average number of daily hours that the specified demographic (country, sex, and date) spent on a specific activity
    """
    )

st.write('**EXAMPLE DATA:**')
st.dataframe(sample_data)

tab1, tab2, tab3, tab4, tab5 = st.tabs(["Country Comparison", "Year Comparison", "Demographic Comparison", "Activity Correlation", "Sex Comparison"])

# Bar chart to compare total free time across countries
with tab1:
    st.subheader("The Average Time Spent per Activity Across All Countries :watch:")
    st.write("""Use the dropdown to choose an activity to see the average hours spent a day on each activity across all countries.""")

    # Interactive Elements
    col1, col2 = st.columns([2, 1], gap="medium")
    with col1:
        sel_activity = st.selectbox("Activity:", activity_names, index=0, key=0)
    with col2:
        st.write(" ")
        st.write(" ")
        proportional = st.checkbox("Proportional?", help="If selected, the chart will display times as a proportion of each country's total free time (instead of as hours)")

    # Calculations
    # filter full_df to selected activity and both sexes
    snow_df_filtered = full_df.filter((col('Activity Name') == sel_activity) & (col('Sex Name') == 'Both sexes'))
    # group by country and average values
    snow_df_avgd_times = snow_df_filtered.group_by('Country Name').agg(avg_(col('"Hours"')).alias('Average Time Spent (hours, daily)')).sort(col('Average Time Spent (hours, daily)'))
    # execute query and convert to pandas dataframe
    pd_df_avgd_times = snow_df_avgd_times.to_pandas()

    if proportional:
        prop_df = pd.merge(pd_df_avgd_times, pd_df_avgd_totals, on="Country Name", how="inner")
        prop_df["Proportion of total free time"] = prop_df["Average Time Spent (hours, daily)"] / prop_df["TOTAL"]
        prop_df = prop_df.sort_values("Proportion of total free time")
        altair_bar_chart = alt.Chart(prop_df, height=400).mark_bar().encode(
            x=alt.X('Country Name', sort=None),
            y='Proportion of total free time',
        )
    else:
        altair_bar_chart = alt.Chart(pd_df_avgd_times, height=400).mark_bar().encode(
            x=alt.X('Country Name', sort=None),
            y='Average Time Spent (hours, daily)',
        )

    # Plots/Output
    st.altair_chart(altair_bar_chart)

    with st.expander("**Analysis**"):
        st.write('Overall, the time spent on total free time activities does not vary much across all the countries, ranging from about 4 to 6 hours daily. TV and Video time also does not vary significantly, but other activities differ widely across countries, showing how various demographics spend their free time differently.')

# Line chart to compare activity values over time
with tab2:
    st.subheader("Time Spent on Each Activity by Country and Sex Over Time :chart:")
    st.write("""Use the dropdowns to see how daily time spent on each activity per specified sex and country changes over time.""")

    # Interactive Elements
    col1, col2, col3 = st.columns(3)
    sex = col1.selectbox(label="Sex", options=sex_names)
    country = col2.selectbox(label="Country", options=countries)
    area_or_line = col3.checkbox("Line chart")

    year_df = conn.query(f'SELECT * FROM ARTS_MEDIA_AND_ENTERTAINMENT_DATA_ATLAS.ARTS_MEDIA_ENTERTAINMENT.UNECE_GELB_FREE_TIMEUSE WHERE "Sex Name" = \'{sex}\' AND "Country Name" = \'{country}\' AND "Activity Name" != \'Total Free Time Activities\';', ttl=600)

    if area_or_line:
        chart = alt.Chart(year_df).mark_line(point=True).encode(
            x=alt.X("Date", axis=alt.Axis(title="Date")),
            y=alt.Y("Value", axis=alt.Axis(title="Time Spent Daily (in Hours)")),
            color="Activity Name"
        ).properties(width=850, height=450)
    else:
        chart = alt.Chart(year_df).mark_area().encode(
            x=alt.X("Date", axis=alt.Axis(title="Date")),
            y=alt.Y("Value", axis=alt.Axis(title="Time Spent Daily (in Hours)"), stack="normalize"),
            color="Activity Name"
        ).properties(width=850, height=450)

    st.altair_chart(chart, use_container_width=True)

    st.write('*Some countries that did not have enough data to display a line chart have been removed.')

    with st.expander("**Analysis**"):
        st.write('Based on these line graphs, it is clear that over the past years, TV and Video is by far the most popular activity that people do in their free time in almost all countries. In addition, there is not much difference between males and females in terms of trends of activities in each country for most of the time.')
        st.write('Many interesting things can be discovered about each country and the specific genders from these graphs. You can see how the preference for what people like to do in their free time has changed in the past two decades. Some things that stand out from this graph are that in Italy, for both sexes, the time spent on each activity has remained stagnant for almost a decade. In the United States, people have spent significantly more time on TV and Video than all the other activities combined in the past years. In the Netherlands, there is a steep dip and increase in all activities from 2005 to 2006 for both genders.')

# Pie chart to visualize proportion of free time spent on different activities
with tab3:
    st.subheader("Comparing the Proportion of Time Spent on Each Activity to the Rest of the World :earth_americas:")

    # Interactive Elements
    st.write("Use the dropdown menus to select a demographic to analyze. The left pie chart shows the free time distribution of your selected demographic, while the right pie chart shows the global average distribution.")
    col1, col2, col3 = st.columns(3)
    sel_country = col1.selectbox("Country:", country_names, index=34)
    sel_sex = col2.selectbox("Sex:", sex_names)
    sel_year = col3.selectbox("Year:", get_available_years(full_df, sel_country))

    # Plots/Output
    int_chart = draw_subset_pie_graph(full_df, sel_country, sel_sex, sel_year)
    avg_chart = draw_plotly_pie_chart(avg_dist_df, "Activity Name", "Hours", color_mapping)
    side_by_side_fig = make_subplots(
        rows=1, cols=2,
        specs=[[{'type':'domain'}, {'type':'domain'}]],
        subplot_titles=["Selected Demographic:", "Global Average:"]
    )
    side_by_side_fig.add_trace(avg_chart, 1, 2)
    side_by_side_fig.add_trace(int_chart, 1, 1)
    side_by_side_fig.update_layout(margin=dict(t=20))
    side_by_side_fig.update_traces(hovertemplate="%{label}: <br>Hours: %{value}<extra></extra>")
    side_by_side_fig.update_annotations(yshift=-40)
    st.plotly_chart(side_by_side_fig)

    with st.expander("**Analysis**"):
        st.write('By choosing a country and changing the year and gender that you want to analyze, you can see not only how the proportion of time spent on each activity has changed over time relative to each gender, but also how it compares to the global average. The global average shows the overall ratio of time spent on each activity averaged among the past two decades from both sexes across all the countries. For example, comparing the United States from both sexes from 2003 to 2014, the time spent on TV and Video has changed from 47.6% to 50.5%. Consistently, the time spent on TV and Video is almost half of all the free time available. In the same way, volunteer work and help takes up the least amount of time out of all free time.')

# Scatter plot to visualize correlation between different activities
with tab4:
    st.subheader("Analyze Relationships Between Different Activities :bike:")
    st.write("""Use the dropdown to choose two free time activities to analyze the relationship and see the correlation between each other.""")

    # Interactive Elements
    act1 = st.selectbox("Activity 1:", activity_names, 1)
    act2 = st.selectbox("Activity 2:", activity_names, 3)

    # Calculations
    act_corr = corr_df.corr(col(f"{act1} Value"), col(f"{act2} Value"))
    act_cov = corr_df.cov(col(f"{act1} Value"), col(f"{act2} Value"))

    # Plots/Output
    altair_scatter_plot = alt.Chart(pd_corr_df, height=400).mark_circle().encode(
        x=f"{act1} Value",
        y=f"{act2} Value",
        tooltip=["Country Name", "Sex Name", "Year", f"{act1} Value", f"{act2} Value"]
    )
    col1, col2 = st.columns([2, 1])
    with col1:
        st.altair_chart(altair_scatter_plot)
    with col2:
        st.subheader(" ")

    st.write(f"**Correlation coefficient:**")
    st.subheader(f"**{act_corr:.4f}**")
    st.subheader(" ")
    st.write(f"**Covariance coefficient:**")
    st.subheader(f"**{act_cov:.4f}**")

    with st.expander("**Analysis**"):
        st.write("While most activity pairs don't show a strong correlation, there are some notable correlations between activities. \n\nFirstly, Socializing and Reading have a moderate/strong positive correlation, simply indicating that countries who spend more time reading also tend to socialize more. \n\nTotal Free Time correlates positively with every activity, which is not a surprise, but comparing these correlations gives us interesting insights. Total Free Time's correlation with Volunteering is the lowest of any of its correlations, indicating that given more free time, people typically spend that time on more \"enjoyable\" hobbies like TV, reading, or socializing. \n\nLastly, we found that TV and Video is the only activity that negatively correlates with just about every other activity, especially Reading and Socializing. This suggests that TV and Video dominates free time, taking away from activities like reading and socializing.")

# Bar chart to compare average time spent on activities by sex
with tab5:
    st.subheader("Average Time Spent on Activities By Sex :boy::girl:")
    st.write("""Use the dropdown to choose an activity to compare the average hours spent daily on an activity between females and males.""")

    col1, col2 = st.columns([1, 2], gap="medium")
    with col1:
        st.write(" ")
        sel_activity = st.selectbox("Activity:", activity_names, index=0, key=1)
        proportional = st.checkbox("Proportional?")
        sex_averages_filtered = snow_df_sex_comp.filter(col("Activity Name") == sel_activity).to_pandas()
        sel_y = "Proportion of total free time" if proportional else "Average hours spent on activity (daily)"
    
    altair_sex_bar_chart = alt.Chart(sex_averages_filtered, height=400).mark_bar().encode(
        x="Sex Name:N",
        y=f"{sel_y}:Q",
        color=alt.Color('Sex Name:N', scale=alt.Scale(range=["#ffc0cb", "#6ca0dc"], domain=["Female", "Male"]), legend=None)
    )
    
    with col2:
        st.altair_chart(altair_sex_bar_chart, use_container_width=True)

    st.write("*The graph displayed averages the time spent on specified activity first by all countries and then by gender so that countries with more years recorded are not weighted more heavily.")

    with st.expander("**Analysis**"):
        st.write('Looking the graph, we are able to see the average amount of time men and women spend
        on each activity, as well as the proportion of all their free time that they actually spend on each activity.
        From the total free time activties, we can see that men have an average of almost an hour of more free
        time compared to women. More specifically, looking at reading, females and males spend around the
        same average amount of time reading, but proportionally, women spend more of their free time on
        reading compared to men. Women also spend a lot more of their time socializing than males. On the
        other hand, men spend a much larger proportion of their time on hobbies and games than women.')
        st.write(' ')
        st.write('It is important to keep in mind that while one sex may spend more hours on average on a
        certain activity, it is important to keep in mind the true proportion of free time that they spend on it. For
        example, while men on average spend more hours on other free time activities, women actually spend
        more of their free time on this than men.')