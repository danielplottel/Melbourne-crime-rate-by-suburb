# Interactive Narrative Visualisation Project
# Author: Daniel Plottel
# Student ID: 21467013
# Date: 02/06/2021

# This narrative visualisation explores the crime rate of suburbs in Melbourne,
# normalised by their residential populations. Broadly, geographical areas of
# suburbs are compared and contrasted with one another to give an idea of which
# areas have more crime. The message then focuses on individual suburbs with
# higher crime rates and/or high change in crime rate and highlights the trends
# of those suburbs over the past decade. The intended audience is anyone with a
# general interest in the data and could include prospective property buyers or
# renters in Melbourne.

# Import libraries
library(shiny)
library(leaflet)
library(RColorBrewer)
library(rgdal)
library(rmapshaper)
library(shinyWidgets)
library(plotly)

# Read data - shapefile and csv data
melb_map <- readOGR("./melbourne.shp")
crime_data <- read.csv("crime.csv")

# Round incidents_per_1000_people
crime_data$incidents_per_1000_people <- 
  round((crime_data$incidents_per_1000_people), 0)

# Filter out crime data for suburbs not in the shapefile
crime_data <- crime_data %>%
  filter(crime_data$Suburb %in% melb_map$NAME)

# Improve optimisation of choropleth map (load/refresh time responsiveness)
# https://stackoverflow.com/questions/44356224/leaflet-shiny-integration-slow
melb_map <- rmapshaper::ms_simplify(melb_map, keep = 0.05, keep_shapes = TRUE)

# Choose colour schema from Color Brewer
colours <- brewer.pal(7,"YlGnBu")
# Map colour palette to values
pal <- colorNumeric(colours, 0:200)

# List of suburbs to choose from in filter dropdown menu
choices <- sort(crime_data$Suburb[match(
    melb_map$NAME, crime_data$Suburb)])

# List of character vectors to be selected for the narrative
suburb_selection <- list(
    c("DANDENONG", "CLYDE", "FRANKSTON", "CAULFIELD EAST", "BOX HILL",
    "CLYDE NORTH", "RINGWOOD"),
    c("ROCKBANK", "RAVENHALL", "SUNSHINE", "LITTLE RIVER", "MELTON",
    "MOUNT COTTRELL"),
    c("HEIDELBERG", "MICKLEHAM", "BROADMEADOWS", "CAMPBELLFIELD",
    "HEIDELBERG WEST", "COOLAROO"),
    c("PARKVILLE", "KENSINGTON", "NORTH MELBOURNE", "DOCKLANDS",
    "SOUTHBANK", "WEST MELBOURNE", "ST KILDA"),
    "MELBOURNE",
    c("PORTSEA", "SORRENTO", "RYE", "BLAIRGOWRIE"),
    c("DANDENONG SOUTH", "OFFICER SOUTH", "BRAESIDE", "DONNYBROOK",
    "KALKALLO", "MELBOURNE AIRPORT", "KEILOR NORTH", "MAMBOURIN",
    "LAVERTON NORTH", "TOTTENHAM")
)

# Vector of text for the narrative
narrative <- c("The visualisations in this application will show you the rate
               of crime commited in suburbs of Melbourne in the years from 2011
               (year ended 30 September 2011) to 2020 (year ended 30 September
               2020). You can use the arrows above to step through the
               narrative.",
               
               "Crime appears to have worsened in Melbourne over the past 10
               years. The choropleth map shows the number of criminal incidents
               in each suburb of Melbourne per 1,000 residents in a given year.
               Click and drag the slider bar below the map to compare different
               years from 2011 to 2020. You can also click the button below the
               right of the slider bar to transition through years. You will
               notice that, overall, the map gets darker over time,
               representing a greater rate of criminal incidents. The highest
               concentration of crime occurs in and around Melbourne's CBD.
               Melbourne's north and west show greater crime rates than the
               east although a number of eastern suburbs show an increase in
               crime rate over the past decade. There remains a cluster of
               suburbs in Melbourne's east-north-east (around Warrandyte and
               Templestowe) where crime rates remain relatively low.",
               
               "In Melbourne's east and southeast, Frankston and Dandenong are
               known to be high crime hotspots. From the map, you can see that
               it is a little lower for Frankston than Dandenong. If you hover
               over Frankston and Dandenong on the map you can see the total
               number of criminal incidents in a given year, which are both
               very high. Interestingly, in 2020, Caulfield East had the same
               rate of criminal incidents per population as Dandenong and more
               than Frankston. You can also view the trends for these selected
               suburbs in the line chart below the map. The suburbs of Clyde
               and Clyde North, on Melbourne's south eastern fringe have seen a
               considerable increase in crime over the past decade, potentially
               because they are developing outer suburbs. Box Hill and Ringwood,
               in Melbourne's east have steadier rates, but they are still high
               relative to other suburbs in their geographical area.",
               
               "In the west, the outer suburb of Rockbank has seen a major jump
               in crime in a very short period of time. Sunshine and Melton
               have fairly steady rates of crime, albeit they are still quite
               high. Ravenhall sees a bit more fluctuation from year to year
               although overall has similar numbers to Sunshine and Melton.
               Little River, on the outskirts of Melbourne's west has seen an
               accelerated rate of growth in crime towards the end of the past
               decade. Mount Cottrell had a similar trajectory to Little River
               but without the spike at the end of the decade.",
               
               "Mickleham, on the northern fringe of Melbourne, saw a decline
               in crime in the early parts of the decade but has since 
               increased considerably to 2020. Coolaroo and Heidelberg West 
               have seen gradual increases in crime while Heidelberg fluctuated
               a bit through the middle of the decade but increased slightly
               overall. Broadmeadows and Campbellfield both had high rates of
               crime though Broadmeadows showed little overall change despite
               increases in the first half of the decade. Campbellfield, on the
               other hand, saw a gradual increase (aside from the spike in 2016)
               ending the period with a higher rate of crime than 
               Broadmeadows.",
               
               "A number of suburbs immediately to the west and northwest of
               Melbourne's CBD (and St Kilda to the south) have recorded
               declining rates of criminal incidents over the past decade. This
               can be due to the explosion in population compared to the
               increase in number of incidents as is the case for Docklands and
               Southbank. In the case of Kensington however, it stems from both
               a reduction in the number of criminal incidents and an increase
               in the population. Both West Melbourne and Docklands saw
               considerable decreases in crime rate from 2011 to 2014 but then
               steady increases from 2014 to 2020",
               
               "The combined suburbs of Melbourne (CBD with postcode 3000 and
               St Kilda Road with postcode 3004) have seen a fairly consistent
               number of criminal incidents over the last decade. Due to the
               development of many residential apartments in the area over
               this time, the residential population has also substantially
               increased. As a result, the rate of criminal activities by
               population has sharply declined, although it is still high.",
               
               "On the Mornington Peninsula, crime rates are mostly stable.
               Portsea had a much higher rate in 2011, and a spike in 2017
               while other years were around the same mark. Sorrento followed
               similar trends to Portsea but on a smaller scale. Being popular
               holiday spots, there would be more foot traffic in these 
               suburbs, which would account for some of the crime. Blairgowrie
               and Rye had stabler and more moderate rates of crime.",
               
               "A number of suburbs in Melbourne are predominantly industrial.
               These suburbs are still subject to criminal incidents but have
               exceptionally high rates of crime when normalised by
               residential population. Please keep this in mind when viewing
               the map.",
               
               "Now it's your turn. You can use the dropdown menu to select or 
               deselect other suburbs to focus. You can compare up to 10
               suburbs at a time in the line chart below.")


# Create user interface
ui <- fluidPage(
    
    # Title
    titlePanel("Crime trends in Melbourne over the past decade"),
  
    # Row 1
    fluidRow(
        column(width = 8,
            h4(strong("Crime rates by suburb"))
            )
    ),
    fluidRow(
        column(width = 8,
            # Map canvas
            leafletOutput("suburbs_map", height = 500)
        ),
        column(width = 4,
            # Drop down filter options     
            pickerInput(inputId = "filter_suburbs",
                        label = NULL,
                        choices = choices,
                        multiple = TRUE,
                        options = list('actions-box' = TRUE,
                                       'live-search' = TRUE,
                                       'dropup-auto' = FALSE,
                                       title = 'Select suburbs',
                                       size = 15
                                      )
                       ),
            # Narrative buttons
            actionButton(inputId = "previous_section",
                         label = NULL,
                         icon = icon("caret-left")),
            actionButton(inputId = "next_section",
                         label = NULL,
                         icon = icon("caret-right")),
            # Narrative text
            h5(textOutput("narrative_text"))
               ),
    ),
    
    # Row 2
    fluidRow(
        column(width = 12,
             # Slider bar
             sliderInput(inputId = "select_year",
                         label = "Year",
                         min = min(crime_data$Year),
                         max = max(crime_data$Year),
                         value = 2011,
                         step = 1,
                         ticks = FALSE,
                         sep = "",
                         animate = animationOptions(
                           interval = 1200),
                         width = '565px'
                        )
             )
    ),
    
    # Row 3
    fluidRow(
        column(width = 12,
               h4(strong("Crime rates over time")),
               h5("Select 1 to 10 suburbs using the filter options"),
               # Line chart canvas
               plotlyOutput("crime_over_time"),
               # Links to data sources
               h6(strong("Data Sources:")),
               h6(helpText("Crime data:", a("Crime Statistics Agency",
                      href="https://www.crimestatistics.vic.gov.au/crime-statistics/latest-crime-data-by-area"))
                  ),
               h6(helpText("Population data:",
                 a("Australian Bureau of Statistics - Census DataPacks",
                    href="https://datapacks.censusdata.abs.gov.au/datapacks/"))
               ),
               h6(helpText("Map polygons:", a("data.gov.au",
                   href="https://data.gov.au/dataset/ds-dga-af33dd8c-0534-4e18-9245-fc64440f742e/details"))
               )
        )
    )

)


# Server side
server <- function(input, output, session) {

    # Reactive value object to control flow of narrative
    # https://stackoverflow.com/questions/38302682/next-button-in-a-r-shiny-app
    values <- reactiveValues()
    values$count <- 1
  
    # Event handle for 'next' button
    observeEvent(input$next_section, {
      # Increase reactive value when 'next' button pressed, up to limit
      if (values$count != length(narrative)){
        values$count <- values$count + 1
      }
    })

    # Event handle for 'back' button
    observeEvent(input$previous_section, {
      # Decrease reactive value when 'back' button pressed, but not below 1
      if (values$count != 1){
        values$count <- values$count - 1
      }
    })

    # Use reactive value to index the narrative vector to output
    output$narrative_text <- renderText({
        narrative[values$count]
    })
    
    # Suburb filters for the narrative (when using next/back button)
    observeEvent(c(input$next_section, input$previous_section), {
      updatePickerInput(session,
                        inputId = "filter_suburbs",
                        selected = if (values$count == 1) {""}
                        else if (values$count %in% 3:9) {
                          suburb_selection[[values$count-2]]
                          } else {choices}
      )
    })
    
    # Reset slider bar when next/back button hit
    observeEvent(c(input$next_section, input$previous_section), {
      updateSliderInput(session,
                        inputId = "select_year",
                        value = if (values$count <= 2) {2011}
                          else if (values$count != length(narrative)) {
                          2020} 
      )
    })
    
  
    # Event handle, for slider bar and check boxes
    # https://github.com/rstudio/shiny-examples/blob/master/051-movie-explorer/server.R
    crime_filtered <- reactive({
        
        # ensure that map updates when next/back button pressed, even if the
        # dropdown menu or slider have not changed
        input$next_section
        input$previous_section

        # Filter original data set according to interactions
        crime_data %>%
            filter(
                Year %in% input$select_year,
                Suburb %in% input$filter_suburbs
            )
    })
    
    # Filtered data by suburb only, for use in the line graphs
    crime_suburb_filtered <- reactive({
        crime_data %>%
            filter(Suburb %in% input$filter_suburbs)
    })
    
    # Create leaflet map
    output$suburbs_map <- renderLeaflet({
        # Use polygon shapefile
        leaflet(melb_map) %>% # create canvas
            # Set view based on section of narrative
            setView(lng = if (values$count == 3) {145.2}
                    else if (values$count == 4) {144.5}
                    else if (values$count == 5) {144.95}
                    else if (values$count == 6) {144.95}
                    else if (values$count == 7) {144.97}
                    else if (values$count == 8) {144.75}
                    else {144.95},
                    lat = if (values$count == 3) {-38}
                    else if (values$count == 4) {-37.8} 
                    else if (values$count == 5) {-37.7}
                    else if (values$count == 6) {-37.85}
                    else if (values$count == 7) {-37.83}
                    else if (values$count == 8) {-38.25}
                    else {-37.95},
                    zoom = if (values$count == 3) {10}
                    else if (values$count == 4) {10} 
                    else if (values$count == 5) {9.5}
                    else if (values$count == 6) {10.5} 
                    else if (values$count == 7) {10.5}
                    else if (values$count == 8) {9.5}
                    else {9}
                    )
        })
    
    # To avoid resetting the view every time a filter is adjusted
    # https://rstudio.github.io/leaflet/shiny.html
    observe({
      
      # Create vector of values from filtered data for choropleth mapping
      crime_normalised <- crime_filtered()$incidents_per_1000_people[match(
        melb_map$NAME, crime_filtered()$Suburb)]
      # Ensure values over 200 are treated as 200 rather than NA when colouring
      # the map
      crime_normalised <- replace(crime_normalised, crime_normalised > 200, 200)

      # Tooltip
      tooltip <- paste(
        "<b>Suburb: </b>", melb_map$NAME, "<br>",
        "<b>Year: </b>", input$select_year, "<br>",
        "<b>Population: </b>", crime_filtered()$pop_est[match(
          melb_map$NAME, crime_filtered()$Suburb)], "<br>",          
        "<b>Total incidents: </b>", round(
          (crime_filtered()$incidents_recorded)[match(
          melb_map$NAME, crime_filtered()$Suburb)], 0), "<br>",
        "<b>Incidents per 1,000 population: </b>",
        crime_filtered()$incidents_per_1000_people[match(
          melb_map$NAME, crime_filtered()$Suburb)]) %>%
        # Allow HTML formatting in the tooltip
        lapply(htmltools::HTML)
      
      leafletProxy("suburbs_map") %>%
        addPolygons( # draw polygons
          data = melb_map,
          stroke = TRUE,
          color = "black",
          weight = 1,
          smoothFactor = 0.2,
          fillOpacity = 1,
          # Highlight suburb border on mouseover
          # https://stackoverflow.com/questions/50668989/highlight-borders-when-mouseover-fill-area-leaflet-r
          highlight = highlightOptions(weight = 3, opacity = 1.0),
          # use the rate of each suburb to find the correct color
          fillColor = ~pal(crime_normalised),
          # Add tooltip as a popup and adjust styling
          label = tooltip, 
          labelOptions = labelOptions(opacity = 0.9,
                                      sticky = TRUE,
                                      direction = "top",
                                      offset = c(0, -25)
                                      )
        )
    })
    
    # Generate legend again when next/back button pressed
    # https://rstudio.github.io/leaflet/shiny.html
    observeEvent(c(input$next_section, input$previous_section), {
      
      leafletProxy("suburbs_map") %>%
        # Clear legend
        clearControls() %>%
        # colour legend 
        addLegend(
          position = "bottomleft",
          colors = colours,
          labels= c("0", "33","67", "100", "133", "167", "200+"),
          title = "Criminal incidents <br> per 1,000 population"
        )     
    })
    
    
    # Create interactive line graph of selected suburbs
    output$crime_over_time <- renderPlotly({
        
        number_of_suburbs = nrow(crime_filtered())

        # Show plot if 1 to 10 suburbs have been selected
        if (number_of_suburbs %in% 1:10) {            
            # Create plot
            plot <- ggplot(crime_suburb_filtered()) +
            aes(x = Year, y = incidents_per_1000_people, col=Suburb) +
            scale_colour_brewer(type = "qual", palette = "Paired") +
            # Create line chart
            geom_line() +
            # Year marker
            geom_vline(xintercept = crime_filtered()$Year,
                       linetype = "dashed") +
            # X-axis markers
            scale_x_continuous(breaks = seq(2011, 2020, 1)) +
            labs(x = "Year", y = "Crime Rate per 1,000 population") +
            theme_classic()
            ggplotly(plot) # Plot
        }
        # Empty canvas if number of suburbs condition not met
        else {
          ggplot() +
            labs(x = "Year", y = "Crime Rate") +
            theme_classic()
        }
    })
}

# Run the app
shinyApp(ui, server)