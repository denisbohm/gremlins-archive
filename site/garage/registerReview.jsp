<%@ include file="base.inc" %>

<%
    printHeader(out, "resources", "Registration Review");

    String reject = request.getParameter("reject");
    if (reject != null) {
        int uid = Integer.parseInt(reject);
        Contact contact = getContact(uid);
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            PreparedStatement update = connection.prepareStatement(
                "UPDATE contact SET rights=11 WHERE uid=?"
            );
            update.setInt(1, uid);
            update.executeUpdate();
            out.println("Set rights<br>\r\n");
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    String approve = request.getParameter("approve");
    if (approve != null) {
        int uid = Integer.parseInt(approve);
        Contact contact = getContact(uid);
if (request.getParameter("mail") == null) {
        out.println("Approving " + contact.getName() + "<br>\r\n");
        java.io.File directory = new java.io.File(
            "/home/denis/web/gremlins.com", contact.getPath()
        );
        directory.mkdir();
        out.println("Created directory " + directory.getAbsolutePath() + "<br>\r\n");
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            PreparedStatement update = connection.prepareStatement(
                "UPDATE contact SET rights=6 WHERE uid=?"
            );
            update.setInt(1, uid);
            update.executeUpdate();
            out.println("Set rights<br>\r\n");
            PreparedStatement insert = connection.prepareStatement(
                "INSERT INTO favorite (owner, label, choice) VALUES (?,?,?)"
            );
            insert.setInt(1, uid);
            insert.setString(2, "Contact");
            insert.setInt(3, uid);
            insert.executeUpdate();
            out.println("Added contact favorite for self<br>\r\n");
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
}
try {
        sendMail(
            "mail.gremlins.com",
            "gremlins@gremlins.com",
            "gremlins@gremlins.com," + contact.getEmail(),
            "Welcome to Gremlins in the Garage!",
"Welcome!\r\n" +
"\r\n" +
"Your gremlins registration has been accepted and your logon setup is\r\n" +
"complete:\r\n" +
"  http://www.gremlins.com/garage/logon.jsp\r\n" +
"\r\n" +
"Your logon user name is \"" + contact.getName() + "\" and your password is \"" + contact.getPassword() + "\".\r\n" +
"\r\n" +
"Please consider joining the members mailing list for help with the\r\n" +
"procedures and forms for adding content to the gremlins web site:\r\n" +
"  http://www.gremlins.com/garage/listed\r\n" +
"\r\n" +
"If you need any help please use the members mailing list or contact me\r\n" +
"directly.\r\n" +
"\r\n" +
"BTW: Web Ring Members - Please add the web ring links to your web site as\r\n" +
"soon as possible so the ring will be unbroken!\r\n" +
"\r\n" +
"Have Fun!\r\n" +
"  Denis Bohm\r\n" +
"  Gremlins in the Garage!\r\n"
        );
        out.println("Sent welcome mail<br>\r\n");
} catch (Throwable e) {
    out.println("<pre>");
    java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
    PrintWriter pw = new PrintWriter(baos);
    e.printStackTrace(pw);
    pw.flush();
    out.print(baos.toString());
    out.println("</pre>");
}
    }

    List contacts = new ArrayList();
    Connection connection = null;
    try {
        connection = openGremlinsConnection();
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid FROM contact WHERE rights=1"
        );
        ResultSet resultSet = select.executeQuery();
        while (resultSet.next()) {
            int uid = resultSet.getInt(1);
            contacts.add(selectContact(connection, uid));
        }
    } finally {
        if (connection != null) {
            connection.close();
        }
    }

    int size = contacts.size();
    for (int i = 0; i < size; ++i) {
        Contact contact = (Contact) contacts.get(i);
if (contact.getOwner() == contact.getUid()) {
%>
Request
<%
} else {
%>
Contact
<%
}
%>
<a href="registerReview.jsp?approve=<%=contact.getUid()%>">Approve</a>
<a href="registerReview.jsp?reject=<%=contact.getUid()%>">Reject</a>
<a href="/servlet/Contact?onView=<%=contact.getUid()%>"><%=contact.getName()%></a><br>
<%
    }

    printFooter(out);
%>
