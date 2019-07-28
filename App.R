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




library(shiny)
library(udpipe)
library(textrank)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)
library(wordcloud)
library(stringr)
library(readr)
library(rvest)



shinyServer(function(input, output) {
  Text_Input_Data <- reactive({
    
    if (is.null(input$Text_Input)) {   
      return(NULL) } else{
        Data1 <- readLines(input$Text_Input$datapath,encoding = "UTF-8")
        return(Data1)
      }
  })
  output$cooccurrence_plot = renderPlot({
    inputText <-  as.character(Text_Input_Data())
    model <- udpipe_download_model(language = "english")
    model <- udpipe_load_model(model$file_model)
    Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
    
    Data <- as.data.frame(Data)
    print(Data)
    co_occ <- cooccurrence(   	
      x = subset(Data, Data$xpos %in% input$checkGroup), term = "lemma", 
      group = c("doc_id", "paragraph_id", "sentence_id"))  
    
    wordnetwork <- head(co_occ, 50)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) 
    
    
    ggraph(wordnetwork, layout = "fr") +  
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none") +
      
      labs(title = "Cooccurrence Plot")
  })
  
  
  
  
  output$mytable1 <- DT::renderDataTable({
    inputText <-  as.character(Text_Input_Data())
    model <- udpipe_download_model(language = "english")
    model <- udpipe_load_model(model$file_model)
    Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
    Data <- as.data.frame(Data)
    Data <-Data[,-4]
    DT::datatable(Data,options = list(pageLength = 100,orderClasses = TRUE),rownames = FALSE)
  })
  output$Data <- downloadHandler(
    
    filename <- "Data.csv",
    content = function(file) {
      inputText <-  as.character(Text_Input_Data())
      model <- udpipe_download_model(language = "english")
      model <- udpipe_load_model(model$file_model)
      Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
      Data <- as.data.frame(Data)
      Data <-Data[,-4]
      write.csv(Data, file, row.names = FALSE)
    }
  )
  output$Word_Cloud_PLot = renderPlot({
    inputText <-  as.character(Text_Input_Data())
    inputText
    model <- udpipe_download_model(language = "english")
    model <- udpipe_load_model(model$file_model)
    Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
    Data <- as.data.frame(Data)
    
    Words = Data %>% subset(., xpos %in% input$checkGroup);
    popular_words = txt_freq(Words$lemma)
    wordcloud(words = popular_words$key, 
              freq = popular_words$freq, 
              min.freq = 2, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
  })
})


# Create Shiny app ----
shinyApp(ui, server)