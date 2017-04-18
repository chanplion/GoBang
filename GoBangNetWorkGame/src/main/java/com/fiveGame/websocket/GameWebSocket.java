package com.fiveGame.websocket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArraySet;

import javax.servlet.http.HttpSession;
import javax.websocket.EncodeException;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import org.springframework.web.context.ContextLoader;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;
import com.fiveGame.service.RoomService;

//该注解用来指定一个URI，客户端可以通过这个URI来连接到WebSocket。类似Servlet的注解mapping。无需在web.xml中配置。  
@ServerEndpoint(value="/gamewebsocket/{roomname}",configurator=wsConfigurator.class,encoders = { ServerEncoder.class })
public class GameWebSocket {
	private RoomService roomService =(RoomService)ContextLoader.getCurrentWebApplicationContext().getBean("roomService");
    //静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。  
    private static int onlineCount = 0;  
       
    //concurrent包的线程安全Set，用来存放每个客户端对应的GameWebSocket对象。若要实现服务端与单一客户端通信的话，可以使用Map来存放，其中Key可以为用户标识  
    private static CopyOnWriteArraySet<GameWebSocket> webSocketSet = new CopyOnWriteArraySet<GameWebSocket>();  
       
    //与某个客户端的连接会话，需要通过它来给客户端发送数据  
    private Session session;  
       
    private static Map<Session,String> usernameMap=new HashMap();
    private String roomname=null;
    private String username=null;
    
    private static Map<String,Integer> roomnumMap=new HashMap();
    
    //存储房间号对应玩家信息
    private static Map<String,List<Map<String,String>>> player=new HashMap();
 
    /**  
     * 连接建立成功调用的方法  
     * @param session  可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据  
     * @throws EncodeException 
     */  
    @OnOpen  
    public void onOpen(@PathParam("roomname")String roomname,EndpointConfig config,Session session) throws EncodeException{  
        this.session = session;  
        HttpSession httpSession = (HttpSession) config.getUserProperties().get(HttpSession.class.getName());
        String username=(String) httpSession.getAttribute("name");
        if(null==usernameMap.get(session)){
        	usernameMap.put(session, username);
        }
        webSocketSet.add(this);     //加入set中  
        addOnlineCount();           //在线数加1
        setRoomname(roomname);
        setUsername(username);
        //将房间的人数添加到Map
        if(null==roomnumMap.get(roomname)){
        	roomnumMap.put(roomname, 1);
        }else{
        	Integer roomnum=roomnumMap.get(roomname);
        	roomnumMap.put(roomname, roomnum+1);
        }
        System.out.println("有新连接加入房间！当前在线人数为" + getOnlineCount());  
        //System.out.println("该用户id:" + session.getId());
        System.out.println("房间号为:" + roomname+"  "+"当前人数为:"+roomnumMap.get(roomname));
        System.out.println("该用户名:" + username);
        
        //根据房间号找玩家信息
        if(null!=player){
        	if(null!=player.get(roomname)){
        		 //原路传回房间人数和用户信息
                sendBackMessage(roomnumMap.get(roomname).toString(),player.get(roomname).get(0),session);
        	}else{
        		 //原路传回房间人数和用户信息
                sendBackMessage(roomnumMap.get(roomname).toString(),null,session);
        	}
        }else{
        	 //原路传回房间人数和用户信息
            sendBackMessage(roomnumMap.get(roomname).toString(),null,session);
        }
    }  
       
    /**  
     * 连接关闭调用的方法  
     */  
    @OnClose  
    public void onClose(Session session){
    	//清空退出的玩家信
    	//玩家减一
    	roomService.subRoomNum(this.roomname);
        webSocketSet.remove(this);  //从set中删除  
        subOnlineCount();           //在线数减1
      //房间人数减一
       Integer roomnum=roomnumMap.get(roomname);
       roomnumMap.put(roomname, roomnum-1);
        System.out.println("有一连接退出房间！当前在线人数为" + getOnlineCount());  
        System.out.println("房间号为:" + this.roomname+"  "+"当前人数为:"+roomnumMap.get(roomname));
        //System.out.println("该用户id:" + session.getId());
        System.out.println("该用户名:" + usernameMap.get(session));
        usernameMap.remove(session);
    }  
       
    /**  
     * 收到客户端消息后调用的方法  
     * @param message 客户端发送过来的消息  
     * @param session 可选的参数  
     * @throws EncodeException 
     */  
    @OnMessage  
    public void onMessage(String message, Session session) throws EncodeException, IOException {  
        System.out.println("来自客户端的消息:" + message);  
        //System.out.println("该用户id:" + session.getId());
        System.out.println("该用户名:" + usernameMap.get(session));
        String [] str=message.split("-");
        
        if("player".equals(str[0])){
        	List<Map<String,String>> list=new ArrayList();
        	Map userInfo=JSON.parseObject(str[1], Map.class);
        	list.add(userInfo);
        	//若房间中没有人
        	if(null==player.get(this.roomname)){
        	player.put(this.roomname, list);
        	}else{//有人则先取出来，再存，防止覆盖信息,
        		Map<String,String> player1=player.get(this.roomname).get(0);
        		//把玩家2信息传到玩家1
        		sendMessageToPlayer(player1.get("nickname"), userInfo);
        		list.add(player1);
        		player.put(this.roomname,list);
        	}
        }else if("ready".equals(str[0])){
        	Map messageType=new HashMap();
        	List<Map<String,String>> playerlist=player.get(this.roomname);
       	 	Map<String, String> mapstr = JSON.parseObject(
    			 str[1],new TypeReference<Map<String, String>>(){} );
    	 	if(mapstr.equals(playerlist.get(0))){
    	 		playerlist.remove(0);
    	 		playerlist.add(mapstr);
    	 		player.put(this.roomname,playerlist);
    	 	}else{
    	 		playerlist.remove(1);
    	 		playerlist.add(mapstr);
    	 		player.put(this.roomname,playerlist);
    	 	}
    	 	Map readyuser=JSON.parseObject(str[1], Map.class);
        	//放入准备用户的用户名
        	messageType.put("ready", readyuser);
        	//传用户名回去
        	sendRoomMessage(messageType);
        }else if("chesses".equals(str[0])){
        	System.out.println("hahaha");
        }else if("outplayer".equals(str[0])){
        	//用户退出时  把玩家信息传回房间
        	Map outplayer=new HashMap();
        	
        	List<Map<String,String>> playerlist=player.get(this.roomname);
        	 Map<String, String> mapstr = JSON.parseObject(
        			 str[1],new TypeReference<Map<String, String>>(){} );
        	 if(mapstr.get("nickname").equals(playerlist.get(0).get("nickname"))){
        		 playerlist.remove(0);
        		 player.put(this.roomname,playerlist);
        	 }else{
        		 playerlist.remove(1);
        		 player.put(this.roomname,playerlist);
        	 }
        	 Map outyuser=JSON.parseObject(str[1], Map.class);
        	outplayer.put("outplayer", outyuser);
        	sendRoomMessage(outplayer);
        }else if("speak".equals(str[0])){//传说话的信息
        	Map speakmessage=new HashMap();
        	Map speak=JSON.parseObject(str[1], Map.class);
        	speakmessage.put("speak", speak);
        	sendRoomMessage(speakmessage);
        }else if("cur".equals(str[0])){
        	Map curlist=new HashMap();
        	Map cur=JSON.parseObject(str[1], Map.class);
        	curlist.put("cur", cur);
        	sendRoomMessage(curlist);
        }
        
    }
    //原路发回数据
    public void sendBackMessage(String roomnum,Map userInfo,Session session) throws EncodeException{
        for(GameWebSocket item: webSocketSet){    
        	
            try {  
            	if(item.session==session){
            	Map messageType=new HashMap();
            	messageType.put("roomnum", roomnum);
            	messageType.put("userInfo", userInfo);
                item.sendMessage(messageType);
                }  
            } catch (IOException e) {  
                e.printStackTrace();  
                continue;  
            }  
        }  
    }
    
    //发数据到某个房间
    public void sendRoomMessage(Object message) throws EncodeException{
        for(GameWebSocket item: webSocketSet){         	
            try {  
            	if(item.getRoomname().equals(this.roomname)){
                item.sendMessage(message);
                }  
            } catch (IOException e) {  
                e.printStackTrace();  
                continue;  
            }  
        }  
    }
    
  //发数据给某个玩家
    public void sendMessageToPlayer(String username,Map userInfo) throws EncodeException{
        for(GameWebSocket item: webSocketSet){    
        	
            try {  
            	if(item.getUsername().equals(username)){
            	Map messageType=new HashMap();
            	messageType.put("player2", userInfo);
                item.sendMessage(messageType);
                }  
            } catch (IOException e) {  
                e.printStackTrace();  
                continue;  
            }  
        }  
    }
       
    /**  
     * 发生错误时调用  
     * @param session  
     * @param error  
     */  
    @OnError  
    public void onError(Session session, Throwable error){  
        System.out.println("发生错误");  
        error.printStackTrace();  
    }  
    
//    private static void broadcastToSpecia(Message msg) {
//        for (GameWebSocket client : webSocketSet)
//            // 感觉用map进行映射会更好点
//            if (Contains(msg.getDests(), client.getUserName()))
//                client.call(msg);
//    }
       
    /**  
     * 这个方法与上面几个方法不一样。没有用注解，是根据自己需要添加的方法。  
     * @param message  
     * @throws IOException  
     * @throws EncodeException 
     */  
    public void sendMessage(Object message) throws IOException, EncodeException{ 
        this.session.getBasicRemote().sendObject(message);
        //this.session.getAsyncRemote().sendText(message);
        
        
    }  
   
    public static synchronized int getOnlineCount() {  
        return onlineCount;  
    }  
   
    public static synchronized void addOnlineCount() {  
    	GameWebSocket.onlineCount++;  
    }  
       
    public static synchronized void subOnlineCount() {  
    	GameWebSocket.onlineCount--;  
    }

	public String getRoomname() {
		return roomname;
	}

	public void setRoomname(String roomname) {
		this.roomname = roomname;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	} 
    
	
    
}
