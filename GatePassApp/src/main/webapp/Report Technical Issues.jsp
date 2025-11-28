<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ==========================================================
    // 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache");    // HTTP 1.0.
    response.setDateHeader("Expires", 0);        // Proxies.

    // ==========================================================
    // 🔑 SESSION AUTHENTICATION CHECK
    // ==========================================================
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return; 
    }
    String loggedInUser = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Technical Support</title>

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f7f6;
            margin: 0;
            padding: 30px;
            color: #333;
        }
        .container {
            max-width: 700px;
            margin: auto;
            padding: 35px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #1e3c72;
            margin-bottom: 30px;
            font-weight: 600;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #555;
        }
        input[type="text"], input[type="email"], select, textarea {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }
        input[type="text"]:focus, input[type="email"]:focus, select:focus, textarea:focus {
            border-color: #1e3c72;
            outline: none;
        }
        input[readonly] {
            background-color: #f0f0f0;
            cursor: default;
        }
        textarea {
            resize: vertical;
            min-height: 150px;
        }
        .submit-btn {
            width: 100%;
            padding: 12px;
            background-color: #1e3c72;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 17px;
            font-weight: bold;
            transition: background-color 0.3s, transform 0.1s;
        }
        .submit-btn:hover {
            background-color: #0056b3;
            transform: translateY(-1px);
        }
        
        /* Custom Alert Box Styles */
        .custom-alert {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 2000;
            padding: 15px 30px;
            border-radius: 8px;
            font-weight: bold;
            color: #fff;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            text-align: center;
            min-width: 300px;
            animation: slideDown 0.3s ease-out;
        }
        .custom-alert.error {
            background-color: #c0392b; /* Red */
        }
        .custom-alert.success {
            background-color: #27ae60; /* Green */
        }
        @keyframes slideDown {
            from { top: -60px; opacity: 0; }
            to { top: 20px; opacity: 1; }
        }
    </style>
</head>
<body onload="document.getElementById('supportSubject').focus()">

    <!-- Custom Message Box Container -->
    <div id="customAlertBox" style="display:none;" class="custom-alert"></div>

    <div class="container">
        <h2>🛠️ Technical Support & Feedback</h2>

        <form id="supportForm" method="POST" action="/SupportMailer" onsubmit="return validateAndSend(this)">

            <div class="form-group">
                <label for="toEmail">To:</label>
                <input type="email" id="toEmail" name="toEmail" value="gajendra.jatav@nfl.co.in" readonly>
            </div>

            <div class="form-group">
                <label for="supportSubject">Subject:</label>
                <select id="supportSubject" name="supportSubject" onchange="updateMessageBody()" required>
                    <option value="" disabled selected>--- Select an Issue Type ---</option>
                    <option value="DATABASE_ERROR">Database Error / Data Issue</option>
                    <option value="CAMERA_ISSUE">Camera / Photo Capture Problem</h3></option>
                    <option value="LOGIN_FAILURE">Login / Authentication Problem</option>
                    <option value="FEATURE_REQUEST">Feature Request / Suggestion</option>
                    <option value="GENERAL_FEEDBACK">General Feedback</option>
                    <option value="OTHER">Other Issue (Please describe below)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="messageBody">Details / Reason:</label>
                <textarea id="messageBody" name="messageBody" required></textarea>
            </div>
            
            <!-- Hidden field for the current user's email/identifier -->
            <input type="hidden" name="fromUser" value="<%= loggedInUser %>">

            <button type="submit" class="submit-btn">Send Support Request</button>
        </form>
    </div>

    <script>
        const loggedInUser = "<%= loggedInUser %>";
        const defaultPrompts = {
            '': 'Please select an issue type above to get a default prompt.',
            'DATABASE_ERROR': `User: ${loggedInUser}\nPage/Module: [Specify Page Name]\n\nProblem: I encountered a database error while attempting to [Action, e.g., register a contract].\nError Details: [Describe the specific error message or action taken before failure].`,
            'CAMERA_ISSUE': `User: ${loggedInUser}\nPage/Module: [Specify Page Name]\n\nProblem: The camera is not initializing or capturing the photo.\nDetails: [E.g., Camera not detected, or Capture button does nothing].`,
            'LOGIN_FAILURE': `User: ${loggedInUser}\n\nProblem: I am unable to log in.\nDetails: [E.g., Getting "Incorrect password" error, or page is stuck in a loop].`,
            'FEATURE_REQUEST': `User: ${loggedInUser}\n\nRequest: I suggest adding/modifying the following feature:\nDetails: [Describe the feature and its benefit].`,
            'GENERAL_FEEDBACK': `User: ${loggedInUser}\n\nFeedback: [Enter your general feedback here].`,
            'OTHER': `User: ${loggedInUser}\n\nIssue: [Please describe your issue in detail].`
        };

        function displayCustomAlert(message, type) {
            const alertBox = document.getElementById('customAlertBox');
            alertBox.innerHTML = message;
            alertBox.className = 'custom-alert ' + type;
            alertBox.style.display = 'block';
            setTimeout(() => {
                alertBox.style.display = 'none';
            }, 4000);
        }

        function updateMessageBody() {
            const subjectSelect = document.getElementById('supportSubject');
            const bodyTextarea = document.getElementById('messageBody');
            const selectedValue = subjectSelect.value;
            
            if (defaultPrompts[selectedValue]) {
                bodyTextarea.value = defaultPrompts[selectedValue];
            }
        }

        function validateAndSend(form) {
            const subject = form.supportSubject.value;
            const body = form.messageBody.value;
            
            if (!subject || body.trim().length < 20) {
                displayCustomAlert("Please select a subject and provide detailed information (min 20 characters).", 'error');
                return false; // Stop submission
            }

            // Client-side validation successful. Allow the form to submit to the server.
            // The server-side component (/SupportMailer) must be configured 
            // to send the email and handle the resulting redirect/message.
            
            return true; // Proceed with form submission
        }

        // Initialize message body on load
        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('messageBody').value = defaultPrompts[''];
        });
    </script>
</body>
</html>