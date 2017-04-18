package com.fiveGame;

import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.alibaba.fastjson.JSON;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:spring-core.xml","classpath:spring-jdbc.xml","classpath:spring-beans.xml"})
public abstract class TestSupport {
	
	protected Logger logger = Logger.getLogger(this.getClass());
	
	public void debug(Object msg){
		logger.debug(JSON.toJSONString(msg));
	}
	
	public void info(Object msg){
		logger.info(JSON.toJSONString(msg));
	}
	
	public void warn(Object msg){
		logger.warn(JSON.toJSONString(msg));
	}
	
	public void error(Object msg){
		logger.error(JSON.toJSONString(msg));
	}
	
	static {
		try{
			DOMConfigurator.configure(TestSupport.class.getResource("test.xml"));
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}

}
