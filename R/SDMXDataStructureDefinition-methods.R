#' @name SDMXDataStructureDefinition
#' @rdname SDMXDataStructureDefinition
#' @aliases SDMXDataStructureDefinition,SDMXDataStructureDefinition-method
#' 
#' @usage
#' SDMXDataStructureDefinition(xmlObj, namespaces)
#' 
#' @param xmlObj object of class "XMLInternalDocument derived from XML package
#' @param namespaces object of class "data.frame" given the list of namespace URIs
#' @return an object of class "SDMXDataStructureDefinition"
#' 
#' @seealso \link{readSDMX}
#' @export
#' 
SDMXDataStructureDefinition <- function(xmlObj, namespaces){
  new("SDMXDataStructureDefinition",
      SDMX(xmlObj, namespaces),
      organisationSchemes = SDMXOrganisationSchemes(xmlObj, namespaces),
      concepts = SDMXConcepts(xmlObj, namespaces),
      codelists = SDMXCodelists(xmlObj, namespaces),
      datastructures = SDMXDataStructures(xmlObj, namespaces)
  )
}