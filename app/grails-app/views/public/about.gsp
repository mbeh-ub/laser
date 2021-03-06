<!doctype html>
<html>
<head>
    <meta name="layout" content="public"/>
    <title>${message(code: 'public.about.label', default: 'About')} | ${message(code: 'laser', default: 'LAS:eR')}</title>
</head>

<body class="public">
    <g:render template="public_navbar" contextPath="/templates" model="['active': 'about']"/>

    <div class="ui container">
        <h1 class="ui left aligned icon header"><semui:headerIcon />${message(code: 'public.nav.about.label', default: 'About LAS:eR')}</h1>

        <div class="ui grid">
            <div class="twelve wide column">
                <markdown:renderHtml><g:dbContent key="kbplus.about.text"/></markdown:renderHtml>
            </div>

            <aside class="four wide column">
                <g:render template="/templates/loginDiv"/>
            </aside>
        </div>
    </div>
</body>
</html>
