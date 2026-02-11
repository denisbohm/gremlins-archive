<%@ page isErrorPage="true" %>

<%@ include file="custom.inc" %>

<% printHeader(out, "Listed Error"); %>

<p>
An unexpected error has occured.
Please e-mail this page to
<b><a href="denis@fireflydesign.com">denis@fireflydesign.com</a></b>.
</p>

<p>
<pre>
<%
    PrintWriter writer = new PrintWriter(out);
    exception.printStackTrace(writer);
    writer.flush();
%>
</pre>
</p>

<% printFooter(out); %>