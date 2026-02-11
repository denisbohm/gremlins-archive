<%@ include file="base.inc" %>

<%@ page import="com.gremlins.gallery.DynamicStatement" %>

<%@ page import="java.io.*" %>

<%!
    public static String getStringParameter(
        HttpServletRequest request, String name, String value
    ) {
        String s = request.getParameter(name);
        return (s != null) ? s : value;
    }

    public static boolean getBooleanParameter(
        HttpServletRequest request, String name, boolean value
    ) {
        String s = request.getParameter(name);
        return (s != null) ? s.equals("true") : value;
    }

    public static int getIntParameter(
        HttpServletRequest request, String name, int value
    ) {
        String s = request.getParameter(name);
        if (s != null) {
            try {
                return Integer.parseInt(s);
            } catch (NumberFormatException e) {
                throw new RuntimeException("expected " + name + " to be a number, but found " + s);
            }
        }
        return value;
    }

    public static class Buildup {

        protected int uid_;
        protected String producerName_;
        protected String kitName_;
        protected String painterName_;
        protected String holderPath_;
        protected String path_;
        protected String iconUrl_;

        public int getUid() {
            return uid_;
        }

        public String getProducerName() {
            return producerName_;
        }

        public String getKitName() {
            return kitName_;
        }

        public String getPainterName() {
            return painterName_;
        }

        public String getIconUrl() {
            return iconUrl_;
        }

    }

    protected static String getFieldName(int field) {
        switch (field) {
            case 0: return "kit.name";
            case 1: return "producer.name";
            case 2: return "sculptor.name";
            case 3: return "painter.name";
        }
        throw new RuntimeException("unknown field id " + field);
    }

    public static List getBuildups(
        int producer, int since, int genre, int material, int field, String pattern
    ) throws SQLException {
        List buildups = new ArrayList();
        Connection connection = null;
        try {
            connection = openGremlinsConnection();

	        DynamicStatement dynamic = new DynamicStatement(
	            "SELECT buildup.uid as uid, producer.name as producer," +
	            " kit.name as kit, painter.name as painter," +
	            " holder.path as holderPath, buildup.path as path, buildup.custom" +
	            " FROM buildup, kit, contact producer, contact painter, contact sculptor, contact holder" +
	            " WHERE" +
	            " kit.uid=buildup.kit AND" +
	            " producer.uid=kit.producer AND" +
	            " painter.uid=buildup.painter AND" +
	            " sculptor.uid=kit.sculptor AND" +
	            " holder.uid=buildup.owner",
	            " AND ",
	            " ORDER BY producer.name, kit.name, painter.name"
	        );
	        dynamic.addReferenceCondition("kit.producer", producer);
	        dynamic.addReferenceCondition("kit.genre", genre);
	        dynamic.addReferenceCondition("kit.material", material);
	        dynamic.addLikeCondition(getFieldName(field), pattern);
	        dynamic.addSinceCondition("buildup.updated", since);
	        PreparedStatement select = connection.prepareStatement(dynamic.getQuery());
            dynamic.setValues(select, 1);
            ResultSet resultSet = select.executeQuery();
            while (resultSet.next()) {
                Buildup buildup = new Buildup();
                buildup.uid_ = resultSet.getInt(1);
                buildup.producerName_ = resultSet.getString(2);
                buildup.kitName_ = resultSet.getString(3);
                buildup.painterName_ = resultSet.getString(4);
                String holderPath = resultSet.getString(5);
                String path = resultSet.getString(6);
                boolean custom = resultSet.getBoolean(7);
                if (custom && path.startsWith("http:")) {
                    int index = path.lastIndexOf(".");
                    buildup.iconUrl_ = path.substring(0, index) + "_icon.gif";
                } else {
                    buildup.iconUrl_ = "/" + holderPath + "/" + path +
                        "_icon.gif";
                }
                buildups.add(buildup);
            }
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
        return buildups;
    }

    public static void printOption(
        JspWriter out, String label, int value, int selected
    ) throws IOException {
        out.print("<option value=\"");
        out.print(value);
        if (value == selected) {
            out.print("\" selected>");
        } else {
            out.print("\">");
        }
        out.print(label);
        out.print("\r\n");
    }

    public static void printCheckbox(
        JspWriter out, String name, boolean value
    ) throws IOException {
        out.print("<input type=\"checkbox\" name=\"");
        out.print(name);
        out.print("\" value=\"true\"");
        if (value) {
            out.print("\" checked");
        }
        out.print(">");
    }
%>

<% printHeader(out, "gallery", "Gallery"); %>

<p>
<a href="http://members.aol.com/fatmanprod/index.html"><img src="http://www.gremlins.com/fatman/bar.jpg" width=544 height=72 border=0></a>
</p>

<p>
<img src="http://www.gremlins.com/garage/letter/w.gif" alt="W">elcome
to the gallery!
From here you can search for any of the kits in gremlins.
If you don't find what you are looking for then
<a href="http://www.gremlins.com/denis_bohm/getting_started.html"><b>build one</b></a>
and
<a href="http://www.gremlins.com/garage/register.jsp"><b>send a picture</b></a>!</b>
</p>

<p>
<form action="gallerySearch.jsp" method="post">
<input type="hidden" name="onFind" value="true">
<p>
<input type="submit" name="bySince" value="Search"> for stuff updated in the last
<select name="since" size="1">
<%
    int since = getIntParameter(request, "since", 28);
    printOption(out, "Millennium", 0, since);
    printOption(out, "24 Hours", 1, since);
    printOption(out, "Week", 7, since);
    printOption(out, "Two Weeks", 14, since);
    printOption(out, "Month", 28, since);
%>
</select>!
</p>
<p>
<input type="submit" name="byField" value="Search"> for
<%
    String pattern = getStringParameter(request, "pattern", "");
%>
<input name="pattern" value="<%=pattern%>" size=20> in the
<select name="field" size="1">
<%
    int field = getIntParameter(request, "field", 0);
    printOption(out, "Kit", 0, field);
    printOption(out, "Painter", 3, field);
    printOption(out, "Producer", 1, field);
    printOption(out, "Sculptor", 2, field);
%>
</select>
name!
</p>
<p>
<input type="submit" name="byGenre" value="Search"> for
<select name="genre" size="1">
<%
    int genre = getIntParameter(request, "genre", 0);
    printOption(out, "Any", 0, genre);
    printOption(out, "Adventure", 1, genre);
    printOption(out, "Anime", 2, genre);
    printOption(out, "Cartoon", 14, genre);
    printOption(out, "Comic", 3, genre);
    printOption(out, "Fantasy", 4, genre);
    printOption(out, "Fiction", 5, genre);
    printOption(out, "Girls", 6, genre);
    printOption(out, "Historical", 17, genre);
    printOption(out, "Horror", 7, genre);
    printOption(out, "Mecha", 8, genre);
    printOption(out, "Mythology", 9, genre);
    printOption(out, "Non-Fiction", 10, genre);
    printOption(out, "Prehistoric", 11, genre);
    printOption(out, "Science Fiction", 12, genre);
%>
</select>
genre!
</p>
<p>
<input type="submit" name="byMaterial" value="Search"> for
<select name="material" size="1">
<%
    int material = getIntParameter(request, "material", 0);
    printOption(out, "Any", 0, material);
    printOption(out, "Bronze", 16, material);
    printOption(out, "Cold Cast Porcelain", 19, material);
    printOption(out, "Fiberglass", 1, material);
    printOption(out, "Latex", 2, material);
    printOption(out, "Metal", 3, material);
    printOption(out, "Pewter", 4, material);
    printOption(out, "Plastic", 5, material);
    printOption(out, "Porcelain", 12, material);
    printOption(out, "Promat", 13, material);
    printOption(out, "Resin", 6, material);
    printOption(out, "Sculpey 3", 18, material);
    printOption(out, "Super Sculpey", 8, material);
    printOption(out, "unknown", 11, material);
    printOption(out, "Vacuform Plastic", 14, material);
    printOption(out, "Vinyl", 10, material);
    printOption(out, "Wood", 20, material);
%>
</select>
material!
</p>
<p>
<input type="submit" name="byAll" value="Search"> for all!
</p>
<p>
<%
    boolean icons = getBooleanParameter(request, "icons", request.getParameter("onFind") == null);
    boolean all = getBooleanParameter(request, "all", false);
%>
<% printCheckbox(out, "icons", icons); %><font size="-1"><i>Show icons!</i></font><br>
<% printCheckbox(out, "all", all); %><font size="-1"><i>All conditions!</i></font>
</p>
</form>
</p>
<p><a href="logon.jsp"><font size="-1"><i>Logon</i></font></a></p>
<%
    int userUid = getUserUid(request);
    if (userUid != -1) {
%>
<p><a href="/servlet/Buildup?onAdd="><img src="add.jpg" border="0"></a></p>
<%
    }

    if (request.getParameter("onFind") != null) {
        int producer = getIntParameter(request, "producer", 0);
        if (!all) {
            boolean bySince = request.getParameter("bySince") != null;
            boolean byField = request.getParameter("byField") != null;
            boolean byGenre = request.getParameter("byGenre") != null;
            boolean byMaterial = request.getParameter("byMaterial") != null;
            if (!bySince && !byField && !byGenre && !byMaterial) {
                // User hit enter assume search by field...
                byField = true;
            }
            if (!bySince) {
                since = 0;
            }
            if (!byField) {
                pattern = "";
            }
            if (!byGenre) {
                genre = 0;
            }
            if (!byMaterial) {
                material = 0;
            }
        }
        List buildups = getBuildups(producer, since, genre, material, field, pattern);
        int size = buildups.size();
        if (size == 0) {
            out.print("<p><b>None found!</b></p>\r\n");
        } else {
            out.print("<p><b>");
            out.print(size);
            out.print(" matches found.</b></p>\r\n");
            for (int i = 0; i < size; ++i) {
                Buildup buildup = (Buildup) buildups.get(i);
                if (icons) {
%>
<p><hr size="1"></p>
<p><table width="544"><tr>
<td width="100"><a href="galleryView.jsp?buildupUid=<%=buildup.getUid()%>"><img src="<%=buildup.getIconUrl()%>" width="64" height="96"></a></td>
<td align="center">
<b><%=buildup.getProducerName()%></b><br>
<a href="galleryView.jsp?buildupUid=<%=buildup.getUid()%>"><font size="+2"><b><%=buildup.getKitName()%></b></font></a><br>
<font size="-1"><i>painted by</i></font><br>
<b><%=buildup.getPainterName()%></b></td>
</tr></table></p>
<%
                } else {
%>
<a href="galleryView.jsp?buildupUid=<%=buildup.getUid()%>"><%=buildup.getKitName()%></a> produced by <%=buildup.getProducerName()%> painted by <%=buildup.getPainterName()%><br>
<%
                }
            }
        }
    }

    printFooter(out);
%>
