library("shiny")
tags$style(type="text/css",
           ".shiny-output-error { visibility: hidden; }",
           ".shiny-output-error:before { visibility: hidden; }"
)

shinyUI(
  fluidPage(
    
    titlePanel("Udipipe Shiny App"),
    
    sidebarLayout( 
      
      sidebarPanel(  
        
        fileInput("txtfl", "Upload Sample Text File in .txt format:"),
        checkboxGroupInput("checkGroup", label = h3("Speech Tags to be Selected"), 
                           choices = list("Adjective" = "JJ", "Noun" = "NN", "Proper Noun" = "NNP", "Adverb" = "RB", "Verb" = "VB"),
                           selected = c("JJ","NN","NNP")),
        hr(),
        fluidRow(column(3, verbatimTextOutput("value"))),
        submitButton(text = "Submit", icon("refresh"))),
      
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    tabPanel("Overview",
                             h4(p("Data input")),
                             p("This app supports only text files (.txt) data file.Please ensure that the text files are saved in UTF-8 Encoding format.",align="justify"),
                             h4('How to use this App'),
                             p('To use this app, click on', 
                               span(strong("Upload Sample Text File for Analysis in .txt format:")))),
                    tabPanel("Annotated Documents", DT::dataTableOutput("mytable1")),
                    tabPanel("Word Cloud",plotOutput('plot2')),tabPanel("Co-Occurence Plot",plotOutput('plot1')))
        ) 
      )
    ) 
  )  
 