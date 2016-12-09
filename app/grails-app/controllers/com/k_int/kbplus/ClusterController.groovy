package com.k_int.kbplus

import com.k_int.kbplus.ajax.AjaxOrgRoleHandler
import org.springframework.dao.DataIntegrityViolationException

class ClusterController extends AjaxOrgRoleHandler {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [clusterInstanceList: Cluster.list(params), clusterInstanceTotal: Cluster.count()]
    }

    def create() {
		switch (request.method) {
		case 'GET':
        	[clusterInstance: new Cluster(params)]
			break
		case 'POST':
	        def clusterInstance = new Cluster(params)
	        if (!clusterInstance.save(flush: true)) {
	            render view: 'create', model: [clusterInstance: clusterInstance]
	            return
	        }

			flash.message = message(code: 'default.created.message', args: [message(code: 'cluster.label', default: 'Cluster'), clusterInstance.id])
	        redirect action: 'show', id: clusterInstance.id
			break
		}
    }

    def show() {
        def clusterInstance = Cluster.get(params.id)
        if (!clusterInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
            redirect action: 'list'
            return
        }

        [clusterInstance: clusterInstance]
    }

    def edit() {
		switch (request.method) {
		case 'GET':
	        def clusterInstance = Cluster.get(params.id)
	        if (!clusterInstance) {
	            flash.message = message(code: 'default.not.found.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
	            redirect action: 'list'
	            return
	        }

	        [clusterInstance: clusterInstance]
			break
		case 'POST':
	        def clusterInstance = Cluster.get(params.id)
	        if (!clusterInstance) {
	            flash.message = message(code: 'default.not.found.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
	            redirect action: 'list'
	            return
	        }

	        if (params.version) {
	            def version = params.version.toLong()
	            if (clusterInstance.version > version) {
	                clusterInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
	                          [message(code: 'cluster.label', default: 'Cluster')] as Object[],
	                          "Another user has updated this Cluster while you were editing")
	                render view: 'edit', model: [clusterInstance: clusterInstance]
	                return
	            }
	        }

	        clusterInstance.properties = params

	        if (!clusterInstance.save(flush: true)) {
	            render view: 'edit', model: [clusterInstance: clusterInstance]
	            return
	        }

			flash.message = message(code: 'default.updated.message', args: [message(code: 'cluster.label', default: 'Cluster'), clusterInstance.id])
	        redirect action: 'show', id: clusterInstance.id
			break
		}
    }

    def delete() {
        def clusterInstance = Cluster.get(params.id)
        if (!clusterInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
            redirect action: 'list'
            return
        }

        try {
            clusterInstance.delete(flush: true)
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'cluster.label', default: 'Cluster'), params.id])
            redirect action: 'show', id: params.id
        }
    }
    
    @Override
    def ajax() {
        // TODO: check permissions for operation
        
        switch(params.op){
            case 'add':
                ajaxOrgRoleAdd()
                return
            break;
            case 'delete':
                ajaxOrgRoleDelete()
                return
            break;
            default:
                ajaxOrgRoleList()
                return
            break;
        }
    }
    @Override
    def private ajaxOrgRoleList() {
        def clusterInstance = Cluster.get(params.id)
        def orgs  = Org.getAll()
        def roles = RefdataValue.findAllByOwner(com.k_int.kbplus.RefdataCategory.findByDesc('Cluster Role'))
        
        render view: 'ajax/orgRoleList', model: [
            clusterInstance: clusterInstance, 
            orgs: orgs, 
            roles: roles
            ]
        return
    }
    @Override
    def private ajaxOrgRoleDelete() {
        
        def orgRole = OrgRole.get(params.orgRole)
        // TODO: switch to resolveOID/resolveOID2 ?
        
        //def orgRole = AjaxController.resolveOID(params.orgRole[0])
        if(orgRole) {
            log.debug("deleting OrgRole ${orgRole}")
            orgRole.delete(flush:true);
        }
        ajaxOrgRoleList()
    }
    @Override
    def private ajaxOrgRoleAdd() {
        
        def x    = Cluster.get(params.id)
        def org  = Org.get(params.org)
        def role = RefdataValue.get(params.role)
                
        def newOrgRole = new OrgRole(org:org, roleType:role, cluster: x)
        if ( newOrgRole.save(flush:true) ) {
            log.debug("adding OrgRole [ ${x}, ${org}, ${role}]")
        } else {
            log.error("Problem saving new orgRole...")
            newOrgRole.errors.each { e ->
                log.error(e)
            }
        }
        
        ajaxOrgRoleList()
    }
}