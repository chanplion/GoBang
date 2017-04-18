package com.fiveGame.service.imp;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fiveGame.dao.RoomMapper;
import com.fiveGame.entity.Room;
import com.fiveGame.service.RoomService;

@Service()
public class RoomServiceImpl implements RoomService{
	private RoomMapper mapper;
	@Autowired
	public void setUserMapper(RoomMapper mapper){
		this.mapper=mapper;
	}
	@Override
	public List<Room> selectRoom() {
		// TODO Auto-generated method stub
		return mapper.allRoom();
	}
	@Override
	public int roomNum(String roomname) {
		// TODO Auto-generated method stub
		return mapper.updateRoomnum(roomname);
	}
	
	@Override
	public int subRoomNum(String roomname) {
		// TODO Auto-generated method stub
		return mapper.subRoomnum(roomname);
	}

}
