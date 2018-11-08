
<div class="ui divided middle aligned selection list la-flex-list">
    <g:each in="${OrgRoleTypes.sort { it?.getI10n("value") }}" var="type">
        <div class="ui item">
            <div class="content la-space-right">
                <strong>${type?.getI10n("value")}</strong>
            </div>
            <g:if test="${editable}">
                <div class="content la-space-right">
                    <div class="ui mini icon buttons">
                        <g:link class="ui negative button js-open-confirm-modal" data-confirm-term="diesen Organisationstyp"
                                controller="organisations" action="deleteOrgRoleType" params="[org: Org.id, removeOrgRoleType: type.id]">
                            <i class="trash alternate icon"></i>
                        </g:link>
                    </div>
                </div>
            </g:if>
        </div>
    </g:each>
</div>