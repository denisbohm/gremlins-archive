<%@ include file="../base.inc" %>

<%@ page import="java.sql.*" %>

<%!
    public static Connection openListedConnection() throws SQLException {
        String driverClassName = "org.gjt.mm.mysql.Driver";
        try {
	        Class.forName(driverClassName);
	    } catch (ClassNotFoundException e) {
	        throw new SQLException("Driver class not found " + driverClassName);
	    }
	    return DriverManager.getConnection("jdbc:mysql://ns2.fireflydesign.com/listed?user=denis&password=mohawk00");
    }

    public static String[] getMailListNames() {
        return new String[] {
            "Gremlins - Figures", "Gremlins - Anime", "Gremlins - New Stuff", "Gremlins - Members"
        };
    }
%>
