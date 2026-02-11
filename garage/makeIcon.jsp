<%@page contentType="image/svg+xml"%>

<%@ include file="base.inc" %>

<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="javax.imageio.ImageIO" %>

<%!
    final static String DIR = "/home/denis/web/gremlins.com";

    public static class Buildup {
        public int uid;
        public String ownerPath;
        public String path;
        public String url;
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

    static String escape(String s) {
        StringBuffer buffer = new StringBuffer();
        for (int i = 0; i < s.length(); ++i) {
            char c = s.charAt(i);
            switch (c) {
                case '"': buffer.append("&quot;"); break;
                case '&': buffer.append("&amp;"); break;
                case '<': buffer.append("&lt;"); break;
                case '>': buffer.append("&gt;"); break;
                default: buffer.append(c); break;
            }
        }
        return buffer.toString();
    }
%>

<%
    response.setContentType("image/svg+xml");
    Buildup buildup = null;
    Connection connection = null;
    try {
        connection = openGremlinsConnection();
        int buildupUid = Integer.parseInt(request.getParameter("buildupUid"));
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
        boolean custom = resultSet.getBoolean(3);
        if (custom) {
            buildup.url = "/" + buildup.ownerPath + "/" + buildup.path + ".html";
        }
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
    } finally {
        if (connection != null) {
            connection.close();
        }
    }

    String imageURI = "/" + buildup.ownerPath + "/" + buildup.path + ".jpg";
    BufferedImage image = ImageIO.read(new File(DIR + imageURI));
    String iconURI = "/" + buildup.ownerPath + "/" + buildup.path + "_icon.gif";
    BufferedImage icon = null;
    try {
        icon = ImageIO.read(new File(DIR + iconURI));
    } catch (IOException e) {
    }
%>
<svg
    width="100%" height="100%"
    viewBox="0 0 <%=image.getWidth()%> <%=image.getHeight()%>"
    onload="init()"
    xmlns="http://www.w3.org/2000/svg" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
>
<script language="JavaScript" xlink:href="grabber.js"/>
<script language="JavaScript"><![CDATA[
function RegionGrabber() {

    this.inheritFrom = MouseGrabber;
    this.inheritFrom(document.rootElement, document.getElementById("region"));

    this.adjustFeedback = function() {
        var x = this.drag_.getX();
        var y = this.drag_.getY();
        var region = document.getElementById("region");
        region.setAttribute("x", x);
        region.setAttribute("y", y);
    }

}

var regionGrabber;

function init() {
    regionGrabber = new RegionGrabber();
}
]]</script>
    <image x="0" y="0" width="<%=image.getWidth()%>" height="<%=image.getHeight()%>"
        xlink:href="<%=imageURI%>"/>
    <image x="400" y="0" width="64" height="96" xlink:href="<%=iconURI%>"/>

    <rect id="region" x="0" y="0" width="64" height="96" fill="white" opacity="0.25"/>
</svg>
