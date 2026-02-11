<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<% printHeader(out, "Listed Logon"); %>

<%
    String message = (String) request.getAttribute("com.fireflydesign.listed.message");
    if (message != null) {
        out.print(message);
    }
%>

<form method="post" action="update.jsp">
<input type="hidden" name="method" value="logon">
<table cellspacing="4">
<tr>
<td align="right">E-Mail Address</td>
<td><input name="address" size="20" value="<%=getOptional(request, "address")%>"></td>
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
<p>
<i>Note: If you did not enter a password when you registered then leave the password field blank.</i>
</p>

<% printFooter(out); %>