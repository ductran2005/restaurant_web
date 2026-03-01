package market.restaurant_web.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AuthenticationFilter implements Filter {
    private static final String[] PUBLIC_URLS = {
            "/auth/login",
            "/auth/register",
            "/index.jsp",
            "/vnpay-return"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Check if URL is public
        if (isPublicURL(requestURI, contextPath)) {
            chain.doFilter(request, response);
            return;
        }

        // Check session
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/auth/login");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublicURL(String requestURI, String contextPath) {
        // Allow root context
        if (requestURI.equals(contextPath) || requestURI.equals(contextPath + "/")) {
            return true;
        }
        // Allow static resources
        if (requestURI.endsWith(".css") || requestURI.endsWith(".js") ||
                requestURI.endsWith(".png") || requestURI.endsWith(".jpg") ||
                requestURI.endsWith(".jpeg") || requestURI.endsWith(".gif") ||
                requestURI.endsWith(".ico") || requestURI.endsWith(".svg")) {
            return true;
        }
        for (String publicURL : PUBLIC_URLS) {
            if (requestURI.contains(publicURL)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void init(FilterConfig config) {
    }

    @Override
    public void destroy() {
    }
}
