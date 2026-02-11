<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>

<%!
public static String DIR = "/users/denis/web/gremlins/dimensional_designs/";

public static Connection openGremlinsConnection() throws SQLException {
    String driverClassName = "org.gjt.mm.mysql.Driver";
    try {
        Class.forName(driverClassName);
    } catch (ClassNotFoundException e) {
        throw new SQLException("Driver class not found " + driverClassName);
    }
    return DriverManager.getConnection(
        "jdbc:mysql://localhost/gremlins?user=denis&password=mohawk00"
    );
}

public static int incrementCounter(
    Connection connection, String name
) throws SQLException, IOException {
    Statement statement = connection.createStatement();
    statement.execute(
        "UPDATE counter SET count = count + 1 WHERE name = '" + name + "'"
    );
    ResultSet resultSet = statement.executeQuery(
        "SELECT count FROM counter WHERE name = '" + name + "'"
    );
    resultSet.next();
    return resultSet.getInt("count");
}

public static void printNumber(
    JspWriter out, int value
) throws IOException {
    String s = Integer.toString(value);
    for (int i = 0; i < s.length(); ++i) {
        out.print("<img src=\"http://www.gremlins.com/garage/number/");
        out.print(s.charAt(i));
        out.print(".gif\">");
    }
}

public static void includeFile(
    JspWriter out, String name
) throws IOException {
    DataInputStream in = null;
    try {
        in = new DataInputStream(new FileInputStream(DIR + name));
        String line;
        while ((line = in.readLine()) != null) {
            out.print(line);
            out.print("\r\n");
        }
    } catch (FileNotFoundException e) {
    } finally {
        try {
            in.close();
        } catch (Throwable t) {
        }
    }
}

public static void printHeaderA(
    JspWriter out, Connection connection, String section, String title
) throws IOException {
    out.print("<html>\r\n");
    out.print("<head>\r\n");
    out.print("<title>Dimensional Designs - ");
    out.print(title);
    out.print("</title>\r\n");
    out.print("<link rev=\"made\" href=\"mailto:DimDesigns@aol.com\">\r\n");
}

public static void printHeaderB(
    JspWriter out, Connection connection, String section, String title
) throws IOException {   
    out.print("</head>\r\n");
    out.print("<body bgcolor=\"#ffffff\">\r\n");
}

public static void printHeaderC(
    JspWriter out, Connection connection, String section, String title
) throws SQLException, IOException {
    out.print("<h1>\r\n");
    out.print("<center>\r\n");
    out.print("<a href=\"/index.jsp\"><img src=\"");
    out.print(section);
    out.print("_here.gif\" border=\"0\" alt=\"");
    out.print(title);
    out.print(": \"></a><br>\r\n");
    out.print("<img border=\"0\" src=\"navigate.gif\" alt=\"Dimensional Designs\" usemap=\"#navigate\"><br>\r\n");
    out.print("<map name=\"navigate\">\r\n");
    out.print("<area href=http://www.gremlins.com coords=\"0,0,75,75\">\r\n");
    out.print("<area href=index.jsp coords=\"78,0,153,75\">\r\n");
    out.print("<area href=index.jsp?what=details coords=\"156,0,231,75\">\r\n");
    out.print("<area href=index.jsp?what=list coords=\"234,0,309,75\">\r\n");
    out.print("<area href=index.jsp?what=gallery coords=\"312,0,387,75\">\r\n");
    out.print("<area href=index.jsp?what=ordering coords=\"390,0,465,75\">\r\n");
    out.print("<area href=index.jsp?what=trade coords=\"468,0,543,75\">\r\n");
    out.print("</map>\r\n");
    out.print("<br>\r\n");
    out.print("</center>\r\n");
    out.print("</h1>\r\n");

    out.print("<center>\r\n");
    out.print("<img src=\"name.gif\" alt=\"Dimensional Designs\"><br>\r\n");
    out.print("Dept. GITG<br>\r\n");
    out.print("1845 Stockton Street<br>\r\n");
    out.print("San Francisco, CA 94133-2908 USA<br>\r\n");
    out.print("Phone: (415) 788-0138<br>\r\n");
    out.print("Fax: (415) 956-9262<br>\r\n");
    out.print("Internet mail: <a href=\"mailto:DimDesigns@aol.com\">DimDesigns@aol.com</a><br>\r\n");
    out.print("<p>\r\n");
    out.print("You are visitor number ");
    printNumber(out, incrementCounter(connection, "dimdesigns"));
    out.print(" obsessed with the art of collecting great model figure kits by Dimensional Designs!\r\n");
    out.print("</p>\r\n");
    out.print("<p>\r\n");
    out.print("<form method=\"post\" action=\"http://www.gremlins.com/garage/gallerySearch.jsp\">\r\n");
    out.print("<input type=hidden name=\"onFind\" value=\"true\">\r\n");
    out.print("<input type=hidden name=\"icons\" value=\"true\">\r\n");
    out.print("<input type=hidden name=\"producer\" value=\"40\">\r\n");
    out.print("<input type=submit value=\"Quick Search\"> for\r\n");
    out.print("<input type=text name=\"pattern\">\r\n");
    out.print("</form>\r\n");
    out.print("</p>\r\n");
    out.print("</center>\r\n");
}

public static void printHeader(
    JspWriter out, Connection connection, String section, String title
) throws SQLException, IOException {
    printHeaderA(out, connection, section, title);
    printHeaderB(out, connection, section, title);
    printHeaderC(out, connection, section, title);
}

public static void printSeparator(JspWriter out) throws IOException {
    out.print("<p><img src=\"http://www.gremlins.com/garage/bones.gif\" alt=\"-----\" WIDTH=\"544\" HEIGHT=\"15\"><p>\r\n");
}

public static void printFooter(
    JspWriter out
) throws IOException {
    printSeparator(out);
    out.print("The Gremlins in the Garage webzine is a production of\r\n");
    out.print("Firefly Design.  If you have any questions or comments please\r\n");
    out.print("<a href=\"/garage/touch.html\"><b>get in touch</b></a>.\r\n");
    out.print("<p>\r\n");
    out.print("<a href=\"/garage/copyright.html\">Copyright</a> &#169; 1994-2002\r\n");
    out.print("<a href=\"http://www.fireflydesign.com\">Firefly Design</a>.\r\n");
    out.print("</td></tr></table>\r\n");
    out.print("</body>\r\n");
    out.print("</html>\r\n");
}

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

public static void writeInfo(
    JspWriter out
) throws IOException {
/*
    out.print("<center>\r\n");
    out.print("<a href=\"http://www.dimensionaldesigns.com\"><img src=\"name.gif\" alt=\"Dimensional Designs\" border=0></a><br>\r\n");
    out.print("Dept. GITG<br>\r\n");
    out.print("1845 Stockton Street<br>\r\n");
    out.print("San Francisco, CA 94133-2908 USA<br>\r\n");
    out.print("<p>\r\n");
    out.print("Email <a href=\"mailto:DimDesigns@aol.com\">DimDesigns@aol.com</a>&nbsp; &nbsp;");
    out.print("Phone 415.788.0138&nbsp; &nbsp;");
    out.print("Fax 415.956.9262");
    out.print("</p>\r\n");
    out.print("<p>\r\n");
    out.print("You are visitor number\r\n");
    out.print("<img src=\"/cgi-bin/counter.exe?link=main&style=odometer&width=6\">\r\n");
    out.print("obsessed with the art of collecting great model figure kits by Dimensional Designs!\r\n");
    out.print("</p>\r\n");
    out.print("<p>\r\n");
    out.print("<form method=\"post\" action=\"http://www.gremlins.com/garage/gallerySearch.jsp\">\r\n");
    out.print("<input type=hidden name=\"onFind\" value=\"true\">\r\n");
    out.print("<input type=hidden name=\"icons\" value=\"true\">\r\n");
    out.print("<input type=hidden name=\"producer\" value=\"40\">\r\n");
    out.print("<input type=submit value=\"Quick Search\"> for\r\n");
    out.print("<input type=text name=\"pattern\">\r\n");
    out.print("(or <a href=\"index.jsp?page=list\">Full Text List</a>)\r\n");
    out.print("</form>\r\n");
    out.print("</p>\r\n");
    out.print("</center>\r\n");
*/
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
        out.print("<table width=\"100%\" bgcolor=\"#ffcccc\"><tr><td><p align=left><font color=\"#000000\"><b>\r\n");
        out.print(comment);
        out.print("\r\n</b></font></td></tr></table></p>\r\n");
    }
}

public static boolean isKnown(String value) {
    return (value != null) && !value.equals("unknown");
}

public static void writeKitBlurb(
    JspWriter out, ResultSet rs
) throws SQLException, IOException {
    out.print("<p align=right>\r\n");
    out.print("This");
    int i;
    if ((i = rs.getInt("parts")) != 0) {
        out.print(" " + i + " part");
    }
    String s;
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
    out.print(NumberFormat.getCurrencyInstance().format(rs.getDouble("price")));
    out.print(".\r\n");
    out.print("</p>\r\n");
}

public static void writeKitTitle(
    JspWriter out, ResultSet rs, Dates dates, String align
) throws SQLException, IOException {
    out.print("<p>\r\n");
    out.print("<table width=\"100%\">\r\n");
    out.print("<tr><td colspan=2 align=" + align + " bgcolor=\"#7799ff\"><font size=+1><b>");
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
    out.print("<a href=\"http://www.dimensionaldesigns.com/ordering.html\">");
    out.print("<b>Order One!</b>");
    out.print("</a>\r\n");
    out.print("</p>\r\n");
}

public static void writeKitText(
    JspWriter out, ResultSet rs, int kitUid, Dates dates, String align
) throws SQLException, IOException {
    writeKitTitle(out, rs, dates, align);
    writeKitComment(out, rs);
    writeKitBlurb(out, rs);
    writeOrderLink(out, kitUid);
}

public static void writeKitIcon(
    JspWriter out, Connection connection, int kitUid
) throws SQLException, IOException {
    PreparedStatement statement = connection.prepareStatement(
        "SELECT uid, path FROM buildup WHERE buildup.kit=? AND buildup.owner=40"
    );
    statement.setInt(1, kitUid);
    ResultSet resultSet = statement.executeQuery();
    if (resultSet.next()) {
        int uid = resultSet.getInt(1);
        String path = resultSet.getString(2);
        out.print("<a href=\"http://www.gremlins.com/garage/galleryView.jsp?buildupUid=" + uid + "\">");
        out.print("<img src=\"" + path + "_icon.gif\" width=64 height=96 border=0>");
        out.print("</a><br>\r\n");
        out.print("<a href=\"http://www.gremlins.com/garage/galleryView.jsp?buildupUid=" + uid + "\">");
        out.print("<font size=\"-2\">more info...</font>");
        out.print("</a>\r\n");
    } else {
        out.print("<a href=\"http://www.gremlins.com/servlet/Kit?onView=" + kitUid + "\">");
        out.print("<img src=blank_icon.gif width=64 height=96>\r\n");
        out.print("</a><br>\r\n");
        out.print("<a href=\"http://www.gremlins.com/servlet/Kit?onView=" + kitUid + "\">");
        out.print("<font size=\"-2\">more info...</font>");
        out.print("</a>\r\n");
    }
}

public static void writeKit(
    JspWriter out, Connection connection, ResultSet rs, Dates dates, int order
) throws SQLException, IOException {
    out.print("\r\n<hr size=1>\r\n");

    out.print("<p><table border=0 width=544><tr>\r\n");
    
    int kitUid = rs.getInt("uid");
    if ((order % 2) == 0) {
        out.print("<td valign=top>\r\n");
        writeKitIcon(out, connection, kitUid);
        out.print("</td>\r\n");
        out.print("<td valign=top width=\"100%\">\r\n");
        writeKitText(out, rs, kitUid, dates, "left");
        out.print("</td>\r\n");
    } else {
        out.print("<td valign=top width=\"100%\">\r\n");
        writeKitText(out, rs, kitUid, dates, "right");
        out.print("</td>\r\n");
        out.print("<td valign=top>\r\n");
        writeKitIcon(out, connection, kitUid);
        out.print("</td>\r\n");
    }

    out.print("</tr></table></p>\r\n");
}

public static long getDeltaTime(int delta) {
    Date date = new Date();
    date.setDate(date.getDate() + delta);
    return date.getTime();
}

public static void writeCategoryIndex(
    JspWriter out, Connection connection, String category
) throws SQLException, IOException {
    printHeader(out, connection, "index", "Dimensional Designs");

    writeInfo(out);

    if (category.equals("Originals")) {
        category = "";
    }
    String query =
        "SELECT" +
        " kit.uid as uid," +
        " kit.updated as updated," +
        " kit.name as name," +
        " scale.name as scale," +
        " material.name as material," +
        " kit.parts as parts," +
        " genre.name as genre," +
        " kit.price as price," +
        " kit.shipping as shipping," +
        " kit.released as released," +
        " kit.discontinued as discontinued," +
        " kit._references as _references," +
        " kit.comment as comment," +
        " producer.name as producer," +
        " sculptor.name as sculptor" +
        " FROM" +
        " kit," +
        " scale," +
        " material," +
        " genre," +
        " contact producer," +
        " contact sculptor" +
        " WHERE" +
        " kit.category=? AND" +
        " kit.available=1 AND" +
        " kit.owner=40 AND" +
        " kit.genre=genre.uid AND" +
        " kit.material=material.uid AND" +
        " kit.scale=scale.uid AND" +
        " kit.producer=producer.uid AND" +
        " kit.sculptor=sculptor.uid" +
        " ORDER BY" +
        " kit.name," +
        " producer.name," +
        " sculptor.name," +
        " kit.scale," +
        " kit.material";
//        " producer.name = 'Dimensional Designs' AND" +
    PreparedStatement statement = connection.prepareStatement(query);
    statement.setString(1, category);
    ResultSet resultSet = statement.executeQuery();

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

    printFooter(out);
}

public static List getCategoryImages(
    Connection connection, String name
) throws SQLException, IOException {
    List images = new ArrayList();
    String query =
        "SELECT buildup.path as path" +
        " FROM kit, buildup" +
        " WHERE" +
        " kit.available=1 AND" +
        " kit.category=? AND" +
        " buildup.kit=kit.uid AND" +
        " buildup.owner=40";
    PreparedStatement statement = connection.prepareStatement(query);
    if (name.equals("Originals")) {
        name = "";
    }
    statement.setString(1, name);
    ResultSet resultSet = statement.executeQuery();
    while (resultSet.next()) {
        String path = resultSet.getString(1);
        images.add(path);
    }
    return images;
}

public static class Category {

    public String name;
    public List images;

    public Category(String name, List images) {
        this.name = name;
        this.images = images;
    }

}

public static void writeIndex(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    List categorys = new ArrayList();
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(
        "SELECT DISTINCT category FROM kit WHERE available=1 AND owner=40 ORDER BY category"
    );
    while (resultSet.next()) {
        String name = resultSet.getString(1);
        if ((name == null) || (name.length() == 0)) {
            name = "Originals";
        }
        List images = getCategoryImages(connection, name);
        categorys.add(new Category(name, images));
    }
    int categoryCount = categorys.size();

    printHeaderA(out, connection, "index", "Dimensional Designs");

    out.print("<SCRIPT language=\"JavaScript\">\r\n");
    out.print("<!--\r\n");

    out.print("var categorys = new Array(\r\n");
    for (int i = 0; i < categoryCount; ++i) {
        Category category = (Category) categorys.get(i);
        String name = category.name;
        out.print("\"" + name + "\"");
        if (i != (categoryCount - 1)) {
            out.print(",");
        }
    }
    out.print(");\r\n");
    out.print("var indexes = new Array();\r\n");
    out.print("var images = new Array();\r\n");
    for (int i = 0; i < categoryCount; ++i) {
        Category category = (Category) categorys.get(i);
        String name = category.name;
        out.print("indexes['" + name + "'] = 0;\r\n");
        out.print("images['" + name + "'] = new Array(\r\n");
        List images = category.images;
        int size = images.size();
        for (int j = 0; j < size; ++j) {
            String path = (String) images.get(j);
            out.print("\"" + path + "\"");
            if (j != (size - 1)) {
                out.print(",");
            }
            out.print("\r\n");
        }
        out.print(");\r\n");
    }
    out.print("function flip(category) {\r\n");
    out.print("    var sources = images[category];\r\n");
    out.print("    var index = indexes[category];\r\n");
    out.print("    indexes[category] = (index + 1) % sources.length;\r\n");
    out.print("    var e = document[category];\r\n");
    out.print("    e.src=sources[index] + \"_icon.gif\";\r\n");
    out.print("}\r\n");
    out.print("var flipper = 0;\r\n");
    out.print("var focus = null;\r\n");
    out.print("function flipNext() {\r\n");
    out.print("    if (focus == null) {\r\n");
    out.print("        do {\r\n");
    out.print("            category = categorys[flipper];\r\n");
    out.print("            flipper = (flipper + 1) % categorys.length;\r\n");
    out.print("            sources = images[category];\r\n");
    out.print("        } while (sources.length <= 1);\r\n");
    out.print("        flip(category);\r\n");
    out.print("    } else {\r\n");
    out.print("        flip(focus);\r\n");
    out.print("    }\r\n");
    out.print("}\r\n");
    out.print("function setFocus(category) {\r\n");
    out.print("    focus = category;\r\n");
    out.print("}\r\n");

    out.print("var timerID = null;\r\n");
    out.print("var timerRunning = false;\r\n");
    out.print("function initializeTimer() {\r\n");
    out.print("    stopTheClock();\r\n");
    out.print("    startTheTimer();\r\n");
    out.print("}\r\n");
    out.print("function stopTheClock() {\r\n");
    out.print("    if (timerRunning) {\r\n");
    out.print("        clearTimeout(timerID);\r\n");
    out.print("    }\r\n");
    out.print("    timerRunning = false;\r\n");
    out.print("}\r\n");
    out.print("function startTheTimer() {\r\n");
    out.print("    flipNext();\r\n");
    out.print("    timerRunning = true;\r\n");
    out.print("    timerID = self.setTimeout(\"startTheTimer()\", 1000);\r\n");
    out.print("}\r\n");

    out.print("//-->\r\n");
    out.print("</SCRIPT>\r\n");

    out.print("</head>\r\n");
    out.print("<body bgcolor=\"#ffffff\" onLoad=\"initializeTimer()\">\r\n");
    printHeaderC(out, connection, "index", "Dimensional Designs");

    writeInfo(out);

    out.print("<center>\r\n");
    out.print("<table width=544 cellspacing=0 cellpadding=0><tr>\r\n");
    for (int i = 0; i < categoryCount; ++i) {
        Category category = (Category) categorys.get(i);
        String name = category.name;
        if ((i % 4) == 0) {
            out.print("</tr><tr>\r\n");
        }
        out.print("<td><table width=136>\r\n");
        out.print("<tr><td align=center><a href=\"index.jsp?category=" + name + "\">");
        out.print("<b>" + name + "</b>");
        out.print("</a></tr></td>\r\n");
        out.print("<tr><td align=center><a href=\"index.jsp?category=" + name + "\">");
        out.print("<img name=\"" + name + "\"");
        List images = category.images;
        int size = images.size();
        if (size > 1) {
            out.print(" onmouseover=\"setFocus('" + name + "')\" onmouseout=\"setFocus(null)\"");
        }
        if (size == 0) {
            out.print(" src=\"blank_icon.gif\"");
        } else {
            String path = (String) images.get(size - 1);
            out.print(" src=\"" + path + "_icon.gif\"");
        }
        out.print(" width=64 height=96 border=0>");
        out.print("</a></tr></td>\r\n");
        out.print("</table></td>\r\n");
    }
    out.print("</tr></table>\r\n");
    out.print("<center>\r\n");

    includeFile(out, "index.txt");

    printFooter(out);
}

public static void writeKitSummary(
    JspWriter out, Connection connection, ResultSet rs, Dates dates, int count
) throws SQLException, IOException {
    if ((count % 2) == 0) {
        out.print("<tr bgcolor=\"#f0f0ff\">");
    } else {
        out.print("<tr bgcolor=\"#e8e8ff\">");
    }
    out.print("<td valign=top><font size=-1>");
    out.print("<a href=\"http://www.gremlins.com/servlet/Kit?onView=" + rs.getString("uid") + "\">");
    out.print(rs.getString("name"));
    out.print("</a>");
    out.print("</font></td>");
    out.print("<td><font size=-1>&nbsp;&nbsp;</font></td>");
    out.print("<td align=right valign=top><font size=-1>");
    out.print(NumberFormat.getCurrencyInstance().format(rs.getDouble("price")));
    out.print("</font></td>");
    out.print("<td><font size=-1>&nbsp;&nbsp;</font></td>");
    out.print("<td valign=top><font size=-1>");
    java.sql.Date date = rs.getDate("released");
    if ((date != null) && (date.getTime() > dates.old)) {
        out.print("New! ");
    }
    String comment = rs.getString("comment");
    if (comment != null) {
        out.print(comment);
    }
    String references = rs.getString("_references");
    if (references != null) {
        out.print(" From ");
        out.print(references);
        out.print(".");
    }
    out.print("&nbsp;</font></td></tr>\r\n");
}

public static void writeCategoryText(
    JspWriter out, Connection connection, String category
) throws SQLException, IOException {
    out.print("<tr><td colspan=5>&nbsp;</td></tr>\r\n");
    out.print("<tr bgcolor=\"#e0e0ff\"><td colspan=5><b>" + category + "</b></td></tr>\r\n");

    if (category.equals("Originals")) {
        category = "";
    }
    String query =
        "SELECT kit.uid as uid, kit.updated as updated, kit.name as name, scale.name as scale, material.name as material," +
        " parts, genre.name as genre, price, shipping, released, discontinued, _references," +
        " kit.comment as comment, producer.name as producer, sculptor.name as sculptor" +
        " FROM kit, scale, material, genre, contact producer, contact sculptor" +
        " WHERE" +
        " kit.category = ? AND" +
        " kit.available = 1 AND" +
        " kit.owner = 40 AND" +
        " kit.genre = genre.uid AND" +
        " kit.material = material.uid AND" +
        " kit.scale = scale.uid AND" +
        " kit.producer = producer.uid AND" +
        " kit.sculptor = sculptor.uid" +
        " ORDER BY kit.name, producer.name, sculptor.name, kit.scale, kit.material";
    PreparedStatement statement = connection.prepareStatement(query);
    statement.setString(1, category);
    ResultSet resultSet = statement.executeQuery();

    int new_age = 28;
    int soon_age = new_age;
    Dates dates = new Dates();
    dates.old = getDeltaTime(-new_age);
    dates.now = getDeltaTime(0);
    dates.soon = getDeltaTime(soon_age);

    int count = 0;
    while (resultSet.next()) {
        writeKitSummary(out, connection, resultSet, dates, count++);
    }
}

public static void writeDetails(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    printHeader(out, connection, "details", "Dimensional Designs");
    includeFile(out, "details.txt");
    printFooter(out);
}

public static void writeList(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    List categorys = new ArrayList();
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(
        "SELECT DISTINCT category FROM kit WHERE available=1 AND owner=40 ORDER BY category"
    );
    while (resultSet.next()) {
        String name = resultSet.getString(1);
        if (name == null) {
            name = "Originals";
        }
        categorys.add(name);
    }
    int categoryCount = categorys.size();

    printHeader(out, connection, "index", "Dimensional Designs");
    writeInfo(out);
    out.print("</table>\r\n");

    out.print("<table cellspacing=0 cellpadding=0 border=0>\r\n");
    out.print("<tr bgcolor=\"#ccccff\">\r\n");
    out.print("<td valign=bottom><b>Source Item Name/Title</b></td>\r\n");
    out.print("<td bgcolor=\"#ffffff\"><font size=-1>&nbsp;&nbsp;</font></td>");
    out.print("<td align=center valign=bottom><b>Price</b></td>\r\n");
    out.print("<td bgcolor=\"#ffffff\"><font size=-1>&nbsp;&nbsp;</font></td>");
    out.print("<td valign=bottom><b>Reference Information</b></td>\r\n");
    out.print("</tr>\r\n");
        
    for (int i = 0; i < categoryCount; ++i) {
        String name = (String) categorys.get(i);
        writeCategoryText(out, connection, name);
    }
    out.print("</table>\r\n");

    out.print("<table width=\"544\" cellspacing=\"0\" cellpadding=\"0\"><tr><td>\r\n");
    printFooter(out);
}

public static void writeGallery(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    printHeader(out, connection, "gallery", "Dimensional Designs");

    List categorys = new ArrayList();
    {
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(
        "SELECT DISTINCT category FROM kit WHERE available=1 AND owner=40 ORDER BY category"
    );
    while (resultSet.next()) {
        String name = resultSet.getString(1);
        if ((name == null) || (name.length() == 0)) {
            name = "Originals";
        }
        categorys.add(name);
    }
    }

    String query =
        "SELECT buildup.uid as uid, buildup.path as path" +
        " FROM kit, buildup" +
        " WHERE" +
        " kit.available=1 AND" +
        " kit.category=? AND" +
        " buildup.kit=kit.uid AND" +
        " buildup.owner=40";
    PreparedStatement statement = connection.prepareStatement(query);
    for (int i = 0; i < categorys.size(); ++i) {
        String name = (String) categorys.get(i);
        if (name.equals("Originals")) {
            name = "";
        }
        statement.setString(1, name);
        boolean first = true;
        ResultSet resultSet = statement.executeQuery();
        while (resultSet.next()) {
            if (first) {
                out.print("<h3>");
                out.print(categorys.get(i));
                out.print("</h3>\r\n");
                first = false;
            }
            int uid = resultSet.getInt(1);
            String path = resultSet.getString(2);
            out.print("<a href=\"http://www.gremlins.com/garage/galleryView.jsp?buildupUid=");
            out.print(uid);
            out.print("\"><img src=\"");
            out.print(path);
            out.print("_icon.");
            out.print((new File(DIR + path + "_icon.jpg").exists()) ? "jpg" : "gif");
            out.print("\" alt=\"\" hspace=2 vspace=2></a>\r\n");
        }
    }

    printFooter(out);
}

public static void writeOrdering(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    printHeader(out, connection, "ordering", "Dimensional Designs");
    includeFile(out, "ordering.txt");
    printFooter(out);
}

public static void writeTrade(
    JspWriter out, Connection connection
) throws SQLException, IOException {
    printHeader(out, connection, "trade", "Dimensional Designs");
    includeFile(out, "trade.txt");
    printFooter(out);
}
%>

<%
String what = request.getParameter("what");
String category = request.getParameter("category");

Connection connection = null;
try {
    connection = openGremlinsConnection();
    if (what != null) {
        if (what.equals("details")) {
            writeDetails(out, connection);
        } else
        if (what.equals("list")) {
            writeList(out, connection);
        } else
        if (what.equals("gallery")) {
            writeGallery(out, connection);
        } else
        if (what.equals("ordering")) {
            writeOrdering(out, connection);
        } else
        if (what.equals("trade")) {
            writeTrade(out, connection);
        }
    } else
    if (category == null) {
        writeIndex(out, connection);
    } else {
        writeCategoryIndex(out, connection, category);
    }
} finally {
    if (connection != null) {
        connection.close();
    }
}
%>
