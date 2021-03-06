package com.k_int.kbplus

import org.apache.commons.logging.LogFactory

import javax.persistence.Transient

class Identifier {

  IdentifierNamespace ns
  String value
  IdentifierGroup ig

  Date dateCreated
  Date lastUpdated

  static hasMany = [ occurrences:IdentifierOccurrence]
  static mappedBy = [ occurrences:'identifier']

  static constraints = {
    value validator: {val,obj ->
      if (obj.ns.validationRegex){
        def pattern = ~/${obj.ns.validationRegex}/
        return pattern.matcher(val).matches() 
      }
    }
    ig(nullable:true, blank:false)

      // Nullable is true, because values are already in the database
      lastUpdated (nullable: true, blank: false)
      dateCreated (nullable: true, blank: false)
  }

  static mapping = {
       id column:'id_id'
    value column:'id_value', index:'id_value_idx'
       ns column:'id_ns_fk', index:'id_value_idx'
       ig column:'id_ig_fk', index:'id_ig_idx'

      dateCreated column: 'id_date_created'
      lastUpdated column: 'id_last_updated'

      occurrences   batchSize: 10
  }

  def beforeUpdate() {
    value = value?.trim()
      boolean forOrg = IdentifierOccurrence.findByIdentifier(this)

      if(forOrg) {
          if(this.ns?.ns == 'wibid')
          {
              if(!(this.value =~ /^WIB/) && this.value != '')
              {
                  this.value = 'WIB'+this.value.trim()
              }
          }

          if(this.ns?.ns == 'ISIL')
          {
              if(!(this.value =~ /^DE-/ || this.value =~ /^[A-Z]{2}-/) && this.value != '')
              {
                  this.value = 'DE-'+this.value.trim()
              }
          }
      }

  }

  static Identifier lookupOrCreateCanonicalIdentifier(ns, value) {
      println "loc canonical identifier"
      value = value?.trim()
      ns = ns?.trim()
      // println ("lookupOrCreateCanonicalIdentifier(${ns},${value})");
      IdentifierNamespace namespace
      Identifier result
      if(IdentifierNamespace.findByNsIlike(ns)) {
          namespace = IdentifierNamespace.findByNsIlike(ns)
          if(Identifier.findByNsAndValue(namespace,value)) {
              Identifier.findByNsAndValue(namespace,value)
          }
          else {
              result = new Identifier(ns:namespace, value:value)
              if(result.save())
                  result
          }
      }
      else {
          namespace = new IdentifierNamespace(ns:ns, isUnique: false, isHidden: false)
          if(namespace.save()) {
              result = new Identifier(ns:namespace, value:value)
              if(result.save())
                  result
              else {
                  println "error saving identifier"
                  println result.getErrors()
              }
          }
          else {
              println "error saving namespace"
              println namespace.getErrors()
          }
      }
  }

  static def refdataFind(params) {
    def result = [];
    def ql = null;
    if ( params.q.contains(':') ) {
      def qp=params.q.split(':');
      // println("Search by namspace identifier: ${qp}");
      def namespace = IdentifierNamespace.findByNsIlike(qp[0]);
      if ( namespace && qp.size() == 2) {
        ql = Identifier.findAllByNsAndValueIlike(namespace,"${qp[1]}%")
      }
    }
    else {
      ql = Identifier.findAllByValueIlike("${params.q}%",params)
    }

    if ( ql ) {
      ql.each { id ->
        result.add([id:"${id.class.name}:${id.id}",text:"${id.ns.ns}:${id.value}"])
      }
    }

    result
  }
    // called from AjaxController.lookup2
    static def refdataFind2(params) {
        def result = []
        if (params.q.contains(':')) {
            def qp = params.q.split(':');
            def namespace = IdentifierNamespace.findByNsIlike(qp[0]);
            if (namespace && qp.size() == 2) {
                def ql = Identifier.findAllByNsAndValueIlike(namespace,"${qp[1]}%")
                ql.each { id ->
                    result.add([id:"${id.class.name}:${id.id}", text:"${id.value}"])
                }
            }
        }
        result
    }

    static def refdataCreate(value) {
        // value is String[] arising from  value.split(':');
        if ( ( value.length == 4 ) && ( value[2] != '' ) && ( value[3] != '' ) )
            return lookupOrCreateCanonicalIdentifier(value[2],value[3]);

        return null;
    }

    static def lookupObjectsByIdentifierString(def object, String identifierString) {
        def result = null

        def objType = object.getClass().getSimpleName()
        LogFactory.getLog(this).debug("lookupByIdentifierString(${objType}, ${identifierString})")

        if (objType) {

            def idstrParts = identifierString.split(':');
            switch (idstrParts.size()) {
                case 1:
                    result = executeQuery('select t from ' + objType + ' as t join t.ids as io where io.identifier.value = ?', [idstrParts[0]])
                    break
                case 2:
                    result = executeQuery('select t from ' + objType + ' as t join t.ids as io where io.identifier.value = ? and io.identifier.ns.ns = ?', [idstrParts[1], idstrParts[0]])
                    break
                default:
                    break
            }
            LogFactory.getLog(this).debug("components: ${idstrParts} : ${result}");
        }

        result
    }

    @Transient
    def afterInsert = {


        if(this.ns?.ns == 'wibid')
        {
            if(this.value == 'Unknown')
            {
                this.value = ''
                this.save()
            }
        }

        if(this.ns?.ns == 'ezb')
        {
            if(this.value == 'Unknown')
            {
                this.value = ''
                this.save()
            }
        }

        if(this.ns?.ns == 'ISIL')
        {
            if(this.value == 'Unknown')
            {
                this.value = ''
                this.save()
            }
            else if(!(this.value =~ /^DE-/ || this.value =~ /^[A-Z]{2,3}-/) && this.value != '')
            {
                this.value = 'DE-'+this.value.trim()
            }

        }
    }



}
