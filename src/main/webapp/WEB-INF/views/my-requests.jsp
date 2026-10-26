<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My requests | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading"><div><h1>My requests</h1><p>See the status of each match you asked to join.</p></div><a class="button secondary" href="${pageContext.request.contextPath}/matches">Find a match</a></div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/></div></c:if>
    <div class="item-list">
      <c:forEach items="${requests}" var="r">
        <article class="item-row">
          <div class="item-main"><h2 class="item-title"><a href="${pageContext.request.contextPath}/matches/${r.match_id}"><c:out value="${r.match_title}"/></a></h2><div class="meta"><span><c:out value="${r.ground_name}"/></span><span><c:out value="${r.match_date}"/></span><span><c:out value="${r.slot}"/></span></div></div>
          <div class="item-action"><span class="status ${r.status == 'PENDING' ? 'pending' : (r.status == 'REJECTED' || r.status == 'CANCELLED' ? 'rejected' : '')}"><c:out value="${r.status}"/></span><c:if test="${r.status == 'APPROVED'}"><form method="post" action="${pageContext.request.contextPath}/requests/${r.id}/cancel"><button class="button danger small" type="submit">Cancel place</button></form></c:if></div>
        </article>
      </c:forEach>
      <c:if test="${empty requests}"><p class="empty">You have not requested to join a match yet.</p></c:if>
    </div>
  </main>
</body>
</html>
