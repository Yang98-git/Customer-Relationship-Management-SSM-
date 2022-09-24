package com.bjpowernode.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.ss.usermodel.CellType;

/**
 * excel文件操作的工具类
 */
public class HSSFUtils {
    /**
     * 从指定的HSSFCell对象，获取列值
     * @return
     */
    public static String getCellValueForStr(HSSFCell cell){
        String ret = "";
        if (cell.getCellType()== CellType.STRING){
            ret=cell.getStringCellValue();
        }else if (cell.getCellType()==CellType.NUMERIC){
            ret=cell.getNumericCellValue()+""; //转成String
        }else if (cell.getCellType()==CellType.BOOLEAN){
            ret=cell.getBooleanCellValue()+""; //转成String
        }else if (cell.getCellType()==CellType.FORMULA){
            ret=cell.getCellFormula()+""; //转成String
        }else {
            ret="";
        }
        return ret;
    }

}
