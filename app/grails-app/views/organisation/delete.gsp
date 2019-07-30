<g:set var="deletionService" bean="deletionService" />

<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI"/>
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'org.label')}</title>
</head>

<body>
    <g:render template="breadcrumb" model="${[ orgInstance:orgInstance, params:params ]}"/>

    <h1 class="ui left aligned icon header"><semui:headerIcon />
        ${orgInstance.name}
    </h1>

    <g:if test="${deletionService.RESULT_SUCCESS != result?.status}">
        <g:render template="nav" />
    </g:if>

    <g:if test="${dryRun}">
        <semui:msg class="info" header="" text="orgInstance.delete.info" />
        <br />
        <g:link controller="organisation" action="edit" params="${[id: orgInstance.id]}" class="ui button">Vorgang abbrechen</g:link>
        <g:if test="${editable}">
            <g:link controller="organisation" action="_delete" params="${[id: orgInstance.id, process: true]}" class="ui button red">Organisation löschen</g:link>
        </g:if>
        <br />
        <table class="ui celled la-table la-table-small table">
            <thead>
            <tr>
                <th>Anhängende, bzw. referenzierte Objekte</th>
                <th>Anzahl</th>
                <th>Objekt-Ids</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${dryRun.info.sort{ a,b -> a[0] <=> b[0] }}" var="info">
                <tr>
                    <td>
                        ${info[0]}
                    </td>
                    <td style="text-align:center">
                        <g:if test="${info.size() > 2 && info[1].size() > 0}">
                            <span class="ui circular label ${info[2]}"
                                <g:if test="${info[2] == 'red'}">
                                    data-tooltip="${message(code:'subscription.delete.blocker')}"
                                </g:if>
                                <g:if test="${info[2] == 'yellow'}">
                                    data-tooltip="${message(code:'subscription.existingCostItems.warning')}"
                                </g:if>
                            >${info[1].size()}</span>
                        </g:if>
                        <g:else>
                            ${info[1].size()}
                        </g:else>
                    </td>
                    <td>
                        ${info[1].collect{ item -> item.hasProperty('id') ? item.id : 'x'}.join(', ')}
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </g:if>

    <g:if test="${result?.status == deletionService.RESULT_SUCCESS}">
        <%--
        <semui:msg class="positive" header=""
                   text="Löschvorgang wurde erfolgreich durchgeführt." />
        <g:link controller="organisation" action="listInstitution" class="ui button">Alle Einrichtungen</g:link>
        --%>
    </g:if>
    <g:if test="${result?.status == deletionService.RESULT_QUIT}">
        <semui:msg class="negative" header="Löschvorgang abgebrochen"
                   text="Es existieren XYZ. Diese müssen zuerst gelöscht werden." />
        <g:link controller="organisation" action="_delete" params="${[id: orgInstance.id]}" class="ui button">Zur Übersicht</g:link>
    </g:if>
    <g:if test="${result?.status == deletionService.RESULT_ERROR}">
        <semui:msg class="negative" header="Unbekannter Fehler"
                   text="Der Löschvorgang wurde abgebrochen." />
        <g:link controller="organisation" action="_delete" params="${[id: orgInstance.id]}" class="ui button">Zur Übersicht</g:link>
    </g:if>

</body>
</html>
