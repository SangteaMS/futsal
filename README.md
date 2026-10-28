# Futsal Finder

A small BCA Spring MVC demo: an organizer books a ground and posts a match; a player requests a place; the organizer approves it; the player can cancel. The pages use JSP and CSS, and MySQL access goes through JDBC (`JdbcTemplate`).

## Setup and run

Requires Java 17+, Maven, MySQL 8, and Tomcat 10.1. This project's Tomcat is in `.runtime` (excluded from Git). Start MySQL first. In PowerShell, from this folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop-local.ps1
& 'C:\Users\sangt\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd' '-Dmaven.repo.local=C:\Users\sangt\OneDrive\Desktop\Java Spring MVC\.m2\repository' clean package
powershell -ExecutionPolicy Bypass -File .\deploy-local.ps1
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

`start-local.ps1` asks for the MySQL password without displaying or saving it. Open <http://localhost:8080/futsal-finder/>. Use `powershell -ExecutionPolicy Bypass -File .\stop-local.ps1` to stop Tomcat later.

On a new computer, install the prerequisites and import `database/schema.sql` in **Command Prompt**:

```cmd
mysql -u root -p < database\schema.sql
```

Set `DB_URL`, `DB_USER`, and `DB_PASSWORD` for the Tomcat process if your MySQL settings differ. Deploy `target/futsal-finder.war` as `futsal-finder.war` in Tomcat's `webapps` folder.

Demo logins (both use password `demo123`):

| Role | Email |
|---|---|
| Organizer | `organizer@futsal.demo` |
| Player | `player@futsal.demo` |

## Two-minute demo

1. Sign in as **organizer**. The first page is **Book a ground**. Pick a future date and an available slot, then click **Book slot**.
2. Open **Matches & requests**. Select the new booking, give the match a name, set **Players needed** to `2`, and click **Post match**.
3. Log out and sign in as **player**. The first page is **Find a match**. Find the new match and click **Request to join**.
4. Sign back in as **organizer**. Open **Matches & requests** and click **Approve** beside the pending request. The filled place count increases.
5. Sign in as **player** again. Open **My requests** and click **Cancel place**. The match has a free place again.

## Where to point in the code

```text
Browser -> DispatcherServlet -> WebController -> FutsalService -> FutsalDao/JDBC -> MySQL
Browser <- JSP page          <- WebController
```

| Layer | File | What it does |
|---|---|---|
| Servlet and Spring setup | `src/main/webapp/WEB-INF/web.xml`, `src/main/webapp/WEB-INF/spring-mvc.xml` | Send requests into Spring MVC and configure JDBC and JSP views. |
| Controller | `src/main/java/edu/bca/futsal/controller/WebController.java` | Receive URLs and form fields; choose the JSP page. |
| Service | `src/main/java/edu/bca/futsal/service/FutsalService.java` | Check booking, approval, capacity, and cancellation rules. |
| DAO/JDBC | `src/main/java/edu/bca/futsal/dao/FutsalDao.java` | Run parameterized SQL with `JdbcTemplate`. |
| Database | `database/schema.sql` | Create tables and sample accounts, grounds, and matches. |
| JSP views | `src/main/webapp/WEB-INF/views/grounds.jsp`, `organizer.jsp`, `matches.jsp`, `my-requests.jsp` | Display booking, matches, approvals, and cancellation. |
