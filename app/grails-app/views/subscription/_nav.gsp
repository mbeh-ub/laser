<laser:serviceInjection />

<semui:subNav actionName="${actionName}">

    <semui:subNavItem controller="subscription" action="show" params="${[id:params.id]}" message="subscription.details.details.label" />

    <g:if test="${controllerName != 'finance'}">%{-- template is used by subscriptionDetails/* and finance/index --}%
        <semui:subNavItem controller="subscription" action="index" params="${[id:params.id]}" message="subscription.details.current_ent" />
    </g:if>
    <g:else>%{-- prevent two active items with action 'index' due url mapping 'subfinance' --}%
        <g:link controller="subscription" action="index" params="${[id:params.id]}" class="item">${message('code': 'subscription.details.current_ent')}</g:link>
    </g:else>

    <g:if test="${showConsortiaFunctions || showCollectiveFunctions || subscriptionInstance.administrative}">
        <%
            String message
            if(showConsortiaFunctions)
                message = "subscription.details.consortiaMembers.label"
            else if(showCollectiveFunctions)
                message = "subscription.details.collectiveMembers.label"
        %>
        <semui:subNavItem controller="subscription" action="members" params="${[id:params.id]}" message="${message}" />

        <semui:securedSubNavItem orgPerm="ORG_CONSORTIUM_SURVEY" controller="subscription" action="surveysConsortia" params="${[id:params.id]}" message="subscription.details.surveys.label" />

        <sec:ifAnyGranted roles="ROLE_ADMIN">
            <semui:subNavItem controller="subscription" action="pendingChanges" params="${[id:params.id]}" text="TN-Änderungen" />
        </sec:ifAnyGranted>
    </g:if>

    <g:if test="${contextService.org?.getCustomerType() in ['ORG_INST', 'ORG_BASIC_MEMBER'] && subscriptionInstance?.type == de.laser.helper.RDStore.SUBSCRIPTION_TYPE_CONSORTIAL}">
        <semui:securedSubNavItem orgPerm="ORG_BASIC_MEMBER" controller="subscription" action="surveys" params="${[id:params.id]}" message="subscription.details.surveys.label" />
    </g:if>

    <semui:securedSubNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="subscription" action="tasks" params="${[id:params.id]}" message="task.plural" />



    <%-- <semui:subNavItem controller="subscription" action="renewals" params="${[id:params.id]}" message="subscription.details.renewals.label" /> --%>
    <%--
        <semui:subNavItem controller="subscription" action="previous" params="${[id:params.id]}" message="subscription.details.previous.label" />
        <semui:subNavItem controller="subscription" action="expected" params="${[id:params.id]}" message="subscription.details.expected.label" />
    --%>
    <%--
        <g:if test="${grailsApplication.config.feature_finance}">
            <semui:subNavItem controller="subscription" action="costPerUse" params="${[id:params.id]}" message="subscription.details.costPerUse.label" />
        </g:if>
    --%>

    <semui:securedSubNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="subscription" action="documents" params="${[id:params.id]}" message="default.documents.label" />
    <semui:subNavItem controller="subscription" action="notes" params="${[id:params.id]}" message="default.notes.label" />

    <g:if test="${grailsApplication.config.feature_finance}">
    %{--Custom URL mapping for re-use of index--}%

        <g:link class="item${controllerName == 'finance' ? ' active':''}" mapping="subfinance" controller="finance" action="index" params="${[sub:params.id]}">
            ${message(code:'subscription.details.financials.label', default:'Subscription Financials')}
        </g:link>

    </g:if>

    <semui:subNavItem controller="subscription" action="changes" params="${[id:params.id]}" message="license.nav.todo_history" />

    <sec:ifAnyGranted roles="ROLE_ADMIN">
        <semui:subNavItem controller="subscription" action="history" params="${[id:params.id]}" class="la-role-admin" message="license.nav.edit_history" />
        <semui:subNavItem controller="subscription" action="permissionInfo" params="${[id:params.id]}" class="la-role-admin" message="default.permissionInfo.label" />
    </sec:ifAnyGranted>
</semui:subNav>
