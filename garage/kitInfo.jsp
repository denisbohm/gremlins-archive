<%@ include file="base.inc" %>

<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="javax.imageio.ImageIO" %>

<%!
    final static String DIR = "/home/denis/web/gremlins.com";

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
            buildup.iconUrl = "/" + buildup.ownerPath + "/" + buildup.path +
                "_icon.gif";
        }
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
    Buildup buildup = null;
    Connection connection = null;
    try {
        connection = openGremlinsConnection();

        ArrayList buildups = (ArrayList) session.getAttribute("buildups");
        if ((buildups == null) || (buildups.size() == 0)) {
            buildups = new ArrayList();
            PreparedStatement select = connection.prepareStatement(
                "SELECT uid FROM buildup"
            );
            ResultSet resultSet = select.executeQuery();
            while (resultSet.next()) {
                int uid = resultSet.getInt(1);
                buildups.add(new Integer(uid));
            }
            session.setAttribute("buildups", buildups);
        }
        int index = (int) Math.floor(Math.random() * buildups.size());
        int buildupUid = ((Integer) buildups.remove(index)).intValue();

        PreparedStatement next = connection.prepareStatement(
            "SELECT uid FROM buildup WHERE uid>? ORDER BY uid ASC LIMIT 1"
        );
        next.setInt(1, buildupUid);
        ResultSet nrs = next.executeQuery();
        if (nrs.next()) {
            buildupUid = nrs.getInt(1);
        } else {
        }
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

    String imageURI = "/" + buildup.ownerPath + "/" + buildup.path + ".jpg";
    File imageFile = new File(DIR + imageURI);
    BufferedImage image = null;
try {
    image = ImageIO.read(imageFile);
} catch (Throwable t) {
    throw new RuntimeException("Can't read image " + imageFile.toString());
}
%>
<%@page contentType="text/xml"%>
<buildup
    buildupUid="<%=buildup.uid%>"
    updated="<%=DateFormat.getDateInstance(DateFormat.LONG).format(buildup.updated)%>"
    imageURI="<%=imageURI%>"
    imageWidth="<%=image.getWidth()%>"
    imageHeight="<%=image.getHeight()%>"
<% if (!buildup.producerName.equals("unknown")) { %>
    producerUid="<%=buildup.producerUid%>"
    producerName="<%=escape(buildup.producerName)%>"
<% } %>    
<% if (!buildup.kitName.equals("unknown")) { %>
    kitUid="<%=buildup.kitUid%>"
    kitName="<%=escape(buildup.kitName)%>"
<% } %>    
<% if (!buildup.painterName.equals("unknown")) { %>
    painterUid="<%=buildup.painterUid%>"
    painterName="<%=escape(buildup.painterName)%>"
<% } %>    
<% if (!buildup.materialName.equals("unknown")) { %>
    materialUid="<%=buildup.materialUid%>"
    materialName="<%=escape(buildup.materialName)%>"
<% } %>    
<% if (buildup.kitPrice != 0.0) { %>
    price="<%=NumberFormat.getCurrencyInstance().format(buildup.kitPrice)%>"
<% } %>    
<% if (buildup.kitParts != 0) { %>
    parts="<%=buildup.kitParts%>"
<% } %>
<% if (!buildup.genreName.equals("unknown")) { %>
    genreUid="<%=buildup.genreUid%>"
    genreName="<%=escape(buildup.genreName)%>"
<% } %>
<% if (!buildup.sculptorName.equals("unknown")) { %>
    sculptorUid="<%=buildup.sculptorUid%>"
    sculptorName="<%=escape(buildup.sculptorName)%>"
<% } %>
>
<% if ((buildup.comment != null) && (buildup.comment.length() > 0)) { %>
    <comment><![CDATA[<%=buildup.comment%>]]></comment>
<% } %>
<%
    List others = buildup.others;
    int size = others.size();
    for (int i = 0; i < size; ++i) {
        Other other = (Other) others.get(i);
%>
    <other buildupUid="<%=other.buildupUid%>" icon="<%=other.ownerPath%>/<%=other.path%>_icon.gif"/>
<% } %>
</buildup>
