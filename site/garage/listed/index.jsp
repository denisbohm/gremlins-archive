<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<% printHeader(out, "Listed"); %>

<table cellspacing="8">

<tr>
<td valign="top" align="right"><a href="search.jsp"><b>Search</b></a></td>
<td>
Messages sent to the mailing lists are stored in a searchable archive.
You do not need to register or subscribe to search the archive.
</td>
</tr>

<tr>
<td valign="top" align="right"><a href="register.jsp"><b>Register</b></a></td>
<td>
To subscribe to the mail lists you must first register your e-mail address.
</td>
</tr>

<tr>
<td valign="top" align="right"><a href="logon.jsp"><b>Logon</b></a></td>
<td>
Registered users can logon and subscribe/unsubscribe to the mail lists.<br>
<font size=-1><i><b>
Note: 
Please do not send subscribe/unsubscribe requests to the mailing lists.
Use the logon web page to change your subscriptions.
</b></i></font>
</td>
</tr>

<tr>
<td valign="top" align="right"><a href="help.jsp"><b>Help</b></a></td>
<td>
If you forgot your password, or need some other kind of help.
</td>
</tr>

</table>

<%
    printDescriptions(out);
    
    printFooter(out);
%>