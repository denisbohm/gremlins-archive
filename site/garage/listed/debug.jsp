<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
public static boolean checkDomain(String address) {
    int length = address.length();
    int index = address.indexOf('.');
    if ((index == -1) || (index == 0) || (index == (length - 1))) {
        return false;
    }
    for (int i = 0; i < length; ++i) {
        char c = address.charAt(i);
        if (!Character.isLetterOrDigit(c) && (c != '.') && (c != '-')) {
            return false;
        }
    }
    return true;
}

public static void printUsersAtDomain(
    JspWriter out, Connection connection, Set domains
) throws SQLException, IOException {
    PreparedStatement select = connection.prepareStatement(
        "SELECT recipient.user,domain.uid FROM recipient,domain" +
        " WHERE recipient.domain=domain.uid AND domain.host=?"
    );
    for (Iterator i = domains.iterator(); i.hasNext(); ) {
        String domain = (String) i.next();
        out.print("<h3>");
        out.print(domain);
        out.print("</h3>\r\n");
        select.setString(1, domain);
        ResultSet resultSet = select.executeQuery();
        while (resultSet.next()) {
            out.print(resultSet.getString(1));
            out.print(" (");
            out.print(resultSet.getInt(2));
            out.print(")<br>\r\n");
        }
    }
}
%>

<%
printHeader(out, "Listed Debug");

Set domains = new HashSet();
Set duplicateDomains = new HashSet();
Set malformedDomains = new HashSet();
Set users = new HashSet();
Set duplicateUsers = new HashSet();
Set malformedUsers = new HashSet();
Connection connection = null;
try {
    connection = openListedConnection();
    Statement select = connection.createStatement();
    ResultSet resultSet = select.executeQuery(
        "SELECT host FROM domain"
    );
    while (resultSet.next()) {
        String domain = resultSet.getString(1);
        if (domains.contains(domain)) {
            duplicateDomains.add(domain);
        } else {
            domains.add(domain);
            if (!checkDomain(domain)) {
                malformedDomains.add(domain);
            }
        }
    }
    
    if (duplicateDomains.size() > 0) {
        out.print("<h2>Recipients at duplicate domains</h2>\r\n");
        printUsersAtDomain(out, connection, duplicateDomains);
    }
    
    if (malformedDomains.size() > 0) {
        out.print("<h2>Recipients at malformed domains</h2>\r\n");
        printUsersAtDomain(out, connection, malformedDomains);
    }
    
    resultSet = select.executeQuery(
        "SELECT recipient.user FROM recipient,member" +
        " WHERE recipient.uid=member.recipient AND recipient.domain<>member.domain"
    );
    boolean first = true;
    while (resultSet.next()) {
        if (first) {
            out.print("<h2>Recipients with mismatched member domain</h2>\r\n");
            first = false;
        }
        out.print(resultSet.getString(1));
        out.print("<br>\r\n");
    }    

    resultSet = select.executeQuery(
        "SELECT user FROM recipient"
    );
    while (resultSet.next()) {
        String user = resultSet.getString(1);
        if (users.contains(user)) {
            duplicateUsers.add(user);
        } else {
            users.add(user);
            try {
                new InternetAddress(user);
            } catch (AddressException e) {
                malformedUsers.add(user);
            }
        }
    }
    
    if (duplicateUsers.size() > 0) {
        out.print("<h2>Duplicate Users</h2>\r\n");
        for (Iterator i = duplicateUsers.iterator(); i.hasNext(); ) {
            String user = (String) i.next();
            out.print(user);
            out.print("<br>\r\n");
        }
    }
    
    if (malformedUsers.size() > 0) {
        out.print("<h2>Malformed Users</h2>\r\n");
        for (Iterator i = malformedUsers.iterator(); i.hasNext(); ) {
            String user = (String) i.next();
            out.print(user);
            out.print("<br>\r\n");
        }
    }
} finally {
    if (connection != null) {
        connection.close();
    }
}

printFooter(out);
%>
