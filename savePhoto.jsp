<%@ page import="java.io.*, java.util.*, java.util.Base64" %>
<%@ page import="jakarta.servlet.*" %>

<%
String base64Data = request.getParameter("photoData");
String visitorName = request.getParameter("visitorName"); // optional, pass from form
if (visitorName == null || visitorName.isEmpty()) visitorName = "Visitor";

if (base64Data != null && base64Data.startsWith("data:image")) {
    try {
        // Remove prefix like "data:image/png;base64,"
        String base64Image = base64Data.split(",")[1];
        byte[] imageBytes = Base64.getDecoder().decode(base64Image);

        // ✅ Folder path (Windows safe)
        String saveDir = "C:\\eclipse\\workspace\\visit\\Captured_Images\\";
        File uploadDir = new File(saveDir);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        // ✅ Create filename: Name_Timestamp.png
        String timestamp = String.valueOf(System.currentTimeMillis());
        String fileName = visitorName.replaceAll("\\s+", "_") + "_" + timestamp + ".png";

        File imageFile = new File(uploadDir, fileName);
        try (FileOutputStream fos = new FileOutputStream(imageFile)) {
            fos.write(imageBytes);
        }

        // ✅ Return file path to JS
        out.print(imageFile.getAbsolutePath());
    } catch (Exception e) {
        e.printStackTrace();
        out.print("ERROR: " + e.getMessage());
    }
} else {
    out.print("ERROR: No image data received");
}
%>
