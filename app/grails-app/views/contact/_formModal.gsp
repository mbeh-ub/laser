<%@ page import="com.k_int.kbplus.Contact" %>

<semui:modal id="${modalId ?: 'contactFormModal'}"
             text="${message(code: 'default.add.label', args: [message(code: 'contact.label')])}">

    <g:form id="newContact" name="newContact" class="ui form" url="[controller: 'contact', action: 'create']" method="POST">
        <input type="hidden" name="redirect" value="true" />

        <div class="field">
            <div class="three fields">

                <div class="field eight wide required">
                    <label for="contentType">
                        <g:message code="contact.contentType.label" default="ContentType" />
                    </label>
                    <laser:select class="ui dropdown" id="contentType" name="contentType.id"
                        from="${com.k_int.kbplus.Contact.getAllRefdataValues('ContactContentType')}"
                        optionKey="id"
                        optionValue="value"
                        value="${contactInstance?.contentType?.id}"/>
                </div>

                <div class="field eight wide required">
                    <label for="type">
                        ${com.k_int.kbplus.RefdataCategory.findByDesc('ContactType').getI10n('desc')}
                    </label>
                    <laser:select class="ui dropdown" id="type" name="type.id"
                                  from="${com.k_int.kbplus.Contact.getAllRefdataValues('ContactType')}"
                                  optionKey="id"
                                  optionValue="value"
                                  value="${contactInstance?.type?.id}"/>
                </div>
            </div>
        </div>

        <div class="field fieldcontain required">
            <label for="content">
                <g:message code="contact.content.label" default="Content" />
            </label>
            <g:textField id="content" name="content" value="${contactInstance?.content}"/>
        </div>

        <g:if test="${!orgId}">
            <div class="field fieldcontain">
                <label for="prs">
                    <g:message code="contact.prs.label" default="Prs" />
                </label>
                <g:if test="${prsId}">
                    ${com.k_int.kbplus.Person.findById(prsId)}
                    <input id="prs" name="prs.id" type="hidden" value="${prsId}" />
                </g:if>
                <g:else>
                    <g:select id="prs" name="prs.id" from="${com.k_int.kbplus.Person.list()}" optionKey="id" value="${personInstance?.id}" class="many-to-one" noSelection="['null': '']"/>
                </g:else>
            </div>
        </g:if>

        <g:if test="${!prsId}">
            <div class="field fieldcontain">
                <label for="org">
                    <g:message code="contact.belongesTo.uppercase.label"  />
                </label>
                <g:if test="${orgId}">
                    <i class="icon university la-list-icon"></i>${com.k_int.kbplus.Org.findById(orgId)}
                    <input id="org" name="org.id" type="hidden" value="${orgId}" />
                </g:if>
                <g:else>
                    <g:select id="org" name="org.id" from="${com.k_int.kbplus.Org.list()}" optionKey="id" value="${org?.id}" class="many-to-one" noSelection="['null': '']"/>
                </g:else>
            </div>
        </g:if>

    </g:form>
</semui:modal>
<r:script>
    $(document).ready(function(){
        $("#newContact").form({
            on: 'blur',
            inline: true,
            fields: {
                content: {
                    identifier: 'content',
                    rules: [
                        {
                            type: 'empty',
                            prompt: '{name} <g:message code="validation.needsToBeFilledOut"/>'
                        }
                    ]
                }
            }
        });
    });
</r:script>