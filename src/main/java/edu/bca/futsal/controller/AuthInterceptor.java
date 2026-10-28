package edu.bca.futsal.controller;

import edu.bca.futsal.model.Account;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;

public class AuthInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        String path = request.getRequestURI().substring(request.getContextPath().length());
        boolean postingMatch = path.equals("/matches") && request.getMethod().equals("POST");
        boolean browsingMatches = path.equals("/matches") && request.getMethod().equals("GET");
        boolean decidingRequest = path.startsWith("/requests/") && !path.endsWith("/cancel");
        boolean organizerPage = path.equals("/grounds") || path.equals("/bookings")
                || path.equals("/organizer") || postingMatch || decidingRequest;
        boolean playerPage = browsingMatches || path.equals("/my-requests")
                || path.endsWith("/join") || path.endsWith("/cancel");

        if ((organizerPage && !user.getRole().equals("ORGANIZER"))
                || (playerPage && !user.getRole().equals("PLAYER"))) {
            response.sendError(403, "This action is not available for your account role.");
            return false;
        }
        return true;
    }
}
