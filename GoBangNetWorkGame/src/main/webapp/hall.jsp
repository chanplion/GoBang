<%@ page language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>五子棋游戏大厅</title>
<!-- <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">  -->
        <title>Login and Registration Form with HTML5 and CSS3</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
        <meta name="description" content="Login and Registration Form with HTML5 and CSS3" />
        <meta name="keywords" content="html5, css3, form, switch, animation, :target, pseudo-class" />
        <meta name="author" content="Codrops" />
        <link rel="shortcut icon" href="../favicon.ico"> 
        <link rel="stylesheet" type="text/css" href="<%=path%>/css/hall.css" />
		<script type="text/javascript" src="<%=path%>/js/jquery-3.1.1.js"></script>
</head>
<script type="text/javascript">  
    var websocket = null;  
    
    //判断当前浏览器是否支持WebSocket  
    if('WebSocket' in window){  
        websocket = new WebSocket("ws://localhost:8080/FiveGame/websocket/"+'${name}');  
    }  
    else{  
        alert('Not support websocket')  
    }  
  
    //连接发生错误的回调方法  
    websocket.onerror = function(){  
        setMessageInnerHTML("error");  
    };  
  
    //连接成功建立的回调方法  
    websocket.onopen = function(event){  
        setMessageInnerHTML("open");  
    }  
  
    //接收到消息的回调方法  
    websocket.onmessage = function(event){ 
        var roomnameTd=$("td[name='roomname']");
        roomnameTd.each(function(){
        	if($(this).text()==event.data){
        		var num=$(this).siblings("td[name='roomnum']").text();
        		$(this).siblings("td[name='roomnum']").text(Number(num)+1);
        	}
        });
    }  
  
    //连接关闭的回调方法  
    websocket.onclose = function(){  
        setMessageInnerHTML("close");  
    }  
  
    //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。  
    window.onbeforeunload = function(){  
        websocket.close();  
    }  
  
    //将消息显示在网页上  
    function setMessageInnerHTML(innerHTML){  
        
    }  
  
    //关闭连接  
    function closeWebSocket(){  
        websocket.close();  
    }  
  
    //发送消息  
    function send(me,roomname){  
       // var message = document.getElementById('text').value;  
       $me=$(me);
        var numtd= $me.parent().parent().siblings("td[name='roomnum']");
        var num=Number(numtd.text());
        if(num<2){
        	websocket.send("00"+roomname);
        	window.location.href="<%=basePath %>hallController/room.do?roomname="+roomname+"&integral="+'${integral}'+"&name="+'${name}';
        }else{
        	alert("本房间人数已满,请选择别的房间");
        }
    } 
</script>  
<body>
<div class="all">
<div class="top">
<div class="ranking">
<div class="rankinglist">排行榜</div>
<table>
<c:forEach items="${userlist }" var="u" varStatus="s">
<tr>
<td>第${s.index+1}名：
<td><span>${u.username}</span></td>
<td><span style="margin-left:10px">积分：</span></td>
<td>${u.integral}</td>
</tr>
</c:forEach>
</table>
</div>
<div class="information">
<div class="userinformation">
用户信息
</div>
<table>
<tr>
<td>姓名：</td>
<td>${name}</td>
</tr>
<tr>
<td>积分：</td>
<td>${integral}</td>
</tr>
</table>
</div>
</div>
<div class="down">
<div class="room">
<table>
<tr>
<td width="300px" class="roomlist">房间编号</td>
<td width="300px" class="roomlist">游戏状态</td>
<td width="300px" class="roomlist">房间人数</td>
<td width="300px" class="roomlist">操作</td>
</tr>

<c:forEach items="${roomlist }" var="r" varStatus="s">
<tr style="text-align: center;
	font-size: 16px;
	height: 60px;">
<td name="roomname">${r.roomname}</td>
<c:if test="${r.roomnum<2}">
<td style="color:yellow;">
等待中...
</td>
</c:if>
<c:if test="${r.roomnum==2}">
<td style="color:red;">
游戏中...
</td>
</c:if>
<td name="roomnum">${r.roomnum}</td>
<td>加入游戏<span style="margin-left:3px;">
<input type="image" src="../images/timg.jpg" width="18px"   height="18px" onclick="send(this,${r.roomname})"/>

</span></td>
</tr>
</c:forEach>
</table>

</div>
</div>
</div>
</body>
</html>