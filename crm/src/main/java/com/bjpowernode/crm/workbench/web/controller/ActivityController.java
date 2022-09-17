package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ActivityController {

    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

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


}
