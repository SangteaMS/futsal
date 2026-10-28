package edu.bca.futsal.service;

import edu.bca.futsal.dao.FutsalDao;
import edu.bca.futsal.model.Account;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FutsalService {
    private static final List<String> SLOTS = List.of(
            "06:00 PM – 07:00 PM", "07:00 PM – 08:00 PM",
            "08:00 PM – 09:00 PM", "09:00 PM – 10:00 PM");

    private final FutsalDao dao;

    public FutsalService(FutsalDao dao) {
        this.dao = dao;
    }

    public Account login(String email, String password) {
        return dao.login(email, password);
    }

    public List<Map<String, Object>> grounds(String date) {
        var grounds = dao.grounds();
        for (var ground : grounds) {
            var available = new ArrayList<>(SLOTS);
            available.removeAll(dao.bookedSlots(((Number) ground.get("id")).intValue(), date));
            ground.put("availableSlots", available);
        }
        return grounds;
    }

    public List<Map<String, Object>> bookingsFor(int organizerId) {
        return dao.bookingsFor(organizerId);
    }

    public List<Map<String, Object>> openMatches(int playerId) {
        return dao.openMatches(playerId);
    }

    public Map<String, Object> matchDetails(int matchId, int playerId) {
        return dao.matchDetails(matchId, playerId);
    }

    public List<Map<String, Object>> myMatches(int organizerId) {
        return dao.myMatches(organizerId);
    }

    public List<Map<String, Object>> requests(int organizerId) {
        return dao.requests(organizerId);
    }

    public List<Map<String, Object>> myRequests(int playerId) {
        return dao.myRequests(playerId);
    }

    @Transactional
    public String book(int groundId, int organizerId, String date, String slot) {
        try {
            if (LocalDate.parse(date).isBefore(LocalDate.now())) {
                return "Choose today or a future date.";
            }
            if (!SLOTS.contains(slot)) {
                return "Choose one of the listed time slots.";
            }
            dao.createBooking(groundId, organizerId, date, slot);
            return "Ground booked. Post your match from Matches & requests.";
        } catch (DuplicateKeyException ex) {
            return "That ground and slot is already booked. Choose another.";
        } catch (DateTimeException ex) {
            return "Enter a valid booking date.";
        }
    }

    public String createMatch(int bookingId, int organizerId, int needed, String title, String notes) {
        if (needed < 1 || needed > 30) {
            return "Enter between 1 and 30 players needed.";
        }
        try {
            int created = dao.createMatch(bookingId, organizerId, needed, title, notes);
            return created == 1 ? "Match posted." : "Choose one of your unused bookings.";
        } catch (DuplicateKeyException ex) {
            return "This booking already has a match.";
        }
    }

    @Transactional
    public String join(int matchId, int playerId) {
        try {
            int created = dao.requestJoin(matchId, playerId);
            return created == 1 ? "Request sent to the organizer." : "This match is no longer open.";
        } catch (DuplicateKeyException ex) {
            return "You already requested to join this match.";
        }
    }

    @Transactional
    public String decide(int requestId, int organizerId, String decision) {
        var request = dao.request(requestId);
        int matchId = ((Number) request.get("match_id")).intValue();
        if (!dao.ownsMatch(matchId, organizerId)) {
            return "Only this match's organizer can decide requests.";
        }
        if (!"PENDING".equals(request.get("status"))) {
            return "This request was already handled.";
        }
        if (!"APPROVE".equals(decision) && !"REJECT".equals(decision)) {
            return "Choose approve or reject.";
        }

        var match = dao.lockMatch(matchId);
        if ("REJECT".equals(decision)) {
            dao.setRequest(requestId, "REJECTED");
            return "Request rejected.";
        }
        int approved = ((Number) match.get("approved_count")).intValue();
        int needed = ((Number) match.get("additional_players_needed")).intValue();
        if (!"OPEN".equals(match.get("status")) || approved >= needed) {
            return "The match is full; this request cannot be approved.";
        }
        dao.setRequest(requestId, "APPROVED");
        if (approved + 1 >= needed) {
            dao.setMatchStatus(matchId, "FULL");
        }
        return "Player approved.";
    }

    @Transactional
    public String cancel(int requestId, int playerId) {
        var request = dao.request(requestId);
        if (!"APPROVED".equals(request.get("status")) || dao.cancelApproved(requestId, playerId) != 1) {
            return "Only your approved place can be cancelled.";
        }
        int matchId = ((Number) request.get("match_id")).intValue();
        var match = dao.lockMatch(matchId);
        if ("FULL".equals(match.get("status"))) {
            dao.setMatchStatus(matchId, "OPEN");
        }
        return "Place cancelled and made available again.";
    }
}
