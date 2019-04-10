<laser:serviceInjection />

<g:if test="${editable}">
    <semui:actionsDropdown>
        <semui:actionsDropdownItem message="task.create.new" data-semui="modal" href="#modalCreateTask" />
        <semui:actionsDropdownItem message="template.documents.add" data-semui="modal" href="#modalCreateDocument" />
        <semui:actionsDropdownItem message="template.addNote" data-semui="modal" href="#modalCreateNote" />

        <g:if test="${license.getLicensingConsortium()?.id == contextService.getOrg()?.id && ! license.isTemplate()}">
            <g:if test="${!( license.instanceOf && ! license.hasTemplate())}">
                <div class="divider"></div>

                <semui:actionsDropdownItem controller="license" action="addMembers" params="${[id:license?.id]}" message="myinst.emptyLicense.child" />
            </g:if>
        </g:if>

        <div class="divider"></div>

        <semui:actionsDropdownItem controller="license" action="copyLicense" params="${[id:license?.id]}" message="myinst.copyLicense" />

        <g:if test="${actionName == 'show'}">
            <g:if test="${springSecurityService.getCurrentUser().hasAffiliation("INST_EDITOR")}">
                <div class="divider"></div>
                <semui:actionsDropdownItem data-semui="modal" href="#propDefGroupBindings" text="Merkmalgruppen konfigurieren" />
            </g:if>

            <%--
            <g:if test="${showConsortiaFunctions}">
                <g:if test="${springSecurityService.getCurrentUser().hasAffiliation("INST_ADM")}">
                    <div class="divider"></div>
                    <semui:actionsDropdownItem id="audit_config_opener" message="property.audit.menu"/>
                </g:if>
            </g:if>
            --%>
        </g:if>

    </semui:actionsDropdown>

    <g:render template="/templates/documents/modal" model="${[ownobj:license, owntp:'license']}"/>
    <g:render template="/templates/notes/modal_create" model="${[ownobj: license, owntp: 'license']}"/>

    <%--<g:render template="/templates/audit/modal_script" model="${[ownobj: license]}" />--%>
</g:if>

<g:if test="${editable || accessService.checkMinUserOrgRole(user, contextOrg, 'INST_EDITOR')}">
    <g:render template="/templates/tasks/modal_create" model="${[ownobj:license, owntp:'license']}"/>
</g:if>