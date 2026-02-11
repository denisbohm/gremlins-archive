<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
public static void writeSelect(
    JspWriter out, String[] names, String selectName, String selectDefault
) throws IOException {
	out.print("<select name=" + selectName + ">");
	for (int i = 0; i < names.length; ++i) {
		String name = names[i];
		if (name.equals(selectDefault)) {
			out.print("<option selected value=\"" + name + "\">" + name);
		} else {
			out.print("<option value=\"" + name + "\">" + name);
		}
	}
	out.print("</select>\r\n");
}

public static void writeOption(
    JspWriter out, String value, String label, String selectDefault
) throws IOException {
	out.print("<option value=\"" + value);
	if (value == selectDefault) {
		out.print("\" selected");
	}
	out.print("\">" + label + "\r\n");
}

public static void writeSearchForms(
    HttpServletRequest request, JspWriter out, String[] mailListNames
) throws IOException {
	out.print("<p>\r\n");
    out.print("<form method=\"post\" action=\"search.jsp\">\r\n");
	out.print("<input type=hidden name=\"state\" value=\"SearchSince\">\r\n");
	out.print("<input type=hidden name=\"limit\" value=\"100\">\r\n");
	out.print("<input type=submit value=\"Search\"> ");
	writeSelect(out, mailListNames, "mail_list", getOptional(request, "mail_list"));
	out.print(" for the last <select name=\"since\">");
	String since = getOptional(request, "since");
	writeOption(out, "1", "24 Hours", since);
	writeOption(out, "7", "One Week", since);
	writeOption(out, "14", "Two Weeks", since);
	writeOption(out, "28", "One Month", since);
	out.print("</select></form>\r\n");
	out.print("</p>\r\n");

	out.print("<p>\r\n");
    out.print("<form method=\"post\" action=\"search.jsp\">\r\n");
	out.print("<input type=hidden name=\"state\" value=\"SearchSubject\">\r\n");
	out.print("<input type=hidden name=\"limit\" value=\"100\">\r\n");
	out.print("<input type=submit value=\"Search\"> ");
	writeSelect(out, mailListNames, "mail_list", getOptional(request, "mail_list"));
	out.print(" for subject <input type=text name=\"subject\" value=\"" + getOptional(request, "subject") +"\">");
	out.print("</form>\r\n");
	out.print("</p>\r\n");

	out.print("<p>\r\n");
    out.print("<form method=\"post\" action=\"search.jsp\">\r\n");
	out.print("<input type=hidden name=\"state\" value=\"SearchSender\">\r\n");
	out.print("<input type=hidden name=\"limit\" value=\"100\">\r\n");
	out.print("<input type=submit value=\"Search\"> ");
	writeSelect(out, mailListNames, "mail_list", getOptional(request, "mail_list"));
	out.print(" for sender <input type=text name=\"sender\" value=\"" + getOptional(request, "sender") +"\">");
	out.print("</form>\r\n");
	out.print("</p>\r\n");

    out.print("<p>Search the mailing list archives by date, subject, or sender.</p>\r\n");
}

public static void writePair(
    JspWriter out, String label, String value
) throws IOException {
	out.print("<tr><td align=right>&nbsp;" + label + ":&nbsp;</td>");
	out.print("<td>&nbsp;" + value + "&nbsp;</td></tr>");
}

public static void writeOperation(
    JspWriter out, String script, String ar, String state, String mail_uid, String label
) throws IOException {
	out.print("<a href=\"" + script + "?");
	if (ar != null) {
		out.print(ar + "&");
	}
	out.print("state=" + state + "&uid=" + mail_uid + "\"><b>" + label + "</b></a>");
	out.print("\r\n");
}

public static class Mail {
    public int uid;
    public java.sql.Date archived;
    public String address;
    public String subject;
}

public static void listMail(JspWriter out, List mails, int limit) throws IOException {
	int count = mails.size();
	if (count < limit) {
	    out.print("<b>" + count + " messages found.</b><br>\r\n");
	} else {
	    out.print("<b>" + count + " messages found (search results limited to " + limit + ").</b><br>\r\n");
	}
	for (int i = 0; i < count; ++i) {
		Mail mail = (Mail) mails.get(i);
		out.print("<p><hr size=1></p>\r\n");
		out.print("<p>\r\n");
		out.print("<table>\r\n");
		writePair(out, "Subject", mail.subject);
		writePair(out, "From", mail.address);
		writePair(out, "Archived", mail.archived.toString());
		out.print("<tr>\r\n");
		out.print("<td colspan=2>&nbsp;");
		out.print("<a href=\"view.jsp?mailUid=" + mail.uid + "\">View</a>");
		out.print("&nbsp;</td>");
		out.print("</tr>\r\n");
		out.print("</table>\r\n");
		out.print("</p>\r\n");
	}
}

public static void getMails(ResultSet resultSet, List mails) throws SQLException {
	while (resultSet.next()) {
	    Mail mail = new Mail();
	    mail.uid = resultSet.getInt(1);
	    mail.archived = resultSet.getDate(2);
	    mail.address = resultSet.getString(3);
	    mail.subject = resultSet.getString(4);
	    mails.add(mail);
	}
}

public static void listSince(
    JspWriter out, String mailListName, int days, int limit
) throws SQLException, IOException {
	java.sql.Timestamp date = new java.sql.Timestamp((new Date()).getTime());
	date.setDate(date.getDate() - days);
    List mails = new ArrayList();
	Connection connection = null;
	try {
	    connection = openListedConnection();
            String query =
		    "SELECT mail.uid as uid,mail.archived as archived,address.name as address,subject.name as subject" +
		    " FROM mail,message,address,subject,mail_list WHERE" +
		    " mail.mail_list=mail_list.uid AND" +
		    " mail_list.name=? AND" +
		    " mail.archived > ? AND" +
		    " mail.message=message.uid AND" +
		    " message.mh_subject=subject.uid AND" +
		    " message.mh_from=address.uid" +
		    " ORDER BY mail.archived DESC" +
		    " LIMIT " + limit;
	    PreparedStatement select = connection.prepareStatement(
		query
	    );
	    select.setString(1, mailListName);
	    select.setTimestamp(2, date);
	    ResultSet resultSet = select.executeQuery();
	    getMails(resultSet, mails);
	} finally {
	    if (connection == null) {
	        connection.close();
	    }
	}
	listMail(out, mails, limit);
}

public static void listSubject(
    JspWriter out, String mailListName, String subject, int limit
) throws SQLException, IOException {
    List mails = new ArrayList();
	Connection connection = null;
	try {
	    connection = openListedConnection();
	    PreparedStatement select = connection.prepareStatement(
		    "SELECT mail.uid as uid,mail.archived as archived,address.name as address,subject.name as subject" +
		    " FROM mail,message,address,subject,mail_list WHERE" +
		    " mail.mail_list=mail_list.uid AND" +
		    " mail_list.name=? AND" +
		    " mail.message=message.uid AND" +
		    " message.mh_from=address.uid AND" +
		    " message.mh_subject=subject.uid AND" +
		    " LCase(subject.name) LIKE ?" +
		    " ORDER BY mail.archived DESC" +
                    " LIMIT " + limit
		);
		select.setString(1, mailListName);
		select.setString(2, "%" + subject.toLowerCase() + "%");
	    ResultSet resultSet = select.executeQuery();
	    getMails(resultSet, mails);
	} finally {
	    if (connection == null) {
	        connection.close();
	    }
	}
	listMail(out, mails, limit);
}

public static void listSender(
    JspWriter out, String mailListName, String sender, int limit
) throws SQLException, IOException {
    List mails = new ArrayList();
	Connection connection = null;
	try {
	    connection = openListedConnection();
	    PreparedStatement select = connection.prepareStatement(
		    "SELECT mail.uid as uid,mail.archived as archived,address.name as address,subject.name as subject" +
		    " FROM mail,message,address,subject,mail_list WHERE" +
		    " mail.mail_list=mail_list.uid AND" +
		    " mail_list.name=? AND" +
		    " mail.message=message.uid AND" +
		    " message.mh_from=address.uid AND" +
		    " message.mh_subject=subject.uid AND" +
		    " LCase(address.name) LIKE ?" +
		    " ORDER BY mail.archived DESC" +
                    " LIMIT " + limit
		);
		select.setString(1, mailListName);
		select.setString(2, "%" +  sender.toLowerCase() + "%");
	    ResultSet resultSet = select.executeQuery();
	    getMails(resultSet, mails);
	} finally {
	    if (connection == null) {
	        connection.close();
	    }
	}
	listMail(out, mails, limit);
}

public static int getLimit(HttpServletRequest request) {
	try {
		return Integer.parseInt(request.getParameter("limit"));
	} catch (NumberFormatException e) {
		throw new RuntimeException("bad limit value " + request.getParameter("limit"));
	}
}
%>

<%
    printHeader(out, "Listed - Search");
    
    String[] mailListNames = getMailListNames();

	String state = request.getParameter("state");
	if (state == null) {
		writeSearchForms(request, out, mailListNames);
	} else
	if (state.equals("SearchSince")) {
		writeSearchForms(request, out, mailListNames);

		String mailListName = request.getParameter("mail_list");
		int days;
		try {
		    days = Integer.parseInt(request.getParameter("since"));
		} catch (NumberFormatException e) {
		    throw new RuntimeException("bad days value " + request.getParameter("since"));
		}
		listSince(out, mailListName, days, getLimit(request));
	} else
	if (state.equals("SearchSubject")) {
		writeSearchForms(request, out, mailListNames);

		String mailListName = request.getParameter("mail_list");
		String subject = request.getParameter("subject");
		listSubject(out, mailListName, subject, getLimit(request));
	} else
	if (state.equals("SearchSender")) {
		writeSearchForms(request, out, mailListNames);

		String mailListName = request.getParameter("mail_list");
		String sender = request.getParameter("sender");
		listSender(out, mailListName, sender, getLimit(request));
	} else {
		writeSearchForms(request, out, mailListNames);
	}
	
	printFooter(out);
%>
