<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>

<%!
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

    final static int MUNGE = 0x2f37492a;

    static int userUidToKey(int uid, int addr) {
        return uid; // seems to have problems - maybe proxy? ^ addr ^ MUNGE;
    }

    static int keyToUserUid(int key, int addr) {
        return key; // seems to have problems - maybe proxy? ^ addr ^ MUNGE;
    }

    static int addressToInt(InetAddress address) {
        byte[] bytes = address.getAddress();
        return
            ((bytes[0] << 24) & 0xff000000) | ((bytes[1] << 16) & 0x00ff0000) |
            ((bytes[2] <<  8) & 0x0000ff00) | ((bytes[3] <<  0) & 0x000000ff);
    }

    static int getAddress(HttpServletRequest request) {
        int addr = 0;
        try {
            InetAddress address = InetAddress.getByName(request.getRemoteAddr());
            addr = addressToInt(address);
        } catch (UnknownHostException e) {
        }
        return addr;
    }

    static public void setCookie(
        HttpServletResponse response, String domain, String name, String value
    ) {
        Cookie cookie = new Cookie(name, value);
        cookie.setPath("/");
        response.addCookie(cookie);
    }

    static Map getCookies(HttpServletRequest request) {
        Map cookies = new HashMap();
        Cookie[] ca = request.getCookies();
        for (int i = 0; i < ca.length; ++i) {
            Cookie c = ca[i];
            cookies.put(c.getName(), c.getValue());
        }
        return cookies;
    }

    static int getUserUid(HttpServletRequest request) {
        int uid = -1;
        try {
            Map cookies = getCookies(request);
            String key = (String) cookies.get("user_key");
            int addr = getAddress(request);
            uid = keyToUserUid(Integer.parseInt(key), addr);
        } catch (Exception e) {
        }
        return uid;
    }

    static void setUserUid(HttpServletRequest request, HttpServletResponse response, int uid) {
        int addr = getAddress(request);
        String key = Integer.toString(userUidToKey(uid, addr));
        String url = "http://" + request.getServerName().toLowerCase();
        setCookie(response, url, "user_key", key);
    }

    public static class Contact {

        protected int uid_;
        protected int owner_;
        protected String name_;
        protected String password_;
        protected String email_;
        protected String url_;
        protected String phone_;
        protected String fax_;
        protected String smail_;
        protected String comment_;
        protected int type_;
        protected boolean ring_;
        protected String path_;

        public int getUid() {
            return uid_;
        }

        public int getOwner() {
            return owner_;
        }

        public void setOwner(int owner) {
            owner_ = owner;
        }

        public String getName() {
            return name_;
        }

        public void setName(String name) {
            name_ = name;
        }

        public String getPassword() {
            return password_;
        }

        public void setPassword(String password) {
            password_ = password;
        }

        public String getEmail() {
            return email_;
        }

        public void setEmail(String email) {
            email_ = email;
        }

        public String getUrl() {
            return url_;
        }

        public void setUrl(String url) {
            url_ = url;
        }

        public String getPhone() {
            return phone_;
        }

        public void setPhone(String phone) {
            phone_ = phone;
        }

        public String getFax() {
            return fax_;
        }

        public void setFax(String fax) {
            fax_ = fax;
        }

        public String getSmail() {
            return smail_;
        }

        public void setSmail(String smail) {
            smail_ = smail;
        }

        public String getComment() {
            return comment_;
        }

        public void setComment(String comment) {
            comment_ = comment;
        }

        public int getType() {
            return type_;
        }

        public void setType(int type) {
            type_ = type;
        }

        public boolean getRing() {
            return ring_;
        }

        public void setRing(boolean ring) {
            ring_ = ring;
        }

        public String getPath() {
            return path_;
        }

        public void setPath(String path) {
            path_ = path;
        }

    }

    public static class UnknownContactNameException extends SQLException {

        protected String name_;

        public UnknownContactNameException(String name) {
            super(name);
            name_ = name;
        }

        public String getAddress() {
            return name_;
        }

    }

    public static class IncorrectContactPasswordException extends SQLException {

        protected String name_;
        protected String password_;

        public IncorrectContactPasswordException(String name, String password) {
            super(name);
            name_ = name;
            password_ = password;
        }

        public String getName() {
            return name_;
        }

        public String getPassword() {
            return password_;
        }

    }

    public static Contact getContact(
        String name, String password
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            Contact contact = selectContact(connection, name);
            if (contact == null) {
                throw new UnknownContactNameException(name);
            }
            if (
                (contact.password_ != null) &&
                (contact.password_.length() > 0) &&
                (!contact.password_.equals(password))
            ) {
                throw new IncorrectContactPasswordException(name, password);
            }
            return contact;
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    public static Contact getContact(
        String name
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            return selectContact(connection, name);
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    public static Contact getContact(
        int uid
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            return selectContact(connection, uid);
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    public static void setContact(
        Contact contact
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openGremlinsConnection();
            updateContact(connection, contact);
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    protected static void fillContact(Contact contact, ResultSet resultSet) throws SQLException {
        contact.uid_ = resultSet.getInt(1);
        contact.owner_ = resultSet.getInt(2);
        contact.name_ = resultSet.getString(3);
        contact.password_ = resultSet.getString(4);
        contact.email_ = resultSet.getString(5);
        contact.url_ = resultSet.getString(6);
        contact.phone_ = resultSet.getString(7);
        contact.fax_ = resultSet.getString(8);
        contact.smail_ = resultSet.getString(9);
        contact.comment_ = resultSet.getString(10);
        contact.type_ = resultSet.getInt(11);
        contact.ring_ = resultSet.getBoolean(12);
        contact.path_ = resultSet.getString(13);
    }

    public static Contact selectContact(
        Connection connection, String name
    ) throws SQLException {
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid,owner,name,password,email,url,phone,fax,smail,comment,type,ring,path" +
            " FROM contact WHERE LCase(name)=?"
        );
        select.setString(1, name.toLowerCase());
        ResultSet resultSet = select.executeQuery();
        if (!resultSet.next()) {
            return null;
        }
        Contact contact = new Contact();
        fillContact(contact, resultSet);
        return contact;
    }

    public static Contact selectContact(
        Connection connection, int uid
    ) throws SQLException {
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid,owner,name,password,email,url,phone,fax,smail,comment,type,ring,path" +
            " FROM contact WHERE uid=?"
        );
        select.setInt(1, uid);
        ResultSet resultSet = select.executeQuery();
        if (!resultSet.next()) {
            return null;
        }
        Contact contact = new Contact();
        fillContact(contact, resultSet);
        return contact;
    }

    public static void insertContact(
        Connection connection, String name, String password, String email, String path,
        String url, String phone, String fax, String smail, String comment, int type, boolean ring
    ) throws SQLException {
	    PreparedStatement insert = connection.prepareStatement(
            "INSERT INTO contact (owner,name,password,email,path,url,phone,fax,smail,comment,type,ring) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
        );
        insert.setInt(1, 201); // owner 201 == Denis Bohm
        insert.setString(2, name);
        insert.setString(3, password);
        insert.setString(4, email);
        insert.setString(5, path);
        insert.setString(6, url);
        insert.setString(7, phone);
        insert.setString(8, fax);
        insert.setString(9, smail);
        insert.setString(10, comment);
        insert.setInt(11, type);
        insert.setBoolean(12, ring);
        insert.executeUpdate();
        PreparedStatement update = connection.prepareStatement(
            "UPDATE contact SET owner=uid WHERE name=?"
        );
        update.setString(1, name);
        update.executeUpdate();
    }

    public static void updateContact(
        Connection connection, Contact contact
    ) throws SQLException {
	    PreparedStatement update = connection.prepareStatement(
		    "UPDATE contact SET name=?,password=?,email=?,url=?,phone=?,fax=?,smail=?,comment=?,type=?,ring=?,path=?,updated=Now() WHERE uid=?"
	    );
	    update.setString(1, contact.name_);
	    update.setString(2, contact.password_);
	    update.setString(3, contact.email_);
	    update.setString(4, contact.url_);
	    update.setString(5, contact.phone_);
	    update.setString(6, contact.fax_);
	    update.setString(7, contact.smail_);
	    update.setString(8, contact.comment_);
	    update.setInt(9, contact.type_);
	    update.setBoolean(10, contact.ring_);
	    update.setString(11, contact.path_);
	    update.setInt(12, contact.uid_);
	    update.executeUpdate();
    }

    public static void sendMail(
        String mailHost, String from, String to, String subject, String text
    ) throws AddressException, MessagingException {
	    Properties properties = (Properties) System.getProperties().clone();
	    properties.put("mail.debug", "true");
	    properties.put("mail.smtp.host", mailHost);
	    Session session = Session.getDefaultInstance(properties, null);

	    Message msg = new MimeMessage(session);
	    msg.setFrom(new InternetAddress(from));
	    InternetAddress[] recipients = InternetAddress.parse(to, false);
if ((recipients == null) || (recipients.length == 0)) {
    throw new RuntimeException("no recipients");
}
	    msg.setRecipients(Message.RecipientType.TO, recipients);
	    msg.setSubject(subject);
	    msg.setText(text);
//	    msg.setSentDate(new Date());

	    Transport.send(msg);
    }

    public static void printHeader(
        JspWriter out, String title
    ) throws IOException {
        printHeader(out, "resources", title);
    }

    public static void printHeaderA(
        JspWriter out, String section, String title
    ) throws IOException {
        out.print("<html>\r\n");
        out.print("<head>\r\n");
        out.print("<title>Gremlins in the Garage! - ");
        out.print(title);
        out.print("</title>\r\n");
        out.print("<link rev=\"made\" href=\"mailto:gremlins@gremlins.com\">\r\n");
    }

    public static void printHeaderB(
        JspWriter out, String section, String title
    ) throws IOException {
        out.print("</head>\r\n");
        out.print("<body bgcolor=\"#ffffff\">\r\n");
    }

    public static void printHeaderC(
        JspWriter out, String section, String title
    ) throws IOException {
        out.print("<table width=\"544\" cellspacing=\"0\" cellpadding=\"0\"><tr><td>\r\n");
        out.print("<h1>\r\n");
        out.print("<a href=\"/index.html\"><img src=\"/garage/");
        out.print(section);
        out.print("_here.gif\" border=\"0\" alt=\"");
        out.print(title);
        out.print(": \" WIDTH=\"544\" HEIGHT=\"41\"></a><br>\r\n");
        out.print("<img border=\"0\" src=\"/garage/navigate.gif\" alt=\"Gremlins in the Garage!\" usemap=\"#navigate\" ismap WIDTH=\"544\" HEIGHT=\"76\"><br>\r\n");
        out.print("<map name=\"navigate\">\r\n");
        out.print("<area coords=\"0,0,75,75\" href=\"/garage/contents.html\">\r\n");
        out.print("<area coords=\"78,0,153,75\" href=\"/servlet/NewStuff\">\r\n");
        out.print("<area coords=\"156,0,231,75\" href=\"/servlet/Bite\">\r\n");
        out.print("<area coords=\"234,0,309,75\" href=\"/garage/garages.html\">\r\n");
        out.print("<area coords=\"312,0,387,75\" href=\"/garage/articles.html\">\r\n");
        out.print("<area coords=\"390,0,465,75\" href=\"/garage/gallerySearch.jsp\">\r\n");
        out.print("<area coords=\"468,0,543,75\" href=\"/garage/resources.html\">\r\n");
        out.print("</map>\r\n");
        out.print("</h1>\r\n");
    }

    public static void printHeader(
        JspWriter out, String section, String title
    ) throws IOException {
        printHeaderA(out, section, title);
        printHeaderB(out, section, title);
        printHeaderC(out, section, title);
    }

    public static void printSeparator(JspWriter out) throws IOException {
        out.print("<p><img src=\"/garage/bones.gif\" alt=\"-----\" WIDTH=\"544\" HEIGHT=\"15\"><p>\r\n");
    }

    public static void printFooter(
        JspWriter out
    ) throws IOException {
        printSeparator(out);
        out.print("The Gremlins in the Garage webzine is a production of\r\n");
        out.print("Firefly Design.  If you have any questions or comments please\r\n");
        out.print("<a href=\"/garage/touch.html\"><b>get in touch</b></a>.\r\n");
        out.print("<p>\r\n");
        out.print("<a href=\"/garage/copyright.html\">Copyright</a> &#169; 1994-2004\r\n");
        out.print("<a href=\"http://www.fireflydesign.com\">Firefly Design</a>.\r\n");
        out.print("</td></tr></table>\r\n");
        out.print("</body>\r\n");
        out.print("</html>\r\n");
    }
%>
