package edu.bca.futsal.dao;

import edu.bca.futsal.model.Account;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class FutsalDao {
    private final JdbcTemplate db;

    public FutsalDao(JdbcTemplate db) {
        this.db = db;
    }

    private static final RowMapper<Map<String, Object>> ROW = (result, number) -> {
        Map<String, Object> values = new LinkedHashMap<>();
        var columns = result.getMetaData();
        for (int i = 1; i <= columns.getColumnCount(); i++) {
            values.put(columns.getColumnLabel(i), result.getObject(i));
        }
        return values;
    };

    public Account login(String email, String password) {
        var rows = db.query("SELECT id, name, role FROM users WHERE email=? AND password=?",
                (result, number) -> new Account(result.getInt("id"), result.getString("name"),
                        result.getString("role")), email, password);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> grounds() {
        return db.query("SELECT * FROM grounds ORDER BY name", ROW);
    }

    public List<String> bookedSlots(int groundId, String date) {
        return db.query("SELECT slot FROM bookings WHERE ground_id=? AND match_date=?",
                (result, number) -> result.getString(1), groundId, date);
    }

    public List<Map<String, Object>> bookingsFor(int organizerId) {
        return db.query("""
                SELECT b.*, g.name ground_name FROM bookings b
                JOIN grounds g ON g.id=b.ground_id
                LEFT JOIN matches m ON m.booking_id=b.id
                WHERE b.organizer_id=? AND m.id IS NULL AND b.match_date >= CURRENT_DATE
                ORDER BY b.match_date, b.slot
                """, ROW, organizerId);
    }

    public List<Map<String, Object>> openMatches(int playerId) {
        return db.query("""
                SELECT m.*, u.name organizer_name, g.name ground_name, b.match_date, b.slot,
                  (SELECT COUNT(*) FROM join_requests x WHERE x.match_id=m.id AND x.status='APPROVED') approved_count,
                  COALESCE(j.status, 'NONE') request_status
                FROM matches m
                JOIN users u ON u.id=m.organizer_id
                JOIN bookings b ON b.id=m.booking_id
                JOIN grounds g ON g.id=b.ground_id
                LEFT JOIN join_requests j ON j.match_id=m.id AND j.player_id=?
                WHERE m.status='OPEN'
                ORDER BY b.match_date, b.slot
                """, ROW, playerId);
    }

    public Map<String, Object> matchDetails(int matchId, int playerId) {
        var rows = db.query("""
                SELECT m.*, u.name organizer_name, g.name ground_name, g.area, b.match_date, b.slot,
                  (SELECT COUNT(*) FROM join_requests x WHERE x.match_id=m.id AND x.status='APPROVED') approved_count,
                  COALESCE(j.status, 'NONE') request_status
                FROM matches m
                JOIN users u ON u.id=m.organizer_id
                JOIN bookings b ON b.id=m.booking_id
                JOIN grounds g ON g.id=b.ground_id
                LEFT JOIN join_requests j ON j.match_id=m.id AND j.player_id=?
                WHERE m.id=?
                """, ROW, playerId, matchId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> myMatches(int organizerId) {
        return db.query("""
                SELECT m.*, g.name ground_name, b.match_date, b.slot,
                  (SELECT COUNT(*) FROM join_requests j WHERE j.match_id=m.id AND j.status='APPROVED') approved_count
                FROM matches m
                JOIN bookings b ON b.id=m.booking_id
                JOIN grounds g ON g.id=b.ground_id
                WHERE m.organizer_id=?
                ORDER BY b.match_date DESC
                """, ROW, organizerId);
    }

    public List<Map<String, Object>> requests(int organizerId) {
        return db.query("""
                SELECT j.id request_id, j.status, u.name player_name, m.title match_title,
                  b.match_date, b.slot
                FROM join_requests j
                JOIN users u ON u.id=j.player_id
                JOIN matches m ON m.id=j.match_id
                JOIN bookings b ON b.id=m.booking_id
                WHERE m.organizer_id=? AND j.status='PENDING'
                ORDER BY j.requested_at DESC
                """, ROW, organizerId);
    }

    public List<Map<String, Object>> myRequests(int playerId) {
        return db.query("""
                SELECT j.*, m.title match_title, g.name ground_name, b.match_date, b.slot
                FROM join_requests j
                JOIN matches m ON m.id=j.match_id
                JOIN bookings b ON b.id=m.booking_id
                JOIN grounds g ON g.id=b.ground_id
                WHERE j.player_id=?
                ORDER BY j.requested_at DESC
                """, ROW, playerId);
    }

    public int createBooking(int groundId, int organizerId, String date, String slot) {
        return db.update("INSERT INTO bookings(ground_id,organizer_id,match_date,slot) VALUES(?,?,?,?)",
                groundId, organizerId, date, slot);
    }

    public int createMatch(int bookingId, int organizerId, int needed, String title, String notes) {
        return db.update("""
                INSERT INTO matches(booking_id,organizer_id,title,additional_players_needed,notes)
                SELECT ?,?,?,?,? WHERE EXISTS
                  (SELECT 1 FROM bookings WHERE id=? AND organizer_id=?)
                """, bookingId, organizerId, title, needed, notes, bookingId, organizerId);
    }

    public int requestJoin(int matchId, int playerId) {
        return db.update("""
                INSERT INTO join_requests(match_id,player_id,status)
                SELECT id,?,'PENDING' FROM matches
                WHERE id=? AND status='OPEN' AND organizer_id<>?
                """, playerId, matchId, playerId);
    }

    public Map<String, Object> lockMatch(int matchId) {
        return db.queryForMap("""
                SELECT m.*,
                  (SELECT COUNT(*) FROM join_requests j WHERE j.match_id=m.id AND j.status='APPROVED') approved_count
                FROM matches m WHERE m.id=? FOR UPDATE
                """, matchId);
    }

    public Map<String, Object> request(int requestId) {
        return db.queryForMap("SELECT * FROM join_requests WHERE id=? FOR UPDATE", requestId);
    }

    public int setRequest(int requestId, String status) {
        return db.update("UPDATE join_requests SET status=? WHERE id=?", status, requestId);
    }

    public int setMatchStatus(int matchId, String status) {
        return db.update("UPDATE matches SET status=? WHERE id=?", status, matchId);
    }

    public int cancelApproved(int requestId, int playerId) {
        return db.update("""
                UPDATE join_requests SET status='CANCELLED'
                WHERE id=? AND player_id=? AND status='APPROVED'
                """, requestId, playerId);
    }

    public boolean ownsMatch(int matchId, int organizerId) {
        return Boolean.TRUE.equals(db.queryForObject("""
                SELECT EXISTS(SELECT 1 FROM matches WHERE id=? AND organizer_id=?)
                """, Boolean.class, matchId, organizerId));
    }
}
