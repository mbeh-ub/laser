openapi: 3.0.2
info:
  title: LAS:eR - API
  description: >
    Known Issues:
    _Authorization_ has to be set manually.
    Usual javascript insertion isn't working due shadow dom mechanic of [React](https://facebook.github.io/react).
    Please copy and paste required/generated fields.
  contact:
    email: david.klober@hbz-nrw.de
  version: "<% print de.laser.api.v0.ApiManager.VERSION %>"

<g:if test="${grails.util.Environment.current == grails.util.Environment.PRODUCTION}">
servers:
  - url: ${grailsApplication.config.grails.serverURL}/api/v0
</g:if>
<g:else>
servers:
  - url: ${grailsApplication.config.grails.serverURL}/api/v0
</g:else>

paths:

<g:render template="/swagger/v0/paths" />

components:

  parameters:

    q:
      name: q
      in: query
      schema:
        type: string
      required: true
      description: Identifier for this query

    v:
      name: v
      in: query
      schema:
        type: string
      required: true
      description: Value for this query

    context:
      name: context
      in: query
      schema:
        type: string
      required: false
      description: Concrete globalUID of context organisation

    authorization:
      name: x-authorization
      in: header
      schema:
        type: string
      required: true
      description: hmac-sha256 generated auth header


  responses:

    ok:
      description: OK

    badRequest:
      description: Invalid or missing identifier/value

    conflict:
      description: Conflict with existing resource

    created:
      description: Resource successfully created

    forbidden:
      description: Forbidden access to this resource

    internalServerError:
      description: Resource not created

    notAcceptable:
      description: Requested format not supported

    notAuthorized:
      description: Request is not authorized

    notImplemented:
      description: Requested method not implemented

    preconditionFailed:
      description: Multiple matches


  schemas:

<g:render template="/swagger/v0/schemas" />
