# Food-Explore-Shiny-App
The work is part of my homework in STAT 436 at University of Wisconsin-Madison.

# Dataset Source
https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-09-16

The dataset was created by Brian Mubia and consists of recipes scraped from AllRecipes.com. It provides a broad snapshot of cooking data collected over time, including information about ingredients, nutrition, country of origin and user ratings.

## Finished app link
**https://xinwei.shinyapps.io/cuisine_explorer/**

## Data Processing
Before visualization, I cleaned the datasets to remove rows with missing data and ensure valid time. I created new columns to decide whether a recipe included key ingredients such as flour, milk, butter, chicken and beef. These ingredient indicators were used to allow filtering and comparison across different food types. Another important step was grouping the calorie variable into broad ranges (0-500, 500-1000, >1000). The step is to create a classification that distinguishes recipes’ energy density. The publication date was converted into a date format to analyze recipe trends by year. In addition, each row of the processed dataset represents a single recipe, including its nutritional information (calories, fat, carbohydrates and protein), average user rating, country of origin, and total preparation time.

## Key Variables 
calories, fat, carb, proteins: nutritional content per serving.
avg_ratings: average rating out of 5 stars, which can reflect user satisfaction
total_time: total time needed to create the recipe
country: Indicates the cuisine’s country of origin.
date_published: The date when the recipe was first uploaded online
flour, milk, butter, chicken, beef, pork, fish: if the recipes contain certain ingredients

## Objectives 
The visualization aims to explore how nutritional values differ across countries and ingredient types, and how the number of recipes published online has changed over time. This app targets general audiences like cooks and foodies curious about recipes data. Therefore, with the specific countries and ingredients selected, audiences can explore what is most relevant to them. The app prioritizes intuitive exploration so audiences can play around the functions.

The app uses controls for personalized exploration. With the first single ingredient dropdown, users can select the ingredient they are most interested in. The country selector, however, allows multiple choices so that audiences can filter a set of certain countries. Variable selectors for the scatter plot make the same display serve multiple analytical purposes. Thus, users can switch to various relationships without changing plots. Brushing works across the scatter and histogram, so one action reflects on several spaces. The year bar chart updates automatically with the filters, showing whether a pattern belongs to older or newer uploaded recipes.

## Design
With the contexts on the top, the interface basically applies a left sidebar and right layout to minimize hand and eye movement. Based on that, controls stay grouped together and outputs remain aligned vertically. Colors come from a clean palette. All three plots share identical heights and a uniform minimalist theme so the eye can move vertically. Margins between the top context area and the main display give breathing space.

## Insights
When using the app, I found something unexpected by selecting and brushing through the data. For Argentinian recipes, the plot shows that dishes with more fat usually get lower ratings on the website. The average calories for these recipes are about 291 kcal. But when I select Thai food, the pattern looks different as the dishes with more fat actually get higher ratings, and the average calories rise to around 421 kcal. This kind of insight is easier to see with the multiple variables selection. Besides, as the app lets me filter by country and highlight parts of the plot, it becomes easy to notice that the same factor can be linked to ratings in different ways depending on the origin of the country.


