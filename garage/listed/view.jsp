<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%
    printHeader(out, "Listed View");
    
    String value = request.getParameter("mailUid");
	int mailUid;
	try {
		mailUid = Integer.parseInt(value);
	} catch (NumberFormatException e) {
		throw new RuntimeException("bad mail uid value " + value);
	}
    viewMail(out, mailUid);
    
    printFooter(out);
%>