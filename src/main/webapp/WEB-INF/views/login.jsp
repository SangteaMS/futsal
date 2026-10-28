<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign in | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261029-clean">
</head>
<body>
  <header class="site-header"><div class="header-inner"><span class="brand">Futsal Finder</span></div></header>
  <main class="login-wrap">
    <section class="login-panel">
      <h1>Sign in</h1>
      <p class="muted">Use a demo account to try the booking or player journey.</p>
      <c:if test="${not empty error}"><div class="notice error" role="alert"><c:out value="${error}"/></div></c:if>
      <form method="post" action="${pageContext.request.contextPath}/login">
        <div class="field"><label for="email">Email</label><input id="email" name="email" type="email" autocomplete="username" required></div>
        <div class="field"><label for="password">Password</label><input id="password" name="password" type="password" autocomplete="current-password" required></div>
        <button class="button" type="submit">Sign in</button>
      </form>
      <div class="demo-accounts">
        <h2>Demo accounts</h2>
        <p><strong>Organizer:</strong> organizer@futsal.demo</p>
        <p><strong>Player:</strong> player@futsal.demo</p>
        <p><strong>Password:</strong> demo123</p>
      </div>
    </section>
  </main>
</body>
</html>
