package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.Date;

@Controller
public class ActivityRemarkController {

    @Autowired
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/workbench/activity/saveCreateActivityRemark.do")
    @ResponseBody
    public Object saveCreateActivityRemark(ActivityRemark remark, HttpSession session){
        //获取当前登录用户
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();

        //客户端传noteContent，activityId参数。其余参数自己二次封装
        remark.setId(UUIDUtils.getUUID());
        remark.setCreateTime(DateUtils.formateDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag(Constants.REMAEK_EDIT_FLAG_NO_EDITED);

        //调用service方法，保存创建的市场活动
        try {
            int ret = activityRemarkService.saveCreateActivityRemark(remark);
            if (ret>0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                //把remark返回给前台拼出来，springmvc会自动把对象转成json
                returnObject.setRetData(remark);
            }else { //数据库错误
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

    @RequestMapping("/workbench/activity/deleteActivityRemarkById.do")
    @ResponseBody
    public Object deleteActivityRemarkById(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activityRemarkService.deleteActivityRemarkById(id);

            if (ret>0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else { //数据库错误
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

    @RequestMapping("/workbench/activity/saveEditActivityRemark.do")
    @ResponseBody
    public Object saveEditActivityRemark(ActivityRemark remark, HttpSession session){
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        //二次封装
        remark.setEditTime(DateUtils.formateDateTime(new Date()));
        remark.setEditBy(user.getId());
        remark.setEditFlag(Constants.REMAEK_EDIT_FLAG_YES_EDITED);
        //调用service
        try {
            int ret = activityRemarkService.saveEditActivityRemark(remark);
            if (ret>0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                //把remark返回给前台拼出来，springmvc会自动把对象转成json
                returnObject.setRetData(remark);
            }else { //数据库错误
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
