package com.fiveGame.service.imp;



import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fiveGame.entity.Room;
import com.fiveGame.entity.User;
import com.fiveGame.service.UserService;
import com.fiveGame.dao.UserMapper;

@Service
public class UserServiceImpl implements UserService{
	private UserMapper mapper;

	@Override
	public User getUser(User userInfo) {
		// TODO Auto-generated method stub
		return mapper.userLogin(userInfo);
	}
	
	@Autowired
	public void setUserMapper(UserMapper mapper){
		this.mapper=mapper;
	}

	@Override
	public int setUser(User userInfo) {
		int flag=0;
		// TODO Auto-generated method stub
		try{
	 mapper.userRegister(userInfo);
	  flag=1;
		}
		catch(Exception e){
			flag=0;
			e.printStackTrace();
		}
		return flag;
	}

	@Override
	public List<User> selectThree() {
		// TODO Auto-generated method stub
		return mapper.selectThreeUser();
	}


	

}
