
<g:render template="/templates/tasks/card" model="${[ownobj:ownobj, owntp:owntp, css_class:'']}"  />

<div id="container-documents" style="margin:1em 0">
    <g:render template="/templates/documents/card" model="${[ownobj:ownobj, owntp:owntp, css_class:'']}" />
</div>

<div id="container-notes" style="margin:1em 0">
    <g:render template="/templates/notes/card" model="${[ownobj:ownobj, owntp:owntp, css_class:'']}" />
</div>