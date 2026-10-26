<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Book a ground | Futsal Finder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css?v=20261026">
</head>
<body>
  <%@ include file="fragments.jspf" %>
  <main class="container">
    <div class="page-heading">
      <div><div class="eyebrow">Ground booking</div><h1>Choose your pitch</h1><p>Pick a date, then reserve one of the open one-hour slots.</p></div>
      <a class="button secondary" href="${pageContext.request.contextPath}/organizer">My matches</a>
    </div>
    <c:if test="${not empty flash}"><div class="notice" role="status"><c:out value="${flash}"/> <a class="text-link" href="${pageContext.request.contextPath}/organizer">Create a match</a></div></c:if>
    <form class="toolbar" method="get" action="${pageContext.request.contextPath}/grounds">
      <div class="field"><label for="booking-date">Booking date</label><input id="booking-date" type="date" name="date" value="${selectedDate}" min="<%= java.time.LocalDate.now().toString() %>" required></div>
      <button class="button secondary" type="submit">Check availability</button>
      <span class="toolbar-note">Showing slots for <strong><c:out value="${selectedDate}"/></strong></span>
    </form>
    <div class="section-heading"><h2>Available grounds</h2><p>Select a time and book your ground</p></div>
    <div class="ground-grid">
      <c:forEach items="${grounds}" var="g" varStatus="loop">
        <article class="ground-card">
          <div class="ground-card-body">
            <span class="eyebrow">Ground 0${loop.count}</span>
            <h3><c:out value="${g.name}"/></h3>
            <p class="area"><c:out value="${g.area}"/></p>
            <div class="ground-facts"><span class="fact"><c:out value="${g.surface}"/></span><span class="fact"><c:out value="${g.capacity}"/> players</span></div>
          </div>
          <div class="ground-book">
            <c:choose>
              <c:when test="${not empty g.availableSlots}">
                <form method="post" action="${pageContext.request.contextPath}/bookings">
                  <input type="hidden" name="groundId" value="${g.id}"><input type="hidden" name="matchDate" value="${selectedDate}">
                  <div class="field"><label for="slot-${g.id}">Available time</label><select id="slot-${g.id}" name="slot" required><c:forEach items="${g.availableSlots}" var="slot"><option value="${slot}"><c:out value="${slot}"/></option></c:forEach></select></div>
                  <button class="button" type="submit">Book this ground</button>
                </form>
              </c:when>
              <c:otherwise><p class="ground-unavailable">All slots are booked for this date.</p><a class="button secondary" href="${pageContext.request.contextPath}/grounds">Try another date</a></c:otherwise>
            </c:choose>
          </div>
        </article>
      </c:forEach>
    </div>
    <c:if test="${empty grounds}"><p class="empty">No grounds are available right now.</p></c:if>
  </main>
</body>
</html>
