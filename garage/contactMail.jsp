<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%
    String name = request.getParameter("name");
    Connection connection = null;
    Contact contact = null;
    try {
        connection = openGremlinsConnection();
        contact = selectContact(connection, name);
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
    if (contact == null) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "Can't find '" + name + "', check the <a href=\"/servlet/Contact\">contact</a> page to make sure it is spelled correctly."
        );
        %><jsp:forward page="contactHelp.jsp?address=<%=address%>" /><%
    }

    String text;
    String email = contact.getEmail();
    String password = contact.getPassword();
    if ((password == null) || (password.length() == 0)) {
        text = "You do not have a password setup.  To logon leave the password field blank.";
    } else {
        text = "Your password is '" + password + "'.";
    }
    sendMail(
        "fireflydesign.com", "gremlins@gremlins.com", email,
        "Gremlins Contact Help", text
    );
%>

<% printHeader(out, "Contact Help"); %>

An E-Mail message with password information has been sent to <%=email%>.

<p><i>Note: If your password is incorrect as shown on the contact page then
you will not receive the e-mail with your password.  So, if you have forgotten
your password and your e-mail address is incorrect then please send mail to
<a href="mailto:gremlins@gremlins.com">gremlins@gremlins.com</a>.</i></p>

<% printFooter(out); %>