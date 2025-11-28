


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Menu Page</title>
    <meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
    <meta http-equiv="description" content="This is my page">
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">

    <link rel="stylesheet" type="text/css" href="menus.css" />

    <script type="text/javascript">
        function executeCommands() {
            alert("Hello!");
            try {
                // ActiveXObject works only in Internet Explorer (not recommended)
                var objShell = new ActiveXObject("Shell.Application");
                var commandToRun = "notepad.exe"; // Example command
                objShell.ShellExecute(commandToRun, "", "", "open", 1);
            } catch (e) {
                alert("ActiveXObject is not supported in this browser.");
            }
        }
    </script>
</head>

<body bgcolor="#BDBDBD">
    <table align="center" height="530" width="300" border="0">
        <tr><td><a href="ContractLabour.jsp" target="right" onclick="executeCommands()">Labour/Trainee Gate Pass</a></td></tr>
        <tr><td><a href="ContractLabourHistory.jsp" target="right" onclick="executeCommands()">Contract Labour History</a></td></tr>
        <tr><td><a href="ForeignerGatepass.jsp" target="right" onclick="executeCommands()">Foreigner Gate Pass</a></td></tr>
        <tr><td><a href="ForeignerGatepassHistory.jsp" target="right" onclick="executeCommands()">Foreigner Pass History</a></td></tr>
        <tr><td><a href="visitor.jsp" target="right" onclick="executeCommands()">Visitor Gatepass</a></td></tr>
        <tr><td><a href="view.jsp" target="right">Visitor View by Date</a></td></tr>
        <tr><td><a href="selectname.jsp" target="right">View by Officer to Meet</a></td></tr>
        <tr><td><a href="viewall.jsp" target="right">View All Visitors</a></td></tr>
        <tr><td><a href="selectstate.jsp" target="right">View Visitors by State</a></td></tr>
        <tr><td><a href="selectid.jsp" target="right">Visitor Revisit</a></td></tr>
        <tr><td><a href="index.html" target="_top">Logout</a></td></tr>
    </table>
</body>
</html>
