package com.k_int.kbplus
import org.elasticsearch.client.*
import org.elasticsearch.client.Client
import org.elasticsearch.index.IndexNotFoundException


class ESSearchService{
// Map the parameter names we use in the webapp with the ES fields
  def reversemap = ['subject':'subject', 
                    'provider':'provid',
                    'type':'rectype',
                    'endYear':'endYear',
                    'startYear':'startYear',
                    'consortiaName':'consortiaName',
                    'cpname':'cpname',
                    'availableToOrgs':'availableToOrgs',
                    'isPublic':'isPublic',
                    'lastModified':'lastModified']

  def ESWrapperService
  def grailsApplication

  def search(params){
    search(params,reversemap)
  }

  def search(params, field_map){
    // log.debug("Search Index, params.coursetitle=${params.coursetitle}, params.coursedescription=${params.coursedescription}, params.freetext=${params.freetext}")
    log.debug("ESSearchService::search - ${params}")

   def result = [:]

   Client esclient = params.esgokb ? ESWrapperService.getGOKBClient() : ESWrapperService.getClient()
   def index = params.esgokb ? (grailsApplication.config.aggr_es_gokb_index ?: "gokb") : (grailsApplication.config.aggr_es_index ?: ESWrapperService.ES_INDEX)
   params = testIndexExist(esclient, params, field_map, index)
   esclient = params.esgokb ? ESWrapperService.getGOKBClient() : ESWrapperService.getClient()
   index = params.esgokb ? (grailsApplication.config.aggr_es_gokb_index ?: "gokb") : (grailsApplication.config.aggr_es_index ?: ESWrapperService.ES_INDEX)

    try {
      if ( (params.q && params.q.length() > 0) || params.rectype || params.esgokb) {
  
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.offset = params.offset ? params.int('offset') : 0

        def query_str = buildQuery(params,field_map)
        if (params.tempFQ) //add filtered query
        {
            query_str = query_str + " AND ( " + params.tempFQ + " ) "
            params.remove("tempFQ") //remove from GSP access
        }

        log.debug("index:${index} query: ${query_str}");
        def search1 = esclient.search{
                  indices index
                  source {
                    from = params.offset
                    size = params.max
                    sort = params.sort?[
                      ("${params.sort}".toString()) : [ 'order' : (params.order?:'asc') ]
                    ] : []

                    query {
                      query_string (query: query_str)
                    }
                    aggregations {
                      consortiaName {
                        terms {
                          field = 'consortiaName'
                          size = 25
                        }
                      }
                      cpname {
                        terms {
                          field = 'cpname'
                          size = 25
                        }
                      }
                      type {
                        terms {
                          field = 'rectype'
                          size = 25
                        }
                      }
                      startYear {
                        terms {
                          field = 'startYear'
                          size = 25
                        }
                      }
                      endYear {
                        terms {
                          field = 'endYear'
                          size = 25
                        }
                      }
                    }

                  }

                }.actionGet()

        if ( search1 ) {
          def search_hits = search1.hits
          result.hits = search_hits.hits
          result.resultsTotal = search_hits.totalHits
          result.index = index

          // We pre-process the facet response to work around some translation issues in ES
          if (search1.getAggregations()) {
            result.facets = [:]
            search1.getAggregations().each { entry ->
              def facet_values = []
              entry.buckets.each { bucket ->
                log.debug("Bucket: ${bucket}");
                bucket.each { bi ->
                  log.debug("Bucket item: ${bi} ${bi.getKey()} ${bi.getDocCount()}");
                  facet_values.add([term: bi.getKey(), display: bi.getKey(), count: bi.getDocCount()])
                }
              }
              result.facets[entry.getName()] = facet_values

            }
          }
        }
      }
      else {
        log.debug("No query.. Show search page")
      }
    }
    finally {
      try {
      }
      catch ( Exception e ) {
        log.error("problem",e);
      }
    }
    result
  }

  def buildQuery(params,field_map) {
    log.debug("BuildQuery... with params ${params}. ReverseMap: ${field_map}");

    StringWriter sw = new StringWriter()

    if ( params?.q != null ){
      sw.write(params.q)
    }
      
    if(params?.rectype){
      if(sw.toString()) sw.write(" AND ");
      sw.write(" rectype:'${params.rectype}' ")
    }

    if(params?.esgokb){
          if(sw.toString()) sw.write(" AND ");
          sw.write(" componentType:\"${params.esgokb}\" ")
    }

      field_map.each { mapping ->

      if ( params[mapping.key] != null ) {
        if ( params[mapping.key].class == java.util.ArrayList) {
          if(sw.toString()) sw.write(" AND ");
          sw.write(" ( (( NOT rectype:\"Subscription\" ) AND ( NOT rectype:\"License\" )) ")

          params[mapping.key].each { p ->
            if(p == params[mapping.key].first())
            {
              sw.write(" OR ( ")
            }
            sw.write(" ( ")
            sw.write(mapping.value)
            sw.write(":")
            sw.write("\"${p}\"")
            sw.write(" ) ")
            if(p == params[mapping.key].last()) {
              sw.write(" ) ")
            }else{
              sw.write(" OR ")
            }

          }
          sw.write(" ) ")
        }
        else {
          // Only add the param if it's length is > 0 or we end up with really ugly URLs
          // II : Changed to only do this if the value is NOT an *

          log.debug("Processing ${params[mapping.key]} ${mapping.key}");

          try {
            if ( params[mapping.key] ) {
              if ( params[mapping.key].length() > 0 && ! ( params[mapping.key].equalsIgnoreCase('*') ) ) {
                if(sw.toString()) sw.write(" AND ");
                sw.write(mapping.value)
                sw.write(":")
                if(params[mapping.key].startsWith("[") && params[mapping.key].endsWith("]")){
                  sw.write("${params[mapping.key]}")
                }else{
                  sw.write("\"${params[mapping.key]}\"")
                }
              }
            }
          }
          catch ( Exception e ) {
            log.error("Problem procesing mapping, key is ${mapping.key} value is ${params[mapping.key]}",e);
          }
        }
      }
    }

    def result = sw.toString();
    result;
  }

  def testIndexExist(esclient, params, field_map, index)
  {
    if ( (params.q && params.q.length() > 0) || params.rectype || params.esgokb) {

      params.max = Math.min(params.max ? params.int('max') : 15, 100)
      params.offset = params.offset ? params.int('offset') : 0

      def query_str = buildQuery(params, field_map)
      if (params.tempFQ) //add filtered query
      {
        query_str = query_str + " AND ( " + params.tempFQ + " ) "
        params.remove("tempFQ") //remove from GSP access
      }

      def search
      try {
        search = esclient.search {
          indices index
          source {
            from = params.offset
            size = params.max
            sort = params.sort ? [
                    ("${params.sort}".toString()): ['order': (params.order ?: 'asc')]
            ] : []

            query {
              query_string(query: query_str)
            }
            aggregations {
              consortiaName {
                terms {
                  field = 'consortiaName'
                  size = 25
                }
              }
              cpname {
                terms {
                  field = 'cpname'
                  size = 25
                }
              }
              type {
                terms {
                  field = 'rectype'
                  size = 25
                }
              }
              startYear {
                terms {
                  field = 'startYear'
                  size = 25
                }
              }
              endYear {
                terms {
                  field = 'endYear'
                  size = 25
                }
              }
            }

          }

        }.actionGet()

      } catch (IndexNotFoundException e) {
        if (params.esgokb) {
          params.remove("esgokb")
          params.rectype = "Package"
        }
      }
    }
    return params
  }

}
