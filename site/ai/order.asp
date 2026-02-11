<%@ LANGUAGE = JScript %>
<!--#include file="../base.inc"-->
<!--#include file="../kits.inc"-->
<% writeHeader("Alternative Images Order Form", "Garages"); %>

<p>
<font size=+1><b>Alternative Images Order Form</b></font>
</p>

<%

function writeKitName(rs) {
	var query =
		"SELECT buildup.uid" +
		" FROM buildup, contact as owner" +
		" WHERE" +
		" buildup.kit=" + rs("uid") + " AND" +
		" buildup.owner=" + ai_uid + " AND" +
		" owner.uid=" + ai_uid;
    var kit_rs = conn.Execute(query);
    if (! kit_rs.EOF) {
        var uid = variantToString(kit_rs("uid"));
        Response.Write("<a href=\"" + www_gremlins_com + "servlet/Buildup?onView=" + uid + "\">");
        Response.Write(rs("name"));
        Response.Write("</a>");
    } else {
        Response.Write(rs("name"));
    }
}

function getKitQuantity(rs) {
    var qty = Request("qty" + variantToString(rs("uid")));
    if (qty.Count() > 0) {
        return qty.Item(1);
    }
    return 0;
}

function writeSelect(name, value, options) {
    Response.Write("<select name=\"" + name + "\">");
    for (var i = 0; i < options.length; ++i) {
        var option = options[i];
        if (value == i) {
            Response.Write("<option value=" + i + " selected>");
        } else {
            Response.Write("<option value=" + i + ">");
        }
        Response.Write(option);
    }
    Response.Write("</select>");
}

var qtys = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
var payments = new Array("Check", "Money Order", "Mastercard", "Visa");
var locations = new Array("USA - Not NYS Resident ($6 S&H)", "NYS Resident ($6 S&H, 8% Sales Tax)", "International (35% S&H)");

function writeKit(rs, location, last) {
    var count = getKitQuantity(rs);
    var price = variantToDouble(rs("price"));
    var sandh = location == 2 ? (price * 0.35) : variantToDouble(rs("shipping"));
    var total = count * (price + sandh);
    Response.Write("<tr>\n");
    Response.Write("<td>&nbsp;"); writeKitName(rs); Response.Write("&nbsp;</td>\n");
    Response.Write("<td align=right>&nbsp;");
    if (last) {
        Response.Write("<input type=hidden name=qty" + rs("uid") + " value=" + count + ">" + count);
    } else {
        writeSelect("qty" + rs("uid"), count, qtys);
    }
    Response.Write("&nbsp;</td>\n");
    Response.Write("<td align=right>&nbsp;" + prettyPrice(variantToString(price)) + "&nbsp;</td>\n");
    Response.Write("<td align=right>&nbsp;" + prettyPrice(variantToString(sandh)) + "&nbsp;</td>\n");
    if (total > 0) {
        Response.Write("<td align=right>&nbsp;" + prettyPrice(variantToString(total)) + "&nbsp;</td>\n");
    } else {
        Response.Write("<td align=right>&nbsp;&nbsp;</td>\n");
    }
    Response.Write("</tr>\n");
    return total;
}

var conn = openConnection();
var rs = conn.Execute("SELECT uid FROM contact WHERE name='Alternative Images Productions'");
var ai_uid = rs("uid").Value;

var query_head =
	"SELECT kit.uid, kit.updated, kit.name, scale.name as scale, material.name as material," +
	" parts, genre.name as genre, price, shipping, released, discontinued, references," +
	" kit.comment as comment, producer.name as producer, sculptor.name as sculptor" +
	" FROM kit, scale, material, genre, contact producer, contact sculptor" +
	" WHERE";
var query_tail =
	" kit.genre = genre.uid AND" +
	" kit.material = material.uid AND" +
	" kit.scale = scale.uid AND" +
	" kit.producer = producer.uid AND" +
	" kit.sculptor = sculptor.uid" +
	" ORDER BY kit.name, producer.name, sculptor.name, kit.scale, kit.material";

var query_custom =
    " kit.available = true AND" +
    " kit.producer = " + ai_uid + " AND";
var query = query_head + query_custom + query_tail;
rs = conn.Execute(query);

Response.Write("<form action=\"order.asp\" method=\"post\">\n");

var last = Request("last").Count() > 0;

var payment = 0;
var payment_value = Request("payment");
if (payment_value.Count() > 0) {
    payment = variantToInteger(payment_value.Item(1));
}

var location = 0;
var location_value = Request("location");
if (location_value.Count() > 0) {
    location = variantToInteger(location_value.Item(1));
}

%>
<p>
<font size=+1><b>1) Location</b></font>
</p>

<%
if (! last) {
%>
<p>
Please enter your location so that the correct taxes as well as shipping and handling
charges can be calculated.  Use the &quot;Recalculate S&amp;H Charges&quot; button to
update the shipping and handling amounts in the kit selection table found in the next
section.
</p>
<%
}
%>

<p>
<%
if (last) {
    Response.Write("<input type=hidden name=\"location\" value=" + location + ">" + locations[location] + "\n");
} else {
    writeSelect("location", location, locations);
    Response.Write("<input name=\"change\" value=\"Recalculate S&H Charges\" type=submit>\n");
}
%>
</p>

<p>
<font size=+1><b>2) Kit Selection</b></font>
</p>

<%
if (! last) {
%>
<p>
Please enter the quantity of each kit that you would like to purchase then use
the &quot;Recalculate&quot; button to update the totals.
</p>
<%
}
%>

<p>
<table width=544 border=1 bgcolor="#ffeeee">

<tr bgcolor="#eeeeff">
<td><b>&nbsp;Item Name&nbsp;</b></td>
<td align=right><b>&nbsp;Qty&nbsp;</b></td>
<td align=right><b>&nbsp;Price&nbsp;</b></td>
<td align=right><b>&nbsp;S&amp;H&nbsp;</b></td>
<td align=right><b>&nbsp;Total&nbsp;</b></td>
</tr>

<%
var merchandise_total = 0;
while (! rs.EOF) {
    if (variantToString(rs("discontinued")) == "") {
        if ((! last) || (getKitQuantity(rs) > 0)) {
    	    merchandise_total += writeKit(rs, location, last);
	    }
	}
	rs.MoveNext();
}

conn.Close();

var tax_total = 0;
if (location == 1) {
    tax_total = merchandise_total * 0.08;
}

var final_total = merchandise_total + tax_total;

Response.Write("<tr bgcolor=\"#eeeeff\">\n");
Response.Write("<td colspan=4 align=right>&nbsp;Merchandise Total&nbsp;</td>\n");
Response.Write("<td align=right>&nbsp;" + prettyPrice(variantToString(merchandise_total)) + "&nbsp;</td>\n");
Response.Write("</tr>\n");

if (location == 1) {
    Response.Write("<tr bgcolor=\"#eeeeff\">\n");
    Response.Write("<td colspan=4 align=right>&nbsp;NYS Resident Sales Tax&nbsp;</td>\n");
    Response.Write("<td align=right>&nbsp;" + prettyPrice(variantToString(tax_total)) + "&nbsp;</td>\n");
    Response.Write("</tr>\n");
}

Response.Write("<tr bgcolor=\"#eeeeff\">\n");
if (last) {
    Response.Write("<td colspan=4 align=right><b>&nbsp;");
    Response.Write("&nbsp;Final Total&nbsp;</b></td>\n");
} else {
    Response.Write("<td colspan=4 align=right><b>&nbsp;");
    Response.Write("&nbsp;<input name=\"change\" value=\"Recalculate\" type=submit> Total&nbsp;</b></td>\n");
}
Response.Write("<td align=right><b>&nbsp;" + prettyPrice(variantToString(final_total)) + "&nbsp;</b></td>\n");
Response.Write("</tr>\n");

Response.Write("</table>\n");
Response.Write("</p>\n");

%>
<p>
<font size=+1><b>3) Personal Information</b></font>
</p>

<%
if (! last) {
%>
<p>
Please provide your contact information and the payment method you would like
to use.
</p>
<%
}
%>

<p>
<table bgcolor="#ffeeee" width=544><tr><td>
<pre>
<%
if (last) {
%>
           Name: <input type=hidden name="name" value="<%= Request("name") %>"><%= Request("name") %>
        Address: <input type=hidden name="address" value="<%= Request("address") %>"><%= Request("address") %>
           City: <input type=hidden name="city" value="<%= Request("city") %>"><%= Request("city") %>
      State/Zip: <input type=hidden name="statezip" value="<%= Request("statezip") %>"><%= Request("statezip") %>
        Payment: <input type=hidden name="payment" value="<%= Request("payment") %>"><%= payments[payment] %>
<%
    if ((payment == 2) || (payment == 3)) { // Mastercard or Visa
        Response.Write("\n");
        Response.Write("    Card&nbsp;Number: __________________________\n");
        Response.Write("Expiration&nbsp;Date: __________________________\n");
        Response.Write("                 (please fill in card information after printing)\n");
    }
} else {
%>
           Name: <input name="name" size=40 value="<%= Request("name") %>">
        Address: <input name="address" size=40 value="<%= Request("address") %>">
           City: <input name="city" size=40 value="<%= Request("city") %>">
      State/Zip: <input name="statezip" size=40 value="<%= Request("statezip") %>">
        Payment: <% writeSelect("payment", payment, payments); %>
<%
}
%>
</pre>
</td></tr></table>
</p>

<%
if (last) {
%>
<p>
<font size=+1><b>4) Send Order</b></font>
</p>

<p>
This order form can be printed and sent along with payment to:
<dl><dd><b>
Alternative Images<br>
114 Fort Hunter Road<br>
Schenectady, NY 12303<br>
</b></dl>
</p>

<p>
Orders are shipped UPS Ground Service.
</p>

<%
    if (location == 2) {
%>
<p>
For international orders payment must be made by international check or
money order, in U.S. funds only, made payable to "Alternative Images".
</p>
<%
    } else if ((payment == 0) || (payment == 1)) {
%>
<p>
Orders paid by personal check should be made payable to "Alternative Images"
and will be held for two weeks pending bank clearance.
Sorry no COD's.
</p>
<%
    } else {
%>
<p>
When payment is made by credit card you can e-mail your order to Alternative
Images 24 hours a day. When ordering by e-mail
please call 518-899-3012 to provide credit card information. Once an
account has been established for you, you will not need to call again
when placing an e-mail order.
Office hours are Monday through Friday 6:00pm - 9:00pm and Saturdays
11:00am - 5:00pm.
An answering machine will take your information during off hours.
Please ensure you leave the following information: first and last name,
e-mail address, and credit card number with expiration date.
Please speak clearly.
</p>
<%
    }
%>
<p>
<input name="change" value="<< Change Order" type=submit>
</p>
<%
} else {
%>
<p>
<font size=+1><b>4) Create Order Summary</b></font>
</p>

<p>
When your ordering information is complete please use the &quot;Order Summary&quot; button
to create a final order form.  The final order form can then be printed and
mailed to Alternative Images.
</p>

<p>
<input name="last" value="Order Summary >>" type=submit>
</p>
<%
}
%>
</form>

<% writeFooter() %>