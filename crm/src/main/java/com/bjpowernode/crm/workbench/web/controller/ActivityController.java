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
import java.util.List;

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
        activity.setCreateBy(user.getId()); //activity.getOwner()?

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
}
