<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>

<%@ include file="custom.inc" %>

<%!
    public static String getOptional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
    
    public static void printDescriptions(JspWriter out) throws SQLException, IOException {
        out.print("<p><font size=\"+1\"><b>Mail List Descriptions</b></font></p>\r\n");
        List mailLists = getMailLists();
        int mailListCount = mailLists.size();
        for (int i = 0; i < mailListCount; ++i) {
            MailList mailList = (MailList) mailLists.get(i);
            out.print("<p><b>");
            out.print(mailList.getName());
            out.print("</b><br>\r\n");
            out.print(mailList.getDescription());
            out.print("\r\n");
            if (mailList.getPosting() != MailListPostingModeratorsOnly) {
                out.print("Send e-mail to <a href=\"mailto:");
                out.print(mailList.getAddress());
                out.print("\"><b>");
                out.print(mailList.getAddress());
                out.print("</b></a> to reach the members of this mailing list.\r\n");
            } else {
                out.print("This is a moderated mailing list.  You will receive mail list e-mail from <b>");
                out.print(mailList.getAddress());
                out.print("</b>\r\n");
            }
            out.print("</p>\r\n");
        }
    }
    
    public final static int MailListPostingAnyone = 0;
    public final static int MailListPostingMembersOnly = 1;
    public final static int MailListPostingModeratorsOnly = 2;
    
    public static class Recipient {
        
        protected int uid_;
        protected String address_;
        protected int domainUid_;
        protected String password_;
        protected String name_;
        
        protected List members_;
        
        public int getUid() {
            return uid_;
        }
        
        public String getAddress() {
            return address_;
        }
        
        public void setAddress(String address) {
            address_ = address;
        }
        
        public String getPassword() {
            return password_;
        }
        
        public void setPassword(String password) {
            password_ = password;
        }
        
        public String getName() {
            return name_;
        }
        
        public void setName(String name) {
            name_ = name;
        }
        
        public List getMembers() {
            return members_;
        }
        
    }
    
    public static class Member {
        
        protected int uid_;
        protected int recipientUid_;
        protected int domainUid_;
        protected int subscriptionUid_;
        protected boolean moderator_;

        protected MailList mailList_;
        protected Subscription subscription_;
        
        public int getUid() {
            return uid_;
        }
        
        public MailList getMailList() {
            return mailList_;
        }
        
        public Subscription getSubscription() {
            return subscription_;
        }
        
        public void setSubscription(Subscription subscription) {
            subscription_ = subscription;
            subscriptionUid_ = (subscription == null) ? 0 : subscription.uid_;
        }
        
        public boolean isModerator() {
            return moderator_;
        }
        
    }
    
    public static class MailList {
        
        protected int uid_;
        protected String name_;
        protected String address_;
        protected String description_;
        protected boolean open_;
        protected int posting_;
        
        protected List subscriptions_;
        
        public int getUid() {
            return uid_;
        }
        
        public String getName() {
            return name_;
        }
        
        public String getAddress() {
            return address_;
        }
        
        public String getDescription() {
            return description_;
        }
        
        public boolean isOpen() {
            return open_;
        }
        
        public int getPosting() {
            return posting_;
        }
        
        public List getSubscriptions() {
            return subscriptions_;
        }
        
    }
    
    public static class Subscription {
        
        protected int uid_;
        protected int mailListUid_;
        protected int scheduleUid_;
        protected String scheduleName_;
        
        public int getUid() {
            return uid_;
        }
        
        public String getScheduleName() {
            return scheduleName_;
        }
        
    }
    
    public static class UnknownRecipientAddressException extends SQLException {
        
        protected String address_;
        
        public UnknownRecipientAddressException(String address) {
            super(address);
            address_ = address;
        }
        
        public String getAddress() {
            return address_;
        }
        
    }
    
    public static class IncorrectRecipientPasswordException extends SQLException {
        
        protected String address_;
        protected String password_;
        
        public IncorrectRecipientPasswordException(String address, String password) {
            super(address);
            address_ = address;
            password_ = password;
        }
        
        public String getAddress() {
            return address_;
        }
        
        public String getPassword() {
            return password_;
        }
        
    }
    
    public static Recipient getRecipient(
        String address, String password
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openListedConnection();
            Recipient recipient = selectRecipient(connection, address);
            if (recipient == null) {
                throw new UnknownRecipientAddressException(address);
            }
            if (
                (recipient.password_ != null) &&
                (recipient.password_.length() > 0) &&
                (!recipient.password_.equals(password))
            ) {
                throw new IncorrectRecipientPasswordException(address, password);
            }
            
            String[] mailListNames = getMailListNames();
            int mailListCount = mailListNames.length;
            List members = new ArrayList(mailListCount);
            recipient.members_ = members;
            for (int i = 0; i < mailListCount; ++i) {
                String mailListName = mailListNames[i];
                MailList mailList = selectMailList(connection, mailListName);
                if (mailList == null) {
                    continue;
                }
                List subscriptions = selectSubscriptions(connection, mailList.uid_);
                mailList.subscriptions_ = subscriptions;
                Member member = selectMember(connection, mailList.uid_, recipient.uid_);
                if (member == null) {
                    member = new Member();
                    member.recipientUid_ = recipient.uid_;
                    member.domainUid_ = recipient.domainUid_;
                } else {
                    int subscriptionCount = subscriptions.size();
                    for (int j = 0; j < subscriptionCount; ++j) {
                        Subscription subscription = (Subscription) subscriptions.get(j);
                        if (subscription.uid_ == member.subscriptionUid_) {
                            member.subscription_ = subscription;
                            break;
                        }
                    }
                }
                member.mailList_ = mailList;
                members.add(member);
            }
            return recipient;
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    public static void setRecipient(
        Recipient recipient
    ) throws SQLException {
        Connection connection = null;
        try {
            connection = openListedConnection();
            updateRecipient(connection, recipient);
            List members = recipient.getMembers();
            int memberCount = members.size();
            for (int i = 0; i < memberCount; ++i) {
                Member member = (Member) members.get(i);
                deleteMember(connection, member.getUid());
                Subscription subscription = member.getSubscription();
                if (subscription != null) {
                    insertMember(connection, recipient.getUid(), recipient.domainUid_, subscription.getUid(), false);
                }
            }
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    public static void mail(
        String mailHost, String from, String to, String subject, String text
    ) throws AddressException, MessagingException {
	    Properties properties = (Properties) System.getProperties().clone();
	    properties.put("mail.smtp.host", mailHost);
	    Session session = Session.getDefaultInstance(properties, null);
	        
	    Message msg = new MimeMessage(session);
	    msg.setFrom(new InternetAddress(from));
	    msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
	    msg.setSubject(subject);
	    msg.setText(text);
	    msg.setSentDate(new Date());

	    Transport.send(msg);
    }

    public static int indexOf(byte[] buffer, int length, char match, int index) {
        while (index < length) {
            if (buffer[index] == match) {
                return index;
            }
            ++index;
        }
        return -1;
    }

    public static List getMailLists() throws SQLException {
        List mailLists = new ArrayList();
        Connection connection = null;
        try {
	        connection = openListedConnection();
	        String[] mailListNames = getMailListNames();
	        int mailListCount = mailListNames.length;
	        for (int i = 0; i < mailListCount; ++i) {
	            String mailListName = mailListNames[i];
                MailList mailList = selectMailList(connection, mailListName);
                if (mailList == null) {
                    continue;
                }
                mailLists.add(mailList);
            }
        } finally {
            if (connection != null) {
	            connection.close();
	        }
	    }
	    return mailLists;
    }
    
    public static void viewMail(
        JspWriter out, int mailUid
    ) throws SQLException, IOException {
        Connection connection = null;
        try {
	        connection = openListedConnection();
	        PreparedStatement select = connection.prepareStatement(
	            "SELECT message FROM mail WHERE uid=?"
	        );
	        select.setInt(1, mailUid);
	        ResultSet resultSet = select.executeQuery();
	        resultSet.next();
	        int messageUid = resultSet.getInt(1);
	        select = connection.prepareStatement(
	            "SELECT compression,content FROM message WHERE uid=?"
	        );
	        select.setInt(1, messageUid);
	        resultSet = select.executeQuery();
	        resultSet.next();
	        boolean compression = resultSet.getBoolean(1);
	        if (compression) {
		        out.print("Mail was stored in compressed form.  A software update is required to uncompress.");
		        return;
	        }
    	    InputStream data = resultSet.getAsciiStream(2);

	        out.print("<pre>\r\n");

	        // Process header.
	        boolean show = false;
	        boolean header = true;
	        String last = "";
	        byte[] chunk = new byte[512];
	        int n;
	        while (header && ((n = data.read(chunk)) > 0)) {
		        int a = 0;
		        int index;
		        while ((index = indexOf(chunk, n, '\n', a)) != -1) {
			        int skip = 1;
			        if ((index > 0) && (chunk[index - 1] == '\r')) {
				        --index;
				        ++skip;
			        }
			        String line = last + new String(chunk, a, index - a);
			        a = index + skip;
			        last = "";
			        if (line.length() == 0) {
				        header = false;
				        break;
			        }
			        char c = line.charAt(0);
			        // if not continuation of last header line
			        if ((c != ' ') && (c != '\t')) {
				        show = false;
				        int i = line.indexOf(':');
				        if (i != -1) {
					        String key = line.substring(0, i);
					        if (key.equals("From") || key.equals("Subject") || key.equals("Date")) {
						        show = true;
					        }
				        }
			        }
			        if (show) {
				        out.print(line + "\r\n");
			        }
		        }
		        last = last + new String(chunk, a, n - a);
	        }

	        // Process body.
	        out.print("\r\n");
	        out.print(last);
	        while ((n = data.read(chunk)) > 0) {
		        out.print(new String(chunk, 0, n));
	        }

	        out.print("</pre>\r\n");
        } finally {
            if (connection != null) {
	            connection.close();
	        }
	    }
    }

    public static String getDomain(String address) {
        int index = address.indexOf('@');
        return address.substring(index + 1);
    }
    
    public static int ensureDomain(Connection connection, String host) throws SQLException {
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid FROM domain WHERE host=?"
        );
        select.setString(1, host);
        ResultSet result = select.executeQuery();
        if (! result.next()) {
	        PreparedStatement insert = connection.prepareStatement(
	            "INSERT INTO domain (host) VALUES (?)"
	        );
	        insert.setString(1, host);
	        insert.executeUpdate();

	        result = select.executeQuery();
	        result.next();
	    }
	    return result.getInt(1);
    }

    public static Recipient selectRecipient(
        Connection connection, String address
    ) throws SQLException {
	    PreparedStatement select = connection.prepareStatement(
	        "SELECT uid,domain,password,name FROM recipient WHERE LCase(user)=?"
	    );
	    select.setString(1, address.toLowerCase());
	    ResultSet result = select.executeQuery();
	    if (!result.next()) {
	        return null;
	    }
	    Recipient recipient = new Recipient();
	    recipient.uid_ = result.getInt(1);
	    recipient.address_ = address;
	    recipient.domainUid_ = result.getInt(2);
	    recipient.password_ = result.getString(3);
	    recipient.name_ = result.getString(4);
	    return recipient;
    }
    
    public static void insertRecipient(
        Connection connection, String address, String password, String name
    ) throws SQLException {
	    PreparedStatement insert = connection.prepareStatement(
            "INSERT INTO recipient (user,domain,password,name) VALUES (?,?,?,?)"
        );
        insert.setString(1, address);
        insert.setInt(2, ensureDomain(connection, getDomain(address)));
        insert.setString(3, password);
        insert.setString(4, name);
        insert.executeUpdate();
    }

    public static void updateRecipient(
        Connection connection, Recipient recipient
    ) throws SQLException {
        recipient.domainUid_ = ensureDomain(connection, getDomain(recipient.address_));
	    PreparedStatement update = connection.prepareStatement(
		    "UPDATE recipient SET user=?,domain=?,password=?,name=?,updated=Now() WHERE uid=?"
	    );
	    update.setString(1, recipient.address_);
	    update.setInt(2, recipient.domainUid_);
	    update.setString(3, recipient.password_);
	    update.setString(4, recipient.name_);
	    update.setInt(5, recipient.uid_);
	    update.executeUpdate();
	    
		PreparedStatement update2 = connection.prepareStatement(
			"UPDATE member SET domain=? WHERE recipient=?"
		);
		update2.setInt(1, recipient.domainUid_);
		update2.setInt(2, recipient.uid_);
	    update2.executeUpdate();
    }

    public static MailList selectMailList(
        Connection connection, String name
    ) throws SQLException {
        PreparedStatement select = connection.prepareStatement(
            "SELECT uid,name,address,description,open_subscription,posting FROM mail_list WHERE name=?"
        );
        select.setString(1, name);
        ResultSet result = select.executeQuery();
        if (!result.next()) {
            return null;
        }
        MailList mailList = new MailList();
        mailList.uid_ = result.getInt(1);
        mailList.name_ = result.getString(2);
        mailList.address_ = result.getString(3);
        mailList.description_ = result.getString(4);
        mailList.open_ = result.getBoolean(5);
        mailList.posting_ = result.getInt(6);
        return mailList;
    }
    
    public static List selectSubscriptions(
        Connection connection, int mailListUid
    ) throws SQLException {
        PreparedStatement select = connection.prepareStatement(
	        "SELECT subscription.uid, schedule.uid, schedule.name" +
	        " FROM subscription,schedule WHERE subscription.mail_list=? AND subscription.schedule=schedule.uid"
	    );
	    select.setInt(1, mailListUid);
	    ResultSet result = select.executeQuery();
	    List subscriptions = new ArrayList();
	    while (result.next()) {
	        Subscription subscription = new Subscription();
	        subscription.uid_ = result.getInt(1);
	        subscription.mailListUid_ = mailListUid;
	        subscription.scheduleUid_ = result.getInt(2);
	        subscription.scheduleName_ = result.getString(3);
	        subscriptions.add(subscription);
	    }
	    return subscriptions;
    }
    
    public static Member selectMember(
        Connection connection, int mailListUid, int recipientUid
    ) throws SQLException {
	    PreparedStatement select = connection.prepareStatement(
		    "SELECT member.uid, member.domain, member.subscription, member.moderator" +
		    " FROM member, subscription WHERE member.subscription=subscription.uid AND" +
		    " subscription.mail_list=? AND member.recipient=?"
	    );
	    select.setInt(1, mailListUid);
	    select.setInt(2, recipientUid);
	    ResultSet result = select.executeQuery();
	    if (!result.next()) {
	        return null;
	    }
	    Member member = new Member();
	    member.uid_ = result.getInt(1);
	    member.recipientUid_ = recipientUid;
	    member.domainUid_ = result.getInt(2);
	    member.subscriptionUid_ = result.getInt(3);
	    member.moderator_ = result.getBoolean(4);
	    return member;
	}

    public static void insertMember(
        Connection connection, int recipientUid, int domainUid, int subscriptionUid, boolean moderator
    ) throws SQLException {
		PreparedStatement insert = connection.prepareStatement(
			"INSERT INTO member (recipient,domain,subscription,subscriber,moderator,blackballed,updated) VALUES (?,?,?,?,?,?,?)"
		);
		insert.setInt(1, recipientUid);
		insert.setInt(2, domainUid);
		insert.setInt(3, subscriptionUid);
		insert.setInt(4, 1);
		insert.setInt(5, moderator ? 1 : 0);
		insert.setInt(6, 0);
		insert.setTimestamp(7, new java.sql.Timestamp(new java.util.Date().getTime()));
		insert.executeUpdate();
	}
	
    public static void deleteMember(
        Connection connection, int memberUid
    ) throws SQLException {
	    PreparedStatement delete = connection.prepareStatement(
	        "DELETE FROM member WHERE uid=?"
	    );
	    delete.setInt(1, memberUid);
		delete.executeUpdate();
    }
%>
