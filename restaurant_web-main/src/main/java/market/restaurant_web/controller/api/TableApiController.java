package market.restaurant_web.controller.api;

import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import market.restaurant_web.dto.TableResponseDTO;
import market.restaurant_web.entity.DiningTable;
import market.restaurant_web.entity.User;
import market.restaurant_web.exception.BusinessException;
import market.restaurant_web.service.TableService;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/api/tables/*")
public class TableApiController extends HttpServlet {
    private final TableService tableService = new TableService();
    private final Jsonb jsonb = JsonbBuilder.create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            if (!checkRole(req, "ADMIN", "STAFF", "CASHIER")) {
                sendError(resp, HttpServletResponse.SC_FORBIDDEN, "Unauthorized role");
                return;
            }
            List<DiningTable> tables = tableService.findAllTables();
            List<TableResponseDTO> dtos = tables.stream().map(this::toDTO).collect(Collectors.toList());
            sendJson(resp, dtos);
        } else {
            sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Table ID missing");
            return;
        }

        String[] parts = pathInfo.split("/");
        if (parts.length < 3) {
            sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Action missing");
            return;
        }

        try {
            Integer id = Integer.parseInt(parts[1]);
            String action = parts[2];

            switch (action) {
                case "reserve":
                    if (!checkRole(req, "STAFF", "ADMIN"))
                        throw new BusinessException("Only STAFF/ADMIN can reserve tables");
                    tableService.reserveTable(id);
                    break;
                case "cancel-reservation":
                    if (!checkRole(req, "STAFF", "ADMIN"))
                        throw new BusinessException("Only STAFF/ADMIN can cancel reservations");
                    tableService.cancelReservation(id);
                    break;
                case "create-order":
                    if (!checkRole(req, "STAFF", "ADMIN"))
                        throw new BusinessException("Only STAFF/ADMIN can create orders");
                    tableService.createOrder(id);
                    break;
                case "request-payment":
                    if (!checkRole(req, "STAFF", "ADMIN"))
                        throw new BusinessException("Only STAFF/ADMIN can request payment");
                    tableService.requestPayment(id);
                    break;
                case "pay":
                    if (!checkRole(req, "CASHIER"))
                        throw new BusinessException("Only CASHIER can process payment");
                    tableService.payOrder(id);
                    break;
                case "clean":
                    if (!checkRole(req, "STAFF", "ADMIN"))
                        throw new BusinessException("Only STAFF/ADMIN can clean tables");
                    tableService.cleanTable(id);
                    break;
                case "disable":
                    if (!checkRole(req, "ADMIN"))
                        throw new BusinessException("Only ADMIN can disable tables");
                    tableService.disableTable(id);
                    break;
                case "enable":
                    if (!checkRole(req, "ADMIN"))
                        throw new BusinessException("Only ADMIN can enable tables");
                    tableService.enableTable(id);
                    break;
                default:
                    sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Unknown action: " + action);
                    return;
            }

            DiningTable updated = tableService.findTableById(id);
            sendJson(resp, toDTO(updated));

        } catch (NumberFormatException e) {
            sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Invalid table ID format");
        } catch (BusinessException e) {
            sendError(resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An internal error occurred");
            e.printStackTrace();
        }
    }

    private boolean checkRole(HttpServletRequest req, String... allowedRoles) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return false;
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRole() == null)
            return false;

        String userRole = user.getRole().getName().toUpperCase();
        for (String role : allowedRoles) {
            if (userRole.equals(role.toUpperCase()))
                return true;
        }
        return false;
    }

    private void sendJson(HttpServletResponse resp, Object data) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        String json = jsonb.toJson(data);
        out.print(json);
        out.flush();
    }

    private void sendError(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.printf("{\"error\": \"%s\", \"status\": %d}", message, status);
        out.flush();
    }

    private TableResponseDTO toDTO(DiningTable table) {
        TableResponseDTO dto = new TableResponseDTO();
        dto.setId(table.getId());
        dto.setTableNumber(table.getTableName());
        dto.setCapacity(table.getCapacity());
        dto.setStatus(table.getStatus());
        dto.setCreatedAt(table.getCreatedAt());
        dto.setUpdatedAt(table.getUpdatedAt());
        return dto;
    }
}
