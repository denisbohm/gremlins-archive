<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%
    String address = request.getParameter("address");
    Connection connection = null;
    Recipient recipient = null;
    try {
        connection = openListedConnection();
        recipient = selectRecipient(connection, address);
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
    if (recipient == null) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address " + address + " is not registered."
        );
        %><jsp:forward page="help.jsp?address=<%=address%>" /><%
    }

    String text;
    String password = recipient.getPassword();
    if ((password == null) || (password.length() == 0)) {
        text = "You do not have a password setup.  To logon leave the password field blank.";
    } else {
        text = "Your password is '" + password + "'.";
    }
    mail(
        "fireflydesign.com", "gremlins@gremlins.com", address,
        "Gremlins Mail List Help", text
    );
%>

<% printHeader(out, "Listed Help"); %>

An E-Mail message with password information has been sent to <%=address%>.

<% printFooter(out); %>