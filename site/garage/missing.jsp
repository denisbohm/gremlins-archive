<%@ include file="base.inc" %>

<%
    printHeader(out, "contents", "Not Found");
%>
<p><b><i>
The page that you were looking for was not found.
</i></b></p>
<p>
It is very likely that the content is still here
but it may have been moved to a new location
(we never throw anything away).
<p>
Check the
<a href="/garage/gallerySearch.jsp"><b>Gallery</b></a>
section for built kit photos.
</p>
<p>
Check the
<a href="/garage/articles.html"><b>Articles</b></a>
section for kit articles.
</p>
<p>
If you still can't find the page then please contact
<a href="mailto:gremlins@gremlins.com"><b>gremlins@gremlins.com</b></a>.
</p>
<%
/*
    out.print("requestURI=");
    out.print(request.getRequestURI());
    out.print("<br>\r\n");
    out.print("queryString=");
    out.print(request.getQueryString());
    out.print("<br>\r\n");
    out.print("pathInfo=");
    out.print(request.getPathInfo());
    out.print("<br>\r\n");
    for (Enumeration e = request.getHeaderNames(); e.hasMoreElements(); ) {
        String name = (String) e.nextElement();
        String value = request.getHeader(name);
        out.print(name);
        out.print("=");
        out.print(value);
        out.print("<br>\r\n");
    }
    for (Enumeration e = request.getParameterNames(); e.hasMoreElements(); ) {
        String name = (String) e.nextElement();
        String[] values = request.getParameterValues(name);
        out.print(name);
        out.print("=");
        for (int i = 0; i < values.length; ++i) {
            out.print(values[i]);
            out.print(",");
        }
        out.print("<br>\r\n");
    }
*/

    printFooter(out);
%>