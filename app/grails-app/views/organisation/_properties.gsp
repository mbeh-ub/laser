<%@ page import="com.k_int.kbplus.Org; com.k_int.kbplus.RefdataValue; com.k_int.kbplus.RefdataCategory; com.k_int.properties.*" %>
<laser:serviceInjection />
<!-- _properties -->

<g:set var="availPropDefGroups" value="${PropertyDefinitionGroup.getAvailableGroups(contextService.getOrg(), Org.class.name)}" />

<%-- modal --%>

<semui:modal id="propDefGroupBindings" message="propertyDefinitionGroup.config.label" hideSubmitButton="hideSubmitButton">

    <g:render template="/templates/properties/groupBindings" model="${[
            propDefGroup: propDefGroup,
            ownobj: orgInstance,
            availPropDefGroups: availPropDefGroups
    ]}" />

</semui:modal>

<div class="ui card la-dl-no-table la-js-hideable">

<%-- grouped custom properties --%>

    <g:set var="allPropDefGroups" value="${orgInstance.getCalculatedPropDefGroups(contextService.getOrg())}" />

    <% List<String> hiddenPropertiesMessages = [] %>

<g:each in="${allPropDefGroups.global}" var="propDefGroup">
    <%-- check visibility --%>
    <g:if test="${propDefGroup.isVisible}">

        <g:render template="/templates/properties/groupWrapper" model="${[
                propDefGroup: propDefGroup,
                propDefGroupBinding: null,
                prop_desc: PropertyDefinition.ORG_PROP,
                ownobj: orgInstance,
                custom_props_div: "grouped_custom_props_div_${propDefGroup.id}"
        ]}"/>
    </g:if>
    <g:else>
        <g:set var="numberOfProperties" value="${propDefGroup.getCurrentProperties(orgInstance)}" />
        <g:if test="${numberOfProperties.size() > 0}">
            <%
                hiddenPropertiesMessages << "${message(code:'propertyDefinitionGroup.info.existingItems', args: [propDefGroup.name, numberOfProperties.size()])}"
            %>
        </g:if>
    </g:else>
</g:each>

<g:each in="${allPropDefGroups.local}" var="propDefInfo">
    <%-- check binding visibility --%>
    <g:if test="${propDefInfo[1]?.isVisible}">

        <g:render template="/templates/properties/groupWrapper" model="${[
                propDefGroup: propDefInfo[0],
                propDefGroupBinding: propDefInfo[1],
                prop_desc: PropertyDefinition.ORG_PROP,
                ownobj: orgInstance,
                custom_props_div: "grouped_custom_props_div_${propDefInfo[0].id}"
        ]}"/>
    </g:if>
    <g:else>
        <g:set var="numberOfProperties" value="${propDefInfo[0].getCurrentProperties(orgInstance)}" />
        <g:if test="${numberOfProperties.size() > 0}">
            <%
                hiddenPropertiesMessages << "${message(code:'propertyDefinitionGroup.info.existingItems', args: [propDefInfo[0].name, numberOfProperties.size()])}"
            %>
        </g:if>
    </g:else>
</g:each>

<g:if test="${hiddenPropertiesMessages.size() > 0}">
    <div class="content">
        <semui:msg class="info" header="" text="${hiddenPropertiesMessages.join('<br/>')}" />
    </div>
</g:if>

<%-- orphaned properties --%>

<g:if test="${true}"><%-- todo: restrict? --%>

    <%--<div class="ui card la-dl-no-table la-js-hideable">--%>
    <div class="content">
        <h5 class="ui header">
            <g:if test="${allPropDefGroups.global || allPropDefGroups.local || allPropDefGroups.member}">
                ${message(code:'subscription.properties.orphaned')}
            </g:if>
            <g:else>
                ${message(code:'org.properties')}
            </g:else>
        </h5>

        <div id="custom_props_div_props">
            <g:render template="/templates/properties/custom" model="${[
                    prop_desc: PropertyDefinition.ORG_PROP,
                    ownobj: orgInstance,
                    orphanedProperties: allPropDefGroups.orphanedProperties,
                    custom_props_div: "custom_props_div_props" ]}"/>
        </div>
    </div>
    <%--</div>--%>

    <r:script language="JavaScript">
        $(document).ready(function(){
            c3po.initProperties("<g:createLink controller='ajax' action='lookup'/>", "#custom_props_div_props");
        });
    </r:script>

</g:if>

</div><!-- .card -->

<%-- private properties --%>
<g:if test="${accessService.checkPerm('ORG_INST,ORG_CONSORTIUM')}">

<g:each in="${authorizedOrgs}" var="authOrg">
    <g:if test="${authOrg.name == contextOrg?.name}">
        <div class="ui card la-dl-no-table">
            <div class="content">
                <h5 class="ui header">${message(code:'org.properties.private')} ${authOrg.name}</h5>

                <div id="custom_props_div_${authOrg.id}">
                    <g:render template="/templates/properties/private" model="${[
                            prop_desc: PropertyDefinition.ORG_PROP, // TODO: change
                            ownobj: orgInstance,
                            custom_props_div: "custom_props_div_${authOrg.id}",
                            tenant: authOrg
                    ]}"/>

                    <r:script language="JavaScript">
                            $(document).ready(function(){
                                c3po.initProperties("<g:createLink controller='ajax' action='lookup'/>", "#custom_props_div_${authOrg.id}", ${authOrg.id});
                            });
                    </r:script>
                </div>
            </div>
        </div><!--.card-->
    </g:if>
</g:each>

</g:if>

<!-- _properties -->