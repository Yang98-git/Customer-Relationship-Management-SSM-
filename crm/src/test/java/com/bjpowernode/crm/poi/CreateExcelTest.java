package com.bjpowernode.crm.poi;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.ss.usermodel.HorizontalAlignment;

import java.io.FileOutputStream;
import java.io.IOException;

/**
 * apache-poi生成excel文件
 */
public class CreateExcelTest {
    public static void main(String[] args) throws IOException {
        //HSSFWorkBook对象， 对应一个excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        //使用wb创建HSSFSheet对象， 对应wb文件中的一页
        HSSFSheet sheet = wb.createSheet("Students List");
        //使用sheet创建HSSFRow对象， 对应sheet中的一行
        HSSFRow row = sheet.createRow(0); //行号：从0开始，放到第几行
        //使用row创建HSSFCell对象， 对应row中的一列
        HSSFCell cell = row.createCell(0);//列号：从0开始，放到第几列
        //写内容
        cell.setCellValue("Student Number"); //传什么类型就代表什么类型
        cell = row.createCell(1);//同一个row，第1列
        cell.setCellValue("Student Name");
        cell = row.createCell(2);//同一个row，第2列
        cell.setCellValue("Student Age");

        //生成HSSFCellStyle
        HSSFCellStyle style = wb.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);

        //使用sheet创建10个HSSFRow对象，放学生info
        for (int i = 1; i <= 10; i++) {
            row = sheet.createRow(i); //第二个row不用new,使用原来的页中的
            cell = row.createCell(0);//列号：从0开始，放到第几列
            cell.setCellValue(100+i);
            cell = row.createCell(1);//同一个row，第1列
            cell.setCellValue("Name"+i);
            cell = row.createCell(2);//同一个row，第2列
            cell.setCellStyle(style); //设置最后一列的样式
            cell.setCellValue(20+i);
        }


        //调用工具函数生成excel文件
        FileOutputStream os = new FileOutputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\studentsListTest.xls"); //目录必须创建好
        wb.write(os);

        try {
            os.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        try {
            wb.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        System.out.println("===================DONE!!!!!!!!!!!");
    }
}
