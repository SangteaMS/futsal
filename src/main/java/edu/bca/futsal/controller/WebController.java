package edu.bca.futsal.controller;

import edu.bca.futsal.model.Account;
import edu.bca.futsal.service.FutsalService;
import jakarta.servlet.http.HttpSession;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.Locale;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class WebController {
    private final FutsalService service;

    public WebController(FutsalService service) {
        this.service = service;
    }

    @ModelAttribute
    public void identity(HttpSession session, Model model) {
        model.addAttribute("user", session.getAttribute("user"));
    }

    private Account user(HttpSession session) {
        return (Account) session.getAttribute("user");
    }

    private String firstPage(Account account) {
        return "ORGANIZER".equals(account.getRole()) ? "redirect:/grounds" : "redirect:/matches";
    }

    @GetMapping({"/", "/login"})
    public String loginPage(HttpSession session) {
        Account account = user(session);
        return account == null ? "login" : firstPage(account);
    }

    @PostMapping("/login")
    public String login(@RequestParam String email, @RequestParam String password,
                        HttpSession session, Model model) {
        Account account = service.login(email, password);
        if (account == null) {
            model.addAttribute("error", "Email or password was incorrect.");
            return "login";
        }
        session.setAttribute("user", account);
        return firstPage(account);
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    @GetMapping("/grounds")
    public String grounds(@RequestParam(required = false) String date, Model model) {
        String selected = date == null || date.isBlank() ? LocalDate.now().plusDays(1).toString() : date;
        try {
            LocalDate.parse(selected);
        } catch (DateTimeException ex) {
            selected = LocalDate.now().plusDays(1).toString();
        }
        model.addAttribute("selectedDate", selected);
        model.addAttribute("grounds", service.grounds(selected));
        return "grounds";
    }

    @PostMapping("/bookings")
    public String book(@RequestParam int groundId, @RequestParam String matchDate,
                       @RequestParam String slot, HttpSession session, Model model) {
        model.addAttribute("flash", service.book(groundId, user(session).getId(), matchDate, slot));
        model.addAttribute("selectedDate", matchDate);
        model.addAttribute("grounds", service.grounds(matchDate));
        return "grounds";
    }

    @GetMapping("/matches")
    public String matches(HttpSession session, Model model) {
        model.addAttribute("matches", service.openMatches(user(session).getId()));
        return "matches";
    }

    @GetMapping("/matches/{id}")
    public String matchDetails(@PathVariable int id, HttpSession session, Model model) {
        model.addAttribute("match", service.matchDetails(id, user(session).getId()));
        return "match-details";
    }

    @PostMapping("/matches/{id}/join")
    public String join(@PathVariable int id, HttpSession session, Model model) {
        model.addAttribute("flash", service.join(id, user(session).getId()));
        model.addAttribute("match", service.matchDetails(id, user(session).getId()));
        return "match-details";
    }

    private void organizerData(int organizerId, Model model) {
        model.addAttribute("bookings", service.bookingsFor(organizerId));
        model.addAttribute("matches", service.myMatches(organizerId));
        model.addAttribute("requests", service.requests(organizerId));
    }

    @GetMapping("/organizer")
    public String organizer(HttpSession session, Model model) {
        organizerData(user(session).getId(), model);
        return "organizer";
    }

    @PostMapping("/matches")
    public String createMatch(@RequestParam int bookingId, @RequestParam int needed,
                              @RequestParam String title,
                              HttpSession session, Model model) {
        int organizerId = user(session).getId();
        model.addAttribute("flash", service.createMatch(bookingId, organizerId, needed, title));
        organizerData(organizerId, model);
        return "organizer";
    }

    @PostMapping("/requests/{id}/{decision}")
    public String decide(@PathVariable int id, @PathVariable String decision,
                         HttpSession session, Model model) {
        int organizerId = user(session).getId();
        model.addAttribute("flash", service.decide(id, organizerId, decision.toUpperCase(Locale.ROOT)));
        organizerData(organizerId, model);
        return "organizer";
    }

    @GetMapping("/my-requests")
    public String myRequests(HttpSession session, Model model) {
        model.addAttribute("requests", service.myRequests(user(session).getId()));
        return "my-requests";
    }

    @PostMapping("/requests/{id}/cancel")
    public String cancel(@PathVariable int id, HttpSession session, Model model) {
        int playerId = user(session).getId();
        model.addAttribute("flash", service.cancel(id, playerId));
        model.addAttribute("requests", service.myRequests(playerId));
        return "my-requests";
    }

    @ExceptionHandler(DataAccessException.class)
    public String databaseError(Model model) {
        model.addAttribute("error", "Database connection failed. Check MySQL and the README setup steps.");
        return "error";
    }
}
