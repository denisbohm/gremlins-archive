<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%
    printHeader(out, "Welcome");

    Contact contact = null;
    if (request.getParameter("logon") != null) {
        String name = request.getParameter("name");
        String password = request.getParameter("password");
        try {
            contact = getContact(name, password);
        } catch (UnknownContactNameException e) {
            request.setAttribute(
                "com.gremlins.garage.message",
                "Unknown address."
            );
            %><jsp:forward page="logon.jsp" /><%
        } catch (IncorrectContactPasswordException e) {
            request.setAttribute(
                "com.gremlins.garage.message",
                "Incorrect password."
            );
            %><jsp:forward page="logon.jsp" /><%
        }
        setUserUid(request, response, contact.getUid());
    } else {
        int uid = getUserUid(request);
        if (uid != -1) {
            contact = getContact(uid);
        }
    }
    if (contact == null) {
        request.setAttribute(
            "com.gremlins.garage.message",
            "You must logon before accessing restricted pages."
        );
        %><jsp:forward page="logon.jsp" /><%
    }
%>

<p>Welcome <%=contact.getName()%>.</p>

<p><a href="members.html"><b>New Member Info</b></a></p>
<p><a href="peopleLinks.jsp"><b>How To Add Figure Kit Web Ring Links</b></a></p>

<b>Forms for searching, noting, and adding content:</b>
<ul>
<li><a href="/servlet/Contact"><b>Contacts</b></a>
<li><a href="/servlet/Kit"><b>Kits</b></a>
<li><a href="/servlet/Picture"><b>Pictures</b></a>
<li><a href="gallerySearch.jsp"><b>Buildups</b></a>
<li><a href="/servlet/Bite"><b>Bites</b></a>
<li><a href="/servlet/Review"><b>Reviews</b></a>
<li><a href="/servlet/Show"><b>Shows</b></a>
</ul>

<% printFooter(out); %>