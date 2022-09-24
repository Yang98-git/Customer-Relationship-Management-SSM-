package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.HSSFUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityRemarkService;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {

    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request){
        //调用service方法，查询所有用户
        List<User> userList = userService.queryAllUsers();
        //存到request中
        request.setAttribute("userList", userList);
        //转发跳转到市场活动主页面,视图解析器
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session){ //对象封装注入，表单name提交和成员变量名一致
        //从session获取当前登录的用户
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        //二次封装参数，前台只提交6个参数，sql需要9个参数
        //自己生成参数封装
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formateDateTime(new Date()));
        //当前用户创建的
        activity.setCreateBy(user.getId());

        //封装返回的json
        ReturnObject returnObject = new ReturnObject();
        //调用service
        //写数据需要考虑是否报异常，查数据不考虑
        try {
            int ret = activityService.saveCreateActivity(activity);

            if (ret>0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else { //底层数据库的错误，未添加成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("The System is busy. Please try again later....");
            }
        } catch (Exception e) { //service的错误
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("The System is busy. Please try again later....");
        }

        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name, String owner, String startDate, String endDate, Integer pageNo, Integer pageSize){
        //封装成map
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("beginNo", (pageNo-1)*pageSize);
        map.put("pageSize", pageSize);

        //调用两个service方法,查询数据
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryCountOfActivityByCondition(map);

        //将查询结果再次封装成map返回，springmvc会自动转成json字符串
        Map<String, Object> retMap = new HashMap<>();
        retMap.put("activityList", activityList);
        retMap.put("totalRows", totalRows);

        return retMap;
    }

    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    @ResponseBody
    public Object deleteActivityByIds(String[] id){ //接受来自客户端的参数和客户端参数名保持一致
        //封装返回的json
        ReturnObject returnObject = new ReturnObject();
        //调用service
        //写数据需要考虑是否报异常，查数据不考虑
        try {
            int ret = activityService.deleteActivityByIds(id);

            if (ret > 0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else { //底层数据库的错误，删除失败
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("The System is busy. Please try again later....");
            }
        } catch (Exception e) { //service的错误
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("The System is busy. Please try again later....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id){
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(Activity activity, HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        //前台只有提交参数不足，添加参数
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        activity.setEditBy(user.getId()); //当前登录用户修改的
        activity.setEditTime(DateUtils.formateDateTime(new Date()));
        try {
            int ret = activityService.saveEditActivity(activity);

            if (ret > 0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else { //底层数据库的错误，更新失败
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("The System is busy. Please try again later....");
            }
        } catch (Exception e) { //service错误
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("The System is busy. Please try again later....");
        }
        return returnObject;
    }

    //自己返回数据，返回文件
    @RequestMapping("/workbench/activity/fileDownload.do")
    public void fileDownload(HttpServletResponse response) throws IOException {
        //1.设置响应类型
        //application/octet-stream：excel文件类型，二进制类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //2.获取输出流
        //PrintWriter out = response.getWriter();//字符流
        OutputStream outputStream = response.getOutputStream(); //字节流

        //浏览器接收响应之后，会默认在显示窗口打开响应信息，打不开会调用响应应用打开，实在打不开才会激活文件下载窗口
        //设置响应头信息，直接激活文件下载窗口
        response.addHeader("Content-Disposition", "attachment;filename=myStudentList.xsl");


        //3.读磁盘excel文件到内存，输出到浏览器
        InputStream inputStream = new FileInputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\studentsListTest.xls");

        byte[] buff = new byte[256]; //缓存区
        int len=0; //每次读几个字节
        while ((len=inputStream.read(buff)) != -1){ //每次读一个缓存区
            outputStream.write(buff,0,len); //读几个转几个
        }

        inputStream.close();
        //谁new的谁close，output不是程序员new的，tomcat会关
        outputStream.flush(); //先flush，但是不close
    }

    @RequestMapping("/workbench/activity/exportAllActivities.do")
    public void exportAllActivities(HttpServletResponse response) throws IOException {
        //service查询所有市场活动
        List<Activity> activityList = activityService.queryAllActivities();
        //创建excel文件，把activityList写入excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("Market Activity List");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("Owner");
        cell = row.createCell(2);
        cell.setCellValue("Name");
        cell = row.createCell(3);
        cell.setCellValue("Start Date");
        cell = row.createCell(4);
        cell.setCellValue("End Date");
        cell = row.createCell(5);
        cell.setCellValue("Cost");
        cell = row.createCell(6);
        cell.setCellValue("Description");
        cell = row.createCell(7);
        cell.setCellValue("Create Time");
        cell = row.createCell(8);
        cell.setCellValue("Create By");
        cell = row.createCell(9);
        cell.setCellValue("Edit Time");
        cell = row.createCell(10);
        cell.setCellValue("Edit By");

        //使用sheet创建10个HSSFRow对象，放info
        if (activityList != null && activityList.size() > 0){
            //不要贸然遍历
            Activity activity = null;
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i);
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }

        //根据workbook对象生成excel文件
        /*FileOutputStream os = new FileOutputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\serverDir\\activityList.xls");
        //内存写到磁盘，效率低!!!!!!!!!!!
        wb.write(os);*/ //响应信息直接返回到文件下载窗口，捕获不了异常，直接抛出异常
        //关闭资源
        /*wb.close();
        os.close();*/

        //把生成的文件下载到客户端
        //1.设置响应类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //2.获取输出字节流
        OutputStream out = response.getOutputStream();

        //设置响应头信息，直接激活文件下载窗口
        response.addHeader("Content-Disposition", "attachment;filename=activityList.xls");

        //3.读磁盘excel文件到内存，输出到浏览器
        /*InputStream is = new FileInputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\serverDir\\activityList.xls");
        byte[] buff = new byte[256]; //缓存区
        int len=0; //每次读几个字节
        while ((len=is.read(buff))!=-1){ //每次读到一个缓存区
            //磁盘读到内存，效率低!!!!!!!!!!!!!!!
            out.write(buff, 0, len); //读几个写几个
        }
        is.close();*/
        wb.write(out); //直接内存到内存，workBook to outputStream，直接写到浏览器
        wb.close();
        out.flush();
    }


    //返回网页，跳转网页，测试就同步请求返回json报错
    /**
     * 必须配置springmvc的文件上传解析器！！！
     * MultipartFile此对象springmvc一开始没有，需要创建，需要配置bean，bean
     * @param userName
     * @param myFile
     * @return
     */
    @RequestMapping("/workbench/activity/fileUpload.do")
    @ResponseBody
    public Object fileUpload(String userName, MultipartFile myFile) throws IOException {
        //把文本数据打印到控制台
        System.out.println("userName="+userName);
        //把文件在服务器指定的目录中生成一个同样的文件
        String originalFilename = myFile.getOriginalFilename();
        File file = new File("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\serverDir\\",originalFilename); //路径必须手动创建好
        myFile.transferTo(file); //上传的myFile转到aaa.xls

        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        returnObject.setMessage("Upload Success");
        return returnObject;
    }

    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile, HttpSession session){ //springmvc要配置文件上传解析器
        ReturnObject returnObject = new ReturnObject();
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            /*//把接收到的文件写到磁盘目录
            String originalFilename = activityFile.getOriginalFilename();
            File file = new File("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\serverDir\\",originalFilename); //路径必须手动创建好
            activityFile.transferTo(file); //对象再内存里，内存到磁盘，效率低 不用往磁盘写了*/

            //解析excel文件，获取文件中的数据，并且封装成activityList
            //根据excel文件生成HSSFWorkbook，封装了excel文件所有信息
            //InputStream is = new FileInputStream("F:\\CS\\Java框架\\CRM项目(SSM)\\项目资料\\serverDir\\"+originalFilename); //不读磁盘了

            InputStream is = activityFile.getInputStream();

            HSSFWorkbook wb = new HSSFWorkbook(is); //文件在磁盘里，磁盘到内存，效率低
            HSSFSheet sheet = wb.getSheetAt(0);

            //根据sheet获取HSSFRow,封装了某一行的info
            HSSFRow row = null;
            HSSFCell cell = null;
            Activity activity = null;
            List<Activity> activities = new ArrayList<>();
            //sheet.getLastRowNum() 最后一行的行数
            for (int i = 1; i <= sheet.getLastRowNum(); i++) { //0是表头，最后一行要=
                row = sheet.getRow(i);
                //每一行都需要一个实体类，并且自己生成部分数据
                activity = new Activity();
                //生成uuid
                activity.setId(UUIDUtils.getUUID());
                //谁导入谁是owner，不让用户输入，业务决定好
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formateDateTime(new Date()));
                activity.setCreateBy(user.getId());

                //根据row获取HSSFCell,封装了某一列的info
                //row.getLastCellNum()总列数，最后一列+1，与上面不同，不用=
                for (int j = 0; j < row.getLastCellNum(); j++) {
                    cell = row.getCell(j);

                    //获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);
                    if (j==0){
                        activity.setName(cellValue);
                    } else if (j==1) {
                        activity.setStartDate(cellValue);
                    } else if (j==2) {
                        activity.setEndDate(cellValue);
                    } else if (j==3) {
                        activity.setCost(cellValue);
                    } else if (j==4) {
                        activity.setDescription(cellValue);
                    }
                }
                //把每一行封装的实体类，添加到List
                activities.add(activity);
            }

            //把list传给service，向数据库保存
            int ret = activityService.saveCreateActivitiesByList(activities);
            //只要不报异常就是成功，有可能ret有可能=0没有数据行
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setRetData(ret); //导入了多少条数据

        } catch (IOException e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("The System is busy. Please try again later....");
        }
        return returnObject;

    }

    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id, HttpServletRequest request){
        //调用service方法
        Activity activity = activityService.queryActivityForDetailById(id);
        List<ActivityRemark> remarkList = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);

        //把数据保存到request
        request.setAttribute("activity", activity);
        request.setAttribute("remarkList", remarkList);

        //转发跳转到市场活动明细主页面,视图解析器
        return "workbench/activity/detail";

    }


}
