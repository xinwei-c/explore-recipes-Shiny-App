---
  title: "Cuisine Explorer"
output: html_document
date: "2025-10-02"
---
  


#library
library(janitor)
library(tidyverse)
library(shiny)
library(bslib)


theme_set(
  theme_bw(base_size = 13) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 14, hjust = 0.5, color = "#222222" ),
      plot.subtitle = element_text(size = 11, hjust = 0.5, color = "#69b3a2")
    )
)
cuisines <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-09-16/cuisines.csv')

## Data Processing

cuisines <- cuisines %>%
  # drop cuisines that missing data
  drop_na() %>%
  filter(total_time != 0 ) %>% # remove rows with invalid total_time
  #  drop unused columns
  select(-c(prep_time, cook_time, author, url, total_ratings, reviews)) %>% 
  mutate(
    # convert ingredients to lowercase 
    ingredients = tolower(ingredients),
    # check if the ingredients have following items
    egg = str_detect(ingredients, "egg"),
    flour = str_detect(ingredients, "flour"),
    milk = str_detect(ingredients, "milk"),
    butter = str_detect(ingredients, "butter"),
    chicken = str_detect(ingredients, "chicken"),
    beef = str_detect(ingredients, "beef"),
    pork = str_detect(ingredients, "pork"),
    fish = str_detect(ingredients, "fish|salmon|tuna")) %>%
  mutate(country = as.factor(country) ) %>% # make it categorical 
  mutate(calorie_bin = cut(
    calories,
    breaks = c(-Inf, 500, 1000, Inf),
    labels = c("0–500", "500–1000", ">1000"),
    right = TRUE)) # categorize the calories column




## Define Visualization




# define a linear line for the two selected variables
lm_line <- function(d, x, y) {
  d <- d[complete.cases(d[, c(x, y)]), ]
  if (nrow(d) < 2) return(NULL)
  fit <- lm(d[[y]] ~ d[[x]])
  geom_abline(
    slope = coef(fit)[2], intercept = coef(fit)[1],
    color = "grey40", linewidth = 0.3
  )
}

# define function for scatter plot. color = calorie_bin.
# use xvar and yvar so audiences can choose variables they care
# if data is selected, the value of alpha will be higher and the unselected ones will be lighter
scatterplot_cuisines <- function(df, selected_, xvar, yvar) {
  sel <- df[selected_, , drop = FALSE]
  ggplot(df, aes(.data[[xvar]], .data[[yvar]], color = calorie_bin)) +
    geom_point(data = df[!selected_, ], alpha = 0.2, size = 1) +
    geom_point(data = sel,            alpha = 0.9, size = 2) +
    lm_line(sel, xvar, yvar) +
    scale_color_brewer(palette = "Set2", name = "Calorie bin") +
    labs(title = "Interactive Scatter Plot",
         subtitle = "Choose provided variables and brush either plot to highlight",
         x = xvar, y = yvar)
}


# shows all and brushed histogram for a chosen numeric variable

overlay_histogram_cuisines <- function(df, selected_, var) {
  # create "sel" to serve the brush part
  sel <- df[selected_, , drop = FALSE]
  # generate the two mean variables to reflect the filtering change on the annotations
  m_all <- mean(df[[var]])
  m_sel <- mean(sel[[var]])
  
  ggplot(df, aes(.data[[var]], fill = calorie_bin)) +
    geom_histogram(data = df[!selected_, ], alpha = 0.3, bins = 30, color = "white") +
    geom_histogram(data = sel,              alpha = 0.9, bins = 30, color = "white") +
    geom_vline(xintercept = m_all, color = "grey60", linetype = "dashed") +
    geom_vline(xintercept = m_sel, color = "black") +
    # add mean value annotations
    annotate("label", x = m_sel, y = Inf,
             label = paste0("mean = ", round(m_sel, 1)),
             vjust = 1.5) +
    scale_fill_brewer(palette = "Set2", guide = "none") +
    labs(title = paste("Distribution of", var),
         subtitle = "Solid overlay = brushed subset; lines show means",
         x = var, y = "Count") 
}



# show publish year's distribution based on selected dataset
plot_publish_years <- function(df) {
  df %>%
    mutate(year = year(as.Date(date_published))) %>%
    count(year) %>%
    ggplot(aes(year, n)) +
    geom_col(fill = "#69b3a2") +
    labs(title = "Recipes shared per year", x = "Year", y = "Count") 
}

ui <- fluidPage(
  theme = bs_theme(
    bootswatch = "minty",   
    bg = "white",
    fg = "#222222",          
    primary = "#69b3a2" ), #CFE6D6 E4F0E7
  titlePanel("Cuisines Explorer"),
  wellPanel(
    style = "background-color:#E4F0E7",
    strong("Instructions: "),
    "The dataset was created by Brian Mubia and consists of recipes scraped from AllRecipes.com. It provides a broad snapshot of cooking data collected over time, including information about ingredients, nutrition, country of origin, and user ratings. Calories are binned in calorie_bin (0–500, 500–1000, >1000).",
    tags$ul(
      tags$li("Choose X and Y variable for scatter plot (the top one). Choose variable for histogram plot (the second one)."),
      tags$li("Filter by ingredient and by countries (leave empty = all). The change will be reflected on all the visualizations."),
      tags$li("Now you can brush the scatter plot or histogram to highlight a subset.")
    )
  ),
  br(),
  sidebarLayout(
    sidebarPanel(
      # add color to the sidebar
      style = "background-color:#E4F0E7",
      width = 3,
      br(),
      tags$b( "Select ingredient"),
      
      # define input ID as "ings", 
      selectInput(
        "ing",  "Ingredient:",
        choices = c("any", "flour", "milk", "butter", "chicken", "beef"),
        selected = "any" ),
      
      # country select input
      tags$b("Select countries"),
      selectInput("countries", "Countries (empty = all)",
                  choices = sort(unique(as.character(cuisines$country))),
                  selected = NULL, multiple = TRUE),
      uiOutput("xy_ui"),
      uiOutput("hist_ui"),
      br()
    ),
    mainPanel(
      plotOutput("scatter", height = 200, brush = brushOpts(id = "brush_scatter", direction = "xy", resetOnNew = TRUE)),
      br(),
      plotOutput("hist", height = 200,
                 brush = brushOpts(id = "brush_hist", direction = "x", resetOnNew = TRUE)),
      br(),
      plotOutput("publish_plot", height = 180),
      br()
    )
  )
)

```

## Server

#define server

server <- function(input, output, session) {
  #choose numerical variables
  nv <- names(select(cuisines, where(is.numeric)))
  
  # write scatter plot
  output$xy_ui <- renderUI({
    tagList(
      tags$b("Select recipe measures for the first chart"),  
      # choose the first numerical variable as the default input
      selectInput("xvar", "Horizontal variable (x axis):", choices = nv,  selected = nv[1]), 
      # choose the last numerical variable as the default input
      
      selectInput("yvar", "Vertical varible (y axis)", choices = nv, selected = nv[2])
    )
  })
  
  # write histogram plot
  output$hist_ui <- renderUI({
    tagList(
      tags$b("Select the variable for the second chart"),
      selectInput("hvar", "Histogram variable", choices = nv, selected =  nv[1]))
  })
  
  
  # creates a reactive expression
  
  filtered <- reactive({
    df <- cuisines
    if (input$ing != "any")
      df <- df[df[[input$ing]], ]
    if (length(input$countries) > 0)
      df <- df[df$country %in% input$countries, ]
    df
  })
  
  # creates a reactive variable to store a value and automatically update
  # keep sel update with filtered
  sel <- reactiveVal(logical(0))
  observeEvent(filtered(), ignoreInit = FALSE, {
    sel(rep(TRUE, nrow(filtered())))
  })
  
  # brushing from scatter
  observeEvent(input$brush_scatter, {
    idx <- brushedPoints(
      filtered(), input$brush_scatter,
      xvar = input$xvar, yvar = input$yvar,
      allRows = TRUE
    )$selected_
    if (!is.null(idx)) sel(idx)
  })
  
  # brushing from histogram 
  observeEvent(input$brush_hist, {
    idx <- brushedPoints(
      filtered(), input$brush_hist,
      xvar = input$hvar,
      allRows = TRUE
    )$selected_
    if (!is.null(idx)) sel(idx)
  })
  
  output$scatter <- renderPlot({
    req(input$xvar, input$yvar)
    scatterplot_cuisines(filtered(), sel(), input$xvar, input$yvar)
  })
  
  output$hist <- renderPlot({
    req(input$hvar)
    overlay_histogram_cuisines(filtered(), sel(), input$hvar)
  })
  
  output$publish_plot <- renderPlot({
    plot_publish_years(filtered())
  })
  
  
}



## App Running


shinyApp(ui, server)



