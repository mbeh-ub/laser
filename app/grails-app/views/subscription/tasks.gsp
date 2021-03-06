<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'subscription.label', default:'Subscription')}</title>
</head>
<body>

    <g:render template="breadcrumb" model="${[ params:params ]}"/>
    <semui:controlButtons>
        <g:render template="actions" />
    </semui:controlButtons>
    <h1 class="ui  icon header"><semui:headerIcon />
        <semui:xEditable owner="${subscriptionInstance}" field="name" />
    </h1>
    <semui:anualRings object="${subscriptionInstance}" controller="subscription" action="tasks" navNext="${navNextSubscription}" navPrev="${navPrevSubscription}"/>

    <g:render template="nav" />

    <g:if test="${subscriptionInstance.instanceOf && (contextOrg?.id in [subscriptionInstance.getConsortia()?.id,subscriptionInstance.getCollective()?.id])}">
        <g:render template="message" />
    </g:if>

    <semui:messages data="${flash}" />

    <g:render template="/templates/tasks/table" model="${[taskInstanceList:taskInstanceList, taskInstanceCount:taskInstanceCount]}"/>
    <g:render template="/templates/tasks/table2" model="${[taskInstanceList:myTaskInstanceList, taskInstanceCount:myTaskInstanceCount]}"/>
    <g:render template="/templates/tasks/js_taskedit"/>

</body>
</html>

