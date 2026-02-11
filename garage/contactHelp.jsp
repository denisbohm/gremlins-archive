<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
    public static String getOptional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
%>

<% printHeader(out, "Contact Help"); %>

<%
    String message = (String) request.getAttribute("com.gremlins.garage.message");
    if (message != null) {
        out.print(message);
    }
%>

To have your password sent to you enter your name, exactly as shown on the
<a href="/servlet/Contact"><b>contact</b></a> page, and click on the OK button.
<form method="post" action="contactMail.jsp">
<p>
Name
<input name="name" size="40" value="<%=getOptional(request, "name")%>">
<input type="submit" value="OK">
</form>

<p><i>Note: If your password is incorrect as shown on the contact page then
you will not receive the e-mail with your password.  So, if you have forgotten
your password and your e-mail address is incorrect then please send mail to
<a href="mailto:gremlins@gremlins.com">gremlins@gremlins.com</a>.</i></p>

<% printFooter(out); %>