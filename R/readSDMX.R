#' @name readSDMX
#' @aliases readSDMX
#' @title readSDMX
#' @description \code{readSDMX} is the main function to use to read SDMX data
#'
#' @usage readSDMX(file = NULL, isURL = TRUE, isRData = FALSE,
#'   provider = NULL, providerId = NULL, providerKey = NULL,
#'   agencyId = NULL, resource = NULL, resourceId = NULL, version = NULL,
#'   flowRef = NULL, key = NULL, key.mode = "R", start = NULL, end = NULL, dsd = FALSE,
#'   headers = list(), validate = FALSE, references = NULL,
#'   verbose = !is.null(logger), logger = "INFO", ...)
#'                 
#' @param file path to SDMX-ML document that needs to be parsed
#' @param isURL a value of class "logical" either the path is an url, and data 
#'        has to be downloaded from a SDMXweb-repository. Default value is TRUE.
#'        Ignored in case \code{readSDMX} is used with helpers (based on the 
#'        embedded list of \code{SDMXServiceProvider})
#' @param isRData a value of class "logical" either the path is local RData file
#'        handling an object of class "SDMX", previously saved with \code{\link{saveSDMX}}.
#'        Default value is FALSE.
#' @param provider an object of class "SDMXServiceProvider". If specified, 
#'        \code{file} and \code{isURL} arguments will be ignored.      
#' @param providerId an object of class "character" representing a provider id. 
#'        It has to be match a default provider as listed in\code{getSDMXServiceProviders()}
#' @param providerKey an object of class "character" giving a key to authenticate
#'        for the given provider endpoint. Some providers may require an authentication or
#'        subscription key to perform SDMX requests.
#' @param agencyId an object of class "character representing an agency id, for
#'        which data should be requested (from a particular service provider)      
#' @param resource an object of class "character" giving the SDMX service request 
#'        resource to query e.g. "data". Recognized if a valid provider or provide 
#'        id has been specified as argument.
#' @param resourceId an object of class "character" giving a SDMX service resource 
#'        Id, e.g. the id of a data structure
#' @param version an object of class "character" giving a SDMX resource version, 
#'        e.g. the version of a dataflow.
#' @param flowRef an object of class "character" giving the SDMX flow ref id. Recognized 
#'        if valid provider or provide id has been specified as argument.
#' @param key an object of class "character" or "list" giving the SDMX data key/filter 
#'        to apply. Recognized if a valid provider or provide id has been specified as argument.
#'        If \code{key.mode} is equal to \code{"R"} (default value), filter has to be an object 
#'        of class "list" representing the filters to apply to the dataset, otherwise the filter 
#'        will be a string.
#' @param key.mode an object of class "character" indicating if the \code{key} has to be provided 
#'        as an R object, ie a object of class "list" representing the filter(s) to apply. Default 
#'        value is \code{"R"}. Alternative value is \code{"SDMX"}
#' @param start an object of class "integer" or "character" giving the SDMX start time to apply. 
#'        Recognized if a valid provider or provide id has been specified as argument.
#' @param end an object of class "integer" or "character" giving the SDMX end time to apply. 
#'        Recognized if a valid provider or provide id has been specified as argument.
#' @param references an object of class "character" giving the instructions to return (or not) the
#'        artefacts referenced by the artefact to be returned.
#' @param dsd an Object of class "logical" if an attempt to inherit the DSD should be performed.
#'        Active only if \code{"readSDMX"} is used as helper method (ie if data is fetched using 
#'        an embedded service provider. Default is FALSE
#' @param validate an object of class "logical" indicating if a validation check has to
#'        be performed on the SDMX-ML document to check its SDMX compliance when reading it.
#'        Default is FALSE.
#' @param verbose an Object of class "logical" that indicates if rsdmx logs should
#'        appear to user. Default is set to \code{FALSE} (see argument \code{logger}).
#' @param logger reports if a logger has to be used to print log messages. Default is \code{NULL} 
#'        (no logs). Use "INFO" to print \pkg{rsdmx} logs, and "DEBUG" to print verbose messages 
#'        from SDMX web requests.
#' @param headers an object of class "list" that contains any additional headers for the request.
#' @param ... (any other parameter to pass to httr::GET request)
#' 
#' @export
#' 
#' @return an object of class "SDMX"
#' 
#' @examples             
#'  # SDMX datasets
#'  #--------------
#'  \dontrun{
#'    # Not run
#'    # (local dataset examples)
#'    #with SDMX 2.0
#'    tmp <- system.file("extdata","Example_Eurostat_2.0.xml", package="rsdmx")
#'    sdmx <- readSDMX(tmp, isURL = FALSE)
#'    stats <- as.data.frame(sdmx)
#'    head(stats)
#'    
#'    #with SDMX 2.1
#'    tmpnew <- system.file("extdata","Example_Eurostat_2.1.xml", package="rsdmx")
#'    sdmx <- readSDMX(tmpnew, isURL = FALSE)
#'    stats <- as.data.frame(sdmx)
#'    head(stats)
#'    ## End(**Not run**)
#'  }
#'  
#'  \dontrun{
#'    # Not run by 'R CMD check'
#'    # (reliable remote datasource but with possible occasional unavailability)
#'    
#'    #examples using embedded providers
#'    sdmx <- readSDMX(providerId = "OECD", resource = "data", flowRef = "MIG",
#'                      key = list("TOT", NULL, NULL), start = 2011, end = 2011)
#'    stats <- as.data.frame(sdmx)
#'    head(stats)
#'    
#'    #examples using 'file' argument
#'    #using url (Eurostat REST SDMX 2.1)
#'    url <- paste("http://ec.europa.eu/eurostat/SDMX/diss-web/rest/data/",
#'                 "cdh_e_fos/all/?startperiod=2000&endPeriod=2010",
#'                 sep = "")
#'    sdmx <- readSDMX(url)
#'    stats <- as.data.frame(sdmx)
#'    head(stats)
#'    
#'    ## End(**Not run**)
#'  }  
#'  
#'  # SDMX DataStructureDefinition (DSD)
#'  #-----------------------------------
#'  \dontrun{
#'    # Not run by 'R CMD check'
#'    # (reliable remote datasource but with possible occasional unavailability)
#'    
#'    #using embedded providers
#'    dsd <- readSDMX(providerId = "OECD", resource = "datastructure",
#'                    resourceId = "WATER_ABSTRACT")
#'    
#'    #get codelists from DSD
#'    cls <- slot(dsd, "codelists")
#'    codelists <- sapply(slot(cls,"codelists"), slot, "id") #get list of codelists
#'    
#'    #get a codelist
#'    codelist <- as.data.frame(cls, codelistId = "CL_WATER_ABSTRACT_SOURCE")
#'    
#'    #get concepts from DSD
#'    concepts <- as.data.frame(slot(dsd, "concepts"))
#'    
#'    ## End(**Not run**)
#'  }
#' 
#' @author Emmanuel Blondel, \email{emmanuel.blondel1@@gmail.com}
#'    

readSDMX <- function(file = NULL, isURL = TRUE, isRData = FALSE,
                     provider = NULL, providerId = NULL, providerKey = NULL,
                     agencyId = NULL, resource = NULL, resourceId = NULL, version = NULL,
                     flowRef = NULL, key = NULL, key.mode = "R", start = NULL, end = NULL, dsd = FALSE,
                     headers = list(), validate = FALSE, references = NULL,
                     verbose = !is.null(logger), logger = "INFO", ...) {
  
  #logger
  debug <- FALSE
  if(!is.null(logger)) debug <- logger == "DEBUG"
  log <- rsdmxLogger$new(enabled = verbose)
  
  #set option for SDMX compliance validation
  .rsdmx.options$validate <- validate
  .rsdmx.options$followlocation <- TRUE
  
  if(!(key.mode %in% c("R", "SDMX"))){
    stop("Invalid value for key.mode argument. Accepted values are 'R', 'SDMX' ")
  }
  
  #check from arguments if request has to be performed
  buildRequest <- FALSE
  if(!missing(provider)){
    if(!is(provider,"SDMXServiceProvider")){
      stop("Provider should be an instance of 'SDMXServiceProvider'")
    }else{
      providerId = slot(provider, "agencyId")
    }
    buildRequest <- TRUE
  }
  
  if(!missing(providerId)){
    provider <- findSDMXServiceProvider(providerId)
    if(is.null(provider)){
      stop("No provider with identifier ", providerId)
    }
    buildRequest <- TRUE
  }
  
  #proceed with the request build
  if(buildRequest){
    
    if(is.null(resource)) stop("SDMX service resource cannot be null")
    
    #request handler
    requestHandler <- provider@builder@handler
    if((resource %in% provider@builder@unsupportedResources) ||
       !(resource %in% names(requestHandler)))
      stop("Unsupported SDMX service resource for this provider")
    
    #apply SDMX key mode
    if(key.mode == "R" && !missing(key) && !is.null(key)){
      key <- paste(sapply(key, paste, collapse = "+"), collapse=".")
    }
    
    #request params
    requestParams <- SDMXRequestParams(
                       regUrl = provider@builder@regUrl,
                       repoUrl = provider@builder@repoUrl,
                       accessKey = providerKey,
                       providerId = providerId,
                       agencyId = agencyId,
                       resource = resource,
                       resourceId = resourceId,
                       version = version,
                       flowRef = flowRef,
                       key = key,
                       start = start,
                       end = end,
                       references = references,
                       compliant = provider@builder@compliant
                     )

    #formatting requestParams
    requestFormatter <- provider@builder@formatter
    requestParams <- switch(resource,
                           "dataflow" = requestFormatter$dataflow(requestParams),
                           "datastructure" = requestFormatter$datastructure(requestParams),
                           "data" = requestFormatter$data(requestParams))
    #preparing request
    file <- switch(resource,
                  "dataflow" = requestHandler$dataflow(requestParams),
                  "datastructure" = requestHandler$datastructure(requestParams),
                  "data" = requestHandler$data(requestParams)
    )
    
    log$INFO(sprintf("Fetching '%s'", file))
  }
  
  #call readSDMX original
  if(is.null(file)) stop("Empty file argument")
  if(buildRequest) isURL = TRUE
  if(isRData) isURL = FALSE
  
  #load data
  status <- 0
  if(isURL == FALSE){
    isXML <- !isRData
    if(isXML){
      if(!file.exists(file)) stop("File ", file, "not found\n")
      content <- readChar(file, file.info(file)$size)
    }
  }else{
    requestURL <- function(file, contentType = TRUE, debug = FALSE){
      rsdmxAgent <- paste("rsdmx/",as.character(packageVersion("rsdmx")),sep="")
      content <- NULL
      if(debug){
        if(contentType){
          content <- httr::with_verbose(httr::GET(
            file, httr::add_headers(
              'Accept' = "application/xml",
              'Content-Type' = "application/xml",
              'User-Agent' = rsdmxAgent, 
              unlist(headers)
            ), ...))
        }else{
          content <- httr::with_verbose(httr::GET(
            file, httr::add_headers(
              'Accept' = "application/xml",
              'User-Agent' = rsdmxAgent, 
              unlist(headers)
            ), ...))
        }
      }else{
        if(contentType){
          content <- httr::GET(file, httr::add_headers(
            'Accept' = "application/xml",
            'Content-Type' = "application/xml",
            'User-Agent' = rsdmxAgent, 
            unlist(headers)
          ), ...)
        }else{
          content <- httr::GET(file, httr::add_headers(
            'Accept' = "application/xml",
            'User-Agent' = rsdmxAgent, 
            unlist(headers)
          ), ...)
        }
      }
      return(content);
    }
    out <- requestURL(file, debug = debug)
    out_headers <- httr::headers(out)
    if(httr::status_code(out) %in% c(301,302)){
      file <- out_headers[["Location"]]
      out <- requestURL(file, debug = debug)
      out_headers <- httr::headers(out)
    }
    if(!is.null(out_headers[["content-type"]])) if(startsWith(out_headers[["content-type"]], "text/html")){
      out <- requestURL(file, contentType = FALSE, debug = debug)
      out_headers <- httr::headers(out)
    }
    if(httr::status_code(out) >= 400) {
      stop("HTTP request failed with status: ",
           httr::status_code(out), " ", httr::message_for_status(out))
    }
    content <- httr::content(out, "text", encoding = "UTF-8")
  }
    
  status <- tryCatch({
    if((attr(regexpr("<!DOCTYPE html>", content), "match.length") == -1) && 
       (attr(regexpr("<html>", content), "match.length") == -1)){
      
      #check the presence of a BOM
      BOM <- "\ufeff"
      if(attr(regexpr(BOM, content), "match.length") != - 1){
        content <- gsub(BOM, "", content)
      }
      
      #check presence of XML comments
      content <- gsub("<!--.*?-->", "", content)
      
      #check presence of invalid XML entities
      content <- gsub("&ldquo;", "&quot;", content)
      content <- gsub("&rdquo;", "&quot;", content)
      content <- gsub("&lsquo;", "'", content)
      content <- gsub("&rsquo;", "'", content)
      
      xmlObj <- xmlTreeParse(content, useInternalNodes = TRUE)
      status <- 1
    }else{
      stop("Invalid SDMX-ML file")
    }
  },error = function(err){
    print(err)
    status <<- 0
    return(status)
  })
  
  #internal function for SDMX Structure-based document
  getSDMXStructureObject <- function(xmlObj, ns, resource){
    strTypeObj <- SDMXStructureType(xmlObj, ns, resource)
    strType <- getStructureType(strTypeObj)
    strObj <- switch(strType,
                     "DataflowsType" = SDMXDataFlows(xmlObj, ns),
                     "ConceptsType" = SDMXConcepts(xmlObj, ns),
                     "CodelistsType" = SDMXCodelists(xmlObj, ns),
                     "DataStructuresType" = SDMXDataStructures(xmlObj, ns),
                     "DataStructureDefinitionsType" = SDMXDataStructureDefinition(xmlObj, ns),
                     NULL
    )
    return(strObj)
  }  
  
  #encapsulate in S4 object
  obj <- NULL
  if(status){ 
    
    #namespaces
    ns <- namespaces.SDMX(xmlObj)
    
    #convenience for SDMX documents embedded in SOAP XML responses
    if(isSoapRequestEnvelope(xmlObj, ns)){
      xmlObj <- getSoapRequestResult(xmlObj)
    }
    
    #convenience for SDMX documents queried through a RegistryInterface
    if(isRegistryInterfaceEnvelope(xmlObj, TRUE)){
      xmlObj <- getRegistryInterfaceResult(xmlObj)
    }
    
    type <- SDMXType(xmlObj)@type
    obj <- switch(type,
                  "StructureType"             = getSDMXStructureObject(xmlObj, ns, resource),
                  "GenericDataType"           = SDMXGenericData(xmlObj, ns),
                  "CompactDataType"           = SDMXCompactData(xmlObj, ns),
                  "UtilityDataType"           = SDMXUtilityData(xmlObj, ns),
                  "StructureSpecificDataType" = SDMXStructureSpecificData(xmlObj, ns),
                  "StructureSpecificTimeSeriesDataType" = SDMXStructureSpecificTimeSeriesData(xmlObj, ns),
                  "CrossSectionalDataType"    = SDMXCrossSectionalData(xmlObj, ns),
                  "MessageGroupType"          = SDMXMessageGroup(xmlObj, ns),
                  NULL
    ) 
    
    if(is.null(obj)){
      if(type == "StructureType"){
        strTypeObj <- SDMXStructureType(xmlObj, ns, resource)
        type <- getStructureType(strTypeObj)
      }
      stop(paste("Unsupported SDMX Type '",type,"'",sep=""))
      
    }else{
      
      #handling footer messages
      footer <- slot(obj, "footer")
      footer.msg <- slot(footer, "messages") 
      if(length(footer.msg) > 0){
        invisible(
          lapply(footer.msg,
                 function(x){
                   code <- slot(x,"code")
                   severity <- slot(x,"severity")
                   lapply(slot(x,"messages"),
                          function(msg){
                            warning(paste(severity," (Code ",code,"): ",msg,sep=""),
                                    call. = FALSE)
                          }
                   )
                 })	
        )
      }
    }
  }else{
    #read SDMX object from RData file (.RData, .rda, .rds)
    if(isRData){
      if(!file.exists(file)) stop("File ", file, "not found\n")
      obj <- readRDS(file, refhook = XML::xmlDeserializeHook)
    }
  }
  
  #attempt to get DSD
  embeddedDSD <- FALSE
  if(is(obj, "SDMXData")){
    strTypeObj <- SDMXStructureType(obj@xmlObj, ns, NULL)
    if(!is.null(strTypeObj@subtype)){
      if(strTypeObj@subtype %in% c("CodelistsType", "DataStructureDefinitionsType")){
        dsd <- TRUE
        embeddedDSD <- TRUE
      }
    }
  }
  
  if(dsd){
    dsdObj <- NULL
    
    #in case codelist or DSD are embedded with data
    if(embeddedDSD){
      dsdObj <- SDMXDataStructureDefinition(obj@xmlObj, ns)
      slot(obj, "dsd") <- dsdObj
    }
    
    #using helpers strategy (with a resource parameter)
    if(buildRequest && resource %in% c("data","dataflow")){
      if(resource == "data" && providerId %in% c("ESTAT", "ISTAT", "ISTAT_LEGACY", "WBG_WITS", "CD2030", "IMF_DATA", "OECD")){
        log$INFO("Attempt to fetch DSD ref from dataflow description")
        flow <- readSDMX(providerId = providerId, providerKey = providerKey, resource = "dataflow",
                         resourceId = flowRef, headers = headers, verbose = TRUE, logger = logger,  
                         ...)
        dsdRef <- slot(slot(flow, "dataflows")[[1]],"dsdRef")
        rm(flow)
      }else{
        dsdRef <- NULL
        if(resource == "data"){
          dsdRef <- slot(obj, "dsdRef")
        }else if(resource=="dataflow"){
          dsdRef <- lapply(slot(obj,"dataflows"), slot,"dsdRef")
        }
        if(!is.null(dsdRef)){
          log$INFO(sprintf("DSD ref identified in dataset = '%s'", dsdRef))
          log$INFO("Attempt to fetch & bind DSD to dataset")
        }else{
          dsdRef <- flowRef
          log$WARN("No DSD ref associated to dataset")
          log$INFO("Attempt to fetch & bind DSD to dataset using 'flowRef'")
        }
      }
      
      if(resource == "data"){
        dsdObj <- readSDMX(providerId = providerId, providerKey = providerKey,
                          resource = "datastructure", resourceId = dsdRef, headers = headers,
                          verbose = verbose, references = references, logger = logger, ...)


        if(is.null(dsdObj)){
          log$WARN(sprintf("Impossible to fetch DSD for dataset '%s'", flowRef))
        }else{
          log$INFO("DSD fetched and associated to dataset!")
          slot(obj, "dsd") <- dsdObj
        }
      }else if(resource == "dataflow"){
        dsdObj <- lapply(1:length(dsdRef), function(x){
          flowDsd <- readSDMX(providerId = providerId, providerKey = providerKey,
                              resource = "datastructure", resourceId = dsdRef[[x]], headers = headers,
                              verbose = verbose, references = references, logger = logger, ...)
          if(is.null(flowDsd)){
            log$INFO(sprintf("Impossible to fetch DSD for dataflow '%s'",resourceId))
          }else{
            log$INFO("DSD fetched and associated to dataflow!")
            slot(slot(obj,"dataflows")[[x]],"dsd") <<- flowDsd
          }
        })
      }
    }
  }
  
  return(obj);
  
}

