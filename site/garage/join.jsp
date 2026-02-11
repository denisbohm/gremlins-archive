<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
    public String nameToPath(String name) throws Exception {
        StringBuffer buffer = new StringBuffer();
        int length = name.length();
        for (int i = 0; i < length; ++i) {
            char c = name.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                buffer.append(Character.toLowerCase(c));
            } else
            if (Character.isSpace(c)) {
                buffer.append('_');
            }
        }
        String root = buffer.toString();
        String path = root;
        int pass = 1;
        ServletConfig config = getServletConfig();
        ServletContext context = config.getServletContext();
        while ((new java.io.File(context.getRealPath("/" + path))).exists()) {
            path = root + pass;
            if (pass > 10) {
                throw new Exception("Can't find reasonable path for " + name);
            }
        }
        return path;
    }
%>

<%
    String name = request.getParameter("name").trim();
    String password = request.getParameter("password").trim();
    String address = request.getParameter("address").trim();
    String url = request.getParameter("url").trim();
    String phone = request.getParameter("phone").trim();
    String fax = request.getParameter("fax").trim();
    String smail = request.getParameter("smail").trim();
    String comment = request.getParameter("comment").trim();
    int type = Integer.parseInt(request.getParameter("type"));
    boolean ring = request.getParameter("ring").equals("true");

    if (name.length() == 0) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "Full Name Error: Name is missing: Expected 'first last'."
        );
        %><jsp:forward page="register.jsp" /><%
    }

    if (password.length() == 0) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "Password Error: Password is missing: Expected 'your password'."
        );
        %><jsp:forward page="register.jsp" /><%
    }

    if (address.length() == 0) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: Address is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    int index = address.indexOf('@');
    if (index == -1) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: Domain name separator '@' is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == (address.length() - 1)) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: Domain name is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == 0) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: User name is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    index = address.indexOf('.', index);
    if (index == -1) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: Domain name separator '.' is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }
    if (index == (address.length() - 1)) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "E-Mail Address Error: Top level domain name is missing: Expected 'user@domain.xxx'."
        );
        %><jsp:forward page="register.jsp" /><%
    }

    Connection connection = null;
    Contact contact = null;
    try {
        connection = openGremlinsConnection();
        contact = selectContact(connection, name);
        if (contact == null) {
            String path = nameToPath(name);
            insertContact(
                connection, name, password, address, path,
                url, phone, fax, smail, comment, type, ring
            );
        }
    } finally {
        if (connection != null) {
            connection.close();
        }
    }

    if (contact == null) {
        printHeader(out, "Registation");
%>
<p>
You have been successfully registered!
</p>
<p>
Your registration will be reviewed shortly.
After it is reviewed you will be given rights to add content to the gremlins web site.
An e-mail message will be sent to let you know when you are ready to go.
</p>
<p>
While you are waiting you may want to <a href="logon.jsp">Logon</a> and read over the
new member information.
</p>
<%
        printFooter(out);
        out.flush();

        sendMail(
            "fireflydesign.com", "gremlins@gremlins.com", "gremlins@gremlins.com",
            "New Member: " + name, "New Member: " + name
        );
    } else {
        printHeader(out, "Registation Problem");
%>
<p>
Someone is already registered with the name
<a href="/servlet/Contact?onView=<%=contact.getUid()%>"><b><%=name%></b></a> (<%=contact.getEmail()%>).
If you previously registered then proceed to the
<a href="logon.jsp?address=<%=address%>">logon form</a>
if you remember your password, or to the
<a href="help.jsp?address=<%=address%>">help form</a>
if you do not remember your password.
</p>

</p>
If you have not previously registered then you can make your
name unique by adding a middle name and/or nick name.
For example, if your name is <b>Spanky Gonzo</b> then you might
try registering with a nickname, <b>Spanky "Mohawk" Gonzo</b>,
or with your middle name, <b>Spanky John Gonzo</b>.
</p>

<%
        printFooter(out);
    }
%>
