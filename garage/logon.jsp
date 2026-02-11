<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
    public static String getOptional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
%>

<%
    printHeader(out, "Logon");

    String message = (String) request.getAttribute("com.gremlins.garage.message");
    if (message != null) {
        out.print(message);
    }
%>

<form method="post" action="welcome.jsp">
<input type="hidden" name="logon" value="true">
<table cellspacing="4">
<tr>
<td align="right">User Name</td>
<td><input name="name" size="20" value="<%=getOptional(request, "name")%>"></td>
</tr>
<tr>
<td align="right">Password</td>
<td><input name="password" size="20" value="<%=getOptional(request, "password")%>"></td>
</tr>
<tr>
<td align="right" colspan=2><input type="submit" value="Logon"></td>
</tr>
</table>
</form>

<p><i><a href="contactHelp.jsp?name=<%=getOptional(request, "name")%>"><b>Help</b></a>, I forgot my password!</i></p>

<% printFooter(out); %>