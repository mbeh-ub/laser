<%@page import="com.k_int.kbplus.*;de.laser.helper.RDStore;"%>
<%
    String modalText
    String submitButtonLabel
    String formUrl
    if(docctx && doc) {
        modalText = message(code:'template.documents.edit')
        submitButtonLabel = message(code:'default.button.edit.label')
        formUrl = createLink(controller:'docWidget',action:'editDocument')
    }
    else {
        modalText = message(code:'template.documents.add')
        submitButtonLabel = message(code:'default.button.create_new.label')
        formUrl = createLink(controller: 'docWidget',action:'uploadDocument')
    }
%>
<semui:modal id="modalCreateDocument" text="${modalText}" msgSave="${submitButtonLabel}">

    <g:form id="upload_new_doc_form" class="ui form" url="${formUrl}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="ownerid" value="${ownobj?.id}"/>
        <input type="hidden" name="ownerclass" value="${ownobj?.class?.name}"/>
        <input type="hidden" name="ownertp" value="${owntp}"/>
        <g:if test="${docctx}">
            <input type="hidden" name="docctx" value="${docctx.id}"/>
        </g:if>

        <div class="inline-lists">
            <dl>
                <dt>
                    <label>${message(code: 'template.addDocument.name', default: 'Document Name')}:</label>
                </dt>
                <dd>
                    <input type="text" name="upload_title" value="${doc?.title}">
                </dd>
            </dl>
            <g:if test="${!docctx && !doc}">
                <dl>
                    <dt>
                        <label>${message(code: 'template.addDocument.file', default: 'File')}:</label>
                    </dt>
                    <dd>
                        <div class="ui fluid action input">
                            <input type="text" readonly="readonly" placeholder="${message(code:'template.addDocument.selectFile')}">
                            <input type="file" name="upload_file" style="display: none;">
                            <div class="ui icon button" style="padding-left:30px; padding-right:30px">
                                <i class="attach icon"></i>
                            </div>
                        </div>
                    </dd>
                </dl>

                <script>
                    $('#modalCreateDocument .action .icon.button').click( function() {
                        $(this).parent('.action').find('input:file').click();
                    });

                    $('input:file', '.ui.action.input').on('change', function(e) {
                        var name = e.target.files[0].name;
                        $('input:text', $(e.target).parent()).val(name);
                    });

                    function showHideTargetableRefdata() {
                        console.log($(org).val());
                        if($(org).val().length === 0) {
                            $("[data-value='com.k_int.kbplus.RefdataValue:${RDStore.SHARE_CONF_UPLOADER_AND_TARGET.id}']").hide();
                        }
                        else {
                            $("[data-value='com.k_int.kbplus.RefdataValue:${RDStore.SHARE_CONF_UPLOADER_AND_TARGET.id}']").show();
                        }
                    }

                    function toggleTarget() {
                        if($("#hasTarget")[0].checked)
                            $("#target").show();
                        else
                            $("#target").hide();
                    }
                </script>
            </g:if>
            <dl>
                <dt>
                    <label>${message(code: 'template.addDocument.type', default: 'Document Type')}:</label>
                </dt>
                <dd>
                    <%
                        List notAvailable = [RefdataValue.getByValueAndCategory('ONIX-PL License','Document Type'),
                                             RefdataValue.getByValueAndCategory('Note','Document Type'),
                                             RefdataValue.getByValueAndCategory('Announcement','Document Type')]
                        List documentTypes = RefdataCategory.getAllRefdataValues("Document Type")-notAvailable
                    %>
                    <g:select from="${documentTypes}"
                              class="ui dropdown fluid"
                              optionKey="value"
                              optionValue="${{ it.getI10n('value') }}"
                              name="doctype"
                              value="${doc?.type?.value}"/>
                </dd>
            </dl>
            <g:if test="${ownobj?.class?.name?.equals(Org.class.name)}">
                <dl>
                    <dt>
                        <label>${message(code:'template.addDocument.shareConf')}</label>
                    </dt>
                    <dd>
                        <%
                            String value = "${RefdataValue.class.name}:${RDStore.SHARE_CONF_UPLOADER_ORG.id}"
                            if(docctx) {
                                value = "${RefdataValue.class.name}:${docctx.shareConf.id}"
                            }
                            List allConfigs = RefdataValue.executeQuery("select rdv from RefdataValue rdv where rdv.owner.desc = 'Share Configuration' order by rdv.order asc")
                            List availableConfigs = []
                            if(!institution.getallOrgTypeIds().contains(RDStore.OT_CONSORTIUM.id)){
                                availableConfigs = allConfigs-RDStore.SHARE_CONF_CONSORTIUM
                            }
                            else availableConfigs = allConfigs
                        %>
                        <laser:select from="${availableConfigs}" class="ui dropdown fluid" name="shareConf"
                                      optionKey="${{it.class.name+":"+it.id}}" optionValue="value" value="${value}"/>
                    </dd>
                </dl>
                <dl>
                    <dt>
                        <label>${message(code:'template.addDocument.hasTarget')}</label>
                    </dt>
                    <dd>
                        <%
                            String selected = docctx?.targetOrg ? "true" : "false"
                        %>
                        <g:checkBox name="hasTarget" id="hasTarget" onchange="toggleTarget()" checked="${selected}"/>
                    </dd>
                </dl>
                <dl id="target">
                    <dt>
                        <label>${message(code:'template.addDocument.targetOrg')}</label>
                    </dt>
                    <dd>
                        <g:if test="${targetOrg}">
                            <input type="hidden" name="targetOrg" value="${targetOrg.id}">
                            <input type="text" value="${targetOrg.name}" class="la-full-width" readonly>
                        </g:if>
                        <g:else>
                            <g:select class="ui dropdown search la-full-width"
                                      name="targetOrg"
                                      from="${Org.executeQuery('select o from Org o where o.status != :deleted or o.status is null order by o.sortname asc',[deleted:RDStore.O_STATUS_DELETED])}"
                                      optionKey="id"
                                      optionValue="name"
                                      noSelection="['':'']"
                                      value="${docctx?.targetOrg?.id}"
                                      onchange="showHideTargetableRefdata()"
                            />
                        </g:else>
                    </dd>
                </dl>
            </g:if>
        </div>

    </g:form>

</semui:modal>