<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%
    String address = getOptional(request, "address").trim();
    String password = getOptional(request, "password").trim();
    String name = getOptional(request, "name").trim();

    int index = address.indexOf('@');
    if (index == -1) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address domain name separator '@' is missing."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == (address.length() - 1)) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address domain name is missing."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == 0) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address user name is missing."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    index = address.indexOf('.', index);
    if (index == -1) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address domain name separator '.' is missing."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == (address.length() - 1)) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Address top level domain name is missing."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    
    Connection connection = null;
    Recipient recipient = null;
    try {
        connection = openListedConnection();
        recipient = selectRecipient(connection, address);
        if (recipient == null) {
            insertRecipient(connection, address, password, name);
        }
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
    
    if (recipient == null) {
        pageContext.forward(
            "update.jsp?address=" + address + ">&password=" + password
        );
    }
%>

<% printHeader(out, "Registation Problem"); %>

The address <%=address%> is already registered.
Please proceed to the <a href="logon.jsp?address=<%=address%>">logon form</a> if you remember your password, or
to the <a href="help.jsp?address=<%=address%>">help form</a> if you do not remember your password.

<% printFooter(out); %>
