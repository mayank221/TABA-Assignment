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
  model <- udpipe_download_model(language = "english")
  model <- udpipe_load_model(model$file_model)
  
  Text_Input_Data <- reactive({
    
    if (is.null(input$Text_Input)) {   
      return(NULL) } else{
        Data1 <- readLines(input$Text_Input$datapath,encoding = "UTF-8")
        return(Data1)
      }
  })
  output$cooccurrence_plot = renderPlot({
    inputText <-  as.character(Text_Input_Data())
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
      Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
      Data <- as.data.frame(Data)
      Data <-Data[,-4]
      DT::datatable(Data,options = list(pageLength = 100,orderClasses = TRUE),rownames = FALSE)
    })
    output$Data <- downloadHandler(
      
      filename <- "Data.csv",
      content = function(file) {
        inputText <-  as.character(Text_Input_Data())
        Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
        Data <- as.data.frame(Data)
        Data <-Data[,-4]
        write.csv(Data, file, row.names = FALSE)
      }
    )
  output$Word_Cloud_PLot = renderPlot({
    inputText <-  as.character(Text_Input_Data())
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