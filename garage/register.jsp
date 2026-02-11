<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
    public static String getOptional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
%>

<%
    printHeader(out, "resources", "Register");
%>
<p>
<img src="letter/w.gif" alt="W">ant to join the web ring?  Add something to the gallery?
Share a kit review? Or announce a new kit release from your company?
You've come to the right place!  Best of all - it's all completely free!
</p>

<p>
To join the web ring simply fill out the form below and click on the register button.
Don't forget to fill out the "URL" field and set the "Web Ring" field to "Yes".
If your contact information changes you can <a href="logon.jsp"><b>logon</b></a> at any time, using
your full name and password, and update it.
</p>
<p>
To add content to the gremlins web site (such as gallery entries, kit reviews, new stuff, etc)
fill out the form below and click on the register button.  Your registration will be reviewed
and you will be sent e-mail when you can start adding content.  To add content you must
<a href="logon.jsp"><b>logon</b></a>.
</p>
<%
    String message = (String) request.getAttribute("com.gremlins.garage.message");
    if (message != null) {
        out.print("<p><blink><font color=\"#ff0000\"><b>");
        out.print(message);
        out.print("</b></font></blink></p>");
    }
%>
<p>
<font size="-1"><b><i>Fields marked with * are required.</i></b></font>
</p>
<form method="post" action="join.jsp">
<table cellspacing="0" border="1" bgcolor="#ffffff">
<tr>
<td align="right" bgcolor="#f0f0f0">*Full Name</td>
<td><input name="name" size="40" value="<%=getOptional(request, "name")%>"></td>
</tr>

<tr>
<td align="right" bgcolor="#f0f0f0">*Password</td>
<td><input name="password" size="40" value="<%=getOptional(request, "password")%>"></td>
</tr>

<tr>
<td align="right" bgcolor="#f0f0f0">*E-Mail&nbsp;Address</td>
<td><input name="address" size="40" value="<%=getOptional(request, "address")%>"></td>
</tr>

<tr>
<td align="right" bgcolor="#f0f0f0">Home Page URL</td>
<td><input name="url" size="40" value="<%=getOptional(request, "url")%>"></td>
</tr>

<tr>
<td align="right" bgcolor="#f0f0f0">Phone</td>
<td><input name="phone" size="40" value="<%=getOptional(request, "phone")%>"></td>
</tr>

<tr>
<td align="right" bgcolor="#f0f0f0">Fax</td>
<td><input name="fax" size="40" value="<%=getOptional(request, "fax")%>"></td>
</tr>

<tr>
<td align="right" valign="top" bgcolor="#f0f0f0">Postal Address</td>
<td valign="top"><textarea name="smail" cols="40" rows="4"><%=getOptional(request, "smail")%></textarea></td>
</tr>

<tr>
<td align="right" valign="top" bgcolor="#f0f0f0">Comment</td>
<td valign="top"><textarea name="comment" cols="40" rows="4"><%=getOptional(request, "comment")%></textarea></td>
</tr>

<tr>
<td align="right" valign="top" bgcolor="#f0f0f0">Type</td>
<%
    if (!getOptional(request, "type").equals("1")) {
%>
<td valign="top"><select name="type"><option value="2" selected>Individual<option value="1">Company</select></td>
<%  } else { %>
<td valign="top"><select name="type"><option value="2">Individual<option value="1" selected>Company</select></td>
<%  } %>
</tr>

<tr>
<td align="right" valign="top" bgcolor="#f0f0f0">Web Ring</td>
<%
    if (getOptional(request, "ring").equals("true")) {
%>
<td valign="top"><select name="ring"><option value="true" selected>Yes<option value="false">No</select></td>
<%  } else { %>
<td valign="top"><select name="ring"><option value="true">Yes<option value="false" selected>No</select></td>
<%  } %>
</tr>

<tr>
<td align="right" colspan="2" bgcolor="#f0f0f0"><input type="submit" value="Register"></td>
</tr>

</table>
</form>

<% printFooter(out); %>