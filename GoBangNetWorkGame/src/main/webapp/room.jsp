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
<title>五子棋</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">

*{margin:0;padding:0;font-size:14px}
li{list-style:none}
#main{width:1000px;margin:10px auto;}


/*房间界面*/
.room{background:#5480AD;display:inline-block}
.room_user{margin:5px;width:190px;height:535px;float:left;background:#DCC09C;text-align:center}
.room_user p{line-height:22px}
.room_user .u1{margin-top:65px;}
.room_user .u2{margin-top:40px}
.room_chess{margin-top:5px;width:535px;height:535px;float:left;background:url('<%=path%>/images/bg.jpg');position:relative;cursor:no-drop}
.room_chess .black{background:url('<%=path%>/images/b.png') center center no-repeat;width:35px;height:33px;position:absolute;z-index:888}
.room_chess .white{background:url('<%=path%>/images/w.png') center center no-repeat;width:35px;height:33px;position:absolute;z-index:888}
.room_chess .cur{background:url('<%=path%>/images/cur.png') center center no-repeat;width:35px;height:33px;position:absolute;z-index:999}
.room_message{margin:5px;width:255px;float:left;}
.room_message .room_button{height:100px;background:#FFF;text-align:center;line-height:50px}
.room_message .room_button .btn{width:98px;height:36px;background:url('<%=path%>/images/btn.gif');border:0;color:#FFF}
.room_message .content{background:#FFF;height:400px;overflow-y:scroll;margin-top:5px;word-wrap:break-word;word-break:break-all; white-space:pre-line;ss }
.room_message .content p{padding:5px;}
.room_message .input{height:30px;background:#FFF;}
.black{background:url('<%=path%>/images/b.png') center center no-repeat;width:35px;height:33px;position:absolute;z-index:888}
.white{background:url('<%=path%>/images/w.png') center center no-repeat;width:35px;height:33px;position:absolute;z-index:888}


/*用户列表*/
.list{height:300px;overflow-y:scroll;background:#FFF;margin:5px;overflow-x:hidden}
.list li{padding:5px}
.list li span{float:right;}

/*消息*/
.message{height:295px;background:#FFF;margin:5px}
.message .content{height:265px;overflow-y:scroll}
.message .content p{padding:5px}
.message .input{height:30px;}
</style>

<script type="text/javascript" src="<%=path%>/js/jquery-3.1.1.js"></script>
<script type="text/javascript" src="<%=path%>/js/five.js"></script>  

<script type="text/javascript">
	
$(function(){
//	$("div.room_chess").css("cursor", "pointer");
	var MSG_ALL  = 0;//发送到所有用户
	var MSG_TO   = 1;//发送指定用户
	var MSG_ROOM = 2;//向指定桌发送消息
	
	var STAT_NORMAL = 0;//无状态
	var STAT_READY  = 1;//准备
	var STAT_START  = 2;//游戏中
	var STAT_END  = 3;//结束
	
	var COLOR_BLACK = 1;//黑色
	var COLOR_WHITE = 2;//白色
	
	var g_Info = {
		"nickname" : "",
		"status" : 0,
		"posIdx" : -1
	};
	
	var player = {
			"nickname" : '${name}',
			"color":-1,
			"integral" : '${integral}',
			"status" : 0,
			"posIdx" : -1,
			"allowDraw":false
				
		};
	var cur = {
		"player": '${name}',
		"x":"",
		"y":""
	};
	var m_RoomData = [];//房间内棋盘信息
	//说话的信息
	var speak={
			"player": '${name}',
			"message":""
	}
	$("div.room_chess").css("cursor", "no-drop");
	var m_RoomData = [];//房间内棋盘信息
	//初始化棋盘数据
	var InitChessData = function(){
		m_RoomData = [];
		for(var i = 0; i < 15; i++){
			m_RoomData[i] = [];
			for(var j = 0; j < 15; j++){
				m_RoomData[i][j] = 0;
			}
		}
	}
	InitChessData();

	//检查游戏是否结束
	var checkGameOver = function(x, y){
		var n;
		var cur = m_RoomData[x][y];
		
		
		//横
		n = 0;
		var startX = (x - 4) < 0 ? 0 : x - 4;
		var endX   = (x + 4) > 14 ? 14 : x + 4;		
		for(var i = startX; i <= endX; i++){
			if(m_RoomData[i][y] == cur){
				n++;
			}else{
				n = 0;
			}
			if(n >= 5) 
				return true;
		}
		
		//竖
		n = 0;
		var startY = (y - 4) < 0 ? 0 : x - 4;
		var endY   = (y + 4) > 14 ? 14 : y + 4;		
		for(var i = startY; i <= endY; i++){
			if(m_RoomData[x][i] == cur){
				n++;
			}else{
				n = 0;
			}
			if(n >= 5) return true;
		}
		
		//正斜
		n = 0;
		var min = x < y ? (x - 4 < 0 ? x : 4) : (y - 4 < 0 ? y : 4);
		var max = x > y ? (x + 4 > 14 ? 14 - x : 4) : (y + 4 > 14 ? 14 - y : 4); 
		var p1x = x - min;
		var p1y = y - min;
		var p2x = x + max;
		//m_RoomData[i][j];
		var p2y = y + max;
		for(var i = p1x, j = p1y; i <= p2x, j <= p2y; i++, j++){
			if(m_RoomData[i][j] == cur){
				n++;
			}else{
				n = 0;
			}
			if(n >= 5) return true;
		}
		
		//反斜
		n = 0;
		var min = (x + 4 > 14 ? 14 - x : 4) < (y - 4 < 0 ? y : 4) ? 
				  (x + 4 > 14 ? 14 - x : 4) : (y - 4 < 0 ? y : 4);
		var max = (x - 4 < 0 ? x : 4) < (y + 4 > 14 ? 14 - y : 4) ?
				  (x - 4 < 0 ? x : 4) : (y + 4 > 14 ? 14 - y : 4);
		var p1x = x + min; 
		var p1y = y - min;  
		var p2x = x - max;
		var p2y = y + max;
		for(var i = p1x, j = p1y; i >= p2x; i--, j++){
			if(m_RoomData[i][j] == cur){
				n++;
			}else{
				n = 0;
			}
			if(n >= 5) return true;
		}
		
		return false;
	}
	//落子
	$("div.room_chess").click(function(ev){
		if(player.status==2){
		var pageX = ev.pageX;
		var pageY = ev.pageY;
		var x = parseInt((pageX - $(this).offset().left - 5) / 35);
		var y = parseInt((pageY - $(this).offset().top - 5) / 35);
		console.info("标记"+m_RoomData[x][y]);
		if(checkValidChess(x,y)==true){
			if(player.allowDraw ==true){
			//console.info("你的颜色是："+player.color);
			cur.x=x;
			cur.y=y;
			websocket.send("cur-"+JSON.stringify(cur));
			m_RoomData[x][y] = player.color;
			}else{
				alert("轮到你的对手下棋!");
			}
		}else{
			alert("您的落子不合法");
		}
		}else if(player.status==0||player.status==1){
			alert("游戏暂未开始！");
		}else if(player.status==3){
			 if(confirm('游戏已结束，是否再来一局?')){
				 player.status==1;
				 $("#game_ready").click();
	    	}
		}
	});
	//检查落子是否合法
	var checkValidChess = function(x, y){
		if(m_RoomData[x][y] == 1){
			return false;
		}
		return true;
	}
	
	//画棋子
	 var drawChess = function(x, y,color){
		 
		 var left = x * 35 + 5;
		var top  = y * 35 + 5;
		//g_Info.allowDraw = false;
			var css  = (color == COLOR_BLACK ? "black" : "white");
			var html = '<div id="chess-' + x + '-' + y + '" style="left:' + left + 'px;top:' + top + 'px" class="' + css + '"></div>';
			$("div.room_chess").append(html);
			
			if($("div.room_chess .cur").length == 0){
				$("div.room_chess").append('<div class="cur"></div>');
			}
			$("div.room_chess .cur").css({
				left : left,
				top : top
			});
			m_RoomData[x][y] = color;
			if(checkGameOver(x, y)){
				player.allowDraw=false;
				player.status=3;
				var b = (player.status == STAT_NORMAL ? "准备" : (player.status == STAT_READY ? "取消" : "游戏中..."));
				$("#game_ready").val(b);
				alert("游戏结束！恭喜您赢了");
				if(color!=player.color){
					sendStatusToRoom("end",player.nickname);
					}else{
						sendStatusToRoom("end");
					}
			}else{
				if(color!=player.color){
				sendStatusToRoom("playChesses",player.nickname);
				}else{
					sendStatusToRoom("playChesses");
				}
			}
		
	}
	//更新房间人员
	function updateRoom(players)
	{
		//alert("这里是posIdx："+posIdx);
		var p = (players.posIdx == 0 ? 1 : 2);
		//alert(p);
		var s = (players.status == STAT_NORMAL ? "未准备" : (players.status == STAT_READY ? "已准备" : "游戏中"));
		//player.nickname='${name}';
		$("#room-p" + p + "-nickname").html("用户名："+players.nickname);
		//var integral = ${integral};
		$("#room-p" + p + "-integral").html("积分："+players.integral);
		$("#room-p" + p + "-status").html(s);
		$("#room-p" + p + "-img").html('<img src="<%=path%>/images/yes_player.gif">');
		//显示玩家的棋子颜色
		var color=(players.posIdx == 0 ? 'black' : 'white');
		var chesses = '<div class="' + color + '"></div>';
		$("#room-p" +p + "-chesses").html(chesses);
		
	}
	
	//从本房间移除另一个成员
	function removeRoom(posIdx)
	{
		var p = (posIdx == 0 ? 1 : 2);
		$("#room-p" + p + "-nickname").html('&nbsp;');
		$("#room-p" + p + "-integral").html("&nbsp;");
		$("#room-p" + p + "-status").html("&nbsp;");
		$("#room-p" + p + "-chesses").html('&nbsp;');
		$("#room-p" + p + "-img").html('<img src="<%=path%>/images/no_player.gif">');	
	}


	/*
	 * websocket
	 */
	    var websocket = null;  
	    //判断当前浏览器是否支持WebSocket  
	    if('WebSocket' in window){  
	        websocket = new WebSocket("ws://localhost:8080/FiveGame/gamewebsocket/00"+'${roomname}');
	    }  
	    else{  
	        alert('Not support websocket')  
	    }  
	  
	    //连接发生错误的回调方法  
	    websocket.onerror = function(){  
	   
	    };  
	  
	    //连接成功建立的回调方法  
	    websocket.onopen = function(event){  
	    }  
	  
	    //接收到消息的回调方法  
	    websocket.onmessage = function(event){ 
	    	var message=JSON.parse(event.data);
	    	//console.log(message);
	       if(null!=message.roomnum){
	    	   //alert("这里是房间人数："+message.roomnum);
	    	   if(message.roomnum==1){
	    		   player.color=COLOR_BLACK;
		    	   player.posIdx=0;
		       }else if(message.roomnum==2){
		    	   var userInfo=message.userInfo;
		    	   if(userInfo.posIdx==0){
		    		   player.color=COLOR_WHITE;
		    		   player.posIdx=1;
		    	   }else{
		    		   player.color=COLOR_BLACK;
		    		   player.posIdx=0;
		    	   }
		    	   updateRoom(userInfo);
		       }
		       updateRoom(player);
		       websocket.send("player-"+JSON.stringify(player));
	       }else if(null!=message.player2){
	    	   updateRoom(message.player2);
	       }else if(null!=message.ready){
	    	   updateRoom(message.ready);
	    	   sendStatusToRoom("ready",message.ready.nickname);
	    	   if($("#room-p1-status").text()=="已准备"&&$("#room-p2-status").text()=="已准备"){
	    		   $("#room-p1-status").text("游戏中");
	    		   $("#room-p2-status").text("游戏中");
	    		   player.status=2;
	    		   $("#game_ready").attr("disabled", true); 
	    		   alert("游戏开始了！");
	    		   document.getElementById("game").style.display="";
	    		   sendStatusToRoom("start");
	    		   $("div.room_chess").css("cursor", "pointer");
	    		   if(player.color==COLOR_BLACK){
	    			   player.allowDraw = true;
	    			   sendStatusToRoom("playChesses",player.nickname);
	    			   }else{
	    				   sendStatusToRoom("playChesses");
	    			   }
	    	   }
	       }else if(null!=message.outplayer){//退出房间
	    	   removeRoom(message.outplayer.posIdx);
	    	   alert("对方提前退出了游戏，您获得了胜利！");
	       }else if(null!=message.speak){
	    	   sendMessageToRoom(message.speak);
	       }else if(null!=message.cur){//对手棋子
	    	   var youcolor = "";
	    	   console.info("cur.player"+cur.player);
	    	   console.info("player.nickname"+player.nickname);
	           if(message.cur.player==player.nickname){
	        	   drawChess(message.cur.x,message.cur.y,player.color);
	        	   player.allowDraw=false;
	        	   //console.info("cur.player"+cur.player);
	           }else{
	        	   if(player.color==COLOR_BLACK){
	        		   youcolor = COLOR_WHITE;
	        	   }else{
	        		   youcolor = COLOR_BLACK;
	        	   }
	        	   console.info("你的颜色是："+player.color);
	        	   console.info("对手颜色"+youcolor);
	        	   drawChess(message.cur.x,message.cur.y,youcolor);
	        	   player.allowDraw=true;
	           }
	       }
	    }  
	  
	    //连接关闭的回调方法  
	    websocket.onclose = function(){  
	   
	    }  
	    
	    //退出房间
	   var outGame = function(){
	    	 if(confirm('您真的要退出房间吗？')){  
	    		 closeWebSocket();
	    		 window.history.go(-1);
	    	}
	    }
	   
	    //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。  
	    window.onbeforeunload = function(){  
	    	
	    	closeWebSocket(); 
	    }  
	  
	    //将消息显示在网页上  
	    function setMessageInnerHTML(innerHTML){  
	        
	    }  
	      
	    //关闭连接  
	    function closeWebSocket(){
	    	//退出消息
	    	//console.info("这里是关闭连接");
	    	
	    	websocket.send("outplayer-"+JSON.stringify(player)); 
	        websocket.close();  
	    }  
	  
	    //发送准备消息  
	    var sendReady = function(){  
	    	//准备
	    	player.status = STAT_READY;
	    	updateRoom(player);
	    	//alert("sakd");
			var b = (player.status == STAT_NORMAL ? "准备" : (player.status == STAT_READY ? "取消" : "游戏中..."));
			$("#game_ready").val(b);
	        websocket.send("ready-"+JSON.stringify(player));
	    } 
	    
	    $("#game_leave").click(function(){
	    	outGame();
	    });
	    
	    
	  //发送准备消息  
	    var sendoutReady = function(){  
	    	//准备
	    	player.status = STAT_NORMAL;
	    	updateRoom(player);
	    	//console.info(player+"这里是取消准备");
			var b = (player.status == STAT_NORMAL ? "准备" : (player.status == STAT_READY ? "取消" : "游戏中..."));
			$("#game_ready").val(b);
	        websocket.send("ready-"+JSON.stringify(player));
	    } 
	    $("#game_ready").click(function(){
	    	if($("#game_ready").val()=="取消"){
		    	sendoutReady();
		    
	    	}else if($("#game_ready").val()=="准备"){
		    	sendReady();
	    	}  
	    });
	    //发送信息到后台
	    $("#room-msg-button").click(function(){
	    	var newinfo = $("#room-msg-input").val();
	    	speak.message=newinfo;
	    	$("#room-msg-input").val("");
	    	websocket.send("speak-"+JSON.stringify(speak));
	    });
	    //发送信息到房间
	    var sendMessageToRoom=function(speak){
	    	var info = $("#room-msg-content").html();
	    	if(info!=""){
	    	$("#room-msg-content").html(info+"<br/>"+speak.player+"："+speak.message);
	    	}else{
	    		$("#room-msg-content").html(speak.player+"："+speak.message);
	    	}
	    }
	    //发送游戏状态信息学到消息框
	    var sendStatusToRoom=function(status,players){
	    	if(status=="ready"){
	    		var info = $("#room-msg-content").html();
	    		if(info!=""){
	    	    	$("#room-msg-content").html(info+"<br/>"+"系统:"+players+"已准备！");
	    	    	}else{
	    	    		$("#room-msg-content").html("系统:"+players+"已准备！");
	    	    	}
	    	}else if(status=="start"){
	    		var info = $("#room-msg-content").html();
	    		$("#room-msg-content").html(info+"<br/>"+"系统:"+"游戏开始了！");
	    		$("#room-msg-content").html(info+"<br/>"+"系统:"+"黑子先下棋！");
	    	}else if(status=="playChesses"){
	    		var info = $("#room-msg-content").html();
	    		console.log("chesses"+players);
	    		console.log("chesses"+player.nickname);
	    		if(players==player.nickname){
	    			$("#room-msg-content").html(info+"<br/>"+"系统:"+"轮到你下棋！");
	    		}else{
	    			$("#room-msg-content").html(info+"<br/>"+"系统:"+"轮到对手下棋！");
	    		}
	    	}else if(status=="end"){
	    		var info = $("#room-msg-content").html();
	    		if(players==player.nickname){
	    			$("#room-msg-content").html(info+"<br/>"+"系统:"+"游戏结束！");
	    	}
	    }
	    //按enter键发送消息
	    $("#room-msg-input").keydown(function() {
            if (event.keyCode == "13") {//keyCode=13是回车键
            	$("#room-msg-button").click();
            }
        });
	    }
	   
});    
	    

</script>
</head>
<body>
<div id="dlgBg"></div>

<div id="main">
	
	
	<div  id="room" class="room">
		<div class="room_user">
			<div class="u1">
				<p id="room-p1-img"><img src="<%=path%>/images/no_player.gif"></p>
				<p id="room-p1-chesses"></p>
				<p id="room-p1-nickname"></p>
				<p id="room-p1-integral"></p>
				<p id="room-p1-status"></p>
			</div>
			<div class="u2">
				<p id="room-p2-chesses"></p>
				<p id="room-p2-nickname"></p>
				<p id="room-p2-integral"></p>
				<p id="room-p2-status"></p>	
				<p id="room-p2-img"><img src="<%=path%>/images/no_player.gif"></p>	
			</div>
		</div>
		<div class="room_chess">
		</div>
		<div class="room_message">
			<div class="room_button">
				<div>
					<input type="button" id="game_ready" class="btn" value="准备">
					<input type="button" id="game_leave" class="btn" value="退出">
				</div>
				<div id="game" style="display: none">
					<input type="button" id="game_leave" class="btn" value="悔棋">
					<input type="button" id="game_leave" class="btn" value="认输">
				</div>
			</div>
			<div id="room-msg-content" class="content"></div>
			<div class="input">
				<input id="room-msg-input" style="width:175px;margin:5px 0 0 8px" type="text" id="input">
				<input id="room-msg-button" style="width:50px;margin:5px 0 0 0" type="button" value="发送">
			</div>		
		</div>
	</div>
	
</div>
</body>
</html>