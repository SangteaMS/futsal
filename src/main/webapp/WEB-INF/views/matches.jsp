<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Find a match | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading">
      <div><div class="eyebrow">Open games</div><h1>Find your next match</h1><p>Choose a game and ask the organizer for a place.</p></div>
      <a class="button secondary" href="${pageContext.request.contextPath}/my-requests">My requests</a>
    </div>
    <div class="match-grid">
      <c:forEach items="${matches}" var="m">
        <article class="match-card">
          <div class="match-card-top">
            <div><span class="eyebrow">Futsal match</span><h2><a href="${pageContext.request.contextPath}/matches/${m.id}"><c:out value="${m.title}"/></a></h2></div>
            <span class="spot-badge">${m.additional_players_needed - m.approved_count} spots open</span>
          </div>
          <dl class="match-facts">
            <div><dt>Ground</dt><dd><c:out value="${m.ground_name}"/></dd></div>
            <div><dt>Date</dt><dd><c:out value="${m.match_date}"/></dd></div>
            <div><dt>Time</dt><dd><c:out value="${m.slot}"/></dd></div>
            <div><dt>Organizer</dt><dd><c:out value="${m.organizer_name}"/></dd></div>
          </dl>
          <div class="match-card-footer">
            <c:choose>
              <c:when test="${m.request_status == 'PENDING'}"><span class="status pending">Request pending</span></c:when>
              <c:when test="${m.request_status == 'APPROVED'}"><span class="status">Place approved</span></c:when>
              <c:when test="${m.request_status == 'REJECTED'}"><span class="status rejected">Request rejected</span></c:when>
              <c:when test="${m.request_status == 'CANCELLED'}"><span class="status cancelled">Place cancelled</span></c:when>
              <c:otherwise><form method="post" action="${pageContext.request.contextPath}/matches/${m.id}/join"><button class="button" type="submit">Request to join</button></form></c:otherwise>
            </c:choose>
            <a class="text-link" href="${pageContext.request.contextPath}/matches/${m.id}">Match details</a>
          </div>
        </article>
      </c:forEach>
    </div>
    <c:if test="${empty matches}"><p class="empty">No open matches right now. Check again later or review your requests.</p></c:if>
  </main>
</body>
</html>
