<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Organizer desk | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading">
      <div><div class="eyebrow">Organizer desk</div><h1>Manage your games</h1><p>Review join requests, follow your squad, and post the next match.</p></div>
      <div class="button-row"><a class="button secondary" href="${pageContext.request.contextPath}/grounds">Book a ground</a><a class="button" href="#create-match">Create a match</a></div>
    </div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/></div></c:if>

    <section class="section" id="requests">
      <div class="section-heading"><h2>Join requests</h2><p>Pending requests appear first</p></div>
      <div class="item-list">
        <c:forEach items="${requests}" var="r">
          <div class="item-row request-row">
            <div class="item-main">
              <h3 class="item-title"><c:out value="${r.player_name}"/> wants to join</h3>
              <div class="meta"><span><c:out value="${r.match_title}"/></span><span><c:out value="${r.ground_name}"/></span><span><c:out value="${r.match_date}"/> · <c:out value="${r.slot}"/></span></div>
            </div>
            <div class="item-action">
              <span class="status ${r.status == 'PENDING' ? 'pending' : (r.status == 'REJECTED' || r.status == 'CANCELLED' ? 'rejected' : '')}"><c:out value="${r.status}"/></span>
              <c:if test="${r.status == 'PENDING'}">
                <form method="post" action="${pageContext.request.contextPath}/requests/${r.request_id}/approve"><button class="button small" type="submit">Approve</button></form>
                <form method="post" action="${pageContext.request.contextPath}/requests/${r.request_id}/reject"><button class="button quiet small" type="submit">Reject</button></form>
              </c:if>
            </div>
          </div>
        </c:forEach>
        <c:if test="${empty requests}"><p class="empty">No requests yet. When players ask to join, you can approve or reject them here.</p></c:if>
      </div>
    </section>

    <section class="section">
      <div class="section-heading"><h2>Your matches</h2><p>Approved players count toward open places</p></div>
      <div class="item-list">
        <c:forEach items="${matches}" var="m">
          <article class="item-row">
            <div class="item-main"><h3 class="item-title"><a href="${pageContext.request.contextPath}/matches/${m.id}"><c:out value="${m.title}"/></a></h3><div class="meta"><span><c:out value="${m.ground_name}"/></span><span><c:out value="${m.match_date}"/></span><span><c:out value="${m.slot}"/></span></div></div>
            <div class="item-action"><span class="places">${m.approved_count} / ${m.additional_players_needed} places filled</span><span class="status ${m.status == 'FULL' ? 'full' : ''}"><c:out value="${m.status}"/></span></div>
          </article>
        </c:forEach>
        <c:if test="${empty matches}"><p class="empty">No matches posted yet. Book a ground and create one below.</p></c:if>
      </div>
    </section>

    <section class="section" id="create-match">
      <div class="section-heading"><h2>Create a match</h2><p>Use a ground booking you have not posted yet</p></div>
      <c:choose>
        <c:when test="${empty bookings}"><div class="empty">All your current bookings have matches. <a class="text-link" href="${pageContext.request.contextPath}/grounds">Book another ground</a> to post a new one.</div></c:when>
        <c:otherwise>
          <form class="form-panel" method="post" action="${pageContext.request.contextPath}/matches">
            <div class="form-grid">
              <div class="field full"><label for="booking">Ground booking</label><select id="booking" name="bookingId" required><c:forEach items="${bookings}" var="b"><option value="${b.id}"><c:out value="${b.ground_name}"/> · <c:out value="${b.match_date}"/> · <c:out value="${b.slot}"/></option></c:forEach></select></div>
              <div class="field"><label for="match-title">Match name</label><input id="match-title" name="title" maxlength="100" placeholder="Evening futsal" required></div>
              <div class="field"><label for="needed">Additional players needed</label><input id="needed" name="needed" type="number" min="1" max="30" value="4" required></div>
              <div class="field full"><label for="notes">Notes for players (optional)</label><textarea id="notes" name="notes" maxlength="500" placeholder="Skill level or anything players should bring"></textarea></div>
              <div class="field full"><button class="button" type="submit">Post match</button></div>
            </div>
          </form>
        </c:otherwise>
      </c:choose>
    </section>
  </main>
</body>
</html>
