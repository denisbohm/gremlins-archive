<%@ page errorPage="error.jsp" %>
<%@ include file="base.inc" %>
<%@ page import="java.io.*" %>

<%!
    public static void printStringField(
        JspWriter out, String label, HttpServletRequest request, String name, String value
    ) throws IOException {
        out.print("<tr>\r\n");
        out.print("<td align=\"right\">");
        out.print(label);
        out.print("</td>\r\n");
        out.print("<td><input name=\"");
        out.print(name);
        out.print("\" size=\"40\" value=\"");
        String parameter = request.getParameter(name);
        out.print((parameter != null) ? parameter : value);
        out.print("\"></td>\r\n");
        out.print("</tr>\r\n");
    }
    
    public static void printTextField(
        JspWriter out, String label, HttpServletRequest request, String name, String value
    ) throws IOException {
        out.print("<tr>\r\n");
        out.print("<td valign=\"top\" align=\"right\">");
        out.print(label);
        out.print("</td>\r\n");
        out.print("<td><textarea name=\"");
        out.print(name);
        out.print("\" cols=\"40\" rows=\"4\">");
        String parameter = request.getParameter(name);
        out.print((parameter != null) ? parameter : value);
        out.print("</textarea></td>\r\n");
        out.print("</tr>\r\n");
    }
    
    public static void printEnumField(
        JspWriter out, String label, HttpServletRequest request, String name, int value, String[] options
    ) throws IOException {
        out.print("<tr>\r\n");
        out.print("<td valign=\"top\" align=\"right\">");
        out.print(label);
        out.print("</td>\r\n");
        out.print("<td><select name=\"");
        out.print(name);
        out.print("\">");
        int selected = value;
        String parameter = request.getParameter(name);
        if (parameter != null) {
            try {
                selected = Integer.parseInt(parameter);
            } catch (NumberFormatException e) {
                throw new RuntimeException("Bad enum parameter value " + parameter);
            }
        }
        for (int i = 0; i < options.length; ++i) {
            out.print("<option value=\"");
            out.print(i);
            if (i == selected) {
                out.print("\" selected>");
            } else {
                out.print("\">");
            }
            out.print(options[i]);
        }
        out.print("</select></td>\r\n");
        out.print("</tr>\r\n");
    }
    
    public static void printBooleanField(
        JspWriter out, String label, HttpServletRequest request, String name, boolean value
    ) throws IOException {
        out.print("<tr>\r\n");
        out.print("<td valign=\"top\" align=\"right\">");
        out.print(label);
        out.print("</td>\r\n");
        out.print("<td><select name=\"");
        out.print(name);
        out.print("\">");
        String parameter = request.getParameter(name);
        if ((parameter != null) ? parameter.equals("true") : value) {
            out.print("<option value=\"true\" selected>Yes<option value=\"false\">No");
        } else {
            out.print("<option value=\"true\">Yes<option value=\"false\" selected>No");
        }
        out.print("</select></td>\r\n");
        out.print("</tr>\r\n");
    }
    
    public static class InvalidParameterException extends Exception {
        
        public InvalidParameterException(String detail) {
            super(detail);
        }
        
    }
%>

<%
    printHeader(out, "Contact Update");

    Contact contact = null;
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
    
    if (request.getParameter("method").equals("update")) {
        try {
            String newName = request.getParameter("newName").trim();
            String newPassword = request.getParameter("newPassword").trim();
            String newUrl = request.getParameter("newUrl").trim();
            String newPhone = request.getParameter("newPhone").trim();
            String newFax = request.getParameter("newFax").trim();
            String newSmail = request.getParameter("newSmail").trim();
            String newComment = request.getParameter("newComment").trim();
            int newType = Integer.parseInt(request.getParameter("newType"));
            boolean newRing = request.getParameter("newRing").equals("true");
    //        String newPath = request.getParameter("newPath").trim();
            
            if (!newName.equalsIgnoreCase(contact.getName())) {
                if (getContact(newName) != null) {
                    throw new InvalidParameterException("Contact name in use.");
                }
            }
            if (newPassword.length() == 0) {
                throw new InvalidParameterException("You must have a password.");
            }
            if (newUrl.length() > 0) {
                if (!newUrl.startsWith("http://")) {
                    throw new InvalidParameterException("URL is invalid, it must start with http://");
                }
            }
                    
            contact.setName(newName);
            contact.setPassword(newPassword);
            contact.setUrl(newUrl);
            contact.setPhone(newPhone);
            contact.setFax(newFax);
            contact.setSmail(newSmail);
            contact.setUrl(newUrl);
            contact.setType(newType);
            contact.setRing(newRing);
    //        contact.setPath(newPath);
            setContact(contact);
            
            out.print("<p>Your information has been updated.</p>\r\n");
        } catch (InvalidParameterException e) {
            out.print("<font color=\"red\"><p>Your information has not been updated because: ");
            out.print(e.toString());
            out.print("</p></font>");
        }
    }
%>

<form method="post" action="update.jsp">
<input type="hidden" name="method" value="update">
<input type="hidden" name="name" value="<%=contact.getName()%>">
<input type="hidden" name="password" value="<%=contact.getPassword()%>">
<table>
<%
    printStringField(out, "Full Name", request, "newName", contact.getName());
    printStringField(out, "Password", request, "newPassword", contact.getPassword());
    printStringField(out, "E-Mail", request, "newEmail", contact.getEmail());
    printStringField(out, "URL", request, "newUrl", contact.getUrl());
    printStringField(out, "Phone", request, "newPhone", contact.getPhone());
    printStringField(out, "Fax", request, "newFax", contact.getFax());
    printTextField(out, "Mail", request, "newSmail", contact.getSmail());
    printTextField(out, "Comment", request, "newComment", contact.getComment());
    printEnumField(out, "Type", request, "newType", contact.getType(), new String[] {"Company", "Individual"});
    printBooleanField(out, "Ring", request, "newRing", contact.getRing());
//    printStringField(out, "Path", request, "newPath", contact.getPath());
%>
<tr>
<td align="right" colspan=2><input type="submit" value="OK"></td>
</tr>
</table>
</form>

<% printFooter(out); %>
