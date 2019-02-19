<%--
  Created by IntelliJ IDEA.
  User: galffy
  Date: 07.02.2019
  Time: 08:56
--%>
<!doctype html>
<html xmlns="http://www.w3.org/1999/html">
    <head>
        <meta name="layout" content="semanticUI"/>
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'subscription.details.financials.label')}</title>
    </head>
    <body>
        <laser:serviceInjection />
        <g:set var="own" value="${financialData.own}"/>
        <g:set var="cons" value="${financialData.cons}"/>
        <g:set var="subscr" value="${financialData.subscr}"/>
        <semui:breadcrumbs>
            <semui:crumb controller="myInstitution" action="dashboard" text="${contextService.getOrg()?.getDesignation()}" />
            <semui:crumb controller="myInstitution" action="currentSubscriptions" text="${message(code:'myinst.currentSubscriptions.label')}" />
            <semui:crumb class="active"  message="${subscription.name}" />
        </semui:breadcrumbs>

        <semui:controlButtons>
            <semui:exportDropdown>
                <semui:exportDropdownItem>
                    <g:if test="${params.submit || params.filterSubStatus}">
                        <g:link  class="item js-open-confirm-modal"
                                 data-confirm-term-content = "${message(code: 'confirmation.content.exportPartial', default: 'Achtung!  Dennoch fortfahren?')}"
                                 data-confirm-term-how="ok"
                                 controller="finance"
                                 action="financialsExport"
                                 params="${params+[forExport:true,sub:subscription.id]}">${message(code:'default.button.exports.xls', default:'XLS Export')}
                        </g:link>
                    </g:if>
                    <g:else>
                        <g:link class="item" controller="finance" action="financialsExport" params="${params+[forExport:true,sub:subscription.id]}">${message(code:'default.button.exports.xls', default:'XLS Export')}</g:link>
                    </g:else>
                </semui:exportDropdownItem>
            <%--
            <semui:exportDropdownItem>
                <a data-mode="sub" class="disabled export" style="cursor: pointer">CSV Costs by Subscription</a>
            </semui:exportDropdownItem>
            <semui:exportDropdownItem>
                <a data-mode="code" class="disabled export" style="cursor: pointer">CSV Costs by Code</a>
            </semui:exportDropdownItem>
            --%>
            </semui:exportDropdown>

            <g:if test="${editable}">
                <semui:actionsDropdown>
                    <semui:actionsDropdownItem id="btnAddNewCostItem" message="financials.addNewCost" />
                    <semui:actionsDropdownItemDisabled message="financials.action.financeImport" />
                <%--<semui:actionsDropdownItem controller="myInstitution" action="financeImport" message="financials.action.financeImport" />--%>
                </semui:actionsDropdown>
            </g:if>
        </semui:controlButtons>

        <g:if test="${showView.equals("cons")}">
            <g:set var="totalString" value="${own.count ? own.count : 0} ${message(code:'financials.header.ownCosts')} / ${cons.count} ${message(code:'financials.header.consortialCosts')}"/>
        </g:if>
        <g:elseif test="${showView.equals("consAtSubscr")}">
            <g:set var="totalString" value="${cons.count ? cons.count : 0} ${message(code:'financials.header.consortialCosts')}"/>
        </g:elseif>
        <g:elseif test="${showView.equals("subscr")}">
            <g:set var="totalString" value="${own.count ? own.count : 0} ${message(code:'financials.header.ownCosts')} / ${subscr.count} ${message(code:'financials.header.subscriptionCosts')}"/>
        </g:elseif>
        <g:else>
            <g:set var="totalString" value="${own.count ? own.count : 0} ${message(code:'financials.header.ownCosts')}"/>
        </g:else>

        <h1 class="ui left aligned icon header"><semui:headerIcon />${message(code:'subscription.details.financials.label')} ${message(code:'default.for')} ${subscription} <semui:totalNumber total="${totalString}"/>
            <semui:anualRings mapping="subfinance" object="${subscription}" controller="finance" action="index" navNext="${navNextSubscription}" navPrev="${navPrevSubscription}"/>
        </h1>

        <g:render template="../subscriptionDetails/nav" model="${[subscriptionInstance:subscription, params:(params << [id:subscription.id])]}"/>

        <g:if test="${showView.equals("consAtSubscr")}">
            <div class="ui negative message">
                <div class="header">
                    <g:message code="myinst.message.attention" />:
                    <g:message code="myinst.subscriptionDetails.message.ChildView" />
                    <span class="ui label">${subscription.getAllSubscribers().collect{itOrg -> itOrg.getDesignation()}.join(',')}</span>.
                </div>
                <p>
                    <g:message code="myinst.subscriptionDetails.message.hereLink" />
                    <g:link controller="subscriptionDetails" action="members" id="${subscription.instanceOf.id}">
                        <g:message code="myinst.subscriptionDetails.message.backToMembers" />
                    </g:link>
                    <g:message code="myinst.subscriptionDetails.message.and" />
                    <g:link controller="subscriptionDetails" action="show" id="${subscription.instanceOf.id}">
                        <g:message code="myinst.subscriptionDetails.message.consotialLicence" />
                    </g:link>.
                </p>
            </div>
        </g:if>

        <g:render template="result" model="[own:own,cons:cons,subscr:subscr,showView:showView,filterPresets:filterPresets,fixedSubscription:subscription]" />
    </body>
</html>