package com.fiveGame.type;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import com.alibaba.fastjson.JSON;

public class StringArrayTypeHandler extends BaseTypeHandler<String[]>{


	@Override
	public void setNonNullParameter(PreparedStatement ps, int i, String[] parameter, JdbcType jdbcType)
			throws SQLException {
		ps.setString(i, JSON.toJSONString(parameter));
	}

	@Override
	public String[] getNullableResult(ResultSet rs, String columnName) throws SQLException {
		return get(rs.getString(columnName));
	}

	@Override
	public String[] getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
		return get(rs.getString(columnIndex));
	}

	@Override
	public String[] getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		return get(cs.getString(columnIndex));
	}
	
	private String[] get(String str) throws SQLException{
		try {
			return JSON.parseArray(str, String.class).toArray(new String[0]);
		} catch (Exception e) {
//			throw new SQLException(e.getMessage(), e);
			return null;
		}
	}

	 



}
