package com.k_int.kbplus

import grails.plugins.springsecurity.Secured
import org.springframework.dao.DataIntegrityViolationException
import com.k_int.kbplus.auth.User

class PersonController {

    def springSecurityService
    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def index() {
        redirect action: 'list', params: params
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [personInstanceList: Person.list(params), personInstanceTotal: Person.count()]
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def create() {
        def userMemberships = []
        User.get(springSecurityService.principal.id).affiliations.each{ uo ->
            userMemberships << uo.org
        }

        // TODO remove this fallback !!!!
        if(userMemberships.size() == 0){
            userMemberships = Org.list()
        }
        
        switch (request.method) {
		case 'GET':
            def personInstance = new Person(params)
            // processing dynamic form data
            addPersonRoles(personInstance)
            
        	[personInstance: personInstance, userMemberships: userMemberships]
			break
		case 'POST':
	        def personInstance = new Person(params)
	        if (!personInstance.save(flush: true)) {
	            render view: 'create', model: [personInstance: personInstance, userMemberships: userMemberships]
	            return
	        }
            // processing dynamic form data
            addPersonRoles(personInstance)
            
			flash.message = message(code: 'default.created.message', args: [message(code: 'person.label', default: 'Person'), personInstance.id])
	        redirect action: 'show', id: personInstance.id
			break
		}
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def show() {
        def personInstance = Person.get(params.id)
        if (!personInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'person.label', default: 'Person'), params.id])
            redirect action: 'list'
            return
        }

        [personInstance: personInstance]
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def edit() {
        def userMemberships = []
        User.get(springSecurityService.principal.id).affiliations.each{ uo ->
            userMemberships << uo.org
        }
        
		switch (request.method) {
		case 'GET':
	        def personInstance = Person.get(params.id)
	        if (!personInstance) {
	            flash.message = message(code: 'default.not.found.message', args: [message(code: 'person.label', default: 'Person'), params.id])
	            redirect action: 'list'
	            return
	        }
            // processing dynamic form data
            addPersonRoles(personInstance)
            deletePersonRoles(personInstance)
            
            // current owner must be present
            if(personInstance.owner){
                userMemberships << personInstance.owner 
            }
            
	        [personInstance: personInstance, userMemberships: userMemberships]
			break
		case 'POST':
	        def personInstance = Person.get(params.id)
	        if (!personInstance) {
	            flash.message = message(code: 'default.not.found.message', args: [message(code: 'person.label', default: 'Person'), params.id])
	            redirect action: 'list'
	            return
	        }

	        if (params.version) {
	            def version = params.version.toLong()
	            if (personInstance.version > version) {
	                personInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
	                          [message(code: 'person.label', default: 'Person')] as Object[],
	                          "Another user has updated this Person while you were editing")
	                render view: 'edit', model: [personInstance: personInstance, userMemberships: userMemberships]
	                return
	            }
	        }

	        personInstance.properties = params

	        if (!personInstance.save(flush: true)) {
	            render view: 'edit', model: [personInstance: personInstance, userMemberships: userMemberships]
	            return
	        }
            // processing dynamic form data
            addPersonRoles(personInstance)
            deletePersonRoles(personInstance)
            
            // current owner must be present
            if(personInstance.owner){
                userMemberships << personInstance.owner 
            }
            
			flash.message = message(code: 'default.updated.message', args: [message(code: 'person.label', default: 'Person'), personInstance.id])
	        redirect action: 'show', id: personInstance.id
			break
		}
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def delete() {
        def personInstance = Person.get(params.id)
        if (!personInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'person.label', default: 'Person'), params.id])
            redirect action: 'list'
            return
        }

        try {
            personInstance.delete(flush: true)
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'person.label', default: 'Person'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'person.label', default: 'Person'), params.id])
            redirect action: 'show', id: params.id
        }
    }
    
    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    def ajax() {        
        def person                  = Person.get(params.id)
        def existingPrsLinks
        
        def allSubjects             // all subjects of given type
        def subjectType             // type of subject
        def subjectFormOptionValue
        
        def cmd      = params.cmd
        def roleType = params.roleType
        
        // requesting form for deleting existing personRoles
        if('list' == cmd){ 
            
            if(person){
                if('func' == roleType){
                    def rdc = RefdataCategory.findByDesc('Person Function')
                    def hqlPart = "from PersonRole as PR where PR.prs = ${person?.id} and PR.functionType.owner = ${rdc.id}"  
                    existingPrsLinks = PersonRole.findAll(hqlPart) 
                }
                else if('resp' == roleType){
                    def rdc = RefdataCategory.findByDesc('Person Responsibility')
                    def hqlPart = "from PersonRole as PR where PR.prs = ${person?.id} and PR.responsibilityType.owner = ${rdc.id}"  
                    existingPrsLinks = PersonRole.findAll(hqlPart)
                }

                render view: 'ajax/listPersonRoles', model: [
                    existingPrsLinks: existingPrsLinks
                ]
                return
            }
            else {
                render "No Data found."
                return
            }
        }
        
        // requesting form for adding new personRoles
        else if('add' == cmd){ 
            
            def roleRdv = RefdataValue.get(params.roleTypeId)

            if('func' == roleType){
                
                // only one rdv of person function
            }
            else if('resp' == roleType){
                
                if(roleRdv?.value == "Specific cluster editor") {
                    allSubjects             = Cluster.getAll()
                    subjectType             = "cluster"
                    subjectFormOptionValue  = "name"
                }
                else if(roleRdv?.value == "Specific licence editor") {
                    allSubjects             = License.getAll()
                    subjectType             = "license"
                    subjectFormOptionValue  = "reference"
                }
                else if(roleRdv?.value == "Specific package editor") {
                    allSubjects             = Package.getAll()
                    subjectType             = "package"
                    subjectFormOptionValue  = "name"
                }
                else if(roleRdv?.value == "Specific subscription editor") {
                    allSubjects             = Subscription.getAll()
                    subjectType             = "subscription"
                    subjectFormOptionValue  = "name"
                }
                else if(roleRdv?.value == "Specific title editor") {
                    allSubjects             = TitleInstance.getAll()
                    subjectType             = "titleInstance"
                    subjectFormOptionValue  = "normTitle"
                }
            }
            
            render view: 'ajax/addPersonRole', model: [
                personInstance:     person,
                allOrgs:            Org.getAll(),
                allSubjects:        allSubjects,
                subjectType:        subjectType,
                subjectOptionValue: subjectFormOptionValue,
                existingPrsLinks:   existingPrsLinks,
                roleType:           roleType,
                roleRdv:            roleRdv,
                org:                Org.get(params.org),        // through passing for g:select value
                timestamp:          System.currentTimeMillis()
                ]
            return
        }
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    private deletePersonRoles(Person prs){

        params?.personRoleDeleteIds?.each{ key, value ->
             def prsRole = PersonRole.get(value)
             if(prsRole) {
                 log.debug("deleting PersonRole ${prsRole}")
                 prsRole.delete(flush:true);
             }
        }
    }

    @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
    private addPersonRoles(Person prs){
    
        params?.functionType?.each{ key, value ->
            def result
            
            def roleRdv = RefdataValue.get(params.functionType[key])
            def org     = Org.get(params.org[key])

            result = new PersonRole(prs:prs, functionType:roleRdv, org:org)
            
            if(PersonRole.find("from PersonRole as PR where PR.prs = ${prs.id} and PR.org = ${org.id} and PR.functionType = ${roleRdv.id}")) {
                log.debug("ignore adding PersonRole because of existing duplicate")
            } else if(result){
                if(result.save(flush:true)) {
                    log.debug("adding PersonRole ${result}")
                } else {
                    log.error("problem saving new PersonRole ${result}")
                }
            }
       }
        
       params?.responsibilityType?.each{ key, value ->     
           def result
           
           def roleRdv      = RefdataValue.get(params.responsibilityType[key])
           def org          = Org.get(params.org[key])
           def subject      // dynamic
           def subjectType  = params.subjectType[key]
           
           switch(subjectType) {
               case "cluster":
                   if(params.cluster){
                       subject = Cluster.get(params.cluster[key])
                       result = new PersonRole(prs:prs, responsibilityType:roleRdv, org:org, cluster:subject)
                   }
               break;
               case"license":
                   if(params.license){
                       subject = License.get(params.license[key])
                       result = new PersonRole(prs:prs, responsibilityType:roleRdv, org:org, lic:subject)
                   }
               break;
               case "package":
                   if(params.package){
                       subject = Package.get(params.package[key])
                       result = new PersonRole(prs:prs, responsibilityType:roleRdv, org:org, pkg:subject)
                   }
               break;
               case "subscription":
                   if(params.subscription){
                       subject = Subscription.get(params.subscription[key])
                       result = new PersonRole(prs:prs, responsibilityType:roleRdv, org:org, sub:subject)
                   }
               break;
               case "titleInstance":
                   if(params.titleInstance){
                       subject = TitleInstance.get(params.titleInstance[key])
                       result = new PersonRole(prs:prs, responsibilityType:roleRdv, org:org, title:subject)
                   }
               break;
           }
           
           // TODO duplicate check
           /* if(PersonRole.find("from PersonRole as PR where PR.prs = ${prs.id} and PR.org = ${org.id} and PR.responsibilityType = ${roleRdv.id} and PR.${typeTODOHERE} = ${subject.id}")) {
               log.debug("ignore adding PersonRole because of existing duplicate")
           }
           else */ if(result){
               if(result.save(flush:true)) {
                   log.debug("adding PersonRole ${result}")
               } else {
                   log.error("problem saving new PersonRole ${result}")
               }
           }
       }
    }
}
