<%@ include file="base.inc" %>

<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.Date" %>

<%!
    public static class Thingie {
        public String ownerPath;
        public String path;
        public boolean custom;
        public String url;
        public String imageUrl;
        public String iconUrl;
    }

    public static class Other extends Thingie {
        public int buildupUid;
    }

    public static class Buildup extends Thingie {
        public int uid;
        public int kitUid;
        public String kitName;
        public int kitParts;
        public double kitPrice;
        public int genreUid;
        public String genreName;
        public int materialUid;
        public String materialName;
        public int painterUid;
        public String painterName;
        public int producerUid;
        public String producerName;
        public int sculptorUid;
        public String sculptorName;
        public Date updated;
        public String comment;
        public List others;
    }

    public void setBuildupUrls(Thingie buildup) {
        if (buildup.custom) {
            if (buildup.path.startsWith("http:")) {
                buildup.url = buildup.path;
                int index = buildup.path.lastIndexOf(".");
                buildup.imageUrl = buildup.path.substring(0, index) + ".jpg";
                buildup.iconUrl = buildup.path.substring(0, index) + "_icon.gif";
            } else {
                buildup.url = "/" + buildup.ownerPath + "/" + buildup.path + ".html";
                buildup.imageUrl = "/" + buildup.ownerPath + "/" + buildup.path +
                    ".jpg";
                buildup.iconUrl = "/" + buildup.ownerPath + "/" + buildup.path +
                    "_icon.gif";
            }
        } else {
            buildup.imageUrl = "/" + buildup.ownerPath + "/" + buildup.path + ".jpg";
            buildup.iconUrl = "/" + buildup.ownerPath + "/" + buildup.path + "_icon.gif";
        }
    }
%>

<%
    int buildupUid = Integer.parseInt(request.getParameter("buildupUid"));
    Buildup buildup = null;
    Connection connection = null;
    try {
        connection = openGremlinsConnection();
        PreparedStatement select = connection.prepareStatement(
	        "SELECT" +
	        " holder.path," +
	        " buildup.path," +
	        " buildup.custom," +
	        " buildup.kit," +
	        " kit.name," +
	        " kit.parts," +
	        " kit.price," +
	        " genre.uid," +
	        " genre.name," +
	        " material.uid," +
	        " material.name," +
	        " buildup.painter," +
	        " painter.name," +
	        " kit.producer," +
	        " producer.name," +
	        " kit.sculptor," +
	        " sculptor.name," +
	        " buildup.updated," +
	        " buildup.comment," +
	        " buildup.uid" +
	        " FROM" +
	        " buildup, kit, genre, material," +
	        " contact sculptor, contact producer, contact painter, contact holder" +
	        " WHERE" +
	        " buildup.kit=kit.uid AND" +
	        " kit.genre=genre.uid AND" +
	        " kit.material=material.uid AND" +
	        " kit.sculptor=sculptor.uid AND" +
	        " kit.producer=producer.uid AND" +
	        " buildup.owner=holder.uid AND" +
	        " buildup.painter=painter.uid AND" +
	        " buildup.uid=?"
	    );
        select.setInt(1, buildupUid);
        ResultSet resultSet = select.executeQuery();
        resultSet.next();
        buildup = new Buildup();
        buildup.ownerPath = resultSet.getString(1);
        buildup.path = resultSet.getString(2);
        buildup.custom = resultSet.getBoolean(3);
        setBuildupUrls(buildup);
        buildup.kitUid = resultSet.getInt(4);
        buildup.kitName = resultSet.getString(5);
        buildup.kitParts = resultSet.getInt(6);
        buildup.kitPrice = resultSet.getDouble(7);
        buildup.genreUid = resultSet.getInt(8);
        buildup.genreName = resultSet.getString(9);
        buildup.materialUid = resultSet.getInt(10);
        buildup.materialName = resultSet.getString(11);
        buildup.painterUid = resultSet.getInt(12);
        buildup.painterName = resultSet.getString(13);
        buildup.producerUid = resultSet.getInt(14);
        buildup.producerName = resultSet.getString(15);
        buildup.sculptorUid = resultSet.getInt(16);
        buildup.sculptorName = resultSet.getString(17);
        buildup.updated = resultSet.getDate(18);
        buildup.comment = resultSet.getString(19);
        buildup.uid = resultSet.getInt(20);
        select = connection.prepareStatement(
            "SELECT buildup.uid,holder.path,buildup.path,buildup.custom" +
            " FROM buildup, contact holder" +
            " WHERE buildup.owner=holder.uid AND buildup.kit=?"
        );
        select.setInt(1, buildup.kitUid);
        resultSet = select.executeQuery();
        buildup.others = new ArrayList();
        while (resultSet.next()) {
            Other other = new Other();
            other.buildupUid = resultSet.getInt(1);
            other.ownerPath = resultSet.getString(2);
            other.path = resultSet.getString(3);
            other.custom = resultSet.getBoolean(4);
            setBuildupUrls(other);
            buildup.others.add(other);
        }
    } finally {
        if (connection != null) {
            connection.close();
        }
    }

    if (buildup.url != null) {
        response.sendRedirect(buildup.url);
        return;
    }

    String title = buildup.producerName + " - " + buildup.kitName + " - " + buildup.painterName;
    printHeader(out, "gallery", title);
%>
<table width=544><tr><td><center>
<%=buildup.producerName%><br>
<font size=+2><b><%=buildup.kitName%></b></font><br>
by <%=buildup.painterName%>
</center></td></tr></table>

<% printSeparator(out); %>

<table>
<% if (!buildup.painterName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Painter:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Contact?onView=<%=buildup.painterUid%>"><b><%=buildup.painterName%></b></a>&nbsp;</td>
</tr>
<% } %>
<% if (!buildup.kitName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Kit:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Kit?onView=<%=buildup.kitUid%>"><b><%=buildup.kitName%></b></a>&nbsp;</td>
</tr>
<% } %>
<% if (!buildup.producerName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Producer:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Contact?onView=<%=buildup.producerUid%>"><b><%=buildup.producerName%></b></a>&nbsp;</td>
</tr>
<% } %>
<% if (!buildup.materialName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Material:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Material?onView=<%=buildup.materialUid%>"><b><%=buildup.materialName%></b></a>&nbsp;</td>
</tr>
<% } %>
<% if (buildup.kitPrice != 0.0) { %>
<tr>
<td valign="top" align="right">&nbsp;Price:&nbsp;</td>
<td valign="top">&nbsp;<b><%=NumberFormat.getCurrencyInstance().format(buildup.kitPrice)%></b>&nbsp;</td>
</tr>
<% } %>
<% if (buildup.kitParts != 0) { %>
<tr>
<td valign="top" align="right">&nbsp;Parts:&nbsp;</td>
<td valign="top">&nbsp;<b><%=buildup.kitParts%></b>&nbsp;</td>
</tr>
<% } %>
<% if (!buildup.genreName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Genre:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Genre?onView=<%=buildup.genreUid%>"><b><%=buildup.genreName%></b></a>&nbsp;</td>
</tr>
<% } %>
<% if (!buildup.sculptorName.equals("unknown")) { %>
<tr>
<td valign="top" align="right">&nbsp;Sculptor:&nbsp;</td>
<td valign="top">&nbsp;<a href="/servlet/Contact?onView=<%=buildup.sculptorUid%>"><b><%=buildup.sculptorName%></b></a>&nbsp;</td>
</tr>
<% } %>
<tr>
<td valign=top align=right>&nbsp;Updated:&nbsp;</td>
<td valign=top>&nbsp;<b><%=DateFormat.getDateInstance(DateFormat.LONG).format(buildup.updated)%></b>&nbsp;</td>
</tr>
<tr>
<td valign=top align=right>&nbsp;Buildups:&nbsp;</td>
<td valign=top>&nbsp;
<%
    List others = buildup.others;
    int size = others.size();
    for (int i = 0; i < size; ++i) {
        Other other = (Other) others.get(i);
%>
<a href="galleryView.jsp?buildupUid=<%=other.buildupUid%>"><img src="<%=other.iconUrl%>" width="64" height="96"></a>&nbsp;
<%
    }
%>
</td>
</tr>
<%
    int userUid = getUserUid(request);
    if (userUid != -1) {
%>
<tr>
<td colspan="2">
<a href="/servlet/Buildup?onInsertFavorite=true&label=Buildup&choice=<%=buildup.uid%>"><img src="note.gif" border="0" width="64" height="24" align="absmiddle" alt="Add Favorite"></a>
<a href="/servlet/Buildup?onRemoveFavorite=true&label=Buildup&choice=<%=buildup.uid%>"><img src="toss.gif" border="0" width="64" height="24" align="absmiddle" alt="Remove Favorite"></a>
<a href="/servlet/Buildup?onEdit=<%=buildup.uid%>"><img src="edit.gif" border="0" width="64" height="24" align="absmiddle" alt="Edit"></a>
</td>
</tr>
<%
    }
%>
</table>
<%
    if ((buildup.comment != null) && (buildup.comment.length() > 0)) {
%>
<p><i><%=buildup.comment%></i></p>
<%
    }
    printSeparator(out);
%>
<p align="center">
<img src="<%=buildup.imageUrl%>">
</p>
<%
    printFooter(out);
%>
