<%@ include file="/garage/base.inc" %>

<%@ page import="java.util.Date" %>

<%!
public static class Dates {
    public long now;
    public long soon;
    public long old;
}

public final static String[] months = new String[] {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
};

public static String getSimpleDate(Date date) {
    return months[date.getMonth()] + " " + date.getDate();
}

public static String prettyPrice(String price) {
    if ((price != null) && (price.length() > 0)) {
        price = "$" + price;
        int index = price.indexOf(".");
        if (index == -1) {
            price += ".00";
        } else
        if (index == (price.length() - 2)) {
            price += "0";
        } else
        if (index < (price.length() - 2)) {
            price = price.substring(0, index + 3);
        }
    } else {
        price = null;
    }
    return price;
}

public static void writeKitStatus(
    JspWriter out, ResultSet rs, Dates dates
) throws SQLException, IOException {
    Date date = rs.getDate("discontinued");
    if (date != null) {
        if (date.getTime() < dates.now) {
            out.print("Discontinued.");
            return;
        } else
        if (date.getTime() < dates.soon) {
            out.print("Soon to be discontinued on " + getSimpleDate(date) + "!");
            return;
        }
    }

    date = rs.getDate("released");
    if (date != null) {
        if (date.getTime() > dates.old) {
            out.print("New Release!");
            return;
        }
    }

	date = rs.getDate("updated");
	if (date != null) {
	    if (date.getTime() > dates.old) {
	        out.print("Updated on " + getSimpleDate(date));
	        return;
	    }
    }
}

public static void writeKitComment(
    JspWriter out, ResultSet rs
) throws SQLException, IOException {
    String comment = rs.getString("comment");
    if ((comment != null) && (comment != "")) {
        out.print("<table width=\"100%\" bgcolor=\"#ff4444\"><tr><td><p align=left><font color=\"#000000\"><b>\r\n");
    	out.print(comment);
    	out.print("\r\n</b></font></td></tr></table></p>\r\n");
    }
}

public static boolean isKnown(String value) {
    return (value != null) && value.equals("unknown");
}

public static void writeKitBlurb(
    JspWriter out, ResultSet rs
) throws SQLException, IOException {
	out.print("<p align=right>\r\n");
    out.print("This");
    String s;
    if (isKnown(s = rs.getString("parts"))) {
        out.print(" " + s + " part");
    }
    if (isKnown(s = rs.getString("scale"))) {
        out.print(" " + s);
        if (s.indexOf("inches") == -1) {
            out.print("th scale");
        }
    }
    if (isKnown(s = rs.getString("material"))) {
        out.print(" " + s.toLowerCase());
    }
    if (isKnown(s = rs.getString("genre"))) {
        out.print(" " + s.toLowerCase());
    }
    out.print(" kit");
    if (isKnown(s = rs.getString("_references"))) {
        out.print(" from ");
        out.print(s);
    }
    out.print(" is ");
    out.print(prettyPrice(rs.getString("price")));
    out.print(".\r\n");
	out.print("</p>\r\n");
}

public static void writeKitTitle(
    JspWriter out, ResultSet rs, Dates dates
) throws SQLException, IOException {
	out.print("<p>\r\n");
	out.print("<table width=\"100%\">\r\n");
	out.print("<tr><td colspan=2 align=center><font size=+1><b>");
	out.print(rs.getString("name"));
	out.print("</b></font></td></tr>\r\n");
    out.print("<tr>\r\n");
    out.print("<td align=left><font size=-1><i>");
	writeKitStatus(out, rs, dates);
	out.print("</i></font></td>\r\n");
    out.print("<td align=right><font size=-1><i>");
	String sculptor = rs.getString("sculptor");
	if ((sculptor != null) && (sculptor != "")) {
	    out.print("sculpted by ");
	    out.print(sculptor);
	}
	out.print("</i></font></td>\r\n");
	out.print("</tr>\r\n");
	out.print("</table>\r\n");
	out.print("</p>\r\n");
}

public static void writeOrderLink(
    JspWriter out, int kitUid
) throws SQLException, IOException {
    out.print("<p align=center>\r\n");
    out.print("<a href=\"order.jsp?qty");
    out.print(kitUid);
    out.print("=1\"><b>Order It!</b></a>\r\n");
    out.print("</p>\r\n");
}

public static void writeKitText(
    JspWriter out, ResultSet rs, int kitUid, Dates dates
) throws SQLException, IOException {
    writeKitTitle(out, rs, dates);
    writeKitComment(out, rs);
    writeKitBlurb(out, rs);
    writeOrderLink(out, kitUid);
}

public static void writeKitIcon(
    JspWriter out, Connection connection, int kitUid
) throws SQLException, IOException {
	Statement statement = connection.createStatement();
	ResultSet resultSet = statement.executeQuery(
		"SELECT buildup.uid as uid, buildup.path as path, owner.path as root" +
		" FROM buildup, contact as owner" +
		" WHERE" +
		" buildup.kit=" + kitUid + " AND" +
		" buildup.owner=owner.uid AND" +
		" owner.name='Alternative Images Productions'"
    );
    if (resultSet.next()) {
        int uid = resultSet.getInt(1);
        String path = resultSet.getString(2);
        String root = resultSet.getString(3);
        out.print("<a href=\"/servlet/Buildup?onView=" + uid + "\">");
        out.print("<img src=\"" + path + "_icon.jpg\" width=216 height=216 border=0>");
        out.print("</a>\r\n");
    } else {
        out.print("<img src=blank_icon.gif width=216 height=216></a>\r\n");
    }
}

public static void writeKit(
    JspWriter out, Connection connection, ResultSet rs, Dates dates, int order
) throws SQLException, IOException {
	out.print("\r\n<hr size=1>\r\n");

	out.print("<table border=0 width=544><tr>\r\n");
	
    int kitUid = rs.getInt("uid");
    if ((order % 2) == 0) {
        out.print("<td valign=top>\r\n");
        writeKitIcon(out, connection, kitUid);
        out.print("</td>\r\n");
        out.print("<td valign=top>\r\n");
        writeKitText(out, rs, kitUid, dates);
        out.print("</td>\r\n");
    } else {
        out.print("<td valign=top>\r\n");
        writeKitText(out, rs, kitUid, dates);
        out.print("</td>\r\n");
        out.print("<td valign=top>\r\n");
        writeKitIcon(out, connection, kitUid);
        out.print("</td>\r\n");
    }

	out.print("</tr></table>\r\n");
}

public static long getDeltaTime(int delta) {
	Date date = new Date();
	date.setDate(date.getDate() + delta);
	return date.getTime();
}
%>

<% printHeader(out, "garages", "Alternative Images"); %>

<p>
<table width=544 cellpadding=0 cellspacing=0>
<tr>
<td valign="top" align="left" width="216">
<img src="title.jpg" width="216" height="216">
</td>
<td valign="top" align="center">
<p>
<b>
<font size="+2">Alternative Images</font><br>
114 Fort Hunter Road<br>
Schenectady, NY 12303<br>
518-899-3012 or 518-355-7958<br>
<a href="mailto:aimages@nycap.rr.com">aimages@nycap.rr.com</a><br>
</b>
</p>
<p>
<b><i>MasterCard and Visa accepted</i></b>
</p>
<p>
<img src="/cgi-bin/counter.exe?link=ai&style=ai&width=6">
</p>
</td>
</tr>
</table>
</p>

<hr size=1>

<p>
Thank you for expressing an interest in our kit line. We at Alternative
Images intend to continue to add new and exciting kits to our current line.
All of our resin kit figures come unassembled and unpainted with a signed
certificate of authenticity. Our kits are both hand and pressure casted.
We maintain a sizable inventory, and orders are processed daily.  We do
offer a built up and painting service, for price quotes please write or
call 518-355-7958, or contact Ron Landis at
<a href="mailto:landis@cfw.com"><b>landis@cfw.com</b></a>.
Please note that occasional parts have to be remolded, to retain the
quality of our resin kits. Should there be any delay in processing your
order you will be notified immediately.
</p>
<p>
We accept money orders, checks,  MasterCard and Visa.  Please include $6.00
per item for shipping and handling, sorry no COD's. Orders paid by personal
check should be made payable to "Alternative Images" and will be held for
two weeks pending bank clearance.  Orders are shipped UPS Ground Service.
Note to NYS Residents: 8% Sales Tax must be calculated on the total cost
of both merchandise cost and shipping and handling cost.
</p>
<p>
International Orders - For orders outside the U.S., please add 35% of the
total cost of your order for shipping and handling. Payment  must be made
by international check or money order, in U.S. funds only.
</p>
<p>
You can e-mail us your order 24 hours a day. When ordering by e-mail
please call 518-899-3012 to provide credit card information. Once an
account has been established for you, you will not need to call again
when placing an e-mail order.
</p>
<p>
To order by phone:
</p>
<p>
Call 518-899-3012.
Monday through Friday 6:00pm - 9:00pm and Saturdays 11:00am - 5:00pm.
An answering machine will take your order during off hours.
Please ensure you leave the following information: Items being ordered,
credit card number with expiration date, telephone number and shipping
address. Please speak clearly, spelling your name and mailing address.
</p>

<%
Connection connection = null;
try {
    connection = openGremlinsConnection();
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(
	    "SELECT kit.uid as uid, kit.updated as updated, kit.name as name, scale.name as scale, material.name as material," +
	    " parts, genre.name as genre, price, shipping, released, discontinued, _references," +
	    " kit.comment as comment, producer.name as producer, sculptor.name as sculptor" +
	    " FROM kit, scale, material, genre, contact producer, contact sculptor" +
	    " WHERE" +
        " kit.available = 1 AND" +
        " producer.name = 'Alternative Images Productions' AND" +
	    " kit.genre = genre.uid AND" +
	    " kit.material = material.uid AND" +
	    " kit.scale = scale.uid AND" +
	    " kit.producer = producer.uid AND" +
	    " kit.sculptor = sculptor.uid" +
	    " ORDER BY kit.name, producer.name, sculptor.name, kit.scale, kit.material"
    );

    int new_age = 28;
    int soon_age = new_age;
    Dates dates = new Dates();
    dates.old = getDeltaTime(-new_age);
    dates.now = getDeltaTime(0);
    dates.soon = getDeltaTime(soon_age);

    int count = 0;
    while (resultSet.next()) {
	    writeKit(out, connection, resultSet, dates, count++);
    }
} finally {
    if (connection != null) {
        connection.close();
    }
}

printFooter(out);
%>
