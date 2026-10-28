<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Matches &amp; requests | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261029-clean">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading">
      <div><h1>Matches &amp; requests</h1><p>Post a match, then decide who joins.</p></div>
    </div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/></div></c:if>

    <section class="section" id="create-match">
      <div class="section-heading"><h2>Post a match</h2></div>
      <c:choose>
        <c:when test="${empty bookings}"><p class="empty">You need an unused booking to post a match. <a class="text-link" href="${pageContext.request.contextPath}/grounds">Book a ground</a>.</p></c:when>
        <c:otherwise>
          <form class="form-panel" method="post" action="${pageContext.request.contextPath}/matches">
            <div class="form-grid">
              <div class="field full"><label for="booking">Your booking</label><select id="booking" name="bookingId" required><c:forEach items="${bookings}" var="b"><option value="${b.id}"><c:out value="${b.ground_name}"/> | <c:out value="${b.match_date}"/> | <c:out value="${b.slot}"/></option></c:forEach></select></div>
              <div class="field"><label for="match-title">Match name</label><input id="match-title" name="title" maxlength="100" placeholder="Evening futsal" required></div>
              <div class="field"><label for="needed">Players needed</label><input id="needed" name="needed" type="number" min="1" max="30" value="2" required></div>
              <div class="field full"><button class="button" type="submit">Post match</button></div>
            </div>
          </form>
        </c:otherwise>
      </c:choose>
    </section>

    <section class="section" id="requests">
      <div class="section-heading"><h2>Pending requests</h2></div>
      <div class="item-list">
        <c:forEach items="${requests}" var="r">
          <div class="item-row">
            <div class="item-main">
              <h3 class="item-title"><c:out value="${r.player_name}"/> requested to join</h3>
              <div class="meta"><span><c:out value="${r.match_title}"/></span><span><c:out value="${r.match_date}"/> | <c:out value="${r.slot}"/></span></div>
            </div>
            <div class="item-action">
              <form method="post" action="${pageContext.request.contextPath}/requests/${r.request_id}/approve"><button class="button small" type="submit">Approve</button></form>
              <form method="post" action="${pageContext.request.contextPath}/requests/${r.request_id}/reject"><button class="button quiet small" type="submit">Reject</button></form>
            </div>
          </div>
        </c:forEach>
        <c:if test="${empty requests}"><p class="empty">No pending requests.</p></c:if>
      </div>
    </section>

    <section class="section">
      <div class="section-heading"><h2>Your matches</h2></div>
      <div class="item-list">
        <c:forEach items="${matches}" var="m">
          <article class="item-row">
            <div class="item-main"><h3 class="item-title"><a href="${pageContext.request.contextPath}/matches/${m.id}"><c:out value="${m.title}"/></a></h3><div class="meta"><span><c:out value="${m.ground_name}"/></span><span><c:out value="${m.match_date}"/> | <c:out value="${m.slot}"/></span></div></div>
            <div class="item-action"><span class="places">${m.approved_count} / ${m.additional_players_needed} places filled</span><span class="status ${m.status == 'FULL' ? 'full' : ''}"><c:out value="${m.status}"/></span></div>
          </article>
        </c:forEach>
        <c:if test="${empty matches}"><p class="empty">No matches posted yet.</p></c:if>
      </div>
    </section>
  </main>
</body>
</html>
