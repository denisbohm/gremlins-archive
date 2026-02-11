<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>

<%!
    public static class Match {
        public Date updated;
        public String url;
        public String path;
        public String name;
        public String smail;
        public String email;
        public String phone;
        public String fax;
        public String comment;
    }

    public static String getOptional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
%>

<%
String targetUrl = null;
String value;
if ((value = request.getParameter("SearchByWebNext")) != null) {
    Connection connection = null;
	try {
	    connection = openGremlinsConnection();
        PreparedStatement select = connection.prepareStatement(
            "SELECT url FROM contact WHERE" +
		    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
            " contact.name > ? AND" +
            " contact.ring=1 ORDER BY contact.name" +
            " ASC LIMIT 1"
        );
        select.setString(1, value);
        ResultSet resultSet = select.executeQuery();
        if (!resultSet.next()) {
            select = connection.prepareStatement(
                "SELECT url FROM contact WHERE" +
    		    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
                " contact.ring=1 ORDER BY contact.name" +
                " ASC LIMIT 1"
            );
            resultSet = select.executeQuery();
            resultSet.next();
        }
        targetUrl = resultSet.getString(1);
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
} else

if ((value = request.getParameter("SearchByWebPrev")) != null) {
    Connection connection = null;
	try {
	    connection = openGremlinsConnection();
        PreparedStatement select = connection.prepareStatement(
            "SELECT url FROM contact WHERE" +
		    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
            " contact.name < ? AND" +
            " contact.ring=1 ORDER BY contact.name" +
            " DESC LIMIT 1"
        );
        select.setString(1, value);
        ResultSet resultSet = select.executeQuery();
        if (!resultSet.next()) {
            select = connection.prepareStatement(
                "SELECT url FROM contact WHERE" +
    		    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
                " contact.ring=1 ORDER BY contact.name" +
                " DESC LIMIT 1"
            );
            resultSet = select.executeQuery();
            resultSet.next();
        }
        targetUrl = resultSet.getString(1);
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
} else

if (request.getParameter("SearchByWebRand") != null) {
    Connection connection = null;
	try {
	    connection = openGremlinsConnection();
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid FROM contact WHERE" +
    	    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
		    " contact.ring=1 ORDER BY contact.name"
		);
        ResultSet resultSet = select.executeQuery();
        List uids = new ArrayList();
        while (resultSet.next()) {
            uids.add(new Integer(resultSet.getInt(1)));
        }
	    int index = (int) (uids.size() * Math.random());
        int uid = ((Integer) uids.get(index)).intValue();
        select = connection.prepareStatement(
		    "SELECT url FROM contact WHERE contact.uid=?"
		);
		select.setInt(1, uid);
        resultSet = select.executeQuery();
        resultSet.next();
        targetUrl = resultSet.getString(1);
    } finally {
        if (connection != null) {
            connection.close();
        }
    }
}

if (targetUrl != null) {
    response.sendRedirect(targetUrl);
    return;
}

printHeader(out, "resources", "People");
%>

<p>
<img src=http://www.gremlins.com/garage/letter/w.gif alt="W">elcome
to the people resources!
From here you can search for people interested in figure kit related
areas.
</p>
<p>
<table><tr><td align=center>
If you have your own figure kit related web page please join the<br>
<a href="register.jsp"><b>Figure Kit Web Ring</b></a>!<br>
<img src=http://www.gremlins.com/garage/people.jpg width=166 height=130 alt="Travel the Figure Kit Web Ring!" ismap usemap="#people">
<map name="people">
<area coords="28,28,132,72"   href="http://www.gremlins.com/garage/people.jsp?SearchByWeb">
<area coords="110,54,166,130" href="http://www.gremlins.com/garage/people.jsp?SearchByWebNext=Denis%20Bohm">
<area coords="0,54,56,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebPrev=Denis%20Bohm">
<area coords="38,0,122,28"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebRand">
<area coords="0,0,166,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWeb">
</map>
</td></tr></table>
</p>

<%
String wordsDefault = request.getParameter("Words");
if (wordsDefault == null) {
	wordsDefault = "";
}
String newFieldDefault = request.getParameter("NewField");
if (newFieldDefault == null) {
    newFieldDefault = "28";
}
%>
<p>
<form action="people.jsp" method="post">
<table width=544>
<tr>
<td>
<input name="SearchByWeb" value="Search" type=submit>
for people with figure model kit related web pages!
</td>
</tr>
<tr>
<td>
<input name="SearchByNew" value="Search" type=submit>
for new stuff in the last
<select name="NewField" size=1>
<option value="1" <%= newFieldDefault.equals("1") ? "selected" : "" %>>24 Hours
<option value="7" <%= newFieldDefault.equals("7") ? "selected" : "" %>>Week
<option value="14" <%= newFieldDefault.equals("14") ? "selected" : "" %>>Two Weeks
<option value="28" <%= newFieldDefault.equals("28") ? "selected" : "" %>>Month
</select>!
</td>
</tr>
<tr>
<td>
<input name="SearchByWords" value="Search" type=submit> for
people with
<input name="Words" size=20 value="<%= wordsDefault %>">
keywords!
</td>
</tr>
<tr>
<td>
<input name="SearchForAll" value="Search" type=submit> for
all the people!
</td>
</tr>
</table>
</form>
</p>

<%
String query_head =
	"SELECT * FROM contact WHERE";
String query_tail =
	" contact.ring=1 ORDER BY contact.name";

List matches = null;
Connection connection = null;
try {
    PreparedStatement select = null;

    if (request.getParameter("SearchByNew") != null) {
	    connection = openGremlinsConnection();
	    String newField = request.getParameter("NewField");
	    int new_age = 0;
	    try {
	        new_age = Integer.parseInt(newField);
	    } catch (NumberFormatException e) {
	        throw new RuntimeException("Expected numeric new age, but found " + value);
	    }
	    java.sql.Date date = new java.sql.Date((new Date()).getTime());
	    date.setDate(date.getDate() - new_age);
	    String query =
		    query_head +
		    " (updated > ?) AND" +
		    query_tail;
	    select = connection.prepareStatement(query);
	    select.setDate(1, date);
    } else

    if (request.getParameter("SearchBySpecialty") != null) {
	    connection = openGremlinsConnection();
	    String specialty = request.getParameter("Specialty");
	    String query =
		    query_head +
		    " (specialty = ?) AND" +
		    query_tail;
	    select = connection.prepareStatement(query);
	    select.setString(1, specialty);
    } else

    if (request.getParameter("SearchByWeb") != null) {
	    connection = openGremlinsConnection();
	    String query =
		    query_head +
		    " (url IS NOT NULL) AND (LENGTH(url) > 0) AND" +
		    query_tail;
	    select = connection.prepareStatement(query);
    } else

    if (request.getParameter("SearchForAll") != null) {
	    connection = openGremlinsConnection();
	    String query = query_head + query_tail;
	    select = connection.prepareStatement(query);
    } else

    if (
	    (request.getParameter("SearchByWords") != null) ||
	    (request.getParameter("Words") != null)
    ) {
	    connection = openGremlinsConnection();
	    String words = request.getParameter("Words");
	    String query = query_head;
	    StringTokenizer tokenizer = new StringTokenizer(words, " ");
	    int count = tokenizer.countTokens();
	    if (count > 0) {
		    query += " (";
		    for (int i = 0; i < count; ++i) {
		        String token = tokenizer.nextToken();
			    query += "(LCase(name) LIKE '%" + token.toLowerCase() + "%')";
			    query += (i < (count - 1)) ? " OR " : ") AND";
		    }
	    }
	    query += query_tail;
	    select = connection.prepareStatement(query);
    }

    if (select != null) {
        ResultSet resultSet = select.executeQuery();
        matches = new ArrayList();
        while (resultSet.next()) {
            Match match = new Match();
            match.updated = resultSet.getDate("updated");
            match.url = resultSet.getString("url");
            match.path = resultSet.getString("path");
            match.name = resultSet.getString("name");
            match.smail = resultSet.getString("smail");
            match.email = resultSet.getString("email");
            match.phone = resultSet.getString("phone");
            match.fax = resultSet.getString("fax");
            match.comment = resultSet.getString("comment");
            matches.add(match);
        }
    }
} finally {
    if (connection != null) {
        connection.close();
    }
}

if (matches != null) {
	if (matches.size() == 0) {
%>
<p>
<b>No people found,
You might try asking on the
<a href=http://www.gremlins.com/garage/listed/index.jsp><font size=+1>figures mailing list</font></a>.
</p>
<%
	} else {
		int count = matches.size();
%>
<p>
<b>Found <%= count %> people.</b>
</p>
<%
	    int new_age = 28;
	    String newField = request.getParameter("NewField");
        if (newField != null) {
	        new_age = Integer.parseInt(newField);
	    }
		Date oldDate = new Date();
		oldDate.setDate(oldDate.getDate() - new_age);
		long old = oldDate.getTime();
		for (int i = 0; i < count; ++i) {
		    Match match = (Match) matches.get(i);
%>
<p>
<hr size=1>
</p>
<p>
<%
			long updated = match.updated.getTime();
			if (updated > old) {
				out.print("<img src=\"http://www.gremlins.com/garage/new.gif\"><br>\r\n");
            }

			String url = match.url;

			String path = match.path;
			if ((path != null) && (path.length() > 0)) {
				String full = getServletConfig().getServletContext().getRealPath("/" + path + "/mugshot.jpg");
				if ((new java.io.File(full)).exists()) {
					if ((url != null) && (url.length() > 0)) {
						out.print("<a href=" + url + "><img src=\"http://www.gremlins.com/" + path + "/mugshot.jpg\"" + " border=0></a><br>\r\n");
					} else {
						out.print("<img src=\"http://www.gremlins.com/" + path + "/mugshot.jpg\"><br>\r\n");
			        }
			    }
			}

			out.print("<table border=\"0\">");

			String name = match.name;
            if ((url != null) && (url.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Person:</td><td><a href=" + url + "><b>" + name + "</b></a></td></tr>\r\n");
            } else {
            	out.print("<tr><td align=right valign=top>Person:</td><td><b>" + name + "</b></td></tr>\r\n");
            }

            String smail = match.smail;
            if ((smail != null) && (smail.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Snail&nbsp;Mail:</td><td><b>" + smail + "</b></td></tr>\r\n");
            }

            String email = match.email;
            if ((email != null) && (email.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Email:</td><td><a href=\"mailto:" + email + "\"><b>" + email + "</b></a></td></tr>\r\n");
            }

            String phone = match.phone;
            if ((phone != null) && (phone.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Phone:</td><td><b>" + phone + "</b></td></tr>\r\n");
            }

            String fax = match.fax;
            if ((fax != null) && (fax.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Fax:</td><td><b>" + fax + "</b></td></tr>\r\n");
            }

            String comment = match.comment;
            if ((comment != null) && (comment.length() > 0)) {
            	out.print("<tr><td align=right valign=top>Comment:</td><td><b>" + comment + "</b></ul></td></tr>\r\n");
            }

			out.print("</table>\r\n</p>\r\n");
        }
	}
}

printFooter(out);
%>
