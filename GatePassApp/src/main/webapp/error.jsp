<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>

<%
    // ==========================================================
    // 🚨 SECURITY HEADERS TO PREVENT CACHING
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Get message from URL parameter or page context
    String errorMessage = request.getParameter("msg");
    if (errorMessage == null) {
        // Fallback for uncaught exceptions handled by JSP container
        exception = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
        if (exception != null) {
             errorMessage = "An unexpected error occurred: " + exception.getMessage();
        } else {
             // Generic fallback
             errorMessage = "An unknown error occurred. Please try navigating again.";
        }
    }
    // Clean up message for display
    errorMessage = errorMessage.replace("'", "&#39;").replace("\"", "&quot;");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Error - Gatepass System</title>

<style>
body {
    font-family: 'Segoe UI', Arial, sans-serif;
    background-color: #f4f5f7;
    color: #333;
    padding-top: 50px;
    text-align: center;
}

.error-container {
    max-width: 600px;
    margin: 0 auto;
    background: #fff;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    border: 1px solid #dc3545; /* Red border for emphasis */
}

h2 {
    color: #dc3545; /* Red accent */
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 20px;
}

.icon {
    font-size: 40px;
    color: #dc3545;
    margin-bottom: 15px;
}

p {
    font-size: 16px;
    margin-bottom: 25px;
}

.error-detail {
    background-color: #f7f7f7;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #eee;
    font-family: monospace;
    white-space: pre-wrap;
    text-align: left;
    color: #555;
}

.go-back-btn {
    display: inline-block;
    padding: 10px 20px;
    background-color: #1e3c72; /* Corporate Navy Blue */
    color: white;
    text-decoration: none;
    border-radius: 5px;
    font-weight: 600;
    transition: background-color 0.3s;
}

.go-back-btn:hover {
    background-color: #152d5b;
}
</style>

</head>
<body>

<div class="error-container">
    <div class="icon">❌</div>
    <h2>System Error</h2>

    <p>We encountered an issue while processing your request.</p>

    <div class="error-detail">
        **Error Message:** <%= errorMessage %>
    </div>

    <p style="margin-top: 30px;">
        <a href="javascript:history.back()" class="go-back-btn">Go Back</a>
        <a href="dashboard.jsp" class="go-back-btn" style="margin-left: 10px;">Go to Dashboard</a>
    </p>
</div>

</body>
</html>