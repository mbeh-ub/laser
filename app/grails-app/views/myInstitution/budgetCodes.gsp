<%@ page import="com.k_int.kbplus.CostItemGroup"%>

<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI"/>
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'menu.institutions.budgetCodes')}</title>
    </head>
    <body>

        <semui:breadcrumbs>
            <semui:crumb controller="myInstitution" action="dashboard" text="${institution?.getDesignation()}" />
            <semui:crumb message="menu.institutions.budgetCodes" class="active"/>
        </semui:breadcrumbs>

        <h1 class="ui header"><semui:headerIcon />${institution.name}</h1>

        <semui:messages data="${flash}" />

        <g:if test="${editable}">
            <div class="content ui form">
                <div class="fields">
                    <div class="field">
                        <button class="ui button" value="" href="#addBudgetCodeModal" data-semui="modal">${message(code:'budgetCode.create_new.label')}</button>
                    </div>
                </div>
            </div>
        </g:if>

    <table class="ui celled sortable table la-table la-table-small">
        <thead>
            <tr>
                <th>${message(code: 'financials.budgetCode')}</th>
                <th>Beschreibung</th>
                <th>Verwendung</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <g:each in="${budgetCodes}" var="bcode">
                <tr>
                    <td>
                        <semui:xEditable owner="${bcode}" field="value" />
                    </td>
                    <td>
                        <semui:xEditable owner="${bcode}" field="descr" />
                    </td>
                    <td>
                        <g:each in="${CostItemGroup.findAllByBudgetCode(bcode)}" var="cig">

                                <g:if test="${cig.costItem.costTitle}">
                                    ${cig.costItem.costTitle}
                                </g:if>
                                <g:else>
                                    ${cig.costItem.globalUID}
                                </g:else>
                                <g:if test="${cig.costItem.costDescription}">
                                    /
                                    ${cig.costItem.costDescription}
                                </g:if>
                                <br />
                        </g:each>
                    </td>
                    <td class="x">
                        <g:if test="${CostItemGroup.findAllByBudgetCode(bcode)}">
                            <g:link controller="myInstitution" action="finance"  class="ui icon button"
                                    params="[filterCIBudgetCode: bcode.value]">
                                <i class="share icon"></i>
                            </g:link>
                        </g:if>
                        <g:if test="${editable && ! CostItemGroup.findAllByBudgetCode(bcode)}">
                            <g:link controller="myInstitution" action="budgetCodes"
                                    params="${[cmd: 'deleteBudgetCode', bc: 'com.k_int.kbplus.BudgetCode:' + bcode.id]}" class="ui icon negative button">
                                <i class="trash alternate icon"></i>
                            </g:link>
                        </g:if>
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>


    <semui:modal id="addBudgetCodeModal" message="budgetCode.create_new.label">

        <g:form class="ui form" url="[controller: 'myInstitution', action: 'budgetCodes']" method="POST">
            <input type="hidden" name="cmd" value="newBudgetCode"/>

            <div class="field">
                <label>Beschreibung</label>
                <input type="text" name="bc"/>
            </div>

            <div class="field">
                <label>Beschreibung</label>
                <textarea name="descr"></textarea>
            </div>

        </g:form>
    </semui:modal>

  </body>
</html>