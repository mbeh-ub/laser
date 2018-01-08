$(document).ready(function() {
    console.log("locale: ${message(code:'default.locale.label')} > " + gspLocale + " > " + gspDateFormat)

    $.fn.editable.defaults.mode = 'inline'
    $.fn.editable.defaults.emptytext = 'Edit'
    // TODO $.fn.datepicker.defaults.language = gspLocale

    $('.xEditable').editable({
        language: gspLocale, /*
    datepicker: {
      language: gspLocale
    }, */
        format: gspDateFormat,
    });

    $('.xEditableValue').editable({
        language: gspLocale, /*
    datepicker: {
      language: gspLocale
    }, */
        format: gspDateFormat,
    });
    $(".xEditableManyToOne").editable();
    $(".simpleHiddenRefdata").editable({
        language: gspLocale, /*
    datepicker: {
      language: gspLocale
    }, */
        format: gspDateFormat,
        url: function(params) {
            var hidden_field_id = $(this).data('hidden-id');
            $("#"+hidden_field_id).val(params.value);
            // Element has a data-hidden-id which is the hidden form property that should be set to the appropriate value
        }
    });

    $(".simpleReferenceTypedown").select2({
        placeholder: "Search for...",
        minimumInputLength: 1,
        ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
            url: "<g:createLink controller='ajax' action='lookup'/>",
            dataType: 'json',
            data: function (term, page) {
                return {
                    format:'json',
                    q: term,
                    baseClass:$(this).data('domain')
                };
            },
            results: function (data, page) {
                return {results: data.values};
            }
        }
    });
    /* todo remove @spotlight
    $('.dlpopover').popover({html:true,
                            placement:'left',
                            title:'search',
                            trigger:'click',
      template:
  '<div class="popover" style="width: 600px;"><div></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"></div></div></div>',
                            'max-width':600,
                            content:function() {
                            return getContent();}
    });
    */

    semanticUiStuff()

});

/*
function getContent() {
    return $.ajax({
        type: "GET",
        url: "<g:createLink controller='spotlight' action='index'/>",
        cache: false,
        async: false
    }).responseText;
}
*/

function semanticUiStuff() {

    // close semui:messages alerts
    $(".close.icon").click(function(){
        $(this).parent().hide();
    });

    // modal opener
    $("*[data-semui=modal]").click(function(){
        $($(this).attr('href') + '.ui.modal').modal('show')
    });

    // dropdowns
    $('.ui.dropdown').dropdown({duration: 150, transition: 'fade'});

    // checkboxes
    $('.ui.checkbox').checkbox();

    //datepicker
    $('.datepicker').calendar({
        type: 'date',
        firstDayOfWeek: 1,
        monthFirst: false,
        formatter: {
            date: function (date, settings) {
                if (!date) return '';
                var day = date.getDate();
                if (day<10) day="0"+day;
                var month = date.getMonth() + 1;
                if (month<10) month="0"+month;
                var year = date.getFullYear();

                if ('dd.mm.yyyy' == gspDateFormat) {
                    console.log('dd.mm.yyyy');
                    return day + '.' + month + '.' + year;
                }
                else if ('yyyy-mm-dd' == gspDateFormat) {
                    console.log('yyyy-mm-dd');
                    return year + '-' + month + '-' + day;
                }
                else {
                    // TODO
                    alert('Please report this error: ' + gspDateFormat + ' for semui-datepicker unsupported')
                }
            }
        }
    });
}

console.log("application.js loaded")