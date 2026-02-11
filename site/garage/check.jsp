<%@ include file="base.inc" %>

<%@ page import="com.gremlins.gallery.DynamicStatement" %>
<%@ page import="java.io.*" %>

<%
Connection connection = null;
try {
    connection = openGremlinsConnection();

    PreparedStatement select = connection.prepareStatement(
"SELECT contact.path,buildup.path FROM contact,buildup WHERE contact.uid=buildup.owner ORDER BY contact.path,buildup.path"
    );
    ResultSet resultSet = select.executeQuery();
    while (resultSet.next()) {
        String directory = resultSet.getString(1);
        String prefix = resultSet.getString(2);
File dir = new File("/home/denis/web/gremlins.com", directory);
if (!dir.exists()) {
    out.print("Missing directory: ");
    out.print(directory);
    out.println("<br>");
    continue;
}

String fullName = prefix + ".jpg";
File full = new File(dir, fullName);
if (!full.exists()) {
    out.print("Missing full: ");
    out.print(directory);
    out.print("/");
    out.print(prefix);
    out.println("<br>");
    String[] files = dir.list();
    for (int i = 0; i < files.length; ++i) {
        String name = files[i];
        if (name.equalsIgnoreCase(fullName)) {
            out.print("renaming ");
            out.print(name);
            out.print(" to ");
            out.print(fullName);
            out.println("<br>");
            File f = new File(dir, name);
            f.renameTo(full);
            break;
        }
    }
    continue;
}
String iconName = prefix + "_icon.gif";
File icon = new File(dir, iconName);
if (!icon.exists()) {
    out.print("Missing icon: ");
    out.print(directory);
    out.print("/");
    out.print(prefix);
    out.println("<br>");
    String[] files = dir.list();
    for (int i = 0; i < files.length; ++i) {
        String name = files[i];
        if (name.equalsIgnoreCase(iconName)) {
            out.print("renaming ");
            out.print(name);
            out.print(" to ");
            out.print(iconName);
            out.println("<br>");
            File f = new File(dir, name);
            f.renameTo(icon);
            break;
        }
    }
    continue;
}
    }
} finally {
    if (connection != null) {
        connection.close();
    }
}
%>
