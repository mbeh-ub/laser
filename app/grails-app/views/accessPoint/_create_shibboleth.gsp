<div id="details">
    <semui:form>
        <g:form action="create_${accessMethod}" controller="accessPoint" method="post" class="ui form">
            <g:render template="access_method" model="${[accessMethod: accessMethod]}"/>
            <g:render template="name" model="${[nameOptions: []]}"/>
            <div class="field required">
                <label>${message(code: 'accessPoint.entityId', default: 'EnitityId')}</label>
                <g:textField name="entityId" value="${entityId}" />
            </div>
            <input type="submit" class="ui button js-click-control" value="${message(code: 'default.button.create.label', default: 'Create')}"/>
        </g:form>
    </semui:form>
</div>