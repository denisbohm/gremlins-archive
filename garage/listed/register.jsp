<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<% printHeader(out, "Listed Register"); %>

<%
    String message = (String) request.getAttribute("com.fireflydesign.listed.message");
    if (message != null) {
        out.print(message);
    }
%>

<form method="post" action="join.jsp">
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
<td align="right">Full Name</td>
<td><input name="name" size="20" value="<%=getOptional(request, "name")%>"></td>
</tr>
<tr>
<td align="right" colspan=2><input type="submit" value="Register"></td>
</tr>
</table>
</form>
<p>
<i>Note: Password and Full Name are optional.</i>
</p>

<% printFooter(out); %>