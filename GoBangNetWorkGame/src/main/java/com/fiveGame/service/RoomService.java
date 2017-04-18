package com.fiveGame.service;

import java.util.List;

import com.fiveGame.entity.Room;

public interface RoomService {
	public List<Room> selectRoom();
    public int roomNum(String roomname);
    public int subRoomNum(String roomname);
}
