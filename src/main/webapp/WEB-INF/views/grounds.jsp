<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Book a ground | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261029">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading">
      <div><h1>Book a ground</h1><p>Choose a date, ground, and available time.</p></div>
    </div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/> <a class="text-link" href="${pageContext.request.contextPath}/organizer">Create a match</a></div></c:if>
    <form class="toolbar" method="get" action="${pageContext.request.contextPath}/grounds">
      <div class="field"><label for="booking-date">Booking date</label><input id="booking-date" type="date" name="date" value="${selectedDate}" min="<%= java.time.LocalDate.now().toString() %>" required></div>
      <button class="button secondary" type="submit">Check availability</button>
    </form>
    <div class="section-heading"><h2>Grounds</h2></div>
    <div class="ground-grid">
      <c:forEach items="${grounds}" var="g">
        <article class="ground-card">
          <div class="ground-card-body">
            <h3><c:out value="${g.name}"/></h3>
            <p class="area"><c:out value="${g.area}"/></p>
            <span class="help"><c:out value="${g.capacity}"/> players</span>
          </div>
          <div class="ground-book">
            <c:choose>
              <c:when test="${not empty g.availableSlots}">
                <form method="post" action="${pageContext.request.contextPath}/bookings">
                  <input type="hidden" name="groundId" value="${g.id}"><input type="hidden" name="matchDate" value="${selectedDate}">
                  <div class="field"><label for="slot-${g.id}">Available time</label><select id="slot-${g.id}" name="slot" required><c:forEach items="${g.availableSlots}" var="slot"><option value="${slot}"><c:out value="${slot}"/></option></c:forEach></select></div>
                  <button class="button" type="submit">Book slot</button>
                </form>
              </c:when>
              <c:otherwise><p class="ground-unavailable">No slots available. Choose another date.</p></c:otherwise>
            </c:choose>
          </div>
        </article>
      </c:forEach>
    </div>
    <c:if test="${empty grounds}"><p class="empty">No grounds are available right now.</p></c:if>
  </main>
</body>
</html>
