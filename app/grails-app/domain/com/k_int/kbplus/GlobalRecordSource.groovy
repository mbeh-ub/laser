package com.k_int.kbplus

import javax.persistence.Transient
 

class GlobalRecordSource {

  String identifier
  String name
  String type
  Date haveUpTo
  String uri
  String editUri
  String listPrefix
  String fullPrefix
  String principal
  String credentials
  Long rectype
  Boolean active

  Date dateCreated
  Date lastUpdated

  static mapping = {
                   id column:'grs_id'
              version column:'grs_version'
           identifier column:'grs_identifier'
                 name column:'grs_name', type:'text'
             haveUpTo column:'grs_have_up_to'
                  uri column:'grs_uri'
              editUri column:'grs_edit_uri'
           fullPrefix column:'grs_full_prefix'
           listPrefix column:'grs_list_prefix'
                 type column:'grs_type'
            principal column:'grs_principal'
          credentials column:'grs_creds'
              rectype column:'grs_rectype'
               active column:'grs_active'

        dateCreated column: 'grs_date_created'
      lastUpdated   column: 'grs_last_updated'
  }

  static constraints = {
     identifier(nullable:true, blank:false)
           name(nullable:true, blank:false, maxSize:2048)
       haveUpTo(nullable:true, blank:false)
            uri(nullable:true, blank:false)
        editUri(nullable:true, blank:false)
           type(nullable:true, blank:false)
     fullPrefix(nullable:true, blank:false)
     listPrefix(nullable:true, blank:false)
      principal(nullable:true, blank:false)
    credentials(nullable:true, blank:false)
         active(nullable:true, blank:false)

      // Nullable is true, because values are already in the database
      lastUpdated (nullable: true, blank: false)
      dateCreated (nullable: true, blank: false)
  }

  @Transient
  def getBaseUrl() {
    // For now, assume type=gokb - and trim off the oai/packages
    def result = uri.replaceAll('oai.*','');
    result
  }

  @Transient
  def getBaseEditUrl() {
      def result = editUri.replaceAll('oai.*','')
      result
  }

  @Transient
  def getNumberLocalPackages() {
    GlobalRecordSource.executeQuery("select count(*) from GlobalRecordTracker grt where grt.owner.source = ?",[this]);
  }

  @Transient
  static def removeSource(source_id) {
    def rel_info = GlobalRecordSource.executeQuery("select gri from GlobalRecordInfo as gri where gri.source.id = ?",[source_id])

    if(rel_info.size() > 0){
      rel_info.each { gri ->
        GlobalRecordSource.executeUpdate("delete GlobalRecordTracker grt where grt.owner = ?",[gri])
      }
    }

    GlobalRecordSource.executeUpdate("delete GlobalRecordInfo gri where gri.source.id = ?",[source_id])
    GlobalRecordSource.executeUpdate("delete GlobalRecordSource grs where grs.id = ?",[source_id])
  }
  
}
