package com.k_int.kbplus

class ChangeNotificationQueueItem {

  String oid
  String changeDocument
  Date ts

  Date dateCreated
  Date lastUpdated

  static mapping = {
               oid column:'cnqi_oid'
    changeDocument column:'cnqi_change_document', type:'text'
                ts column:'cnqi_ts'

    dateCreated column: 'cnqi_date_created'
    lastUpdated column: 'cnqi_last_updated'
  }

  static constraints = {
    oid(nullable:false, blank:false);
    changeDocument(nullable:false, blank:false);
    ts(nullable:false, blank:false);

    // Nullable is true, because values are already in the database
    lastUpdated (nullable: true, blank: false)
    dateCreated (nullable: true, blank: false)
  }

}
