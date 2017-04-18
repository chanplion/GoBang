package com.fiveGame.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/hallController")
public class HallController {
	@RequestMapping("/room")
	public ModelAndView shall(String roomname,String name,String integral){
		ModelAndView mv=new ModelAndView();
		mv.addObject("roomname", roomname);
		mv.addObject("name", name);
		mv.addObject("integral", integral);
		mv.setViewName("/room");
		return mv;
	}
}
