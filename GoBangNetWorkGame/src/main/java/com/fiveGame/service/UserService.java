package com.fiveGame.service;

import java.util.List;

import com.fiveGame.entity.User;

/*
 * 该方法由子类实现*
 * */

public interface UserService {
	public User getUser(User user);
	public int setUser(User user);
	public List<User> selectThree();
}
