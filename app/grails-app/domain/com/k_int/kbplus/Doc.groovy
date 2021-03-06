package com.k_int.kbplus

import com.k_int.kbplus.auth.User
import de.laser.helper.RefdataAnnotation
import org.hibernate.Session

import javax.persistence.Transient
import java.sql.Blob

class Doc {

    @Transient
    def grailsApplication

    static final CONTENT_TYPE_STRING              = 0
    static final CONTENT_TYPE_DOCSTORE            = 1
    static final CONTENT_TYPE_UPDATE_NOTIFICATION = 2
    static final CONTENT_TYPE_BLOB                = 3

  static transients = [ 'blobSize', 'blobData', 'sessionFactory' ]
  private static final MAX_SIZE = 1073741824 // 4GB 
  def sessionFactory

    @RefdataAnnotation(cat = 'Document Status')
    RefdataValue status

    @RefdataAnnotation(cat = 'Document Type')
    RefdataValue type

  String title
  String filename
  User creator
  String mimeType
  Integer contentType = CONTENT_TYPE_STRING
  String content 
  Blob blobContent 
  String uuid 
  Date dateCreated
  Date lastUpdated
  User user
  Org owner         //the context org of the user uploading a document
  String migrated

  static mapping = {
                id column:'doc_id'
           version column:'doc_version'
            status column:'doc_status_rv_fk'
              type column:'doc_type_rv_fk', index:'doc_type_idx'
       contentType column:'doc_content_type'
              uuid column:'doc_docstore_uuid', index:'doc_uuid_idx'
             title column:'doc_title'
           creator column:'doc_creator'
          filename column:'doc_filename'
           content column:'doc_content', type:'text'
       blobContent column:'doc_blob_content'
          mimeType column:'doc_mime_type'
              user column:'doc_user_fk'
             owner column:'doc_owner_fk'
  }

  static constraints = {
    status    (nullable:true, blank:false)
    type      (nullable:true, blank:false)
    content   (nullable:true, blank:false)
    blobContent(nullable:true, blank:false, maxSize:MAX_SIZE)
    uuid      (nullable:true, blank:false)
    contentType(nullable:true, blank:false)
    title     (nullable:true, blank:false)
    creator   (nullable:true, blank:true)
    filename  (nullable:true, blank:false)
    mimeType  (nullable:true, blank:false)
    user      (nullable:true, blank:false)
    owner     (nullable:true, blank:false)
    migrated  (nullable:true, blank:false, maxSize:1)
  }

    @Deprecated
  def setBlobData(InputStream is, long length) {
    Session hib_ses = sessionFactory.getCurrentSession()
    blobContent = hib_ses.getLobHelper().createBlob(is, length)
  }

    @Deprecated
  def getBlobData() {
    return blobContent?.binaryStream
  }

    @Deprecated
  Long getBlobSize() {
    return blobContent?.length() ?: 0
  }

    def render(def response, def filename) {
        // erms-790
        def output
        def contentLength

        try {
            def fPath = grailsApplication.config.documentStorageLocation ?: '/tmp/laser'
            def file = new File("${fPath}/${uuid}")
            output = file.getBytes()
            contentLength = output.length
        } catch(Exception e) {
            // fallback
            output = getBlobData()
            contentLength = getBlobSize()
        }

        response.setContentType(mimeType)
        response.addHeader("Content-Disposition", "attachment; filename=\"${filename}\"")
        response.setHeader('Content-Length', "${contentLength}")

        response.outputStream << output
    }
    
  static fromUpload(def file) {
    if(!file) return new Doc()
        
    def filename = file.originalFilename
    def slashIndex = Math.max(filename.lastIndexOf("/"),filename.lastIndexOf("\\"))
    if(slashIndex > -1) filename = filename.substring(slashIndex + 1)
        
    def doc = new Doc(filename: filename)
    doc.setBlobData(file.inputStream, file.size)
    return doc
  }

    // erms-790
    def beforeInsert = {
        if (contentType in [CONTENT_TYPE_BLOB, CONTENT_TYPE_DOCSTORE]) {
            log.info('generating new uuid')
            uuid = java.util.UUID.randomUUID().toString()
        }
    }
}
