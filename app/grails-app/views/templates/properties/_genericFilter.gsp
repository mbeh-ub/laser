<%@ page import="com.k_int.kbplus.RefdataValue;com.k_int.kbplus.RefdataCategory;de.laser.helper.RDStore" %>
<!-- genericFilter.gsp -->
<%--params.filterProp: ${params.filterProp}--%>
<div class="field">
    <label for="filterPropDef">${message(code: 'subscription.property.search')}
        <i class="question circle icon la-popup"></i>
        <div class="ui  popup ">
            <i class="shield alternate icon"></i> = ${message(code: 'subscription.properties.my')}
        </div>
    </label>
    <r:script>
        $(".la-popup").popup({
        });
    </r:script>
    <%-- value="${params.filterPropDef}" --%>
    <semui:dropdown id="filterPropDef" name="filterPropDef"

                    class="la-filterPropDef"
                    from="${propList.toSorted()}"
                    iconWhich = "shield alternate"
                    optionKey="${{
                        it.refdataCategory ?
                                "com.k_int.properties.PropertyDefinition:${it.id}\" data-rdc=\"com.k_int.kbplus.RefdataCategory:${RefdataCategory.findByDesc(it.refdataCategory)?.id}"
                                : "com.k_int.properties.PropertyDefinition:${it.id}"
                    }}"
                    optionValue="${{ it.getI10n('name') }}"
                    noSelection="${message(code: 'default.select.choose.label', default: 'Please Choose...')}"/>
    <r:script>
        $(function() {
            $.each($(".la-filterPropDef"), function(i, dropdown) {
                var val = $(dropdown).find(".item.active").data("value");
                var text = $(dropdown).find(".item.active").html();
                if (val != undefined) {
                    $(dropdown)
                            .dropdown("set value", val)
                            .dropdown("set text", text);
                }
            });
        });
    </r:script>
</div>

<g:if test="${!hideFilterProp}">
<div class="field">
    <label for="filterProp">${message(code: 'subscription.property.value')}</label>

    <input id="filterProp" id="filterProp" name="filterProp" type="text"
           placeholder="${message(code: 'license.search.property.ph')}" value="${params.filterProp ?: ''}"/>
</div>
</g:if>



<script>


    $(function () {

        var propertyFilterController = {

            updateProp: function (selOpt) {

                //If we are working with RefdataValue, grab the values and create select box
                if (selOpt.attr('data-rdc')) {
                    $.ajax({
                        url: '<g:createLink controller="ajax" action="refdataSearchByOID"/>' + '?oid=' + selOpt.attr('data-rdc') + '&format=json',
                        success: function (data) {
                            var genericNullValue = "${RefdataValue.class.name}:${RDStore.GENERIC_NULL_VALUE.id}";
                            var select = '';
                            for (var index = 0; index < data.length; index++) {
                                var option = data[index];
                                var optionText = option.text;

                                if(option.value === genericNullValue) {
                                    optionText = "<em>${RDStore.GENERIC_NULL_VALUE.getI10n('value')}</em>";
                                }
                                select += '<div class="item"  data-value="' + option.value + '">' + optionText + '</div>';
                            }

                            select = ' <div class="ui fluid search selection dropdown la-filterProp">' +
                                '   <input type="hidden" id="filterProp" name="filterProp">' +
                                '   <i class="dropdown icon"></i>' +
                                '   <div class="default text">${message(code: 'default.select.choose.label', default: 'Please Choose...')}</div>' +
                                '   <div class="menu">'
                                + select +
                                '   </div>' +
                                '</div>';


                            $('label[for=filterProp]').next().replaceWith(select);


                            $('.la-filterProp').dropdown({
                                duration: 150,
                                transition: 'fade',
                                clearable: true,
                                onChange: function (value, text, $selectedItem) {
                                    value.length === 0 ? $(this).removeClass("la-filter-selected") : $(this).addClass("la-filter-selected");
                                }
                            });
                        }, async: false

                    });
                } else {
                    $.ajax({
                        url: '<g:createLink controller="ajax" action="getPropValues"/>' + '?oid=' + selOpt.attr('data-value') + '&domain=${actionName}&format=json',
                        success: function (data) {
                            var select = '';
                            for (var index = 0; index < data.length; index++) {
                                var option = data[index];
                                var optionText = option.text;

                                select += '<div class="item"  data-value="' + option.value + '">' + optionText + '</div>';
                            }

                            select = ' <div   class="ui fluid search selection dropdown la-filterProp">' +
                                '   <input type="hidden" id="filterProp" name="filterProp">' +
                                '   <i class="dropdown icon"></i>' +
                                '   <div class="default text">${message(code: 'default.select.choose.label')}</div>' +
                                '   <div class="menu">'
                                + select +
                                '   </div>' +
                                '</div>';


                            $('label[for=filterProp]').next().replaceWith(select);


                            $('.la-filterProp').dropdown({
                                duration: 150,
                                transition: 'fade',
                                clearable: true,
                                onChange: function (value, text, $selectedItem) {
                                    value.length === 0 ? $(this).removeClass("la-filter-selected") : $(this).addClass("la-filter-selected");
                                }
                            });
                        }, async: false

                    });
                    /*$('label[for=filterProp]').next().replaceWith(
                        '<input id="filterProp" type="text" name="filterProp" placeholder="${message(code:'license.search.property.ph', default:'property value')}" />'
                    )*/
                }
            },

            init: function () {

                /*
                // register change event
                $('#filterPropDef').change(function (e) {
                    var selOpt = $('option:selected', this);
                    propertyFilterController.updateProp(selOpt);
                });
             */
                $(document).ready(function() {
                    $(".la-filterPropDef").dropdown({
                        clearable: true,
                        onChange: function (value, text, $selectedItem) {
                            if ((typeof $selectedItem != 'undefined')){
                                var selOpt = $selectedItem;
                                propertyFilterController.updateProp(selOpt);
                            }
                            else {
                                $('#filterProp').dropdown ('clear', true)
                            }

                        }
                    });
                })
                    // set filterPropDef by params
                    // iterates through all the items and set the item class on 'active selected' when value and URL Parameter for filterPropDef match
                    var item = $( ".la-filterPropDef .item" );

                    var selOpt = $('.la-filterPropDef').find(item).filter(function ()
                        {
                        return  $(this).attr('data-value') == "${params.filterPropDef}";
                        }
                    ).addClass('active').addClass('selected');
                    // sets the URL Parameter on the hidden input field
                    var hiddenInput = $('#filterPropDef').val("${params.filterPropDef}");



                    propertyFilterController.updateProp(selOpt);


                    // set filterProp by params
                    var paramFilterProp = "${params.filterProp}";

                    $('#filterProp').val(paramFilterProp);



            }
        }


        propertyFilterController.init()
    });

</script>


<!-- genericFilter.gsp -->