<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Match details | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading"><div><h1>Match details</h1><p>Ground, time, and places for this game.</p></div><c:if test="${user.role == 'PLAYER'}"><a class="text-link" href="${pageContext.request.contextPath}/matches">Back to matches</a></c:if></div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/></div></c:if>
    <c:choose>
      <c:when test="${empty match}"><div class="detail"><p>This match could not be found.</p></div></c:when>
      <c:otherwise>
        <article class="detail">
          <h2><c:out value="${match.title}"/></h2>
          <p class="muted">Organized by <c:out value="${match.organizer_name}"/></p>
          <dl class="detail-grid">
            <div><dt>Ground</dt><dd><c:out value="${match.ground_name}"/> — <c:out value="${match.area}"/></dd></div>
            <div><dt>Date and time</dt><dd><c:out value="${match.match_date}"/> · <c:out value="${match.slot}"/></dd></div>
            <div><dt>Places available</dt><dd>${match.additional_players_needed - match.approved_count} of ${match.additional_players_needed}</dd></div>
            <div><dt>Match status</dt><dd><span class="status ${match.status == 'FULL' ? 'full' : ''}"><c:out value="${match.status}"/></span></dd></div>
          </dl>
          <c:if test="${not empty match.notes}"><h3>Notes</h3><p><c:out value="${match.notes}"/></p></c:if>
          <div class="detail-actions">
            <c:choose>
              <c:when test="${user.role == 'ORGANIZER'}"><span class="help">Review players and requests from your organizer page.</span><a class="button secondary" href="${pageContext.request.contextPath}/organizer">My matches &amp; requests</a></c:when>
              <c:when test="${match.request_status == 'PENDING'}"><span class="status pending">Request pending</span><span class="help">The organizer has not decided yet.</span></c:when>
              <c:when test="${match.request_status == 'APPROVED'}"><span class="status">Approved</span><a class="text-link" href="${pageContext.request.contextPath}/my-requests">View or cancel my place</a></c:when>
              <c:when test="${match.request_status == 'REJECTED'}"><span class="status rejected">Request rejected</span></c:when>
              <c:when test="${match.request_status == 'CANCELLED'}"><span class="status cancelled">Place cancelled</span></c:when>
              <c:when test="${match.status == 'OPEN'}"><form method="post" action="${pageContext.request.contextPath}/matches/${match.id}/join"><button class="button" type="submit">Request to join</button></form><span class="help">The organizer will confirm your place.</span></c:when>
              <c:otherwise><span class="status full">This match is full</span></c:otherwise>
            </c:choose>
          </div>
        </article>
      </c:otherwise>
    </c:choose>
  </main>
</body>
</html>
