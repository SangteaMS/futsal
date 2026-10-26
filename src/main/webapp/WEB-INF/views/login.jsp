<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign in | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <header class="site-header"><div class="header-inner"><a class="brand" href="${pageContext.request.contextPath}/login"><span class="brand-mark" aria-hidden="true"></span>Futsal Finder</a></div></header>
  <main class="login-wrap">
    <aside class="login-aside">
      <div><div class="eyebrow">Match day starts here</div><h1>Make the next game happen.</h1><p>Find a futsal match, or book a ground and build your squad.</p></div>
      <p>Simple booking and player requests for local games.</p>
    </aside>
    <section class="login-panel">
      <div class="eyebrow">Welcome back</div>
      <h2>Sign in</h2>
      <p class="muted">Use a demo account to explore the organizer or player view.</p>
      <c:if test="${not empty error}"><div class="notice error" role="alert"><c:out value="${error}"/></div></c:if>
      <form method="post" action="${pageContext.request.contextPath}/login">
        <div class="field"><label for="email">Email</label><input id="email" name="email" type="email" autocomplete="username" required></div>
        <div class="field"><label for="password">Password</label><input id="password" name="password" type="password" autocomplete="current-password" required></div>
        <button class="button" type="submit">Sign in</button>
      </form>
      <section class="demo-accounts" aria-labelledby="demo-title">
        <h3 id="demo-title">Demo accounts</h3>
        <p><strong>Organizer</strong> — organizer@futsal.demo</p>
        <p><strong>Player</strong> — player@futsal.demo</p>
        <p class="help">Password for both: <strong>demo123</strong></p>
      </section>
    </section>
  </main>
</body>
</html>
