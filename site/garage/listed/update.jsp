<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>

<%!
    public static String getNewAddress(HttpServletRequest request, Recipient recipient) {
        String newAddress = request.getParameter("newAddress");
        if (newAddress == null) {
            newAddress = recipient.getAddress();
        }
        if (newAddress == null) {
            newAddress = "";
        }
        return newAddress;
    }
    
    public static String getNewPassword(HttpServletRequest request, Recipient recipient) {
        String newPassword = request.getParameter("newPassword");
        if (newPassword == null) {
            newPassword = recipient.getPassword();
        }
        if (newPassword == null) {
            newPassword = "";
        }
        return newPassword;
    }
    
    public static String getNewName(HttpServletRequest request, Recipient recipient) {
        String newName = request.getParameter("newName");
        if (newName == null) {
            newName = recipient.getName();
        }
        if (newName == null) {
            newName = "";
        }
        return newName;
    }
    
    public static void printMemberRows(
        HttpServletRequest request, Recipient recipient, JspWriter out
    ) throws IOException {
        List members = recipient.getMembers();
        int memberCount = members.size();
        for (int i = 0; i < memberCount; ++i) {
            Member member = (Member) members.get(i);
            MailList mailList = member.getMailList();
            out.print("<tr>\r\n");
            out.print("<td align=\"right\">");
            out.print(mailList.getAddress());
            out.print("</td>\r\n");
            out.print("<td>\r\n");
            out.print("<select name=\"mailList");
            out.print(mailList.getUid());
            out.print("\">\r\n");
            Subscription currentSubscription = member.getSubscription();
            if (currentSubscription == null) {
                out.print("<option value=\"0\" selected>unsubscribed*");
            } else {
                out.print("<option value=\"0\">unsubscribed");
            }
            List subscriptions = mailList.getSubscriptions();
            int subscriptionCount = subscriptions.size();
            for (int j = 0; j < subscriptionCount; ++j) {
                Subscription subscription = (Subscription) subscriptions.get(j);
                out.print("<option value=\"");
                out.print(subscription.getUid());
                if (currentSubscription == subscription) {
                    out.print("\" selected>");
                    out.print(subscription.getScheduleName());
                    out.print("*");
                } else {
                    out.print("\">");
                    out.print(subscription.getScheduleName());
                }
            }
            out.print("\r\n");
            out.print("</select>\r\n");
            out.print("</tr>\r\n");
        }
    }
%>

<%
    printHeader(out, "Listed Update");

    Recipient recipient = null;
    String address = getOptional(request, "address");
    String password = getOptional(request, "password");
    try {
        recipient = getRecipient(address, password);
    } catch (UnknownRecipientAddressException e) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Unknown address."
        );
        %><jsp:forward page="logon.jsp" /><%
    } catch (IncorrectRecipientPasswordException e) {
        request.setAttribute(
            "com.fireflydesign.listed.message",
            "Incorrect password."
        );
        %><jsp:forward page="logon.jsp" /><%
    }
    
    if ("update".equals(request.getParameter("method"))) {
        String newAddress = request.getParameter("newAddress").trim();
        int index = newAddress.indexOf('@');
        if (index == -1) {
            out.print("<p>Domain name part is missing.  Address should be of the form <b>yourname@yourdomain</b></p>\r\n");
        } else
        if (index == 0) {
            out.print("<p>User name is missing.  Address should be of the form <b>yourname@yourdomain</b></p>\r\n");
        } else
        if (index == (newAddress.length() - 1)) {
            out.print("<p>Domain name is missing.  Address should be of the form <b>yourname@yourdomain</b></p>\r\n");
        } else {
            recipient.setAddress(newAddress);
            recipient.setPassword(getOptional(request, "newPassword").trim());
            recipient.setName(getOptional(request, "newName").trim());
            
            List members = recipient.getMembers();
            int memberCount = members.size();
            for (int i = 0; i < memberCount; ++i) {
                Member member = (Member) members.get(i);
                MailList mailList = member.getMailList();
                String name = "mailList" + Integer.toString(mailList.getUid());
                String value = request.getParameter(name);
                int newSubscription;
                try {
                    newSubscription = Integer.parseInt(value);
                } catch (NumberFormatException e) {
                    throw new RuntimeException("Expected an integer, but found " + value);
                }
                if (newSubscription == 0) {
                    member.setSubscription(null);
                    continue;
                }
                List subscriptions = mailList.getSubscriptions();
                int subscriptionCount = subscriptions.size();
                for (int j = 0; j < subscriptionCount; ++j) {
                    Subscription subscription = (Subscription) subscriptions.get(j);
                    if (newSubscription == subscription.getUid()) {
                        member.setSubscription(subscription);
                        break;
                    }
                }
            }
            
            setRecipient(recipient);
            out.print("<p>Your information has been updated.</p>\r\n");
        }
    }
%>

<form method="post" action="update.jsp">
<input type="hidden" name="method" value="update">
<input type="hidden" name="address" value="<%=recipient.getAddress()%>">
<input type="hidden" name="password" value="<%=recipient.getPassword()%>">
<table>
<tr>
<td align="right">E-Mail Address</td>
<td><input name="newAddress" size="20" value="<%=getNewAddress(request, recipient)%>"></td>
</tr>
<tr>
<td align="right">Password</td>
<td><input name="newPassword" size="20" value="<%=getNewPassword(request, recipient)%>"></td>
</tr>
<tr>
<td align="right">Full Name</td>
<td><input name="newName" size="20" value="<%=getNewName(request, recipient)%>"></td>
</tr>

<%
    printMemberRows(request, recipient, out);
%>

<tr>
<td align="right" colspan=2><input type="submit" value="OK"></td>
</tr>
</table>
</form>
<%
    printDescriptions(out);
    
    printFooter(out);
%>
