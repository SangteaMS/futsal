<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Home | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <section class="home-hero">
      <div class="eyebrow">Your local futsal board</div>
      <h1>Plan a game. Fill the team.</h1>
      <p>Find an open match or reserve a ground and invite the players you need. Everything for the next kickoff is here.</p>
    </section>
    <div class="path-grid">
      <section class="path-card">
        <div class="eyebrow">For players</div>
        <h2>Find a match</h2>
        <p>See open games, check the ground and time, then request a place.</p>
        <c:choose>
          <c:when test="${user.role == 'PLAYER'}"><a class="button" href="${pageContext.request.contextPath}/matches">Browse open matches</a></c:when>
          <c:otherwise><a class="button secondary" href="${pageContext.request.contextPath}/logout">Switch to player account</a></c:otherwise>
        </c:choose>
      </section>
      <section class="path-card">
        <div class="eyebrow">For organizers</div>
        <h2>Book a ground</h2>
        <p>Choose an available slot, post your match, and approve players.</p>
        <c:choose>
          <c:when test="${user.role == 'ORGANIZER'}"><a class="button" href="${pageContext.request.contextPath}/grounds">Browse grounds</a></c:when>
          <c:otherwise><a class="button secondary" href="${pageContext.request.contextPath}/logout">Switch to organizer account</a></c:otherwise>
        </c:choose>
      </section>
    </div>
  </main>
</body>
</html>
