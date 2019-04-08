<!doctype html>
<html>
  <head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} : Manage Affiliation Requests</title>
  </head>

  <body>

      <semui:breadcrumbs>
          <semui:crumb message="menu.admin.dash" controller="admin" action="index"/>
          <semui:crumb message="menu.institutions.affiliation_requests" class="active"/>
      </semui:breadcrumbs>

      <semui:messages data="${flash}" />

        <h2 class="ui header">${message(code: "menu.institutions.affiliation_requests")}</h2>

        <table class="ui celled la-table table">
            <thead>
                <tr>
                    <th>${message(code: "profile.user")}</th>
                    <th>${message(code: "profile.display")}</th>
                    <th>${message(code: "profile.email")}</th>
                    <th>Organisation</th>
                    <th>${message(code: "profile.membership.role")}</th>
                    <th>${message(code: "profile.membership.status")}</th>
                    <th>${message(code: "profile.membership.date2")}</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <g:each in="${pendingRequests}" var="req">
                <tr>
                    <td>${req.user.username}</td>
                    <td>${req.user.displayName}</td>
                    <td>${req.user.email}</td>
                    <td>${req.org.name}</td>
                    <td><g:message code="cv.roles.${req.formalRole?.authority}"/></td>
                    <td><g:message code="cv.membership.status.${req.status}"/></td>
                    <td><g:formatDate format="dd MMMM yyyy" date="${req.dateRequested}"/></td>
                    <td class="x">
                        <g:link controller="admin" action="actionAffiliationRequest" params="${[req:req.id, act:'approve']}" class="ui icon positive button">
                            <i class="checkmark icon"></i>
                        </g:link>
                        <g:link controller="admin" action="actionAffiliationRequest" params="${[req:req.id, act:'deny']}" class="ui icon negative button">
                            <i class="times icon"></i>
                        </g:link>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>


  </body>
</html>
