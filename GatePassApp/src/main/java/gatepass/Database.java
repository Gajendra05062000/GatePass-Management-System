package gatepass;
import java.sql.Connection;
import java.sql.DriverManager;

public class Database {
	//String ipFinal="10.3.122.106";	
String ipFinal="10.3.126.43";
String ipFinalName="gatepass";
public Connection getConnection() {
		Connection conn = null;
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");

			String url = "jdbc:oracle:thin:@10.3.111.120:1521:ORCL";
			conn = DriverManager.getConnection(url, "GATEPASS", "GATEPASS");			
			
			System.out.println("DB CONNECTED-->PERSONNEL");

		} catch (Exception e) {
			e.printStackTrace();
		}
		return (conn);
	}
	

public String getServerIp() {
	
	String serverIp = ipFinal+":8080";
	//String serverIp = "10.3.122.106:8080";
	
	return serverIp;
}

public String getServerIpOnly() {
	 String serverIp = ipFinal;	
     return serverIp;
}


public String getImageSavingIp() {
	//String serverIp = "10.3.111.103";	
	String serverIp = ipFinal;	
	
	
	return serverIp;
	
	 
}

public String imageSavingPath() {
	//gatepass.Database db = new gatepass.Database();	
	//String ip = db.getImageSavingIp();	
	//String imgPath="C:/Users/Hrishikesh/Pictures";
	//String imgPath="C:/Users/Gate Pass/Pictures";
	//String imgPath="C:/Users/gatepass/Pictures/Logitech Webcam";
	String imgPath="C:/Users/GATEPASS/Pictures/Logitech Webcam";
	//String imgPath="C:/Users/gate pass/My Pictures/Logitech Webcam";
	//C:\Users\gatepass\Pictures\Logitech Webcam
	
	
	
	
	//String imgPath="////"+ip+"//Users//bank";	
	return imgPath;	
	 
}


public String camInstallationPath() {
	//path is for client not for server...specific path of client machine needed
	//Ip access 
	  //File file = new File("////10.3.111.103//Users//bank");   
 //String camInstallationPath="C:/Program Files/VideoCap/iBall Face2Face C8.0 Webcam/VideoCap.exe";
 //String camInstallationPath="C:/Program Files/VideoCap/iBall Face2Face C8.0 Webcam/VideoCap.exe";
	 String camInstallationPath="C:/Program Files (x86)/Common Files/LogiShrd/LWSPlugins/LWS/Applets/HelpMain/launchershortcut.exe";
	 //C:\Program Files\Common Files\LogiShrd\LWSPlugins\LWS\Applets\HelpMain\launchershortcut.exe
	//String camInstallationPath="////10.3.122.106//Program Files//VideoCap//iBall Face2Face C8.0 Webcam//VideoCap.exe";
	
	return camInstallationPath;	
	 
}
}


