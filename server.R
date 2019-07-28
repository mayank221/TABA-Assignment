
setwd("C:/Work/ISB/TABA Project")
getwd()
library(DT)
shinyServer(function(input, output) {
  options(shiny.maxRequestSize=30*1024^2)
  TxtFil <- reactive({
    
    if (is.null(input$txtfl)) {   # locate 'txtfl' from ui.R
      
      return(NULL) } else{
        Data1 <- readLines(input$txtfl$datapath,encoding = "UTF-8")
        return(Data1)
      }
  })
  # Calc and render plot    
  output$plot1 = renderPlot({
    inputText <-  as.character(TxtFil())
    model = udpipe_load_model(file="C:/Work/ISB/TABA Project/english-ewt-ud-2.4-190531.udpipe")
    Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
   
    Data <- as.data.frame(Data)
    print(Data)
      co_occ <- cooccurrence(   	# try `?cooccurrence` for parm options
        x = subset(Data, Data$xpos %in% input$checkGroup), term = "lemma", 
        group = c("doc_id", "paragraph_id", "sentence_id"))  # 0.02 secs

    wordnetwork <- head(co_occ, 75)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) 
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    suppressWarnings(ggraph(wordnetwork, layout = "fr") +  
                       
                       geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
                       geom_node_text(aes(label = name), col = "darkgreen", size = 6) +
                       
                       theme_graph(base_family = "Arial Unicode MS") +  
                       theme(legend.position = "none") +
                       
                       labs(title = "Cooccurrence Plot", subtitle = "Speech TAGS as chosen"))
  })
  output$Document = renderDataTable({
    Text <-  as.character(TxtFil())
    model = udpipe_load_model(file="C:/Work/ISB/TABA Project/english-ewt-ud-2.4-190531.udpipe")
    Data <- udpipe_annotate(model, x = Text, doc_id = seq_along(Text))
    Data <- as.data.frame(Data)
    Data <- subset(Data, select = -c(sentence))
    output$table <-  renderDataTable(Data)
  })
  server <- function(input, output) {
    
    # choose columns to display
    Text <-  as.character(TxtFil())
    model = udpipe_load_model(file="C:/Work/ISB/TABA Project/english-ewt-ud-2.4-190531.udpipe")
    Data <- udpipe_annotate(model, x = Text, doc_id = seq_along(Text))
    Data <- as.data.frame(Data)
    Data <- subset(Data, select = -c(sentence))
    print(Data)
    output$mytable1 <- DT::renderDataTable({
      DT::datatable(Data,options = list(orderClasses = TRUE))
    })}
  output$plot2 = renderPlot({
    inputText <-  as.character(TxtFil())
    model = udpipe_load_model(file="C:/Work/ISB/TABA Project/english-ewt-ud-2.4-190531.udpipe")
    Data <- udpipe_annotate(model, x = inputText, doc_id = seq_along(inputText))
    Data <- as.data.frame(Data)
    
      all_words = Data %>% subset(., xpos %in% input$checkGroup);
    top_words = txt_freq(all_words$lemma)
    wordcloud(words = top_words$key, 
              freq = top_words$freq, 
              min.freq = 2, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
  })
  output$Text_Data = renderText({
    inputText <-  as.character(TxtFil())
    inputText
  })
})