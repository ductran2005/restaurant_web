<%@ page contentType="text/html; charset=UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Đăng ký - Restaurant</title>
        <style>
            body {
                font-family: Arial;
                background: #f5f5f5;
                margin: 0;
            }

            .container {
                max-width: 400px;
                margin: 50px auto;
                background: white;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            h2 {
                text-align: center;
                color: #333;
            }

            .form-group {
                margin: 15px 0;
            }

            label {
                display: block;
                margin-bottom: 5px;
                font-weight: bold;
            }

            input {
                width: 100%;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 4px;
                box-sizing: border-box;
            }

            button {
                width: 100%;
                padding: 10px;
                background: #4CAF50;
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 16px;
            }

            button:hover {
                background: #45a049;
            }

            .error {
                color: red;
                margin: 10px 0;
            }

            .login-link {
                text-align: center;
                margin-top: 15px;
            }

            .login-link a {
                color: #4CAF50;
                text-decoration: none;
            }
        </style>
    </head>

    <body>
        <div class="container">
            <h2>Đăng Ký</h2>
            <% if (request.getAttribute("errorMessage") !=null) { %>
                <div class="error">
                    <%= request.getAttribute("errorMessage") %>
                </div>
                <% } %>
                    <form method="post" action="<%= request.getContextPath() %>/auth/register">
                        <div class="form-group">
                            <label>Tên đăng nhập:</label>
                            <input type="text" name="username" required>
                        </div>
                        <div class="form-group">
                            <label>Họ tên:</label>
                            <input type="text" name="fullName" required>
                        </div>
                        <div class="form-group">
                            <label>Email:</label>
                            <input type="email" name="email" required>
                        </div>
                        <div class="form-group">
                            <label>Mật khẩu:</label>
                            <input type="password" name="password" required>
                        </div>
                        <div class="form-group">
                            <label>Xác nhận mật khẩu:</label>
                            <input type="password" name="confirmPassword" required>
                        </div>
                        <button type="submit">Đăng Ký</button>
                    </form>
                    <div class="login-link">
                        Đã có tài khoản? <a href="<%= request.getContextPath() %>/auth/login">Đăng nhập tại đây</a>
                    </div>
        </div>
    </body>

    </html>