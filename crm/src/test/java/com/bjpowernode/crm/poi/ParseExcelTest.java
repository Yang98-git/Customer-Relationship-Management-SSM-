package com.bjpowernode.crm.poi;

import com.bjpowernode.crm.commons.utils.HSSFUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellType;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 使用apache-poi解析Excel文件
 */
public class ParseExcelTest {
    public static void main(String[] args) throws IOException {
        //根据excel文件生成HSSFWorkbook，封装了excel文件所有信息
        InputStream is = new FileInputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\studentsListTest.xls");
        HSSFWorkbook wb = new HSSFWorkbook(is);

        //根据wb获取HSSFSheet,封装了某一页的info
        HSSFSheet sheet = wb.getSheetAt(0); //页的下标，从0开始

        //根据sheet获取HSSFRow,封装了某一行的info
        HSSFRow row = null;
        HSSFCell cell = null;
        //sheet.getLastRowNum() 最后一行的行数
        for (int i = 0; i <= sheet.getLastRowNum(); i++) { //0是表头，最后一行要=
            row = sheet.getRow(i);
            //根据row获取HSSFCell,封装了某一列的info
            //row.getLastCellNum()总列数，最后一列+1，与上面不同，不用=
            for (int j = 0; j < row.getLastCellNum(); j++) {
                cell = row.getCell(j);

                 //获取列中的数据
                System.out.print(HSSFUtils.getCellValueForStr(cell)+" ");
            }
            //每行中所有列打完，打印一个换行
            System.out.println();
        }

    }
}


