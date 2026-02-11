<%@page contentType="image/svg+xml"%>
<svg width="100%" height="100%" viewBox="0 0 500 500" onload="init()"
    xmlns="http://www.w3.org/2000/svg" 
    xmlns:xlink="http://www.w3.org/1999/xlink">
<script type="text/ecmascript"><![CDATA[
var label1Element = null;
var label2Element = null;
var label3Element = null;
var targetWidth = 0;
var targetHeight = 0;

function init() {
    label1Element = document.getElementById("label1").childNodes.item(0);
    label2Element = document.getElementById("label2").childNodes.item(0);
    label3Element = document.getElementById("label3").childNodes.item(0);
    var image = document.getElementById("image");
    targetWidth = image.getAttribute("width");
    targetHeight = image.getAttribute("height");
    flip();
}

function flipCallback(status) {
    if (status.success) {
        var frag = parseXML(status.content, null);
        var buildup = frag.getElementsByTagName("buildup").item(0);
        var buildupUid = buildup.getAttribute("buildupUid");
        var imageURI = buildup.getAttribute("imageURI");
        var imageWidth = buildup.getAttribute("imageWidth");
        var imageHeight = buildup.getAttribute("imageHeight");
        var image = document.getElementById("image");
        image.setAttributeNS("http://www.w3.org/1999/xlink", "href", imageURI);
        var scale = Math.min(targetWidth / imageWidth, targetHeight / imageHeight);
        image.setAttribute("width", imageWidth * scale);
        image.setAttribute("height", imageHeight * scale);
        image.setAttribute("x", (500 - imageWidth * scale) / 2);
        var kitName = buildup.getAttribute("kitName");
        var producerName = buildup.getAttribute("producerName");
        label1Element.setData(kitName);
        var painterName = buildup.getAttribute("painterName");
        if (painterName != null) {
            label2Element.setData("painted by");
            label3Element.setData(painterName);
        } else
        if (producername != null) {
            label2Element.setData("produced by");
            label3Element.setData(producerName);
        } else {
            label2Element.setData("");
            label3Element.setData("");
        }
        var link = document.getElementById("link");
        link.setAttributeNS(
            "http://www.w3.org/1999/xlink", "href",
            "/garage/galleryView.jsp?buildupUid=" + buildupUid
        );
    }
    setTimeout("flip()", 5000);
}

function flip() {
    getURL("kitInfo.jsp", flipCallback);
}
]]></script>
<a id="link">
<text id="label1" x="250" y="15" text-anchor="middle" font-size="15"> </text>
<text id="label2" x="250" y="25" text-anchor="middle" font-size="9" font-style="italic" fill="#c0c0c0"> </text>
<text id="label3" x="250" y="37" text-anchor="middle" font-size="12"> </text>
<image id="image" x="0" y="50" width="500" height="450" preserveAspectRatio="xMidYMin"/>
</a>
</svg>
