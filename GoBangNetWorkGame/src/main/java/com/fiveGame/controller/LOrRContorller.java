package com.fiveGame.controller;


import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.fiveGame.entity.Room;
import com.fiveGame.entity.User;
import com.fiveGame.service.RoomService;
import com.fiveGame.service.UserService;

@Controller
@RequestMapping("/LOrRContorller")
public class LOrRContorller {
	private UserService userService;
	private RoomService roomService;

	@Autowired
	public void setUserService(UserService userService) {
		this.userService = userService;
	}
	@Autowired
	public void setRoomService(RoomService roomService) {
		this.roomService = roomService;
	}
	
	@RequestMapping("/login")
	public ModelAndView login(User userInfo,HttpSession httpSession){
		User user=userService.getUser(userInfo);
		ModelAndView mv=new ModelAndView();
//		//防止重复提交
//		if(null!=httpSession.getAttribute("name")){
//			List<User> userlist = userService.selectThree();
//			List<Room> roomlist = roomService.selectRoom();
//			httpSession.setAttribute("userlist",userlist);
//			httpSession.setAttribute("roomlist",roomlist);
//			mv.setViewName("/hall");
//			return mv;
//		}
		
		String flag="";
		if(null!=user){
			flag="success";
			mv.setViewName("/hall");
			httpSession.setAttribute("name", user.getUsername());
			httpSession.setAttribute("integral", user.getIntegral());
			List<User> userlist = userService.selectThree();
			List<Room> roomlist = roomService.selectRoom();
			httpSession.setAttribute("userlist",userlist);
			httpSession.setAttribute("roomlist",roomlist);
//			System.out.println(roomlist.toString());
			return mv;
		}else{
			flag="账号或密码错误,请重新登录";
			mv.addObject("flag",flag);
			mv.setViewName("/index");
			return mv;
		}
		
	}
	
	@RequestMapping("/register")
	public ModelAndView register(User userInfo){
		int flag=userService.setUser(userInfo);
		ModelAndView mv=new ModelAndView();
		if(flag==1){
			mv.setViewName("/index");
			return mv;
		}else{
			mv.setViewName("/index.jsp#toregister");
			return mv;
		}
		
	}
	
	

}
