package com.fiveGame.vo;

import java.util.Calendar;
import java.util.Date;

/**
 * EasyUI中DataGrid提交的基本数据模型<br/>
 * 分页查询的基础条件<br/>
 * 包含 <br/>
 * page ： 当前页码<br/>
 * rows ： 每页的最大数量<br/>
 * sort : 进行排序的列<br/>
 * order: asc/desc<br/>
 * key : 通用模糊匹配关键字
 * 
 * @author J.L.Zhou
 * 
 */
public class Search {

	/**
	 * 当前页码
	 */
	private int page = 1;
	/**
	 * 每页的最大数量
	 */
	private int rows = 10;
	/**
	 * 需要排序的列的名称
	 */
	private String sort;
	/**
	 * 使用asc或者desc排序
	 */
	private String order;
	
	private Date beginDate, endDate;

	/**
	 * key 通用模糊匹配
	 */
	private String key;

	public int getPage() {
		return page;
	}

	public void setPage(int page) {
		this.page = page;
	}

	public int getRows() {
		return rows;
	}

	public void setRows(int rows) {
		this.rows = rows;
	}

	public String getSort() {
		return sort;
	}

	/**
	 * 进行排序的列
	 * @param sort
	 */
	public void setSort(String sort) {
		this.sort = sort;
	}

	public String getOrder() {
		return order;
	}

	/**
	 * asc/desc
	 * @param order
	 */
	public void setOrder(String order) {
		this.order = order;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}
	/**
	 * 格式化结束日期，结束时间为当天23：59：59
	 * @param date
	 * @return
	 */
	public Date formatEndDate(Date date){
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.DATE, 1);
		c.add(Calendar.MILLISECOND, -1);
		return c.getTime();
	}
	

	public Date getBeginDate() {
		if (beginDate == null) {
			return null;
		}
		if (endDate != null) {
			if (beginDate.after(endDate)) {
				return endDate;
			} else {
				return beginDate;
			}
		} else {
			return beginDate;
		}
	}

	public void setBeginDate(Date beginDate) {
		this.beginDate = beginDate;
	}

	public Date getEndDate() {
		if (endDate == null) {
			return null;
		}
		if (beginDate != null) {
			if (beginDate.before(endDate)) {
				return formatEndDate(endDate);
			} else {
				return formatEndDate(beginDate);
			}
		} else {
			return formatEndDate(endDate);
		}
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}
	
	public int getIndex(){
		return (page-1)*rows;
	}
}
