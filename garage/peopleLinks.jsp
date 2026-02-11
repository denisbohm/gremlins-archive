<%@ include file="base.inc" %>

<% printHeader(out, "resources", "People"); %>

<%
    String name;
    int uid = getUserUid(request);
    if (uid == -1) {
        name = "Denis%20Bohm";
%>
<p><b>
In the following samples replace the string "Denis%20Bohm" with your name as it appears when you search for it
on the <a href="/servlet/Contact.jsp"><b>Contact</b></a> page.  Note that in the HTML you must use "%20"
instead of a space.
</b></p>
<%
    } else {
        Contact contact = getContact(uid);
        String s = contact.getName();
        StringBuffer buffer = new StringBuffer();
        for (int i = 0; i < s.length(); ++i) {
            char c = s.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                buffer.append(c);
            } else {
                buffer.append('%');
                buffer.append(Integer.toString((c >> 4) & 0xf, 16));
                buffer.append(Integer.toString((c >> 0) & 0xf, 16));
            }
        }
        name = buffer.toString();
    }
%>

<h2>Links</h2>
To add the graphical figure kit web ring links<br>
<img src="http://www.gremlins.com/garage/people.jpg" width="166" height="130" alt="Travel the Figure Kit Web Ring!" ismap usemap="#people">
<map name="people">
<area coords="28,28,132,72"   href="http://www.gremlins.com/garage/people.jsp?SearchByWeb">
<area coords="110,54,166,130" href="http://www.gremlins.com/garage/people.jsp?SearchByWebNext=<%=name%>">
<area coords="0,54,56,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebPrev=<%=name%>">
<area coords="38,0,122,28"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebRand">
<area coords="0,0,166,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWeb">
</map>
<br>to your web site you can use the following HTML:
<pre>
&lt;img src="http://www.gremlins.com/garage/people.jpg" width="166" height="130" alt="Travel the Figure Kit Web Ring!" ismap usemap="#people"&gt;
&lt;map name="people"&gt;
&lt;area coords="28,28,132,72"   href="http://www.gremlins.com/garage/people.jsp?SearchByWeb"&gt;
&lt;area coords="110,54,166,130" href="http://www.gremlins.com/garage/people.jsp?SearchByWebNext=<%=name%>"&gt;
&lt;area coords="0,54,56,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebPrev=<%=name%>"&gt;
&lt;area coords="38,0,122,28"    href="http://www.gremlins.com/garage/people.jsp?SearchByWebRand"&gt;
&lt;area coords="0,0,166,130"    href="http://www.gremlins.com/garage/people.jsp?SearchByWeb"&gt;
&lt;/map&gt;
</pre>
</p>
<p>
You can also create textual links by using the following HTML:<br>
<pre>
&lt;a href="http://www.gremlins.com/garage/people.jsp?SearchByWebNext=<%=name%>"&gt;Next&lt;/a&gt;
&lt;a href="http://www.gremlins.com/garage/people.jsp?SearchByWebPrev=<%=name%>"&gt;Back&lt;/a&gt;
&lt;a href="http://www.gremlins.com/garage/people.jsp?SearchByWebRand"&gt;Random&lt;/a&gt;
</pre>
</p>
<p>
<b>Please</b> place the web ring links on the same web page that appears in your entry on
the people page.  It's easy for visitors to get lost if they have to try and dig through your
site to find the links to navigate the ring.
And don't forget to test out the links on your page after you have added them to your page.
</p>
<p>
Thanks!
</p>

<% printFooter(out); %>