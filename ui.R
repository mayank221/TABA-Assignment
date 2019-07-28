library("shiny")



shinyUI(
  fluidPage(
    
    titlePanel("Udipipe Shiny App"),
    
    sidebarLayout( 
      
      sidebarPanel(  
        
        fileInput("Text_Input", "Upload English Text File in .txt format:"),
        checkboxGroupInput("checkGroup", label = h3("Speech Tags"), 
                           choices = list("Adjective" = "JJ" ,"Adverb" = "RB", "Proper Noun" = "NNP", "Noun" = "NN", "Verb" = "VB"),
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
                             p("To use this app you need a english document in txt file format.\n\n 
                       To upload the article text, click on Browse in left-sidebar panel and upload the txt file from your local machine. \n\n
                       Once the file is uploaded, the shinyapp will compute a text summary in the back-end with default inputs and accordingly results will be displayed in various tabs.", align = "justify"),
                             p('To use this app, click on', 
                               span(strong("Upload Sample Text File for Analysis in .txt format:")))),
                    tabPanel("Annotated Documents", DT::dataTableOutput("mytable1"),downloadLink('Data', 'Download')),
                    tabPanel("Word Cloud",plotOutput('Word_Cloud_PLot')),tabPanel("Co-Occurence Plot",plotOutput('cooccurrence_plot')))
        ) 
      )
    ) 
  )  
 