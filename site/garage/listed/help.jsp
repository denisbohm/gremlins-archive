<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<% printHeader(out, "Listed Help"); %>

<%
    String message = (String) request.getAttribute("com.fireflydesign.listed.message");
    if (message != null) {
        out.print(message);
    }
%>

To have your password sent to you enter your e-mail address below and click on the OK button.
<form method="post" action="mail.jsp">
<p>
E-Mail Address
<input name="address" size="20" value="<%=getOptional(request, "address")%>">
<input type="submit" value="OK">
</form>

<% printFooter(out); %>