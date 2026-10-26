# Futsal Finder — Match Booking & Player Finder

A small classroom demo built with Java 17+, Spring MVC, JSP, JDBC (`JdbcTemplate`) and MySQL. It has organizer and player logins, ground bookings, match creation, join requests, approval/rejection, full squad handling, and player cancellation.

## Requirements

- JDK 17 or newer (`java -version`)
- Apache Maven 3.9+
- MySQL 8.0+
- Apache Tomcat 10.1 (Jakarta Servlet 6)

## Already set up on this Windows computer

The WAR was built with Maven 3.10.0, the sample schema was imported into the running MySQL 8.0 service, and Tomcat 10.1.61 was installed in `.runtime`. To view the running site, open <http://localhost:8080/futsal-finder/>. After a reboot, run this from PowerShell in the project folder; it asks for the MySQL password without displaying or saving it:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

To stop the local server:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop-local.ps1
```

If you edit the Java or JSP files, stop Tomcat, rebuild and deploy, then start it again:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop-local.ps1
& 'C:\Users\sangt\Downloads\apache-maven-3.10.0-bin\apache-maven-3.10.0\bin\mvn.cmd' '-Dmaven.repo.local=C:\Users\sangt\OneDrive\Desktop\Java Spring MVC\.m2\repository' clean package
powershell -ExecutionPolicy Bypass -File .\deploy-local.ps1
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

## Database setup on another computer

In **Command Prompt** at the project folder, import the schema and sample data:

```cmd
mysql -u root -p < database\schema.sql
```

The script creates `futsal_finder`, its five tables, two demo grounds bookings/matches, and the demo accounts. The demo uses plain passwords for simplicity; do not use that password pattern in a real application.

Default local database connection is `jdbc:mysql://localhost:3306/futsal_finder`, username `root`, password `root`. Override with environment variables `DB_URL`, `DB_USER`, and `DB_PASSWORD` before starting Tomcat. On Windows PowerShell:

```powershell
$env:DB_URL = 'jdbc:mysql://localhost:3306/futsal_finder?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC'
$env:DB_USER = 'root'
$env:DB_PASSWORD = 'your-mysql-password'
```

## Build and launch

From the project directory:

```sh
mvn clean package
```

Copy `target/futsal-finder.war` to Tomcat's `webapps` directory and start Tomcat. On Windows, for a default Tomcat installation:

```powershell
Copy-Item target/futsal-finder.war C:\path\to\apache-tomcat-10.1\webapps\
& C:\path\to\apache-tomcat-10.1\bin\startup.bat
```

Open <http://localhost:8080/futsal-finder/>. Stop Tomcat with `shutdown.bat`.

Demo accounts:

| Role | Email | Password |
|---|---|---|
| Organizer | `organizer@futsal.demo` | `demo123` |
| Player | `player@futsal.demo` | `demo123` |

## Two-minute teacher demo

1. Sign in as organizer. Open **Book a ground**, select a future date and an open slot, then reserve a ground.
2. Open **My matches & requests**. Select that booking, enter a title and `2` additional players, then post the match.
3. Log out; sign in as player. Open **Find a match**, select the new match to review its details, then request to join.
4. Log out and sign back in as organizer. In **My matches & requests**, approve the player's pending request; show the squad count.
5. Switch back to player, open **My requests**, and cancel the approved place. The organizer's match becomes open again.

The seeded matches can be used immediately to demonstrate browsing/requesting. The booking uniqueness key blocks the same ground/date/slot twice. A unique `(match_id, player_id)` key prevents duplicate requests. Approval locks the match row inside a transaction, checks organizer ownership and capacity, and marks a filled match `FULL`; cancelling an approved request reopens it.

## UI previews

These screenshots were captured from the running Tomcat application at desktop and phone widths. The organizer screenshot shows a temporary pending request used to review the approval controls; that test request was removed afterward.

- [Login, desktop](preview/login-desktop.png)
- [Home, desktop](preview/home-desktop.png) and [phone](preview/home-mobile.png)
- [Book a ground, desktop](preview/grounds-desktop.png) and [phone](preview/grounds-mobile.png)
- [Organizer approvals, desktop](preview/organizer-desktop.png)
- [Find a match, desktop](preview/matches-desktop.png) and [phone](preview/matches-mobile.png)
- [Match details, phone](preview/match-details-mobile.png)
- [My requests, phone](preview/requests-mobile.png)

## Database schema

- `users`: demo accounts and roles.
- `grounds`: ground directory.
- `bookings`: organizer's ground/date/slot reservation. Unique `(ground_id, match_date, slot)` prevents double booking.
- `matches`: one match per booking, organizer, needed extra places, and `OPEN`/`FULL` status.
- `join_requests`: player application state. Unique `(match_id, player_id)` blocks duplicates; approved requests occupy places.

## Spring MVC request flow

```text
Browser
  → DispatcherServlet (Tomcat)
  → WebController (routes, session identity, view selection)
  → FutsalService (@Transactional business rules)
  → FutsalDao (JdbcTemplate / prepared JDBC statements)
  → MySQL (foreign keys, unique constraints, transaction locks)
  ← JSP view (JSTL renders model data as HTML)
  ← Browser
```

The starter accounts are for a local assignment demo, not production authentication. There are no payment, chat, external API, or notification features.
