package com.k_int.kbplus

import com.k_int.kbplus.auth.User
import grails.plugin.springsecurity.annotation.Secured // 2.0
import org.xml.sax.SAXException

@Secured(['IS_AUTHENTICATED_FULLY'])
class LicenseImportController {

  def CAT_TYPE = "UsageType",
      CAT_STATUS = "UsageStatus",
      CAT_DOCTYPE = 'Document Type',
      DOCTYPE = 'ONIX-PL License',
      DEFAULT_DOC_TITLE = 'ONIX-PL License document',
      CAT_USER = "User",
      CAT_USEDRESOURCE = "UsedResource"

  def MAX_FILE_SIZE_MB = 10
  def MAX_FILE_SIZE    = MAX_FILE_SIZE_MB * 1024 * 1024 // 10Mb
  // These values are used in the view
  def CMD_REPLACE_OPL  = "replace"
  def CMD_CREATE_OPL   = "create"

  def springSecurityService
  def onixplPrefix = 'onixPL:'

  /**
   * Main request-handling method.
   * Review the offered import to make sure it is a valid ONIX-PL file.
   * @return
   */
  @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
  def doImport() {
    // log.debug("Ghost_license" + grails.util.Holders.config.onix_ghost_license);
    // Setup result object
    def result = [:]
    result.validationResult = [:]
    result.validationResult.messages = []
    result.validationResult.errors = []

    // Identify user
    if (!"anonymousUser".equals(springSecurityService.principal)) {
      result.user = User.get(springSecurityService.principal.id);
    }

    // Find a license if id specified
    if (params.license_id) {
      log.debug("Import requested with license id ${params.license_id}")
      result.license_id = params.license_id
      result.license    = License.findById(params.license_id)
    }

    // Now process if a form was posted
    if ( request.method == 'POST' ) {
      // Record form submission values
      result.import_file   = params.import_file?.getOriginalFilename()
      // hidden values
      result.upload_title  = DEFAULT_DOC_TITLE
      result.uploaded_file = params.uploaded_file
      result.upload_mime_type = params.upload_mime_type
      result.upload_filename = params.upload_filename
      result.existing_opl_id = params.existing_opl_id
      result.description = params.description
      result.existing_opl = OnixplLicense.findById(result.existing_opl_id)

      // A file offered for upload
      def offered_multipart_file = request.getFile("import_file")

      // If a replace_opl result is specified, record it
      if (params.replace_opl) {
        //log.debug("replace_opl ${params.replace_opl}")
        result.replace_opl  = params.replace_opl
      }
      // Otherwise check upload file
      else if (!result.existing_opl) {
        // Check user-specified params
        if (!result.import_file) {
          result.validationResult.errors.add("Please specify a file to upload.")
          return result
        }
        if (request.getFile("import_file").size > MAX_FILE_SIZE) {
          result.validationResult.errors.add(
              "The file is too large - max size is ${MAX_FILE_SIZE_MB} Mb.")
          return result
        }
      }

      // Process the upload file appropriately
      try {
        // Read file if one is being offered for upload, and check if it matches
        // an existing OPL
        if (offered_multipart_file) {
          log.debug("Request to upload ONIX-PL file type: ${offered_multipart_file.contentType}" + " filename ${offered_multipart_file.originalFilename}");

          // 1. Read the file and parse it as XML - Extract properties and set them on the onix_parse_result map
          def onix_parse_result = readOnixMultipartFile(offered_multipart_file)
          if (onix_parse_result.errors) {
            result.validationResult.errors.addAll(onix_parse_result.errors)
            return result
          }
          result.offered_file = offered_multipart_file
          result.accepted_file = onix_parse_result


          result.putAll(onix_parse_result)

          result.validationResult.messages.add("Document validated: ${offered_multipart_file.originalFilename}")
          log.debug("Passed first phase validation")

          // If the specified license does not already have an OPL associated,
          // check for existing OPLs that appear to match.
          // If the license does have an OPL, it is replaced by default.
          if (!result.license?.onixplLicense) {
            // Save the upload to a temp file if the license matches an existing one
            def existingOpl = checkForExistingOpl(result.accepted_file, result.license)
            if (existingOpl) {
              log.debug("Found existing opl "+existingOpl)
              // Create a temp file to hold the uploaded file, which will be
              // automatically deleted when JVM exits
              File tmp = File.createTempFile("opl_upload", ".xml")
              tmp.deleteOnExit()
              offered_multipart_file.transferTo(tmp)
              result.uploaded_file = tmp
              result.existing_opl = existingOpl
              return result
            }
          }
        }

        // Process the import and combine results
        result.validationResult.putAll(processImport(result))

      } catch (SAXException e) {
        result.validationResult.errors.add(
            "Could not parse file; is this a valid ONIX-PL file?");
      } catch (IOException e) {
        result.validationResult.errors.add(
            "There was an error processing the file; please check the " +
                "file you have supplied is a valid ONIX-PL file, try again.");
      }
    }

    // Redirect to some ONIX-PL display page
    //log.debug("Redirecting...");
    //redirect controller: 'licenseDetails', action:'onixpl', id:params.licid, fragment:params.fragment
    log.debug("Returning result ${result}")
    result
  }


  /**
   * Verify an uploaded file and extract metadata.
   *
   * @param file a MultipartFile upload
   * @return a onix_parse_result object with extracted metadata
   * @throws SAXException
   * @throws IOException
   */
  @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
  def readOnixMultipartFile(file) throws SAXException, IOException {
    log.debug("Reading uploaded ONIX-PL file ${file?.originalFilename} " +
        "of type ${file?.contentType}")
    def onix_parse_result = [:]
    // Verify the character set of the offered ONIX-PL file, and read the title
    // if the file is okay.
    def charset = UploadController.checkCharset(file?.inputStream)
    if  ( ( charset != null ) && ( ! charset.equals('UTF-8') ) ) {
      onix_parse_result.errors = []
      onix_parse_result.errors.add("Detected input character stream encoding: ${charset}. Expected UTF-8.")
      return onix_parse_result
    } else {
      // Extract the description, (original k-int code)
      def response = new XmlSlurper().parse(file.inputStream)
      onix_parse_result.description = new XmlSlurper().parse(file.inputStream).LicenseDetail.Description.text()

      // extract list of path to fields to be imported from onix-pl
      def pathList = buildImportPath(grailsApplication.config.onixImportFields)
    }

    // Record mime type, filename
    onix_parse_result.upload_mime_type = file?.contentType
    onix_parse_result.upload_filename = file?.originalFilename
    onix_parse_result.size = file?.size
    onix_parse_result
  }

    /** load fields from onix specified in config */
     @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
      def loadFields(pathList) {
         pathList.each { key, value ->
             String fieldPath = key
             fieldPath.concat(concatPath(value))
             log.debug(fieldPath)
         }
      }

    /** concat path */
    @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
    def concatPath(pathList) {
        String fieldPath
        pathList.each { key, value ->
            fieldPath.concat("${key}.")
            log.debug(fieldPath)
            fieldPath.concat(concatPath(value))
        }

        fieldPath
    }

  /** load fields from onix specified in config
  @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
  def loadFields(fieldsMap) {
      fieldsMap.each { key, value ->
          def keyList = fieldsMap.keySet() as List
          String fieldPath = keyList.join(".")
          log.debug(fieldPath)
          loadFields(value)
      }
  } */

    /** build path for import fields from onix-pl file */

    @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
    def buildImportPath(importFieldsMap) {
        def pathList = []

        importFieldsMap.each { key, value ->
            iterateEach(key, value, pathList)
        }

        pathList
    }

      /** recursive function for retreaving keys of map with each */
    @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
    def iterateEach(field, fieldMap, pathList) {

        fieldMap.each { key, value ->
            def gPath = field + "." + key
            if (!value.empty) {
                iterateEach(gPath, value, pathList)
            } else {
                pathList.add(gPath)
            }
        }
    }

        /**
   * Check whether an OPL exists with the same title.
   * --Check whether the license already points to an OPL or if one exists with
   * the same title.--
   * @param result
   * @return
   */
  @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
  def checkForExistingOpl(acceptedFile, license) {
    log.debug("Checking for existing OPL for acceptedFile ${acceptedFile} and license ${license}")
    //def existingOpl = license?.onixplLicense
    def existingOpl
    if (!existingOpl) {
      def fileDesc = acceptedFile?.description
      log.debug("Finding OPL by title '${fileDesc}'")
      existingOpl = OnixplLicense.findByTitle(fileDesc)
      // TODO Offer a selection? Do we really want multiple OPLs with same title?
      //existingOpls = OnixplLicense.findAllByTitle(fileDesc)
    }
    existingOpl
  }

  /**
   * Process the uploaded license import file, creating database
   * records for the license, an associated KB+ license record, an uploaded
   * document in the docstore, and UsageTerms.
   * @param upload
   * @return a stats object about the import
   */
  @Secured(['ROLE_DATAMANAGER', 'ROLE_ADMIN', 'IS_AUTHENTICATED_FULLY'])
  def processImport(upload) {
    // log.debug("processImport(upload) "); upload.each{k,v-> log.debug("  ${k} -> ${v}")}
    //log.debug("Processing imported ONIX-PL document");
    // A stats struct holding summary info for display to the user
    def importResult = [:],
        // Whether to replace an existing OPL
        replaceOplRecord = upload.replace_opl==CMD_REPLACE_OPL,
        // Create a new doc record for the upload only if we are not replacing an existing OPL
        createNewDocument = !replaceOplRecord,
        // Create a new license if none is specified, and we are not updating
        // an OPL (in which case we assume the existing OPL is already linked
        // to licenses where necessary)
        createNewLicense = !upload.license && !replaceOplRecord,
        // Use specified license if there is one
        license = upload.license

    log.debug("replaceOplRecord: ${replaceOplRecord} createNewDocument: ${createNewDocument} createNewLicense: ${createNewLicense} upload.replace_opl: ${upload.replace_opl} license: ${upload.license!=null}")
    importResult.replace = replaceOplRecord
    RefdataValue currentStatus = RefdataCategory.lookupOrCreate(RefdataCategory.LIC_STATUS, 'Current')
    RefdataValue templateType  = RefdataCategory.lookupOrCreate(RefdataCategory.LIC_TYPE, 'Template')
    // Create a new license

    if (createNewLicense) {
      license = new License(
          reference     : upload.description,
          licenseStatus : currentStatus.value,
          licenseType   : templateType.value,
          status        : currentStatus,
          type          : templateType,
          lastmod       : new Date().time
      )
      // Save it
      if (!license.save(flush: true)) {
        license.errors.each {
          log.error("License error:" + it);
        }
      }
      //log.debug("Created template KB+ license for '${upload.description}': ${license}")
      log.debug("Created template KB+ license ${license}")
    }

    def onix_file_input_stream = upload.uploaded_file ? new FileInputStream(upload.uploaded_file) : upload.offered_file?.inputStream
    def onix_file_size = upload.uploaded_file ? new File(upload.uploaded_file).size() : upload.offered_file?.size

    def doctype = RefdataCategory.lookupOrCreate(CAT_DOCTYPE, DOCTYPE);
    def doc_content, doc_context

    // If we are creating a new document for the upload
    if (createNewDocument) doc_content = new Doc(contentType: Doc.CONTENT_TYPE_BLOB)

    // Otherwise update the existing doc's description
    else doc_content = upload.existing_opl.doc

    // Update doc properties
    doc_content.uuid     = java.util.UUID.randomUUID().toString()
    doc_content.filename = upload.uploaded_file
    doc_content.mimeType = upload.upload_mime_type
    doc_content.title    = upload.upload_title
    doc_content.type     = doctype
    doc_content.user     = upload.user
    doc_content.setBlobData(onix_file_input_stream, onix_file_size)
    doc_content.save(flush:true)

    log.debug("${createNewDocument?'Created new':'Updated'} document ${doc_content}")
    // Record a doc context if there is a new document or a new license.
    // We don't want duplicate doc_contexts.
    if (createNewDocument || createNewLicense) {
      doc_context = new DocContext(
          license: license,
          owner:   doc_content,
          doctype: doctype
      ).save(flush:true)
      log.debug("Created new document context ${doc_context}")
    }

    // Create an OnixplLicense and update the KB+ License
    def opl
    if (replaceOplRecord) {
      opl = upload.existing_opl
      opl.lastmod = new Date()
      opl.doc = doc_content
      opl.title = upload.description
      opl.save()
    } else {
      def opl_title = upload.description
      // two licenses with the same name will make searching and selection for comparison a problem
      // for now append upload date to distinguish, users can suggest different approach
      if(OnixplLicense.findByTitle(opl_title)){
          def upload_date = new java.text.SimpleDateFormat('yyyy-MM-dd HH:mm').format(new Date())
          opl_title += " (${upload_date})"
      }
      opl = recordOnixplLicense(doc_content, opl_title)
    }
    log.debug("${replaceOplRecord?'Updated':'Created new'} ONIX-PL License ${opl}")
    // If a single license is specified, link it to the OPL
    if (license) {
      license.onixplLicense = opl
      license.save(flush:true)
      log.debug("Linked OPL ${opl.id} to LIC ${license.id}")
    }
    importResult.license = license
    importResult.onixpl_license = opl


    importResult.success = true

    importResult
  }



  // -------------------------------------------------------------------------
  // Domain object creation methods
  // -------------------------------------------------------------------------

  /**
   * Record a new ONIX-PL License in the database, linked to the given KB+
   * license and uploaded Doc.
   *
   * @param doc an uploaded Doc
   * @return an OnixplLicense, or null
   */
  def recordOnixplLicense(doc, title) {
    def opl = null;
    try {
      opl = new OnixplLicense(
          lastmod:new Date(),
          doc: doc,
          title: title
      );
      opl.save(flush:true, failOnError: true);
      //log.debug("Created ONIX-PL License ${opl}");
    } catch (Exception e) {
      log.debug("Exception saving ONIX-PL License");
      e.printStackTrace();
    }
    return opl;
  }
}

