<%@ page isErrorPage="true" %>

<%@ page import="java.io.*" %>

<html>
<head>
<title>Listed Error</title>
</head>

<body>
An unexpected error has occured.  Please e-mail this page to gremlins@gremlins.com.
<pre>
<%
    PrintWriter writer = new PrintWriter(out);
    exception.printStackTrace(writer);
    writer.flush();
%>
</pre>
</body>

</html>
