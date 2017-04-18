package com.fiveGame.vo;

import java.util.List;

/**
 * 分页结果存放数据模型
 * @author J.L.Zhou
 *
 * @param <T>
 */
public class PageVO<T> {
	
	/**
	 * 当前页码
	 */
	private int current = 1;
	
	/**
	 * 每页最大数
	 */
	private int rowMax = 10;
	
	/**
	 * 最大页码
	 */
	private int pageMax;
	
	/**
	 * 总计数量
	 */
	private long total;
	/**
	 * 当前页的数据
	 */
	private List<T> rows;
	
	
	public int getCurrent() {
		return current;
	}
	public void setCurrent(int current) {
		this.current = current;
	}
	public int getRowMax() {
		return rowMax;
	}
	public void setRowMax(int rowMax) {
		this.rowMax = rowMax;
	}
	public long getTotal() {
		return total;
	}
	public void setTotal(long total) {
		this.total = total;
	}
	public List<T> getRows() {
		return rows;
	}
	public void setRows(List<T> rows) {
		this.rows = rows;
	}
	public int getPageMax() {
		return pageMax;
	}
	public void setPageMax(int pageMax) {
		this.pageMax = pageMax;
	}
	@Override
	public String toString() {
		return "PageVO [current=" + current + ", rowMax=" + rowMax + ", pageMax=" + pageMax + ", total=" + total
				+ ", rows=" + rows + "]";
	}
	
	
	

}
